using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;

namespace XtremeWorlds.Tools
{
    public class AdminPlayer
    {
        public int ConnectionId { get; set; }
        public string Name { get; set; } = "";
        public string Login { get; set; } = "";
        public int Access { get; set; }
        public int Sprite { get; set; }
        public int Map { get; set; }
        public int X { get; set; }
        public int Y { get; set; }
        public string IpAddress { get; set; } = "";
        public string HardwareId { get; set; } = "";
        public bool IsMuted { get; set; }
        public bool IsJailed { get; set; }
    }
    public sealed class AdminToolsService
    {
        private readonly Func<IEnumerable<AdminPlayer>> players;
        private readonly Func<AdminPlayer, Task> update;
        private readonly Func<AdminPlayer, AdminPlayer, Task> ban;
        private readonly Func<Task> clearBans;
        private readonly Action<int> disconnect;
        private readonly Action<int, string> reply;
        private readonly Func<int, Task> refreshMap;
        private readonly Dictionary<int, (int Map, int X, int Y)> releaseLocations = new Dictionary<int, (int Map, int X, int Y)>();
        private (int Map, int X, int Y) jailLocation = (1, 0, 0);
        public AdminToolsService(Func<IEnumerable<AdminPlayer>> players, Func<AdminPlayer, Task> update, Func<AdminPlayer, AdminPlayer, Task> ban, Func<Task> clearBans, Action<int> disconnect, Action<int, string> reply, Func<int, Task> refreshMap)
        {
            this.players = players;
            this.update = update;
            this.ban = ban;
            this.clearBans = clearBans;
            this.disconnect = disconnect;
            this.reply = reply;
            this.refreshMap = refreshMap;
        }
        public void ForgetPlayer(int connection)
        {
            releaseLocations.Remove(connection);
        }
        public static bool Recognizes(string command)
        {
            return new[] { "kickplayer", "banplayer", "bandestroy", "setaccess", "setsprite", "playersprite", "muteplayer", "unmuteplayer", "jailplayer", "unjailplayer", "moderation", "mapreport", "maprespawn" }.Contains(command);
        }
        public async Task HandleAsync(int connection, string[] fields)
        {
            string failure = null;
            try
            {
                AdminPlayer[] online = players().ToArray();
                var actor = online.FirstOrDefault(player => player.ConnectionId == connection);
                if (actor is null || actor.Access < 1)
                    throw new UnauthorizedAccessException("Only admins may use these tools.");
                string command = fields[0];
                string targetName = fields.Length > 1 ? fields[1].Trim() : "";
                if (command == "moderation")
                {
                    if (fields.Length != 3)
                        throw new ArgumentException("Invalid moderation request.");
                    command = fields[1].Trim().ToLowerInvariant();
                    targetName = fields[2].Trim();
                    if (command == "setjail")
                    {
                        RequireAccess(actor, 2);
                        jailLocation = (actor.Map, actor.X, actor.Y);
                        reply(connection, "Jail location set to your current tile.");
                        return;
                    }
                    command += "player";
                }
                if (command == "mapreport")
                {
                    RequireAccess(actor, 2);
                    reply(connection, "Online maps: " + string.Join(", ", online.GroupBy(player => player.Map).Select(@group => group.Key.ToString(CultureInfo.InvariantCulture) + " (" + @group.Count().ToString(CultureInfo.InvariantCulture) + " players)")));
                    return;
                }
                if (command == "maprespawn")
                {
                    RequireAccess(actor, 2);
                    await refreshMap(connection);
                    reply(connection, "Map refreshed.");
                    return;
                }
                if (command == "bandestroy")
                {
                    RequireAccess(actor, 4);
                    await clearBans();
                    reply(connection, "Ban list cleared.");
                    return;
                }
                if (command == "setsprite")
                {
                    RequireAccess(actor, 2);
                    actor.Sprite = Number(fields, 1, 0, 32767);
                    await update(actor);
                    return;
                }
                var target = online.FirstOrDefault(player => string.Equals(player.Name, targetName, StringComparison.OrdinalIgnoreCase));
                if (command == "playersprite")
                {
                    if (fields.Length != 3)
                        throw new ArgumentException("Enter a sprite number and player name.");
                    targetName = fields[2].Trim();
                    target = online.FirstOrDefault(player => string.Equals(player.Name, targetName, StringComparison.OrdinalIgnoreCase));
                }
                if (target is null)
                    throw new ArgumentException("That player is not online.");
                if (target.ConnectionId == actor.ConnectionId || target.Access >= actor.Access)
                    throw new UnauthorizedAccessException("You may only modify players with lower access than yours.");
                switch (command ?? "")
                {
                    case "kickplayer":
                        {
                            disconnect(target.ConnectionId);
                            break;
                        }
                    case "banplayer":
                        {
                            RequireAccess(actor, 2);
                            await ban(actor, target);
                            disconnect(target.ConnectionId);
                            break;
                        }
                    case "setaccess":
                        {
                            RequireAccess(actor, 4);
                            target.Access = Number(fields, 2, 0, 4);
                            await update(target);
                            break;
                        }
                    case "playersprite":
                        {
                            RequireAccess(actor, 2);
                            target.Sprite = Number(fields, 1, 0, 32767);
                            await update(target);
                            break;
                        }
                    case "muteplayer":
                    case "unmuteplayer":
                        {
                            target.IsMuted = command == "muteplayer";
                            await update(target);
                            break;
                        }
                    case "jailplayer":
                        {
                            if (!target.IsJailed)
                                releaseLocations[target.ConnectionId] = (target.Map, target.X, target.Y);
                            target.IsJailed = true;
                            target.Map = jailLocation.Map;
                            target.X = jailLocation.X;
                            target.Y = jailLocation.Y;
                            await update(target);
                            break;
                        }
                    case "unjailplayer":
                        {
                            target.IsJailed = false;
                            (int Map, int X, int Y) location;
                            if (releaseLocations.TryGetValue(target.ConnectionId, out location))
                            {
                                target.Map = location.Map;
                                target.X = location.X;
                                target.Y = location.Y;
                                releaseLocations.Remove(target.ConnectionId);
                            }
                            await update(target);
                            break;
                        }

                    default:
                        {
                            throw new ArgumentException("Unknown moderation action.");
                        }
                }
                reply(connection, command.Replace("player", "") + " applied to " + target.Name + ".");
            }
            catch (Exception ex)
            {
                failure = ex is ArgumentException || ex is UnauthorizedAccessException ? ex.Message : "The admin action could not be completed.";
            }
            if (failure is not null)
                reply(connection, failure);
        }
        private static void RequireAccess(AdminPlayer actor, int minimum)
        {
            if (actor.Access < minimum)
                throw new UnauthorizedAccessException("Your access level does not permit this action.");
        }
        private static int Number(string[] fields, int index, int minimum, int maximum)
        {
            int value;
            if (fields.Length <= index || !int.TryParse(fields[index], NumberStyles.Integer, CultureInfo.InvariantCulture, out value) || value < minimum || value > maximum)
                throw new ArgumentException("Enter a whole number in the allowed range.");
            return value;
        }
    }
}