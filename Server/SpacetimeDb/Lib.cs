using SpacetimeDB;

public static partial class Module
{
    [SpacetimeDB.Table(Accessor = "Content", Name = "content")]
    public partial struct Content
    {
        [SpacetimeDB.PrimaryKey] public string Key;
        [SpacetimeDB.Index.BTree]
        public string Kind;
        public int NumericId;
        public string DisplayName;
        public string Json;
        public int Revision;
    }

    [SpacetimeDB.Table(Accessor = "Account", Name = "account")]
    public partial struct Account
    {
        [SpacetimeDB.PrimaryKey] public string Login;
        public string PasswordHash;
        public string PasswordSalt;
        public string EncKey;
    }

    [SpacetimeDB.Table(Accessor = "Character", Name = "character")]
    public partial struct Character
    {
        [SpacetimeDB.PrimaryKey] public string Key;
        [SpacetimeDB.Index.BTree]
        public string AccountLogin;
        public int Slot;
        [SpacetimeDB.Unique] public string Name;
        public string Json;
    }

    [SpacetimeDB.Table(Accessor = "Ban", Name = "ban")]
    public partial struct Ban
    {
        [SpacetimeDB.PrimaryKey] public string BanKey;
        [SpacetimeDB.Index.BTree]
        public string Ip;
        public string CharacterName;
        public string BannedBy;
        [SpacetimeDB.Index.BTree]
        public string HardwareId;
    }

    [SpacetimeDB.Table(Accessor = "ServerSetting", Name = "server_setting")]
    public partial struct ServerSetting
    {
        [SpacetimeDB.PrimaryKey] public string Key;
        public string Value;
    }

    [SpacetimeDB.Reducer]
    public static void UpsertContent(ReducerContext ctx, string key, string kind, int numericId, string displayName, string json, int revision)
    {
        var row = new Content { Key = key, Kind = kind, NumericId = numericId, DisplayName = displayName, Json = json, Revision = revision };
        if (ctx.Db.Content.Key.Find(key) is null)
            ctx.Db.Content.Insert(row);
        else
            ctx.Db.Content.Key.Update(row);
    }

    [SpacetimeDB.Reducer]
    public static void DeleteContent(ReducerContext ctx, string key) => ctx.Db.Content.Key.Delete(key);

    [SpacetimeDB.Reducer]
    public static void UpsertAccount(ReducerContext ctx, string login, string passwordHash, string passwordSalt, string encKey)
    {
        var row = new Account { Login = login, PasswordHash = passwordHash, PasswordSalt = passwordSalt, EncKey = encKey };
        if (ctx.Db.Account.Login.Find(login) is null)
            ctx.Db.Account.Insert(row);
        else
            ctx.Db.Account.Login.Update(row);
    }

    [SpacetimeDB.Reducer]
    public static void DeleteAccount(ReducerContext ctx, string login) => ctx.Db.Account.Login.Delete(login);

    [SpacetimeDB.Reducer]
    public static void UpsertCharacter(ReducerContext ctx, string key, string accountLogin, int slot, string name, string json)
    {
        var row = new Character { Key = key, AccountLogin = accountLogin, Slot = slot, Name = name, Json = json };
        if (ctx.Db.Character.Key.Find(key) is null)
            ctx.Db.Character.Insert(row);
        else
            ctx.Db.Character.Key.Update(row);
    }

    [SpacetimeDB.Reducer]
    public static void DeleteCharacter(ReducerContext ctx, string key) => ctx.Db.Character.Key.Delete(key);

    [SpacetimeDB.Reducer]
    public static void UpsertBan(ReducerContext ctx, string banKey, string ip, string characterName, string bannedBy, string hardwareId)
    {
        var row = new Ban { BanKey = banKey, Ip = ip, CharacterName = characterName, BannedBy = bannedBy, HardwareId = hardwareId };
        if (ctx.Db.Ban.BanKey.Find(banKey) is null)
            ctx.Db.Ban.Insert(row);
        else
            ctx.Db.Ban.BanKey.Update(row);
    }

    [SpacetimeDB.Reducer]
    public static void DeleteBan(ReducerContext ctx, string banKey) => ctx.Db.Ban.BanKey.Delete(banKey);

    [SpacetimeDB.Reducer]
    public static void SetServerSetting(ReducerContext ctx, string key, string value)
    {
        var row = new ServerSetting { Key = key, Value = value };
        if (ctx.Db.ServerSetting.Key.Find(key) is null)
            ctx.Db.ServerSetting.Insert(row);
        else
            ctx.Db.ServerSetting.Key.Update(row);
    }
}
