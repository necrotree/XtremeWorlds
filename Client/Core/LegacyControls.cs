using Eto.Forms;

namespace XtremeWorlds.Client.UI
{
    // Thin compatibility controls keep familiar VB6/twinBASIC property names
    // while the underlying widgets are Eto.Forms controls.
    public class LegacyLabel : Label
    {
        public string Caption
        {
            get
            {
                return Text;
            }
            set
            {
                Text = value ?? string.Empty;
            }
        }
    }

    public class LegacyButton : Button
    {
        public string Caption
        {
            get
            {
                return Text;
            }
            set
            {
                Text = value ?? string.Empty;
            }
        }
    }

    public class LegacyRadioButton : RadioButton
    {
        public LegacyRadioButton() : base()
        {
        }
        public LegacyRadioButton(RadioButton controller) : base(controller)
        {
        }
        public string Caption
        {
            get
            {
                return Text;
            }
            set
            {
                Text = value ?? string.Empty;
            }
        }
        public bool Value
        {
            get
            {
                return Checked;
            }
            set
            {
                Checked = value;
            }
        }
    }

    public class LegacyCheckBox : CheckBox
    {
        public string Caption
        {
            get
            {
                return Text;
            }
            set
            {
                Text = value ?? string.Empty;
            }
        }
        public int Value
        {
            get
            {
                return Checked == true ? 1 : 0;
            }
            set
            {
                Checked = value != 0;
            }
        }
    }

    public class LegacyTextBox : TextBox
    {
        public bool Locked
        {
            get
            {
                return ReadOnly;
            }
            set
            {
                ReadOnly = value;
            }
        }
    }

    public class LegacyPasswordBox : PasswordBox
    {

        public bool Locked
        {
            get
            {
                return ReadOnly;
            }
            set
            {
                ReadOnly = value;
            }
        }
    }

    public class LegacyTextArea : TextArea
    {
        public bool Locked
        {
            get
            {
                return ReadOnly;
            }
            set
            {
                ReadOnly = value;
            }
        }
    }

    public class LegacyScrollBar : Slider
    {
        public int SmallChange { get; set; } = 1;
        public int LargeChange { get; set; } = 1;
    }

    public class LegacyComboBox : ComboBox
    {
        public int ListIndex
        {
            get
            {
                return SelectedIndex;
            }
            set
            {
                SelectedIndex = value;
            }
        }
    }

    public class LegacyListBox : ListBox
    {
        public int ListIndex
        {
            get
            {
                return SelectedIndex;
            }
            set
            {
                SelectedIndex = value;
            }
        }
    }

    public class LegacyPictureBox : Panel
    {
        public Drawable Canvas { get; private set; }

        public LegacyPictureBox()
        {
            Canvas = new Drawable();
            Content = Canvas;
        }
    }

    public class LegacyFrame : GroupBox
    {
        public string Caption
        {
            get
            {
                return Text;
            }
            set
            {
                Text = value ?? string.Empty;
            }
        }
    }
}