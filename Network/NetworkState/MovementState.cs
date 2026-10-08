using System.Diagnostics;

namespace XtremeWorlds.Networking;

public readonly record struct MovementState(int Map, double X, double Y, int Direction)
{
    public MovementState Move(int direction, double pixels = 4) => this with {
        X = Math.Clamp(X + (direction == 2 ? -pixels : direction == 3 ? pixels : 0), 0, 16 * 32 - 1),
        Y = Math.Clamp(Y + (direction == 0 ? -pixels : direction == 1 ? pixels : 0), 0, 12 * 32 - 1),
        Direction = direction
    };
    public bool IsValid => Map >= 0 && double.IsFinite(X) && double.IsFinite(Y) && X >= 0 && X < 512 && Y >= 0 && Y < 384 && Direction is >= 0 and <= 3;
}

public readonly record struct MovementInput(long Sequence, long ClientTick, int Direction, long AckTick, long AckSequence, string Epoch);
public readonly record struct ConfirmedMovement(long Tick, long InputSequence, MovementState Movement);
public static class NetworkClock
{
    public static double Seconds => (double)Stopwatch.GetTimestamp() / Stopwatch.Frequency;
}
