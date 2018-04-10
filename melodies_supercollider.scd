(

Pdef(\melody0, Pbind(	\instrument, \synth1,

					\freq, Pseq( [60, 64, 65, 67, 65, 67, 68, 70, 68, 67, 62, 64, 65, 67, 65, 64, 58, 60, 61, 63, 61, 60], inf).midicps,

					\dur,  Pseq([0.25, 0.25, 0.25, 0.25, 0.5, 0.5, 0.25, 0.25, 0.25, 0.5,0.25,0.25, 0.5, 0.25, 0.5, 0.5, 0.5, 0.25, 0.5,0.25, 0.5, 1], 2)

));

)

(

Pdef(\melody1, Pbind(	\instrument, \sine,

					\freq, Pseq( [64, 65, 67, 68, 67, 65, 67, 65, 64, 65,64, 65, 67, 68, 67, 65,67  ], inf).midicps,

					\dur,  Pseq([0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.25, 0.5,0.25,0.25, 0.5, 0.25, 0.5, 0.5,2.75], 2)

));

)

(

Pdef(\melody2, Pbind(	\instrument, \synth1,

					\freq, Pseq( [64, 65, 67, 68, 67, 65, 67, 65, 64, 65, 64,64,64, 61, 64, 61,  60 ], inf).midicps,

					\dur,  Pseq([0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.25, 0.5,0.25,0.25, 0.5, 0.25, 0.5, 0.5,2.75], 2)

));

)
(

Pdef(\melody3, Pbind(	\instrument, \sine,

					\freq, Pseq( [64, 65, 67, 68, 67, 65, 67, 65, 64, 65,64, 65, 67, 68, 67, 65,67  ]+2, inf).midicps,

					\dur,  Pseq([0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.25, 0.5,0.25,0.25, 0.5, 0.25, 0.5, 0.5,2.75], 2)
));

)

(

Pdef(\melody4, Pbind(	\instrument, \synth1,

					\freq, Pseq( [64, 65, 67, 68, 67, 65, 67, 65, 64, 65, 64,64,64, 61, 64, 61,  60 ]+2, inf).midicps,

					\dur,  Pseq([0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.25, 0.5,0.25,0.25, 0.5, 0.25, 0.5, 0.5,2.75], 2)

));

)
b = Pdef(\melody1).play(TempoClock(60/60),quant:[1]);
c = Pdef(\melody2).play(TempoClock(60/60),quant:[1]);
d = Pdef(\melody3).play(TempoClock(60/60),quant:[1]);
e = Pdef(\melody4).play(TempoClock(60/60),quant:[1]);
f = Pdef(\melody0).play(TempoClock(60/60),quant:[1]);

t = TempoClock.new;
t.tempo(2);
c = Pdef(\melody1).play(TempoClock(120/60),quant:[1]);
c = Pdef(\melody2).play(TempoClock(120/60),quant:[1]);
c = Pdef(\melody3).play(TempoClock(120/60),quant:[1]);
c = Pdef(\melody4).play(TempoClock(120/60),quant:[1]);
c = Pdef(\melody0).play(TempoClock(120/60),quant:[1]);