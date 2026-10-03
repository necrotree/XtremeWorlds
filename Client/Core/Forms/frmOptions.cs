using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmOptions : EditForm
    {

        public readonly LegacyFrame SSTab1;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyButton cmdSave;
        public readonly LegacyFrame Frame1;
        public readonly LegacyRadioButton optPlayerOff;
        public readonly LegacyRadioButton optPlayerOn;
        public readonly LegacyRadioButton optPlayerMouse;
        public readonly LegacyFrame Frame2;
        public readonly LegacyRadioButton optNPCOn;
        public readonly LegacyRadioButton optNPCMouse;
        public readonly LegacyRadioButton optNPCOff;
        public readonly LegacyFrame Frame3;
        public readonly LegacyRadioButton optMusicOn;
        public readonly LegacyRadioButton optMusicOff;
        public readonly LegacyFrame Frame4;
        public readonly LegacyRadioButton optSoundOn;
        public readonly LegacyRadioButton optSoundOff;
        public readonly LegacyFrame Frame5;
        public readonly LegacyRadioButton optWASDOn;
        public readonly LegacyRadioButton optWASDOff;
        public readonly LegacyButton cmdHotkeys;
        public readonly LegacyFrame Frame6;
        public readonly LegacyRadioButton optVitalsOn;
        public readonly LegacyRadioButton optVitalsOff;

        public frmOptions()
        {
            Title = "Options";
            ClientSize = new Size(288, 504);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            SSTab1 = new LegacyFrame();
            SSTab1.Caption = "Options";
            SSTab1.Size = new Size(273, 489);
            rootLayout.Add(SSTab1, 14, 2);
            var layout_SSTab1 = new PixelLayout();
            SSTab1.Content = layout_SSTab1;
            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(97, 25);
            layout_SSTab1.Add(cmdCancel, 166, 455);

            cmdSave = new LegacyButton();
            cmdSave.Caption = "Save";
            cmdSave.Size = new Size(97, 25);
            layout_SSTab1.Add(cmdSave, 14, 455);

            Frame1 = new LegacyFrame();
            Frame1.Caption = "Player Names";
            Frame1.Size = new Size(241, 57);
            layout_SSTab1.Add(Frame1, 16, 40);
            var layout_Frame1 = new PixelLayout();
            Frame1.Content = layout_Frame1;
            optPlayerOff = new LegacyRadioButton();
            optPlayerOff.Caption = "Off";
            optPlayerOff.Size = new Size(57, 17);
            layout_Frame1.Add(optPlayerOff, 176, 24);

            optPlayerOn = new LegacyRadioButton(optPlayerOff);
            optPlayerOn.Caption = "On";
            optPlayerOn.Value = true;
            optPlayerOn.Size = new Size(57, 17);
            layout_Frame1.Add(optPlayerOn, 15, 24);

            optPlayerMouse = new LegacyRadioButton(optPlayerOff);
            optPlayerMouse.Caption = "Mouse Over";
            optPlayerMouse.Size = new Size(81, 17);
            layout_Frame1.Add(optPlayerMouse, 72, 24);


            Frame2 = new LegacyFrame();
            Frame2.Caption = "NPC Names";
            Frame2.Size = new Size(241, 57);
            layout_SSTab1.Add(Frame2, 16, 104);
            var layout_Frame2 = new PixelLayout();
            Frame2.Content = layout_Frame2;
            optNPCOn = new LegacyRadioButton();
            optNPCOn.Caption = "On";
            optNPCOn.Value = true;
            optNPCOn.Size = new Size(57, 17);
            layout_Frame2.Add(optNPCOn, 16, 24);

            optNPCMouse = new LegacyRadioButton(optNPCOn);
            optNPCMouse.Caption = "Mouse Over";
            optNPCMouse.Size = new Size(81, 17);
            layout_Frame2.Add(optNPCMouse, 72, 24);

            optNPCOff = new LegacyRadioButton(optNPCOn);
            optNPCOff.Caption = "Off";
            optNPCOff.Size = new Size(57, 17);
            layout_Frame2.Add(optNPCOff, 176, 24);


            Frame3 = new LegacyFrame();
            Frame3.Caption = "Music";
            Frame3.Size = new Size(241, 57);
            layout_SSTab1.Add(Frame3, 16, 168);
            var layout_Frame3 = new PixelLayout();
            Frame3.Content = layout_Frame3;
            optMusicOn = new LegacyRadioButton();
            optMusicOn.Caption = "On";
            optMusicOn.Size = new Size(57, 17);
            layout_Frame3.Add(optMusicOn, 16, 24);

            optMusicOff = new LegacyRadioButton(optMusicOn);
            optMusicOff.Caption = "Off";
            optMusicOff.Value = true;
            optMusicOff.Size = new Size(57, 17);
            layout_Frame3.Add(optMusicOff, 104, 23);


            Frame4 = new LegacyFrame();
            Frame4.Caption = "Sound";
            Frame4.Size = new Size(241, 57);
            layout_SSTab1.Add(Frame4, 17, 232);
            var layout_Frame4 = new PixelLayout();
            Frame4.Content = layout_Frame4;
            optSoundOn = new LegacyRadioButton();
            optSoundOn.Caption = "On";
            optSoundOn.Value = true;
            optSoundOn.Size = new Size(57, 17);
            layout_Frame4.Add(optSoundOn, 16, 24);

            optSoundOff = new LegacyRadioButton(optSoundOn);
            optSoundOff.Caption = "Off";
            optSoundOff.Size = new Size(57, 17);
            layout_Frame4.Add(optSoundOff, 104, 23);


            Frame5 = new LegacyFrame();
            Frame5.Caption = "WASD";
            Frame5.Size = new Size(241, 57);
            layout_SSTab1.Add(Frame5, 16, 293);
            var layout_Frame5 = new PixelLayout();
            Frame5.Content = layout_Frame5;
            optWASDOn = new LegacyRadioButton();
            optWASDOn.Caption = "On";
            optWASDOn.Value = true;
            optWASDOn.Size = new Size(57, 17);
            layout_Frame5.Add(optWASDOn, 16, 23);

            optWASDOff = new LegacyRadioButton(optWASDOn);
            optWASDOff.Caption = "Off";
            optWASDOff.Size = new Size(57, 17);
            layout_Frame5.Add(optWASDOff, 104, 21);


            cmdHotkeys = new LegacyButton();
            cmdHotkeys.Caption = "Keyboard Shortcuts...";
            cmdHotkeys.Size = new Size(256, 25);
            layout_SSTab1.Add(cmdHotkeys, 6, 420);

            Frame6 = new LegacyFrame();
            Frame6.Caption = "Vitals";
            Frame6.Size = new Size(241, 57);
            layout_SSTab1.Add(Frame6, 16, 354);
            var layout_Frame6 = new PixelLayout();
            Frame6.Content = layout_Frame6;
            optVitalsOn = new LegacyRadioButton();
            optVitalsOn.Caption = "On";
            optVitalsOn.Value = true;
            optVitalsOn.Size = new Size(57, 17);
            layout_Frame6.Add(optVitalsOn, 16, 21);

            optVitalsOff = new LegacyRadioButton(optVitalsOn);
            optVitalsOff.Caption = "Off";
            optVitalsOff.Size = new Size(57, 17);
            layout_Frame6.Add(optVitalsOff, 104, 21);



            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}