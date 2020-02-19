SynthDef(\limiter, {
  | peak = 1, lookahead = 0.01,
    out = 0 |
  ReplaceOut.ar(out, Limiter.ar(In.ar(2), peak, lookahead));
}).add;
