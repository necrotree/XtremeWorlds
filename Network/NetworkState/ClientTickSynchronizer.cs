namespace XtremeWorlds.Networking;

public sealed record SceneTick(string Epoch, long Tick, long AckSequence, int TickRate, string LocalPlayer,
    IReadOnlyDictionary<string, MovementState> Players, bool Frozen = false);

/// <summary>Interpolates remote actors and reconciles/replays unacknowledged local movement inputs.</summary>
public sealed class ClientTickSynchronizer
{
    private readonly object _gate = new();
    private readonly List<(SceneTick Frame, double Received)> _frames = new();
    private readonly List<MovementInput> _pending = new();
    private MovementState _predicted;
    private readonly Queue<string> _retiredEpochs = new();
    private long _sequence;
    private double _correctionX, _correctionY, _correctionStarted;
    private bool _active;
    private string? _awaitingEpoch;
    public double InterpolationDelay { get; }
    public Func<MovementState, bool>? CanMove { get; set; }
    public ClientTickSynchronizer(double interpolationDelay = 0.1) => InterpolationDelay = Math.Clamp(interpolationDelay, 0.02, 0.5);
    public bool IsActive { get { lock (_gate) return _active; } }
    public int PendingCount { get { lock (_gate) return _pending.Count; } }
    public SceneTick? Latest { get { lock (_gate) return _frames.LastOrDefault().Frame; } }
    public double LastReceived { get { lock (_gate) return _frames.Count == 0 ? double.NaN : _frames[^1].Received; } }

    public bool Receive(SceneTick frame, double now)
    {
        lock (_gate)
        {
            if (frame.Epoch.Length is < 1 or > 64 || frame.Tick < 0 || frame.AckSequence < 0 || frame.TickRate is < 1 or > 240
                || !double.IsFinite(now) || !frame.Players.TryGetValue(frame.LocalPlayer, out var local) || frame.Players.Any(p => !p.Value.IsValid)) return false;
            if (_retiredEpochs.Contains(frame.Epoch)) return false;
            var previous = _frames.LastOrDefault().Frame;
            bool reset = previous == null || previous.Epoch != frame.Epoch || _predicted.Map != local.Map;
            if (!reset && (frame.Tick < previous!.Tick || frame.AckSequence < previous.AckSequence)) return false;
            if (!reset && frame.Tick == previous!.Tick && frame.AckSequence == previous.AckSequence) return false;
            var oldPrediction = _predicted;
            if (reset)
            {
                if (previous != null && previous.Epoch != frame.Epoch)
                {
                    _retiredEpochs.Enqueue(previous.Epoch);
                    if (_retiredEpochs.Count > 64) _retiredEpochs.Dequeue();
                }
                _awaitingEpoch = null;
                _frames.Clear();
                _pending.Clear();
                _sequence = frame.AckSequence;
                _correctionX = _correctionY = 0;
            }
            _pending.RemoveAll(input => input.Sequence <= frame.AckSequence);
            _sequence = Math.Max(_sequence, frame.AckSequence);
            _predicted = local;
            foreach (var input in _pending) Predict(input.Direction);
            if (!reset && oldPrediction.Map == _predicted.Map && Distance(oldPrediction, _predicted) <= 96)
            {
                _correctionX = oldPrediction.X - _predicted.X;
                _correctionY = oldPrediction.Y - _predicted.Y;
                _correctionStarted = now;
            }
            else _correctionX = _correctionY = 0;
            // Own the dictionary so caller-side render changes cannot rewrite history.
            frame = frame with { Players = new Dictionary<string, MovementState>(frame.Players) };
            _frames.Add((frame, now));
            if (_frames.Count > 64) _frames.RemoveAt(0);
            _active = !frame.Frozen && _awaitingEpoch != frame.Epoch;
            return true;
        }
    }
    public bool TryInput(int direction, long clientTick, out MovementInput input)
    {
        lock (_gate)
        {
            input = default;
            if (!_active || direction is < 0 or > 3 || clientTick < 0 || _pending.Count >= 256 || _frames.Count == 0) return false;
            var latest = _frames[^1].Frame;
            input = new(++_sequence, clientTick, direction, latest.Tick, latest.AckSequence, latest.Epoch);
            _pending.Add(input);
            Predict(direction);
            return true;
        }
    }
    private void Predict(int direction)
    {
        var moved = _predicted.Move(direction);
        _predicted = CanMove == null || CanMove(moved) ? moved : _predicted with { Direction = direction };
    }
    public IReadOnlyDictionary<string, MovementState> Sample(double now)
    {
        lock (_gate)
        {
            if (_frames.Count == 0) return new Dictionary<string, MovementState>();
            var latest = _frames[^1];
            if (!_active) return new Dictionary<string, MovementState>(latest.Frame.Players);
            double target = latest.Frame.Tick + Math.Max(0, now - latest.Received) * latest.Frame.TickRate - InterpolationDelay * latest.Frame.TickRate;
            var a = _frames[0].Frame;
            var b = latest.Frame;
            foreach (var candidate in _frames)
            {
                if (candidate.Frame.Tick <= target) a = candidate.Frame;
                if (candidate.Frame.Tick >= target) { b = candidate.Frame; break; }
            }
            double blend = b.Tick == a.Tick ? 1 : Math.Clamp((target - a.Tick) / (b.Tick - a.Tick), 0, 1);
            var result = new Dictionary<string, MovementState>(b.Players);
            foreach (var pair in b.Players)
                if (a.Players.TryGetValue(pair.Key, out var old) && old.Map == pair.Value.Map && Distance(old, pair.Value) <= 96)
                    result[pair.Key] = pair.Value with { X = old.X + (pair.Value.X - old.X) * blend, Y = old.Y + (pair.Value.Y - old.Y) * blend };
            double remaining = Math.Clamp(1 - (now - _correctionStarted) / 0.1, 0, 1);
            result[latest.Frame.LocalPlayer] = _predicted with { X = _predicted.X + _correctionX * remaining, Y = _predicted.Y + _correctionY * remaining };
            return result;
        }
    }
    public bool IsInactive(double now, double timeout)
    {
        lock (_gate) return _frames.Count > 0 && now - _frames[^1].Received >= timeout;
    }
    public void Rollback()
    {
        lock (_gate)
        {
            _pending.Clear();
            if (_frames.Count > 0)
            {
                var latest = _frames[^1].Frame;
                _predicted = latest.Players[latest.LocalPlayer];
                _sequence = latest.AckSequence;
                _awaitingEpoch = latest.Epoch;
            }
            _correctionX = _correctionY = 0;
            _active = false;
        }
    }
    public void Reset()
    {
        lock (_gate)
        {
            _frames.Clear(); _pending.Clear(); _retiredEpochs.Clear(); _sequence = 0; _active = false; _awaitingEpoch = null;
            _correctionX = _correctionY = 0;
        }
    }
    private static double Distance(MovementState a, MovementState b) => Math.Max(Math.Abs(a.X - b.X), Math.Abs(a.Y - b.Y));
}
