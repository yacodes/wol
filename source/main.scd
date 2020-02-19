(
  ~server = (File.getcwd +/+ "/server.scd").load;
  ~server.waitForBoot({
    (File.getcwd +/+ "/synths/instruments.scd").load;
    (File.getcwd +/+ "/synths/effects.scd").load;
    (File.getcwd +/+ "/gui/gui.scd").load;
    (File.getcwd +/+ "/midi/midi.scd").load;
  });
)

{SinOsc.ar(440!2)}.play

s.freeAll;
