QtGUI.palette = QPalette.dark;

(
~gui = ();

// GUI Config
~gui.config = ();
~gui.config.bounds = Rect(
  (Window.screenBounds.width / 2) - 250,
  (Window.screenBounds.height / 2) - 250,
  500,
  500,
);


// Window
~gui.window = Window.new("wol", ~gui.config.bounds);
// ~gui.window.view.background = Color(0, 0, 0, 1);

// Elements
~gui.elements = ();

// Elements::Filters
~gui.elements.filters =
  View()
    .background_(Color.white)
    .maxSize_(120@140)
    .layout_(
      VLayout(
        View()
          .background_(Color.black)
          .layout_(
            VLayout(
              StaticText().align_(\topLeft).string_("Filters").maxHeight_(24),
              HLayout(
                VLayout(Knob().mode_(\vert), StaticText().align_(\top).string_("LPF")),
                VLayout(Knob().mode_(\vert), StaticText().align_(\top).string_("HPF")),
              ),
              [CompositeView(), stretch: 10]
            )
          )
      ).margins_(1)
    );

// Elements::Limiter
~gui.elements.limiter =
  View()
    .background_(Color.white)
    .maxSize_(80@140)
    .layout_(
      VLayout(
        View()
          .background_(Color.black)
          .layout_(
            VLayout(
              StaticText().align_(\topLeft).string_("Limiter").maxHeight_(24),
              VLayout(
                VLayout(Knob().mode_(\vert), StaticText().align_(\top).string_("Threshold")),
                VLayout(Button().states_([["", Color.grey, Color.grey], ["", Color.green, Color.green]])),
              )
            )
          )
      ).margins_(1)
    );

// Spacing
// CompositeView(~gui.elements.filters.root, 1@8);

// Show window
~gui.window.layout = VLayout(
  HLayout(
    ~gui.elements.filters,
    ~gui.elements.limiter,
  ).margins_(0),
).margins_(0);
~gui.window.front;
)

(
w = Window.new.layout_(
    HLayout(
        [Button.new.states_([["Super"]]), align:\bottom],
        TextView(),
        [Button.new.states_([["Collider"]]), align:\top],
        [View().layout_(VLayout(
          TextView(),
          Button.new.states_([["WAT"]])
        ))]
    )
).front;
)

(
w = Window.new(bounds:Rect(100,100,200,200)).layout_(
    VLayout(
        UserView.new.background_(Color.rand),
        TextField().string_("Super").maxWidth_(100),
        UserView.new.background_(Color.rand).minSize_(200@200),
        TextField().string_("Collider").maxWidth_(100)
    )
).front;
)

w = Window(bounds:Rect(200,200,200,200)).layout_(
    VLayout(
        TextField(), TextField(), TextField(),
        HLayout( Button(), Button(), Button() )
    )
).front;

{SinOsc.ar(440!2)}.play
s.freeAll


// ~gui.layout = HLayoutView(~gui.win, Rect(8, 256, 500, 256));
// ~gui.resize = 5;

// // Amplitude
// ~vlayout1 = VLayoutView(~gui.layout, Rect(0, 0, 30, 100));
// StaticText(~vlayout1, Rect(0, 0, 55, 20)).string_("Amp").align(\center);
// StaticText(~vlayout1, Rect(0, 0, 55, 5)).string_("").align(\center);
// ~slider1 = Slider(~vlayout1, Rect(0, 0, 20, 200))
// .orientation_(\vertical)
// // .value_(~control.amp.value)
// .knobColor_(Color.white)
// .background_(Color.black);

// ~vlayout2 = VLayoutView(~gui.layout, Rect(50, 0, 30, 100));
// StaticText(~vlayout2, Rect(0, 0, 55, 20)).string_("Reverb").align(\center);
// StaticText(~vlayout2, Rect(0, 0, 55, 5)).string_("").align(\center);
// ~slider2 = Slider(~vlayout2, Rect(0, 0, 20, 200))
// .orientation_(\vertical)
// // .value_(~control.reverb.value)
// .knobColor_(Color.white)
// .background_(Color.black);

// ~vlayout3 = VLayoutView(~gui.layout, Rect(50, 0, 30, 100));
// StaticText(~vlayout3, Rect(0, 0, 55, 20)).string_("Phaser").align(\center);
// StaticText(~vlayout3, Rect(0, 0, 55, 5)).string_("").align(\center);
// ~slider3 = Slider(~vlayout3, Rect(0, 0, 20, 200))
// .orientation_(\vertical)
// // .value_(~control.phaser.value)
// .knobColor_(Color.white)
// .background_(Color.black);

// ~gui.win.view.background = Color(0, 0, 0, 1);
// ~gui.win.front;
