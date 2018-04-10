
(
SynthDef(\smooth, { |freq = 440, sustain = 1, amp = 0.5|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: Done.freeSelf);
    Out.ar(0, sig ! 2)
}).add;

SynthDef(\stereosineWenv, {arg freq=333, amp=0.4, pan=0.0, dur=1; // we add a new argument
	var signal, env;
	env = EnvGen.ar(Env.perc(0.01, dur), doneAction:2); // doneAction gets rid of the synth
	signal = SinOsc.ar(freq, 0, amp) * env;
	signal = Pan2.ar(signal, pan);
	Out.ar(0, signal);

}).add;

SynthDef(\sine, {arg out=0, amp=0.1, freq=1200, envdur=1, pan=0.0;
	var signal;
	signal = Pan2.ar(SinOsc.ar(freq, 0, amp**amp).cubed, pan); // note the pan
	signal = signal * EnvGen.ar(Env.perc(0.01, envdur), doneAction:2);
	Out.ar(out, signal);
}).add;



SynthDef(\synth1, {arg out=0, freq=440, envdur=1, amp=0.4, pan=0;
    var x, env;
    env = EnvGen.kr(Env.perc(0.001, envdur, amp), doneAction:2);
    x = Mix.ar([FSinOsc.ar(freq, pi/2, 0.5), Pulse.ar(freq,Rand(0.3,0.7))]);
    x = RLPF.ar(x,freq*4,Rand(0.04,1));
    x = Pan2.ar(x,pan);
    Out.ar(out, x*env);
	}).add;



