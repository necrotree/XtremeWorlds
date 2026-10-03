using XtremeWorlds.Client.Engine.Runtime;

var stages = new List<string>();
var connected = true;
var pumps = 0;
var loop = new ModGameLogic(() => pumps++, () => connected, stages.Add);
void Check(bool condition, string message)
{
    if (!condition) throw new Exception(message);
}

loop.GameInit();
Check(loop.InGame && loop.GettingMap && stages.SequenceEqual(new[] { "GameInit" }), "Initialization state");
stages.Clear();
loop.GameLoop(TimeSpan.FromMilliseconds(15), true);
Check(pumps == 1 && !stages.Contains("CheckMovement"), "Do not move while receiving map");
loop.GettingMap = false;
stages.Clear();
loop.GameLoop(TimeSpan.FromMilliseconds(30), true);
Check(stages.SequenceEqual(new[] { "CheckInput", "CheckMovement", "CheckAttack", "ProcessMovement", "ProcessNpcMovement" }), "Legacy update order");
stages.Clear();
loop.GameLoop(TimeSpan.FromMilliseconds(31), true);
Check(!stages.Contains("CheckMovement"), "Movement timer gates short updates");
loop.GameLoop(TimeSpan.FromMilliseconds(250), true);
Check(loop.MapAnim == 1 && stages.Count(s => s == "BltMap") == 1, "Map animation at 250 ms");
stages.Clear();
loop.GameLoop(TimeSpan.FromMilliseconds(500), false);
Check(loop.MapAnim == 0 && stages.Contains("ClearInput") && !stages.Contains("CheckAttack"), "Inactive window releases input");
for (var i = 1; i <= 60; i++) loop.PresentGameFrame(TimeSpan.FromSeconds(i / 60.0));
Check(loop.GameFPS == 60, "FPS counts presented frames");
connected = false;
stages.Clear();
loop.GameLoop(TimeSpan.FromSeconds(2), true);
Check(!loop.InGame && stages.Count == 0, "Disconnect stops game before input");
var before = pumps;
loop.GameLoop(TimeSpan.FromSeconds(3), true);
Check(pumps == before, "Stopped loop does not poll network");
loop.GameInit();
Check(loop.GettingMap && loop.MapAnim == 0 && loop.GameFPS == 0, "Restart resets timers and state");
loop.GameDestroy();
Check(!loop.InGame, "Explicit shutdown");
Console.WriteLine("Game loop lifecycle, timing, update order, inactive input, FPS and disconnect checks passed.");
