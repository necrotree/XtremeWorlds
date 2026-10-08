using XtremeWorlds.Networking;
int checks = 0;
void Check(bool passed, string name) { if (!passed) throw new Exception(name); checks++; }
SceneTick Frame(string epoch, long tick, long ack, double localX, double remoteX, int map = 1, bool frozen = false) =>
    new(epoch, tick, ack, 60, "self", new Dictionary<string, MovementState> {
        ["self"] = new(map, localX, 32, 3), ["remote"] = new(map, remoteX, 64, 3)
    }, frozen);
var client = new ClientTickSynchronizer();
Check(client.Receive(Frame("one", 0, 0, 32, 0), 0), "initial frame");
Check(client.Receive(Frame("one", 6, 0, 32, 60), .1), "second frame");
Check(Math.Abs(client.Sample(.15)["remote"].X - 30) < .001, "interpolates remote tick midpoint");
Check(client.Sample(4)["remote"].X == 60, "never extrapolates beyond latest");
Check(client.TryInput(3, 1, out var first) && first.Sequence == 1, "predict first input");
Check(client.TryInput(3, 2, out var second) && second.Sequence == 2, "predict second input");
Check(client.Sample(.3)["self"].X == 40, "local movement responds immediately");
Check(client.Receive(Frame("one", 7, 1, 36, 64), .2), "authoritative ack");
Check(client.PendingCount == 1 && client.Sample(.4)["self"].X == 40, "replays remaining input once");
Check(!client.Receive(Frame("one", 6, 0, 32, 60), .3), "ignores out of order snapshot");
Check(!client.Receive(Frame("one", 7, 1, 36, 64), .3), "ignores duplicate snapshot");
var invalid = Frame("one", 8, 2, double.NaN, 64);
Check(!client.Receive(invalid, .3), "rejects invalid movement");
Check(client.IsInactive(2.2, 2), "detects receive inactivity");
client.Rollback();
Check(client.Receive(Frame("one", 9, 1, 36, 64), 2.21) && !client.IsActive, "delayed snapshot cannot restart prediction during resync");
Check(!client.IsActive && client.PendingCount == 0 && client.Sample(2.2)["self"].X == 36, "rollback clears prediction");
Check(!client.TryInput(3, 3, out _), "frozen client does not predict");
Check(client.Receive(Frame("two", 10, 0, 96, 96, frozen:true), 2.3), "accepts rollback epoch");
Check(!client.Receive(Frame("one", 11, 2, 40, 64), 2.4), "old epoch cannot undo rollback");
Check(client.Sample(2.4)["self"].X == 96, "rollback snaps to confirmed state");
Check(client.Receive(Frame("two", 11, 0, 96, 96), 2.4) && client.IsActive, "confirmed heartbeat resumes client");
client.CanMove = state => state.X <= 96;
Check(client.TryInput(3, 4, out _) && client.Sample(2.6)["self"].X == 96, "collision prediction keeps blocked position");
Check(client.Receive(Frame("three", 12, 0, 400, 400, 2), 2.7) && client.PendingCount == 0
    && client.Sample(2.7)["self"].Map == 2, "map changes reset history");

var authority = new TickAuthority(4);
var origin = new MovementState(1, 32, 32, 3);
authority.Begin(origin, 1, 0);
string epoch = authority.Epoch;
Check(authority.Accept(new(1, 1, 3, 1, 0, epoch), .1) == InputAcceptance.Accepted, "server accepts contiguous input");
authority.Record(1, origin.Move(3));
Check(authority.Acknowledge(epoch, 1, 0, .2) && authority.Confirmed.Movement.X == 32,
    "same tick acknowledgement uses exact input sequence");
Check(authority.Acknowledge(epoch, 1, 1, .3) && authority.Confirmed.Movement.X == 36, "confirms recorded pose");
Check(authority.Accept(new(1, 1, 3, 1, 0, epoch), .4) == InputAcceptance.Duplicate, "duplicate input ignored");
Check(authority.Accept(new(3, 2, 3, 1, 1, epoch), .4) == InputAcceptance.Rejected, "rejects input sequence gap");
Check(authority.Accept(new(2, 0, 3, 1, 1, epoch), .4) == InputAcceptance.Rejected, "rejects backwards client tick");
Check(!authority.Acknowledge(epoch, 50, 1, .4), "future snapshot cannot be acknowledged");
Check(!authority.Acknowledge(epoch, 1, 2, .4), "future input cannot be acknowledged");
Check(authority.Accept(new(2, 2, 3, 1, 1, epoch), .4) == InputAcceptance.Accepted, "accepts next input");
authority.Record(2, origin.Move(3).Move(3));
Check(authority.IsInactive(2.4, 2), "server detects inactivity");
var restored = authority.Rollback(20);
Check(restored.X == 36 && authority.Frozen && authority.LastInputSequence == 0, "server restores last acknowledged pose");
Check(authority.Epoch != epoch && authority.Accept(new(3, 3, 3, 2, 2, epoch), 2.5) == InputAcceptance.StaleEpoch,
    "queued old movement cannot move restored state");
Check(authority.Acknowledge(authority.Epoch, 20, 0, 2.6) && !authority.Frozen, "new epoch acknowledgement resumes server");
for (int tick = 21; tick <= 30; tick++) authority.Record(tick, restored);
Check(!authority.Acknowledge(authority.Epoch, 21, 0, 3), "bounded history rejects evicted snapshot");
Check(authority.Rollback(31) == restored, "confirmed pose survives history eviction");

var queue = new OrderedPacketQueue(2);
var release = new TaskCompletionSource(TaskCreationOptions.RunContinuationsAsynchronously);
var order = new List<int>();
Check(queue.TryEnqueue(async () => { order.Add(1); await release.Task; order.Add(2); }), "first packet queued");
Check(queue.TryEnqueue(() => { order.Add(3); return Task.CompletedTask; }), "second packet queued");
Check(!queue.TryEnqueue(() => Task.CompletedTask), "bounded queue rejects overload");
Check(order.SequenceEqual(new[] { 1 }), "async packet handlers do not overlap");
release.SetResult(); await queue.Completion;
Check(order.SequenceEqual(new[] { 1, 2, 3 }), "packet order preserved after await");
int errors = 0; var failingQueue = new OrderedPacketQueue(error: _ => errors++);
failingQueue.TryEnqueue(() => throw new Exception("expected"));
failingQueue.TryEnqueue(() => { order.Add(4); return Task.CompletedTask; });
await failingQueue.Completion;
Check(errors == 1 && order[^1] == 4, "exception does not stall packet queue");
var disposeQueue = new OrderedPacketQueue();
var blocked = new TaskCompletionSource(TaskCreationOptions.RunContinuationsAsynchronously);
disposeQueue.TryEnqueue(async () => await blocked.Task);
disposeQueue.TryEnqueue(() => { order.Add(5); return Task.CompletedTask; });
disposeQueue.Dispose(); blocked.SetResult(); await disposeQueue.Completion;
Check(order[^1] == 4 && !disposeQueue.TryEnqueue(() => Task.CompletedTask), "disconnected queue skips remaining packets");
await WireChecks.Run(Check);
Console.WriteLine($"Passed {checks} network interpolation and rollback checks.");