SynthDef(\transitioneffect,{|out =1 gate= 1 threshold= 0.1 amp=0.1|

		var a,c,z,y,in;
		var env = Linen.kr(gate, 0.1, 1, 0.1, 2);

		c = 6; // number of comb delays
		a = 4; // number of allpass delays

		in=In.ar(out,2);

		// reverb predelay:
		z = DelayN.ar(LeakDC.ar(in), 0.048,0.048);

		y=Mix.arFill(c,{CombL.ar(z,0.1,rrand(0.01, 0.1),5)});

		// chain of 4 allpass delays on each of two channels (8 total) :
		a.do({ y = AllpassN.ar(y, 0.051, [rrand(0.01, 0.05),rrand(0.01, 0.05)], 1) });

		Out.ar(out,Pan2.ar(y,0)*env*amp);

	}).add;


	SynthDef(\eightoeightkick,{|out= 0 freq = 440 amp = 0.1 ringTime=10.0 releaseTime=1.0 distortion = 0.1 pan=(-0.1)|

		var impulse, filter, env;

		impulse = Impulse.ar(0);

		filter = Ringz.ar(impulse,XLine.ar(freq,60,0.1),ringTime);

		env = EnvGen.ar(Env.perc(0.001,releaseTime),doneAction:2);

		filter = (1.0-distortion)*filter + (distortion*(filter.distort));

		filter = BLowShelf.ar(filter,30,1,-40);

		Out.ar(out,Pan2.ar(filter*env*amp,pan));

	}).add;

	SynthDef(\algohihat,{|out= 0 freq = 4400 amp = 0.1 rq=0.5 releaseTime=0.2 distortion = 0.0 pan=(-0.1)|

		var impulse, filter, env;

		impulse = WhiteNoise.ar;

		filter =  BBandPass.ar(impulse, XLine.ar(10000,freq,0.05),rq.reciprocal);

		env = EnvGen.ar(Env.perc(0.001,releaseTime),doneAction:2);

		filter = (1.0-distortion)*filter + (distortion*(filter.distort));

		filter = BHiPass.ar(filter,2000,rq);

		Out.ar(out,Pan2.ar(filter*env*amp*2,pan));

	}).add;



	SynthDef(\fatvelocitybass,{|out= 0 freq = 440 amp = 0.1 gate=1 cutoff= 12000 rq=0.25 lagTime=0.01 pan = 0.0|

		var lfo, osc, filter, env;

		var basefreq =  ((freq.lag(lagTime).cpsmidi)+[0,11.95,31.03]).midicps;

		osc = Saw.ar(basefreq,[0.5,0.4,0.1]); //+PinkNoise.ar(Line.kr(1.0,0,0.03));

		env = EnvGen.ar(Env.adsr(0.01,1.0,1.0,0.25),gate,doneAction:2);

		filter = BLowPass4.ar(osc,400+(((amp)*(freq+cutoff)).min(20000).max(100)),rq); //was amp.squared

		Out.ar(out,Pan2.ar(Mix(filter)*env*amp*0.8,pan));

	}).add;


	SynthDef(\pwmbling,{|out= 0 freq = 440 amp = 0.1 gate=1 lforate = 4.85 lfowidth= 0.5 cutoff= 12000 rq=0.25 pan = 0.0|

		var lfo, pulse, filter, env;
		var basefreq =  ((freq.cpsmidi)+[0,12.12]).midicps;

		lfo = LFTri.kr(lforate*[1,1.01],Rand(0,2.0)!2);

		pulse = Pulse.ar(basefreq,lfo*lfowidth+0.5);

		env = EnvGen.ar(Env.adsr(0.0,1.0,0.2,1.5),gate,doneAction:2);

		//env.squared
		filter = RLPF.ar(pulse,(cutoff*(env)).max(20000).min(100)+100,rq);

		Out.ar(out,Pan2.ar(Mix(filter)*env*amp,pan));

	}).add;


	SynthDef(\spacetheremin,{|out= 0 freq = 440 amp = 0.1 gate=1 lforate = 6 lfowidth= 0.5 cutoff= 4000 rq=0.25 lagTime=0.1 pan=0.0|

		var lfo, osc, filter, env;

		lfo = LFTri.kr(lforate+(LFNoise1.kr(5,0.3,0.3)),Rand(0,2.0));

		osc = Saw.ar((freq.lag(lagTime).cpsmidi+(lfo*lfowidth)).midicps,0.5);

		filter = BLowPass4.ar(osc,(cutoff.lag(lagTime*4)).min(20000).max(200),rq);

		env = EnvGen.ar(Env.adsr(0.6,0.0,1.0,0.05),gate,doneAction:2);

		Out.ar(out,Pan2.ar(filter*env*amp.lag(lagTime*4),pan));

	}).add;


	//with dirty attack
	SynthDef(\handclapsmash2,{|out= 0 amp = 0.1 gate=1 cutoff= 12000 cutoff2=10000 rq=0.5 modamount=0.0 modrate=50 releaseTime=0.7 pan=0.0|

		var noise, filter, filterenv, modulation, env;

		noise = WhiteNoise.ar;

		filterenv = EnvGen.ar(Env([0.0,1.0,0.3,0.0],[0.0,0.3,0.3]));

		modulation = (LFSaw.ar(modrate).range(0.0,1.0))*EnvGen.ar(Env([1,1,0,0],[0.1,0.0,1.0]));

		//filter = BHiPass.ar(RLPF.ar(noise,cutoff*filterenv*(1.0+(modamount*modulation)),rq),150); //alternative
		filter = BHiPass.ar(RLPF.ar(noise,(cutoff*filterenv+ (cutoff2*modamount*modulation)).min(20000).max(200),rq),150);

		//body
		filter = BPeakEQ.ar(filter,440,1.0,8);
		//snap
		filter = BPeakEQ.ar(filter,1200,1.0,14);

		//no gate, fixed percussion sound
		env = EnvGen.ar(Env.perc(0.005,releaseTime),doneAction:2);

		//amp modulation too not very effective ((1.0-modamount)+(modamount*modulation))
		Out.ar(out,Pan2.ar(filter*env*amp,pan));

	}).add;


	//no use of gate, fixed length
	SynthDef(\moogbasstone2,{|out= 0 freq = 440 amp = 0.1 gate=1 attackTime= 0.2 fenvamount=0.5 cutoff= 1000 gain=2.0 pan=0.0|

		var osc, filter, env, filterenv;

		//alternative: richer source
		osc = Mix(Pulse.ar(freq.lag(0.05)*[1.0,1.001,2.0],Rand(0.45,0.5)!3,0.33));

		filterenv = EnvGen.ar(Env.adsr(attackTime,0.0,1.0,0.2),gate); //,doneAction:2
		filter =  MoogFF.ar(osc,(cutoff*(1.0+(fenvamount*filterenv))).min(20000).max(200),gain);

		env = EnvGen.ar(Env.adsr(0.001,0.3,0.9,0.2),gate,doneAction:2);

		Out.ar(out,Pan2.ar((0.7*filter+(0.3*filter.distort))*env*amp,pan));

	}).add;



	//no use of gate, fixed length
	SynthDef(\laserbeam,{|out= 0 freq = 880 amp = 0.1 attackTime= 0.04 gate=1 pan=0.0|

		var osc1, freqenv, ampenv, env;

		freqenv = EnvGen.ar(Env([4,0.5,1,1],[attackTime,0.01,1.0]));

		osc1 = LFTri.ar((freq*freqenv).min(10000));

		env = EnvGen.ar(Env.adsr(0.01,0.0,1.0,0.1),gate,doneAction:2);
		//no gate, fixed envelope size
		ampenv = EnvGen.ar(Env([0,1,0.5,0.0],[0.02,0.2,0.1])); //,doneAction:2

		Out.ar(out,Pan2.ar(osc1*ampenv*amp,pan));

	}).add;


	SynthDef(\finalfx,{|out =0 in=16, gate= 1 threshold= 0.1 amp=0.1|

		var a,c,z,y;
		var env = Linen.kr(gate, 0.0, 1, 0.5, 2);
		var inputs = Array.fill(9,{|i| In.ar(in+(2*i),2)});
		var delay, hatdelay, output, good;

		c = 6; // number of comb delays
		a = 4; // number of allpass delays

		// reverb predelay:
		z = DelayN.ar(LeakDC.ar(inputs[6]+(0.3*inputs[3])), 0.048,0.048);

		y=Mix.arFill(c,{CombL.ar(z,0.1,rrand(0.01, 0.1),5)});

		// chain of 4 allpass delays on each of two channels (8 total) :
		a.do({ y = AllpassN.ar(y, 0.051, [rrand(0.01, 0.05),rrand(0.01, 0.05)], 1) });

		delay = CombC.ar(LeakDC.ar(In.ar(in+(2*Rand(1,5)))),2.1.reciprocal,(2.1.reciprocal)/Rand(2,5),ExpRand(0.1,10));

		hatdelay = CombC.ar(LeakDC.ar(In.ar(in+14,2)),2.1.reciprocal,(2.1.reciprocal)/4,ExpRand(0.1,2))*(Rand(0,1).round(1.0));

		//Limiter.ar(HPF.ar(,10))
		output =(0.5*y) + inputs[0]+ inputs[7]+ Mix(inputs.copyRange(1,5))  +(Rand(0.01,0.03)*delay) + inputs[8] +([hatdelay[1],hatdelay[0]]);

		good = BinaryOpUGen('==', CheckBadValues.ar(output, 0, 0), 0);

		output = Limiter.ar(LeakDC.ar(BLowShelf.ar(good*output,30,1.0, -40)),0.99,0.01);

		Out.ar(out,(env*output).clip(-1.0,1.0));
	}).add;

	SynthDef(\transitionsound1,{|out=0 startfreq=261.626 endfreq = 261.626 amp = 0.5 dur=2.0|
		var env, sound, time, freq, pancontrol;

		freq = XLine.kr(startfreq,endfreq,dur);
		pancontrol = Line.kr(Rand(-1,1),Rand(-1,1),dur);

		env = EnvGen.ar(Env([0,1,1,0],[0.01,0.1,dur]),doneAction:2);

		sound = Mix(Saw.ar(XLine.kr(8,1,dur*0.9)*freq*[0.5,1,2,3,6/5]))*0.2;

		time = (0.5*freq).reciprocal;

		sound = CombC.ar(LeakDC.ar(sound),time,time,Line.kr(0.1,5,dur));

		Out.ar(out,Pan2.ar(sound*env*amp,pancontrol));

	}).add;
)