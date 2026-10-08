namespace XtremeWorlds.Networking;

public enum InputAcceptance { Accepted, Duplicate, StaleEpoch, Rejected }

/// <summary>Bounded movement-only history. Inventory, persistence and admin actions are never rolled back.</summary>
public sealed class TickAuthority
{
    private readonly SortedDictionary<(long Tick, long Sequence), MovementState> _history = new();
    private readonly int _capacity;
    public TickAuthority(int capacity = 256) => _capacity = Math.Max(4, capacity);
    public string Epoch { get; private set; } = string.Empty;
    public long LastInputSequence { get; private set; }
    public long LastClientInputTick { get; private set; }
    public double LastActivity { get; private set; }
    public bool ProtocolEnabled { get; private set; }
    public bool Frozen { get; private set; }
    public ConfirmedMovement Confirmed { get; private set; }

    // The host holds the session lock across validation, movement and snapshot capture.
    public void Begin(MovementState movement, long tick, double now)
    {
        if (!movement.IsValid || tick < 0 || !double.IsFinite(now)) throw new ArgumentException("Invalid initial network state.");
        Epoch = Guid.NewGuid().ToString("N");
        LastInputSequence = 0;
        LastClientInputTick = 0;
        LastActivity = now;
        ProtocolEnabled = false;
        Frozen = false;
        Confirmed = new(tick, 0, movement);
        _history.Clear();
        Record(tick, movement);
    }
    public void Record(long tick, MovementState movement)
    {
        if (Epoch.Length == 0 || !movement.IsValid) return;
        _history[(tick, LastInputSequence)] = movement;
        while (_history.Count > _capacity) _history.Remove(_history.First().Key);
    }
    public bool Acknowledge(string epoch, long tick, long sequence, double now)
    {
        if (epoch != Epoch || tick < 0 || sequence < 0 || sequence > LastInputSequence || !double.IsFinite(now)) return false;
        if ((tick, sequence).CompareTo((Confirmed.Tick, Confirmed.InputSequence)) < 0)
        {
            LastActivity = now;
            ProtocolEnabled = true;
            return true;
        }
        if (!_history.TryGetValue((tick, sequence), out var state)) return false;
        Confirmed = new(tick, sequence, state);
        LastActivity = now;
        ProtocolEnabled = true;
        Frozen = false;
        return true;
    }
    public InputAcceptance Accept(MovementInput input, double now)
    {
        if (input.Epoch != Epoch) return InputAcceptance.StaleEpoch;
        if (input.Sequence <= LastInputSequence && input.Sequence > 0) return InputAcceptance.Duplicate;
        if (input.Direction is < 0 or > 3 || input.Sequence != LastInputSequence + 1 || input.ClientTick < LastClientInputTick || input.ClientTick < 0
            || !Acknowledge(input.Epoch, input.AckTick, input.AckSequence, now)) return InputAcceptance.Rejected;
        LastInputSequence = input.Sequence;
        LastClientInputTick = input.ClientTick;
        return InputAcceptance.Accepted;
    }
    public bool IsInactive(double now, double timeout) => ProtocolEnabled && now - LastActivity >= timeout;
    public MovementState Rollback(long tick)
    {
        var restored = Confirmed.Movement;
        // A new epoch prevents already-queued pre-rollback inputs from moving the restored character.
        Epoch = Guid.NewGuid().ToString("N");
        LastInputSequence = 0;
        LastClientInputTick = 0;
        Confirmed = new(tick, 0, restored);
        Frozen = true;
        _history.Clear();
        Record(tick, restored);
        return restored;
    }
}
