Server.default.record;
(
{

 var burstEnv, att = 0, dec = 0.001; //Variable declarations

 burstEnv = EnvGen.kr(Env.perc(att, dec), gate: Impulse.kr(1)); //envelope

 PinkNoise.ar(burstEnv); //Noise, amp controlled by burstEnv

}.play

)


(
    var n = 16;
    {
        Mix.fill(n, { arg index;
            var freq;
            index.postln;
            freq = 440 + index;
            freq.postln;
            SinOsc.ar(freq , 0, 1 / n)
        })
    }.play;
)
