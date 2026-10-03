using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmSetSprite : EditForm
    {

        public readonly LegacyLabel Label5;
        public readonly LegacyLabel lblSpriteNum;
        public readonly LegacyPictureBox picSprite;
        public readonly LegacyScrollBar scrlSprite;
        public readonly UITimer tmrSprite;
        public readonly LegacyButton cmdSend;
        public readonly LegacyButton cmdCancel;

        public frmSetSprite()
        {
            Title = "Sprite Change";
            ClientSize = new Size(290, 123);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            Label5 = new LegacyLabel();
            Label5.Caption = "Sprite";
            Label5.Size = new Size(49, 25);
            rootLayout.Add(Label5, 8, 48);

            lblSpriteNum = new LegacyLabel();
            lblSpriteNum.Caption = "0";
            lblSpriteNum.Size = new Size(33, 25);
            rootLayout.Add(lblSpriteNum, 248, 48);

            picSprite = new LegacyPictureBox();
            picSprite.Size = new Size(33, 33);
            rootLayout.Add(picSprite, 8, 8);

            scrlSprite = new LegacyScrollBar();
            scrlSprite.MinValue = 0;
            scrlSprite.MaxValue = 600;
            scrlSprite.Value = 0;
            scrlSprite.Orientation = Orientation.Horizontal;
            scrlSprite.SmallChange = 1;
            scrlSprite.LargeChange = 1;
            scrlSprite.Size = new Size(193, 25);
            rootLayout.Add(scrlSprite, 56, 48);

            tmrSprite = new UITimer() { Interval = 0.05d };
            tmrSprite.Start();
            cmdSend = new LegacyButton();
            cmdSend.Caption = "Send";
            cmdSend.Size = new Size(73, 25);
            rootLayout.Add(cmdSend, 40, 88);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(73, 25);
            rootLayout.Add(cmdCancel, 176, 88);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}