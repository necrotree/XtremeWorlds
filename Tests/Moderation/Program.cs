using Server;

var session = new PlayerSession();
string[] chat = ["saymsg", "emotemsg", "globalmsg", "broadcastmsg", "adminmsg", "playermsg"];
string[] gameplay = ["playermove", "playerdir", "useitem", "attack", "cast", "warpmeto", "warptome", "warpto", "warpsearch", "mapgetitem", "mapdropitem", "trade", "traderequest", "innsleep", "usechar", "delchar", "delaccount"];
void Check(string command, bool blocked)
{
    if ((ModerationPolicy.Rejection(session, command) is not null) != blocked)
        throw new Exception($"Incorrect moderation result for {command} (muted={session.IsMuted}, jailed={session.IsJailed}).");
}
foreach (var command in chat.Concat(gameplay)) Check(command, false);
session.IsMuted = true;
foreach (var command in chat) Check(command.ToUpperInvariant(), true);
foreach (var command in gameplay) Check(command, false);
Check("bugreport", false);
session.IsJailed = true;
foreach (var command in gameplay) Check(command, true);
foreach (var command in new[] { "needmap", "requestnewmap", "requestlocation", "bugreport" }) Check(command, false);
session.IsMuted = false;
foreach (var command in chat) Check(command, false);
foreach (var command in gameplay) Check(command, true);
session.IsJailed = false;
foreach (var command in gameplay) Check(command, false);
Console.WriteLine("Mute, jail, independent release, and allowed system packet checks passed.");

// Exercise real packet dispatch without a live TCP listener or database calls.
var settings = new ServerSettings();
var network = new MirrorTcpHost(0, 4096, true);
using var database = new SpacetimeRepository(settings);
var sessions = new System.Collections.Concurrent.ConcurrentDictionary<int, PlayerSession>();
PlayerSession Player(int id, string name, byte access) => new()
{
    ConnectionId = id, IsPlaying = true, Character = new PlayerCharacter { Name = name, Access = access }
};
sessions[1] = Player(1, "Admin", 2);
sessions[2] = Player(2, "Player With Spaces", 0);
sessions[3] = Player(3, "Peer", 2);
var router = new PacketRouter(settings, network, database, sessions);
async Task Dispatch(int actor, string command, string name) =>
    await router.HandleAsync(actor, PacketCodec.Compose(command, name));
void Assert(bool condition, string description)
{
    if (!condition) throw new Exception(description);
}
await Dispatch(2, "muteplayer", "Peer");
Assert(!sessions[3].IsMuted, "Non-admin moderation must be rejected.");
await Dispatch(1, "jailplayer", "Peer");
Assert(!sessions[3].IsJailed, "Equal-access moderation must be rejected.");
await Dispatch(1, "muteplayer", "Admin");
Assert(!sessions[1].IsMuted, "Self moderation must be rejected.");
await Dispatch(1, "MUTEPLAYER", "player with spaces");
await Dispatch(1, "jailplayer", "Player With Spaces");
Assert(sessions[2].IsMuted && sessions[2].IsJailed, "Admin mute and jail must be applied.");
await Dispatch(1, "unmuteplayer", "Player With Spaces");
Assert(!sessions[2].IsMuted && sessions[2].IsJailed, "Unmute must preserve jail.");
await Dispatch(1, "unjailplayer", "Player With Spaces");
Assert(!sessions[2].IsMuted && !sessions[2].IsJailed, "Unjail must release the player.");
sessions[1].IsPlaying = false;
await Dispatch(1, "muteplayer", "Player With Spaces");
Assert(!sessions[2].IsMuted, "Inactive admins must be rejected.");
sessions[1].IsPlaying = true;
await Dispatch(1, "jailplayer", "" );
await Dispatch(1, "jailplayer", "Missing player");
Console.WriteLine("Moderation packet dispatch and access checks passed.");