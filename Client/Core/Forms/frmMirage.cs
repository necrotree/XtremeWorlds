using XtremeWorlds.Client.Logic;

namespace XtremeWorlds.Client.Forms
{
    /// <summary>
    /// Compatibility name for the original twinBASIC frmMirage form.
    /// The twinBASIC source declares the class as frmMainGame; both names now
    /// resolve to the same Eto game window and use the XtremeWorlds icon.
    /// </summary>
    public class frmMirage : frmMainGame
    {

        public frmMirage(IGameClientRuntime client = null) : base(client)
        {
        }
    }
}