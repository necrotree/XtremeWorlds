
namespace Server
{
    public class PlayerSession
    {
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
