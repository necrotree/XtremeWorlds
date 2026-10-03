using Eto.Forms;

namespace XtremeWorlds.Client.Forms
{
    public sealed class GameDialogs
    {
        private GameDialogs()
        {
        }

        public static GameDialogResult Alert(Window owner, string message, string title = "Alert")
        {
            using (var dialog = new frmAlert())
            {
                dialog.Configure(message, GameDialogButtons.Ok, title);
                return ShowDialog(dialog, owner);
            }
        }

        public static GameDialogResult Confirm(Window owner, string message, string title = "Alert")
        {
            using (var dialog = new frmAlert())
            {
                dialog.Configure(message, GameDialogButtons.YesNo, title);
                return ShowDialog(dialog, owner);
            }
        }

        public static string Input(Window owner, string message, string defaultValue, string title = "Alert")
        {
            using (var dialog = new frmAlert())
            {
                dialog.ConfigureInput(message, defaultValue, title);
                var result = ShowDialog(dialog, owner);
                if (result == GameDialogResult.Yes)
                    return dialog.InputValue;
                return string.Empty;
            }
        }

        private static GameDialogResult ShowDialog(frmAlert dialog, Window owner)
        {
            if (owner is not null)
                return dialog.ShowModal(owner);
            if (Application.Instance is not null && Application.Instance.MainForm is not null)
            {
                return dialog.ShowModal(Application.Instance.MainForm);
            }
            return dialog.ShowModal();
        }
    }
}