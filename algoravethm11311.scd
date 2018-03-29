
//Sick Lincoln December 2012, tweaks April 2013

//double click on outer brackets to select all, then run
//Don't worry about any FAILURE /n_set Node not found or late messages, they're not important
(
var numsections = 14;
var numsectiontypes = 6;
var sectiondata;
var formgenerator = Pxrand((0..(numsectiontypes-1)),inf).asStream;
var form = formgenerator.nextN(numsections); //{numsectiontypes.rand}!numsections;

var kickrhythms1 = [[4.0],[1.0,3.0],[1.0,0.5,0.5],[0.5,0.5,0.5,0.5],[1.5,0.5],[1.0,1.0], [1.0,0.25,0.25,0.25,0.25],[0.5,0.5,0.5,0.5],[0.5,1.0,0.5],[1.0,1.0]];
var kickaccents1 = [[1],[1,0], [0,0,0],[-1,1,0,0],[0,0],[1,0], [-1,0,0,0,0],[-1,1,0,0],[-1,1,0],[-1,0]];

var tempoflag = 0;

var addSynthDefs;

Server.local.options.memSize = 10*8192;  //so lots of memory for delay lines in Comb UGens etc
Server.internal.options.memSize = 10*8192;

addSynthDefs = {

	SynthDef(\transitioneffect,{|out =0 gate= 1 threshold= 0.1 amp=0.1|

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
	SynthDef(\laserbeam,{|out= 0 freq = 440 amp = 0.1 attackTime= 0.04 gate=1 pan=0.0|

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

};



//first half first half bar, second second
//-1 rest, 0 no accent, 1 accent


sectiondata = Array.fill(numsectiontypes,{
	var dictionary = ();
	var kickfreq;

	dictionary[\mixamplitudes]  = {[0.5,[rrand(0.3,0.6),0].wchoose([0.7,0.3]),[0.15,0.0].wchoose([0.9,0.1]),[rrand(0.2,0.4),0.0].wchoose([0.8,0.2]),[rrand(0.15,0.55),0.0].wchoose([0.8,0.2]),0.4,[0.0,rrand(0.1,0.2)].choose, [rrand(0.02,0.05),0.0].wchoose([0.5,0.5])]}.value;

	dictionary[\mixpans]  = {[0.0,[0.0,rrand(0.0,0.2)].choose,[0.0,rrand(0.0,-0.2)].choose,0.2.rand2,0.2.rand2,0.3.rand2,0.3.rand2,rrand(0.2,0.5)*((-1)**(2.rand))]}.value;

	  //exprand(200,600)
	dictionary[\kickparams] = {[rrand(0.2,2.0),rrand(1.0,10.0),exprand(0.01,0.9),exprand(100,400)]}.value;

	kickfreq = dictionary[\kickparams][3];

	dictionary[\kicksource]  = kickrhythms1.collect{|pattern,i| var accents = kickaccents1[i];
		pattern.collect{|val,j| var accentnow = accents[j];

			//dur, freq, amp
			[val,if(accentnow<0,\rest,kickfreq),if(accentnow>0,0.8,0.5)]

		}

	};
	dictionary[\kickweights] = Array.fill(5,{[rrand(0.0,1.0),1,0.0001].choose}).normalizeSum;

	if(0.3.coin) {dictionary[\kickweights] = [[0.9,0.1,0,0,0].scramble,[1.0,0,0,0,0].scramble].choose};

	dictionary[\kickmode] = 2.rand;

	dictionary[\hatgap] = [2,1,0.5].choose;
	dictionary[\hataccent] = [{Pseq( ((1!(rrand(1,10)*2))++(0!(rrand(0,3)*2))++({Prand([0,1],1)}!(rrand(0,3)*2))).scramble,inf)},{1},{Pseq( {[rrand(0.1,1.0),0.0,1.0,exprand(0.05,0.5)].choose}!rrand(7,15),inf)},{var num= rrand(5,17); Pseq(Array.series(num,0.1,0.9/num).reverse,inf)}].choose.value;
	dictionary[\hatparams] = {[rrand(0.1,0.3),rrand(0.2,0.8),rrand(2000,9000),exprand(0.01,0.4)]}.value;

	dictionary[\laserparams]  = {[[rrand(48,72),60,55,72].choose,rrand(0.01,0.1)]}.value;
	//cutoff, cutoff2, rq, modrate, modamount, releaseTime
	dictionary[\clapparams]  = {[rrand(1000,12000),rrand(1000,10000),rrand(0.4,1.0),rrand(20,100),rrand(0.1,0.9),rrand(0.2,0.8)]}.value;

	dictionary[\transposepattern]  = Pstutter([32,64,96].choose,Pseq({[0,5,7,-2,-4,2,3].choose}!10,inf)).asStream;
	dictionary[\mainpattern]  = [
	{Pn(Plazy({Pstutter(rrand(1,3),Pseq( ([12,10,8,7,3,0,-12]+([24,36,48].choose) ++ [\rest,\rest]).scramble,1))}),inf)},
	{Pn(Plazy({Pstutter(rrand(1,3),Pxrand( [0,3,5,7,10,-1,7.1,0.1,0]+([24,36,48].choose),1))}),inf)},
	{Pn(Plazy({Pstutter(rrand(1,3),Pseq( ([0,7,12,-5,-2,-3]+([24,36,48].choose) ++ [\rest,\rest,\rest,\rest]).scramble,1))}),inf)}
	].choose.value;
	dictionary[\bass1params]  = {[rrand(2000,7000),rrand(0.2,0.3)]}.value; //\cutoff,3000,\rq,0.1,
	dictionary[\pwmparams]  = {[rrand(0.0,0.5),rrand(1000,10000)]}.value; //\lfowidth,Pn(Pseries(0.0,0.07,7),inf),\cutoff,Pstutter(8,Pn(Pseries(10000,-1000,9),inf)),
	dictionary[\theremindur]  = rrand(3,11)*0.5;
	dictionary[\moogdur]  = rrand(2,5)*1.0;

	if(0.2.coin) {

		dictionary[\moogdur]  = rrand(3,11)*0.5;

		dictionary[\theremindur]  = rrand(1,3)*1.0;

	};

	dictionary[\tempo] = [2.1,4.2].wchoose([0.5,0.5]);

	//if((dictionary[\tempo]==4.2) || (dictionary[\hatgap]==0.5)) {dictionary[\hataccent] = Pseq( ((1!(rrand(1,10)*2))++(0!(rrand(1,4)*2))++({Prand([0,1],1)}!(rrand(1,4)*2))).scramble,inf) };

	dictionary[\bass1durpattern] = Pseq([[0.5,1.0,0.5],[0.5],[0.25,0.25,0.25,0.25,3.0],[1.0,2.0,1.0]].choose.scramble,inf);
	dictionary[\pwmblingpattern] = [
	{Pwrand([0.5,3.5],[[0.72,0.28],({rrand(0.1,0.9)}!2).normalizeSum].choose,inf)},
	{Pwrand([1.5,3.5],[[0.92,0.08],({rrand(0.1,0.9)}!2).normalizeSum].choose,inf)},
	{Pwrand([0.5,1.0,1.5],[[0.22,0.48,0.3],({rrand(0.1,0.9)}!3).normalizeSum].choose,inf)},
	].choose.value;

	dictionary

});

s.waitForBoot({
	var g = Group();
	var auxbusindex = s.options.numInputBusChannels + s.options.numOutputBusChannels;
	var transitioneffect;

	//load synthdefs
	addSynthDefs.value;

	s.sync;


	transitioneffect = Synth.tail(g,\transitioneffect,[\out,auxbusindex+16]);


	{

		form.do {|section, stage|

			var pattern;
			var dictionary = sectiondata[section];

			var transpose = 0;
			var whichkickpattern = 2.rand;

			var mixamplitudes = dictionary[\mixamplitudes];
			var kickparams = dictionary[\kickparams];
			var kicksource = dictionary[\kicksource];
			var kickweights = dictionary[\kickweights];
			var kickmode = dictionary[\kickmode];
			var hatparams = dictionary[\hatparams];
			var laserparams = dictionary[\laserparams];
			var clapparams = dictionary[\clapparams];
			var transposepattern = dictionary[\transposepattern];
			var mainpattern = dictionary[\mainpattern];
			var bass1params = dictionary[\bass1params];
			var pwmparams = dictionary[\pwmparams];
			var theremindur = dictionary[\theremindur];
			var moogdur = dictionary[\moogdur];
			var fx;

			//opening
			if(stage==0) {
				mixamplitudes = [0.5,0,0.14,0.0,rrand(0.15,0.35),0.4,0.0,0.05];
			};

			if(stage<3) {
				mixamplitudes[6] = 0.0; //no theremin before fourth stage
			};

			tempoflag = 1-tempoflag;


			s.bind{fx = Synth.tail(g,\finalfx)};

			Synth.head(g,\transitionsound1,[\out,auxbusindex+16,\startfreq,rrand(36,55).midicps,\endfreq,rrand(36,55).midicps,\dur,rrand(1.0,3.0), \amp, rrand(0.2,0.3)]);

			//alternate between sections
			//TempoClock.default.tempo = if(tempoflag==1,2.1,4.2); //dictionary[\tempo].postln;

			("stage" + stage+ "completed" +(100*((stage/form.size).round(0.001)))++"%" +"tempo" + TempoClock.default.tempo+ "\n").postln;


			pattern = Ppar([
			Pbind(
			\instrument,\eightoeightkick,
			[\dur,\freq,\amp],Pn(Plazy({ if(kickmode>0,{whichkickpattern = 1-whichkickpattern;}); Pseq(if(whichkickpattern==0,{kicksource[0..4].wchoose(kickweights)},{kicksource[5..9].wchoose(kickweights)}) ,1); }),inf),
			//\freq,kickparams[3],
			//\amp,Pseq([0.5,\],inf),
			\releaseTime,kickparams[0],
			\ringTime,kickparams[1],
			\distortion,kickparams[2],
			\out,auxbusindex,
			\group,g
			),
			Pbind(
			\instrument, \laserbeam,
			\amp, mixamplitudes[1],
			\midinote,Pseq([\,laserparams[0]],inf),
			\dur,2.0,
			\attackTime,laserparams[1],
			\out,auxbusindex+2,
			\group,g,
			\pan,dictionary[\mixpans][1]
			),
			Pbind(
			\instrument,\handclapsmash2,
			\amp, mixamplitudes[2],
			[\dur,\midinote],Pn(Plazy({ Pseq([[[2.0,\rest],[2.0,50]],[[2.0,\rest]]++([0.25,50]!4)++[[1.0,\rest]]].wchoose([0.75,0.25]),1) }),inf),
			\cutoff,clapparams[0],
			\cutoff2, clapparams[1],
			\rq,clapparams[2],
			\modrate,clapparams[3],
			\modamount,clapparams[4],
			\releaseTime,clapparams[5],
			\out,auxbusindex+4,
			\group,g,
			\pan,dictionary[\mixpans][2]
			),
			PmonoArtic(
			\fatvelocitybass,
			\midinote,mainpattern, //Pn(Plazy({Pstutter(rrand(1,3),Pseq([12,10,8,7,3,0,-12]+36,1))}),inf),
			\dur,dictionary[\bass1durpattern] * (if(tempoflag==1,1,2)), //Pseq([0.5,1.0,0.5],inf),
			\amp,Pshuf(mixamplitudes[3]*[0.7,1.0,0.5,0.6,0.4,0.7,0.8,0.3,0.6,0.4,0.7],inf),
			\cutoff,bass1params[0],
			\rq,bass1params[1],
			\ctranspose,Pfunc({transpose = transposepattern.next; transpose}),
			\out,auxbusindex+6,
			\group,g,
			\pan,dictionary[\mixpans][3]
			),
			Pbind(
			\instrument,\pwmbling,
			\midinote,mainpattern,
			\dur,dictionary[\pwmblingpattern], //Pwrand([1.5,3.5],[0.92,0.08],inf),
			\amp, mixamplitudes[4],
			\lfowidth,pwmparams[0], //Pn(Pseries(0.0,0.07,7),inf),
			\cutoff,pwmparams[1], //Pstutter(8,Pn(Pseries(10000,-1000,9),inf)),
			\ctranspose,Pfunc({transpose}),
			\out,auxbusindex+8,
			\group,g,
			\pan,dictionary[\mixpans][4]
			),
			Pmono(
			\moogbasstone2,
			\amp, mixamplitudes[5],
			\midinote,mainpattern,
			\dur,moogdur, //2.5,
			\gain,Pn(Pseries(2,0.1,18),inf),
			\cutoff,Pstutter(3,Pn(Pseries(50,250,40),inf)),
			\attackTime,Pn(Pseries(0.0,0.01,30),inf),
			\fenvamount,Pstutter(4,Pn(Pseries(0.0,0.05,20),inf)),
			\ctranspose,Pfunc({transpose}),
			\out,auxbusindex+10,
			\pan,dictionary[\mixpans][5],
			\group,g
			),
			Pmono(
			\spacetheremin,
			\amp,Prand([0.4,0.45,0.5,0.55,0.5]*mixamplitudes[6],inf),
			\midinote,Prand([0,2,3,5,6,7,8,11]+72,inf), //octotonic
			\dur,Prand([1,2]*theremindur,inf), //[2.0,3.0]
			\lagTime,Pstutter(7,Pn(Pseries(0.05,0.05,8),inf)),
			\lfoRate,Pstutter(9,Pn(Pseries(6,0.5,5),inf)),
			\cutoff,Pstutter(11,Prand([1000,1500,2000,3000],inf)),
			\ctranspose,Pfunc({transpose}),
			\out,auxbusindex+12,
			\group,g,
			\pan,dictionary[\mixpans][6]
			),
			Pbind(
			\instrument,\algohihat,
			\amp,mixamplitudes[7]*dictionary[\hataccent],
			\dur,dictionary[\hatgap],
			\releaseTime,hatparams[0],
			\rq,hatparams[1],
			\freq,hatparams[2],
			\distortion,hatparams[3],
			\out,auxbusindex+14,
			\group,g
			),
			]).play;

			if(tempoflag==1) {

				(rrand(1,2)*8*4).wait;
				} {

				(rrand(2,4)*8*4).wait;
			};

			{0.5.wait; pattern.stop; }.fork;

			if(stage==(form.size-1)) {

				16.0.wait;

			};

			fx.release;

		};

		1.0.wait;
		transitioneffect.free;

	}.fork;

});



)





