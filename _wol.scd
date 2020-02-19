ServerOptions.inDevices; // input devices
ServerOptions.outDevices; // output devices

s.plotTree;
FreqScope.new;

// Server config
(
  ~config = (
    device: "Scarlett 2i4 USB",
    // device: "Built-in Output",
    channels: 2,
  );
  s.options.outDevice = ~config.device;
  s.options.sampleRate = 44100;
  s.options.blockSize = 2**9;
  s.options.hardwareBufferSize = 2**9;
  s.options.numBuffers = 2**20;
  s.options.memSize = 2**20;
  s.options.maxNodes = 2**20;
  s.options.numOutputBusChannels = ~config.channels;
  s.options.numInputBusChannels = 0;
  s.latency = 0.2;
  s.boot;
)

(
SynthDef(\bass, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	freq = freq / 4;
	freq = freq * ((0..1)/1 - 0.5 * 0.0007 + 1);
	env1 = EnvGen.kr(Env([0,1,0.051,0],[0.001,0.01,0.8], [4,-8]), 1);
	env2 = EnvGen.kr(Env([0,1,0.051,0],[0.005,0.5,1.5], [0,-8], releaseNode:2), 1);
	env3 = EnvGen.kr(Env([0,1,1,0],[0.01,0.01,0.2], [0,0,-4], releaseNode:2), gate);
	env4 = EnvGen.kr(Env([0,1,0],[0.002,2.8], [0,-4]), 1);
	env5 = EnvGen.kr(Env([0,1,1,0],[0.001,0.1,0.8], [4,0,-4], releaseNode:2), gate);
	env6 = EnvGen.kr(Env([0,1,0],[0.001,3.0], [0,-4]), 1);
	//freq = freq * EnvGen.kr(Env([1,1.002,0.998,1],[0.1,0.8]), 1);
	sig1 = SinOsc.ar(freq * 11 + 0) * env1;
	sig2 = SinOsc.ar(freq * 6 * ( sig1 * 2.5 + 1 )) * env2;
	sig3 = SinOsc.ar(freq * 2 * 1 + 0) * env3;
	sig4 = SinOsc.ar(freq * 1 * ( sig3 * 2.5 + 1 ) + 0) * env4;
	sig5 = SinOsc.ar(freq * 1 * ( sig2 * 2.5 + 1 ) * (sig4 * 2.5 + 1)) * env5;
	sig6 = SinOsc.ar(freq * 2) * env6;
	//sig = sig2 + sig3 + sig4 + sig5 + sig6;
	sig = [sig1, sig2, sig3, sig4, sig5, sig6] * DC.ar([0.0, 0.0, 0.0,  0.0, 0.5, 0.5]);
	sig.debug("sig");
	sig = sig /2;
	sig = sig.flop.sum;
	sig = sig * EnvGen.ar(\adsr.kr( Env.adsr(0.001,0,1,0.01, 1,-1) ),gate,doneAction:2);
	sig = sig * AmpComp.kr(freq);
	sig.debug("sigx");
	sig = Pan2.ar(sig, pan + [ 0, 0, 0, 0, 0, 0], amp).sum;
	Out.ar(out, sig);
}).add;
)

Synth(\fmbass, [\freq, 400])
s.freeAll

(
SynthDef("bass", { arg freq = 440, amp = 0.5, gate = 1;
	var snd, env, oscfreq, output;
	oscfreq = {freq * LFNoise2.kr(0.5).range(0.98, 1.02)}!3;
	snd = Splay.ar(LFSaw.ar(oscfreq, mul: amp));
	env = Env.adsr(0.7, 4, 0, 0.1).kr(doneAction:2, gate: gate);
	snd = snd;
	output = LPF.ar(snd, (env*freq) + 2*freq);
	Out.ar(0, output);
	}).add;
)
)
Synth(\bass)
s.freeAll

