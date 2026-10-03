using System;

namespace XtremeWorlds.Client.Engine.Runtime;

/// <summary>
/// Frame-based translation of modGameLogic.GameInit/GameLoop. FNA owns the
/// clock and presentation; no nested DoEvents/Sleep loop runs on the UI thread.
/// </summary>
public sealed class ModGameLogic
{
    private readonly Action _pumpNetwork;
    private readonly Func<bool> _isConnected;
    private readonly Action<string> _process;
    private TimeSpan _walkTimer, _mapAnimTimer, _fpsTimer;
    private int _frames;

    public ModGameLogic(Action pumpNetwork, Func<bool> isConnected, Action<string> process)
    {
        _pumpNetwork = pumpNetwork;
        _isConnected = isConnected;
        _process = process;
    }

    public bool InGame { get; private set; }
    public bool GettingMap { get; set; } = true;
    public int MapAnim { get; private set; }
    public int GameFPS { get; private set; }

    public void GameInit()
    {
        _walkTimer = _mapAnimTimer = _fpsTimer = TimeSpan.Zero;
        _frames = MapAnim = GameFPS = 0;
        GettingMap = true;
        InGame = true;
        _process("GameInit");
    }

    public void GameLoop(TimeSpan tick, bool active)
    {
        if (!InGame) return;
        _pumpNetwork();
        if (!_isConnected())
        {
            InGame = false;
            return;
        }
        _process(active ? "CheckInput" : "ClearInput");
        if (tick - _walkTimer >= TimeSpan.FromMilliseconds(5))
        {
            if (!GettingMap && active)
            {
                _process("CheckMovement");
                _process("CheckAttack");
            }
            _process("ProcessMovement");
            _process("ProcessNpcMovement");
            _walkTimer = tick;
        }
        if (tick - _mapAnimTimer >= TimeSpan.FromMilliseconds(250))
        {
            MapAnim ^= 1;
            _process("BltMap");
            _mapAnimTimer = tick;
        }
    }

    public void PresentGameFrame(TimeSpan tick)
    {
        _frames++;
        var elapsed = tick - _fpsTimer;
        if (elapsed >= TimeSpan.FromSeconds(1))
        {
            GameFPS = (int)Math.Round(_frames / elapsed.TotalSeconds);
            _frames = 0;
            _fpsTimer = tick;
        }
    }

    public void GameDestroy() => InGame = false;
}
