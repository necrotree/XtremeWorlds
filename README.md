# XtremeWorlds

**XtremeWorlds** is a free 2D MMORPG maker inspired by the classic PlayerWorlds-style development experience.

This repository contains both the **game client** and **game server**, allowing you to run your own local PlayerWorld and begin building your own MMORPG.

We recommend TwinBasic for your IDE in Visual Basic 6.
https://twinbasic.com/

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/necrotree/XtremeWorlds.git
cd XtremeWorlds
```

The project is organized into two main parts:

```text
XtremeWorlds/
├── Client/
├── Server/
├── LICENSE
└── README.md
```

* **Client** — The application players use to connect to your world.
* **Server** — The application that hosts your world and handles players, maps, NPCs, and game logic.

---

## 2. Start the Server

Open the `Server` directory and locate the server project/executable.

Start the server first.

The server needs to be running before the client can connect to PlayerWorlds.

Keep the server window open while testing the game.

> **Tip:** If you are developing the game, start the server before starting the client so you can see connection and server-side errors while testing.

---

## 3. Start the Client

After the server is running, open the `Client` directory and start the client project/executable.

The client should connect to your local server using the configured server address and port.

For local development, the server address will normally be:

```text
127.0.0.1
```

or:

```text
localhost
```

If the client does not connect, check the client/server configuration for the expected IP address and port.

---

# Creating your World

Once the client and server are running, you can begin treating the project as your own world.

A typical development workflow is:

```text
Start Server
     ↓
Start Client
     ↓
Connect to your World
     ↓
Create/Edit your game content
     ↓
Restart and test
     ↓
Repeat
```

## Recommended Development Order

If you're new to PlayerWorlds development, start small.

### 1. Get the basic world running

First make sure you can:

* Start the server
* Start the client
* Connect to the server
* Create/login with a player
* Enter the game world
* Move around successfully

Don't start modifying gameplay until this works.

### 2. Build your first map

Create a small test map before attempting to build an entire MMORPG.

For example:

```text
Town
├── Spawn
├── Inn
├── Shop
├── NPC area
└── Exit to Route 1
```

Keep your first map simple. It makes debugging much easier.

### 3. Add NPCs

After your map works, start adding NPCs such as:

* Shopkeepers
* Quest NPCs
* Trainers
* Guards
* Story characters
* Enemies

Test each NPC individually before adding large numbers of them.

### 4. Add items and equipment

Once the world and NPCs work, begin creating:

* Weapons
* Armor
* Consumables
* Quest items
* Currency
* Other usable items

### 5. Build your gameplay

After the basic world is working, you can expand into:

* Combat
* Quests
* Shops
* Experience and levels
* Player progression
* Guilds
* PvP
* Economy
* Events
* Multiple maps
* Custom game systems

---

# Client and Server Development

It is important to understand that the client and server have different responsibilities.

## Client

The client is responsible for things the player sees and interacts with, such as:

* Graphics
* Maps displayed to the player
* User interface
* Input
* Menus
* Player movement presentation
* Chat presentation
* Visual effects

## Server

The server is responsible for the authoritative game state, including things such as:

* Connected players
* Player data
* NPCs
* Game rules
* World state
* Combat/gameplay logic
* Player movement validation
* Saving/loading data

When developing multiplayer features, avoid assuming that the client can be trusted. The server should be responsible for important game-state decisions.

---

# Local Development

For development on one computer, use a local server.

A typical setup is:

```text
┌─────────────────────┐
│       Client        │
│                     │
│   Your PlayerWorld  │
└──────────┬──────────┘
           │
           │ Local connection
           │
           ▼
┌─────────────────────┐
│       Server        │
│                     │
│   Your Game World   │
└─────────────────────┘
```

Start the **Server first**, then start the **Client**.

When you're ready to let other players connect, configure the server for network access and make sure the appropriate port is reachable.

---

# Troubleshooting

### Client cannot connect

Check:

1. Is the server running?
2. Is the client using the correct IP address?
3. Is the client using the correct port?
4. Is the server listening on that port?
5. Is a firewall blocking the connection?
6. Are the client and server using compatible versions?

For a local server, try:

```text
127.0.0.1
```

or:

```text
localhost
```

### Server starts but the client disconnects

Check the server console for errors first.

The server log is usually more useful than the client when diagnosing connection problems.

### Changes aren't appearing

Make sure you're editing the files/data actually used by the running server or client.

After changing server-side data, restart the server if the change isn't hot-loaded.

---

# Development Tips

### Make backups

Before making large changes, back up your world and data.

### Test with a small world

Build a tiny test area before creating your entire game.

### Keep client and server changes separate

When troubleshooting, determine whether the problem is:

```text
Client → visual/input problem
Server → gameplay/data/network problem
```

This makes problems much easier to locate.

### Build incrementally

A good first milestone is:

```text
Login
  ↓
Spawn
  ↓
Move
  ↓
Chat
  ↓
NPC
  ↓
Item
  ↓
Combat
  ↓
Quest
```

Get each system working before moving to the next one.

---

# Development

The goal of XtremeWorlds is to give you a starting point for creating your own 2D MMORPG.

You can use the project as a foundation for creating a world with your own:

* Maps
* Characters
* NPCs
* Items
* Quests
* Monsters
* Classes
* Gameplay systems
* Story
* Community

Start with a small playable area, get the client/server loop working, and expand your PlayerWorld from there.

## Repository

[XtremeWorlds on GitHub](https://github.com/necrotree/XtremeWorlds?utm_source=chatgpt.com)

## License

XtremeWorlds is released under the **BSD 2-Clause License**. See [`LICENSE`](LICENSE) for the full license text.
