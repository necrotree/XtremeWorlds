
namespace Server
{
    public class PlayerSession
    {
        public XtremeWorlds.Networking.TickAuthority NetworkState { get; } = new();
        public bool IsChargingMana { get; set; }
        public double ManaChargeExpires { get; set; }
        public double LastManaChargeSeconds { get; set; }
        public double ManaChargeRemainder { get; set; }
        public double LastManaSaveSeconds { get; set; }
        public XtremeWorlds.Networking.MovementState ManaChargePose { get; set; }
        public double NextAttackSeconds { get; set; }
        public double AttackStartedSeconds { get; set; } = -1;
        public double NextEmoteSeconds { get; set; }
        public double NextItemSeconds { get; set; }
        public System.Collections.Generic.Dictionary<int, double> SpellCooldowns { get; } = new();
        public int ConnectionId { get; set; }
        public string IpAddress { get; set; } = "";
        public string Login { get; set; } = "";
        public string HardwareId { get; set; } = "";
        public int CharacterSlot { get; set; }
        public PlayerCharacter? Character { get; set; }
        public bool IsLoggedIn { get; set; }
        public bool IsPlaying { get; set; }
        public volatile bool IsMuted;
        public volatile bool IsJailed;
    }
}
