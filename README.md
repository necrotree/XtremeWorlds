# XtremeWorlds

XtremeWorlds is a free 2D MMORPG maker based on the classic PlayerWorlds development experience. It includes a Windows game client, a multiplayer server, and editors for building your own world.

The project includes **twinBASIC projects** alongside legacy **Visual Basic 6 projects** and exported source files. Some project metadata still uses the Playerworlds Lite name.

## Project layout

```text
XtremeWorlds/
|-- Client/
|   |-- Client.twinproj    twinBASIC client project
|   |-- Client.vbp         Legacy VB6 client project
|   |-- Src/               Exported modules, classes, and forms
|   |-- Gfx/               Game and interface graphics
|   |-- music/             Music assets
|   |-- data/              Client configuration and game data
|   |-- options.ini        Server address and menu settings
|   `-- bass.dll           Native audio library
|-- Server/
|   |-- Server.twinproj    twinBASIC server project
|   |-- Server.vbp         Legacy VB6 server project
|   |-- Src/               Exported server source
|   |-- scripts/           Server scripts, including Main.as
|   |-- data/              Accounts and world data
|   `-- logs/              Server logs
|-- build/                 Development and project synchronization scripts
|-- README.md
`-- LICENSE
```

Runtime files are resolved relative to the executable's directory. Keep each application with its corresponding data, scripts, assets, and libraries.

## Getting started

### 1. Get the source

```powershell
git clone https://github.com/necrotree/XtremeWorlds.git
cd XtremeWorlds
```

The paths below are relative to the folder containing this README.

### 2. Build the applications

On Windows, open `Server/Server.twinproj` and `Client/Client.twinproj` in twinBASIC. Build the applications and place their outputs in the respective `Server/` and `Client/` runtime folders. If `Server.exe` and `Client.exe` are already available, you can use them to try the local setup.

The `.vbp` files are the legacy VB6 entry points. Their references include older COM controls and libraries, such as RichTextBox, Internet Transfer, and Common Dialog controls; the client also references DAO, DirectX 7, and a Playerworlds movement plugin. These dependencies must be available for the legacy projects to load and compile. Check each `.vbp` for its exact references.

### 3. Configure a local connection

The client reads its server address from [`Client/options.ini`](Client/options.ini):

```ini
[Options]
IP=127.0.0.1
MenuMusic=music1.ogg
Website=https://xtremeworlds.com
```

Use `127.0.0.1` when both applications run on the same computer. For another computer on your network, set `IP` to the server's address. The client main menu also provides a server address setting.

The supplied [`Server/scripts/Main.as`](Server/scripts/Main.as) sets `GAME_PORT` to **7234** and passes it to `SetServerPort`. The client initializes its port to **7234** when creating `Client/data/Data.dat`; an existing file retains its saved port. Changing `IP` in `options.ini` does not change that port. Keep the client and server port settings aligned.

### 4. Start the server, then the client

From the project folder, when the executables are available:

```powershell
Start-Process -FilePath .\Server\Server.exe -WorkingDirectory .\Server
Start-Process -FilePath .\Client\Client.exe -WorkingDirectory .\Client
```

Wait for the server to finish loading before connecting with the client. Keep the server running throughout your session. Create an account or log in, select a character, and verify that you can enter the world, move, and chat.

## Building your world

Start with a small playable area and test each addition:

1. Create a map with a spawn point and a few connected areas.
2. Add NPCs and test their behavior.
3. Add items, equipment, shops, and spells using the available editors.
4. Test combat and character progression.
5. Expand into quests, guilds, and additional maps as your world develops.

Back up `Server/data/` and `Server/scripts/` before changing world content or game rules. Preserve client assets and configuration alongside those backups when distributing a matching client.

## Development

The client handles rendering, interface controls, input, audio, and presentation. The server manages connected players, world state, game rules, and persistent data. Validate important multiplayer actions on the server.

Source exports are in `Client/Src/` and `Server/Src/`, including `.bas`, `.cls`, `.frm`, `.twin`, and `.tbform` files. **The twinBASIC project files also contain embedded source and forms.** Editing an exported file alone may not update the project you build. Keep the project contents and source exports synchronized, and verify that your build includes the intended changes.

The `build/` folder contains scripts used for specific development changes and project synchronization. Review a script's inputs and target files before running it; these scripts are not a general build command.

For changes to networking or saved data formats, update both applications together and test with a matching client/server pair.

## Troubleshooting

| Problem | Checks |
| --- | --- |
| Client cannot connect | Confirm the server has finished loading, the IP in `Client/options.ini` is correct, and both sides use the same port. For connections from another computer, check the server's firewall and network access. |
| Client disconnects after connecting | Check the server window and `Server/logs/`; verify that the client and server use compatible builds and data formats. |
| Missing graphics, music, or scripts | Keep the executable in its runtime folder with its assets. Confirm that `Client/bass.dll`, the graphics and music folders, and `Server/scripts/Main.as` are present. |
| Source changes do not appear | Check that the twinBASIC project's embedded source was updated, rebuild, and confirm you launched the new executable. |
| World changes do not appear | Confirm you edited the data used by the running application. The server reads world data under its own `data/` folder. Reload or restart as required by the changed content. |
| Legacy VB6 project fails to load | Check the references and controls listed in the `.vbp` file and resolve missing dependencies in the IDE. |

## License

XtremeWorlds is released under the **BSD 2-Clause License**. See [`LICENSE`](LICENSE) for the full terms.
