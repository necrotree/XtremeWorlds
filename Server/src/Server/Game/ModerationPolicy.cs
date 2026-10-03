namespace Server;

public static class ModerationPolicy
{
    public static string? Rejection(PlayerSession session, string command)
    {
        command = command.Trim().ToLowerInvariant();
        if (session.IsMuted && command is "saymsg" or "emotemsg" or "globalmsg" or "broadcastmsg" or "adminmsg" or "playermsg")
            return "You are muted by the Server.";
        if (session.IsJailed && command is "playermove" or "playerdir" or "useitem" or "attack" or "cast" or "warpmeto" or "warptome" or "warpto" or "warpsearch" or "mapgetitem" or "mapdropitem" or "trade" or "traderequest" or "innsleep" or "usechar" or "delchar" or "delaccount")
            return "You are jailed by the Server. Wait for release before continuing.";
        return null;
    }
}