(
SynthDef(\bass, { |outbus, midinote = 42|
  var freq = midinote.midicps;
  var subfreq = freq / 2;

  // Envelopes
  var subenv = EnvGen.kr(Env.perc(0, 1), doneAction:2);
  var env = EnvGen.kr(Env.perc(0, 0.5));

  // Component synthesis
  var pluck = Pluck.ar(PinkNoise.ar, 1, 0.2, subfreq.reciprocal) * subenv * 2;
  var tri = VarSaw.ar(freq) * env;
  var sin = SinOsc.ar(freq) * env;
  var sub = (SinOsc.ar([subfreq, subfreq - 2, subfreq + 2]).sum * subenv).tanh;
  var click = RLPF.ar(Impulse.ar(0), [2000, 8000], 1).sum * 1000;

  // Initial signal
  var sig = pluck + tri + sub + click;

  // Resonant LPFs
  sig = RLPF.ar(sig, XLine.ar(freq * 100, freq * 10, 0.15));
  sig = sig + (MoogFF.ar(sig, freq * 20, 2.5) * 0.1);

  // EQ resulting signal
  sig = BPeakEQ.ar(sig, 400, 0.5, -9);
  sig = BPeakEQ.ar(sig, 2000, 0.5, 6);
  sig = BHiShelf.ar(sig, 8000, 1, 3);
  sig = BPeakEQ.ar(sig, 200, 1, 3);

  // Apply another envelope to dampen a bit more
  sig = sig * XLine.kr(1, 0.6, 0.1);

  // Tanh distortion / limiting
  sig = (sig * 1).tanh;

  // Another round of signal coloring, using another RLPF
  // and sine components
  sig = sig + RLPF.ar(sig, XLine.ar(freq * 100, freq * 10, 0.15)) + sin + sub;

  // Another round of tanh distortion / limiting
  sig = (sig / 2.3).tanh;

  // Another resonant LPF
  sig = MoogFF.ar(sig, XLine.ar(freq*150, freq*30, 0.1), 0.1);

  Out.ar(outbus, sig!2);
}).add;
)
Synth(\bass, [\midinote, 47])

// Synth defenitions
(
  SynthDef(\sine, {
    | freq = 440, gate = 1,
      amp = 1, out = 0 |
    var signal, feedback;

    feedback = LocalIn.ar(2) * 0.99;
    signal = Saw.ar(freq);
    // VarSaw.ar(freq: 440.0,  iphase: 0.0,  width: 0.5,  mul: 1.0,  add: 0.0)
    signal = Pan2.ar(signal, 0);
    feedback = signal + feedback;
    LocalOut.ar(feedback);

    feedback = LowShelf.ar(feedback, freq, 1, 6);
    feedback = LPF.ar(feedback, 2000);

    feedback = EnvGen.ar(Env.adsr(0.01, 0.3, 0.5, 1, 1, -8), gate, doneAction: Done.freeSelf) * feedback;
    // feedback = FreeVerb.ar(feedback);
    feedback = Limiter.ar(feedback);

    OffsetOut.ar(out, feedback * amp);
  }).add;
)

StageLimiter.activate()

Env.adsr.plot

Env.adsr(0.1, 0.3, 0.5, 1, 1, -8).plot

Synth(\sine)
s.freeAll

MIDIClient.init;
MIDIIn.connectAll();
(
  var keys = Array.newClear(128);

  ~noteOnFunc = {arg src, chan, num, vel;
    var node;
    node = keys.at(num);
    if (node.notNil, {
      node.release;
      keys.put(num, nil);
    });
    node = Synth.tail(nil, \bass, [\freq, num.midicps, \amp, vel/127]);
    keys.put(num, node);
    [chan,num,vel/127].postln;
  };
  MIDIIn.addFuncTo(\noteOn, ~noteOnFunc);

  ~noteOffFunc = {arg src, chan, num, vel;
    var node;
    node = keys.at(num);
    if (node.notNil, {
      node.release;
      keys.put(num, nil);
    });
  };
  MIDIIn.addFuncTo(\noteOff, ~noteOffFunc);
)

(

)

// Cleanup
(
  MIDIIn.removeFuncFrom(\noteOn, ~noteOnFunc);
  MIDIIn.removeFuncFrom(\noteOff, ~noteOffFunc);
)
