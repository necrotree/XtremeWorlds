using System.Text.Json;
using XtremeWorlds.Networking;

namespace Server;

public sealed partial class PacketRouter
{
    public void EndManaChargeOnDisconnect(int id)
    {
        if (!_sessions.TryGetValue(id,out var session)) return;
        lock (_gameplayGate) lock (session) StopManaCharge(session);
    }
    private void HandleManaCharge(int id,string[] fields)
    {
        if (fields.Length != 2 || !int.TryParse(fields[1],out int held) || held is < 0 or > 1
            || !_sessions.TryGetValue(id,out var session)) return;
        lock (_gameplayGate)
        lock (session)
        {
            if (!session.IsPlaying || session.Character is not { } player) return;
            if (held == 0) { StopManaCharge(session); return; }
            if (session.IsJailed || session.NetworkState.Frozen || player.HP <= 0 || player.MaxMP <= 0 || player.MP >= player.MaxMP) return;
            double now = NetworkClock.Seconds;
            if (!session.IsChargingMana)
            {
                session.IsChargingMana = true; session.LastManaChargeSeconds = now;
                session.ManaChargeRemainder = 0; session.ManaChargePose = Pose(player); session.LastManaSaveSeconds = now;
                SendGameplayState(session);
            }
            session.ManaChargeExpires = now + .75;
        }
    }
    private void StopManaCharge(PlayerSession session)
    {
        if (!session.IsChargingMana) return;
        session.IsChargingMana = false; session.ManaChargeRemainder = 0;
        SendGameplayState(session);
        SaveManaProgress(session);
    }
    private void SaveManaProgress(PlayerSession session)
    {
        if (session.Character is not { } player || session.Login.Length == 0 || session.CharacterSlot <= 0) return;
        var saved = JsonSerializer.Deserialize<PlayerCharacter>(JsonSerializer.Serialize(player))!;
        _gameplaySave = SaveGameplayAfterAsync(_gameplaySave,new() { (session.Login,session.CharacterSlot,saved) },session.ConnectionId);
    }
    private void TickManaCharging()
    {
        lock (_gameplayGate)
        {
            double now = NetworkClock.Seconds;
            foreach (var session in _sessions.Values)
                lock (session)
                {
                    if (!session.IsChargingMana) continue;
                    if (!session.IsPlaying || session.Character is not { } player || session.IsJailed || session.NetworkState.Frozen
                        || player.HP <= 0 || player.MaxMP <= 0 || now >= session.ManaChargeExpires
                        || Pose(player) != session.ManaChargePose || player.MP >= player.MaxMP)
                    { StopManaCharge(session); continue; }
                    // Ten percent of maximum mana per second; packet spam cannot change this server clock.
                    double elapsed = Math.Clamp(now-session.LastManaChargeSeconds,0,.25);
                    session.LastManaChargeSeconds = now;
                    double available = session.ManaChargeRemainder + elapsed * Math.Max(1,player.MaxMP * .1);
                    int gain = (int)Math.Min(available,int.MaxValue);
                    session.ManaChargeRemainder = available-gain;
                    if (gain == 0) continue;
                    player.MP = (int)Math.Min(player.MaxMP,(long)player.MP+gain);
                    if (player.MP >= player.MaxMP) { StopManaCharge(session); continue; }
                    SendGameplayState(session);
                    if (now-session.LastManaSaveSeconds >= 2) { session.LastManaSaveSeconds = now; SaveManaProgress(session); }
                }
        }
    }
}
