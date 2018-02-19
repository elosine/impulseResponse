// IASIAR LIVE INPUT //////////////////////////////

(
// INIT ////////////////////////////////////////////////
~fftsize = 2048;
s.options.memSize = 204800;
//s.options.numOutputBusChannels_(24);
~numImpulses = 15;
~irSpectrum01 = Array.newClear(~numImpulses);
~irSpectrum02 = Array.newClear(~numImpulses);
~liveIn1 = Array.newClear(~numImpulses);
~liveIn2 = Array.newClear(~numImpulses);
~irIdxLSet = ["_ch7_5", "_ch7_13", "_ch9_8", "_ch21_15", "_ch29_6", "_ch7_2", "_ch25_1", "_ch15_21", "_ch3_1", "_ch9_1", "_ch1L_1", "_ch1L_4", "_ch1L_17", "_ch1L_20", "_ch25_13" ];
~irIdxRSet = ["_ch8_3", "_ch8_8", "_ch10_4", "_ch22_11", "_ch30_19", "_ch8_2", "_ch26_1", "_ch16_17", "_ch3_2", "_ch10_1", "_ch1R_1", "_ch1R_7", "_ch1R_17", "_ch1R_21", "_ch26_13"];
~ampsSet = [0.2, 0.15, 0.26, 0.17, 0.15, 0.4, 0.7, 0.2, 0.45, 0.7, 0.7, 0.24, 0.22, 0.11, 0.1 ];

s.waitForBoot {
	~numImpulses.do{ |ix|
		{
			var irbuffer, bufsize;
			irbuffer = Buffer.read(s, "/Users/jyang/Dropbox/LiveElectronics/IASIAR/impulsesL/impulse" ++ ~irIdxLSet[ix] ++ ".aif" );
			s.sync;
			bufsize = PartConv.calcBufSize(~fftsize, irbuffer);
			~irSpectrum01[ix] = Buffer.alloc(s, bufsize, 1);
			~irSpectrum01[ix].preparePartConv(irbuffer, ~fftsize);
			s.sync;
			irbuffer.free;
		}.fork;
		0.1.wait;
	};
	~numImpulses.do{ |ix|
		{
			var irbuffer, bufsize;
			irbuffer = Buffer.read(s, "/Users/jyang/Dropbox/LiveElectronics/IASIAR/impulsesR/impulse" ++ ~irIdxRSet[ix] ++ ".aif" );
			s.sync;
			bufsize = PartConv.calcBufSize(~fftsize, irbuffer);
			~irSpectrum02[ix] = Buffer.alloc(s, bufsize, 1);
			~irSpectrum02[ix].preparePartConv(irbuffer, ~fftsize);
			s.sync;
			irbuffer.free;
		}.fork;
		0.1.wait;
	};

	// 2 - SET UP GROUPS & FUNCTIONS
	~ogGroup = Group.new;
	~repeatGroup = Group.new(~ogGroup, \addAfter);

	~inputOn = { arg ix;
		~liveIn1[ix].set(\gate, 1);
		~liveIn2[ix].set(\gate, 1);
	};

	~inputOff = { arg ix;
		~liveIn1[ix].set(\gate, 0);
		~liveIn2[ix].set(\gate, 0);
	};

	~impulseSynthOn = { arg ix;
		~liveIn1[ix] =	Synth("IASIARliveIn", [\inBus, 0, \outBus, 0, \gate, 1, \peakAmp, ~ampsSet[ix], \inAmp, 0.9, \fftSize, ~fftsize, \spectrumBufnum, ~irSpectrum01[ix].bufnum], ~ogGroup,\addToHead);
		~liveIn2[ix] =	Synth("IASIARliveIn", [\inBus, 1, \outBus, 1, \gate, 1, \peakAmp, ~ampsSet[ix], \inAmp, 0.9, \fftSize, ~fftsize, \spectrumBufnum, ~irSpectrum02[ix].bufnum], ~ogGroup,\addToHead);
	};

	~killSynth = { arg ix;
		Routine{
			~liveIn1[ix].set(\gate, 0);
			~liveIn2[ix].set(\gate, 0);
			7.0.wait;
			~liveIn1[ix].free;
			~liveIn2[ix].free;
		}.play;
	};


};


~buttons1 = Array.newClear(~numImpulses);
~buttons2 = Array.newClear(~numImpulses);
~numImpulses.do{ arg ix;
	~buttons1[ix] = Button(w)
	.states_([
		[ix.asString, Color.black, Color.grey],
		[ix.asString, Color.black, Color.green]
	])
	.action_({ arg but;
		if( but.value == 0,
			{~inputOff.value(ix)},
			{~inputOn.value(ix)}
		)
	})
	.minHeight_(50);

	~buttons2[ix] = Button(w)
	.states_([
		[ix.asString, Color.black, Color.grey],
		[ix.asString, Color.black, Color.red]
	])
	.action_({ arg but;
		if( but.value == 0,
			{~killSynth.value(ix); ~buttons1[ix].value_(0);},
			{~impulseSynthOn.value(ix); ~buttons1[ix].value_(1);}
		)
	})
	.minHeight_(50);
};

s.meter;
s.makeGui;
s.freqscope;

~win = Window.new( "IASIAR", bounds:Rect(200, 400, 200, 120)).layout_(
	VLayout(
		HLayout(*~buttons1),
		HLayout(*~buttons2)
	)
).front;



)


(
SynthDef( "IASIARliveIn", {
	arg inBus=0, outBus=0, peakAmp=0.7, gate=1, inAmp=1, fftSize=2048, spectrumBufnum=400;
	var input, env;
	env = EnvGen.ar(Env.asr(0.8, peakAmp, 0.25), gate, peakAmp);
	input= SoundIn.ar(inBus)*env;
	Out.ar(outBus, PartConv.ar(input*inAmp, fftSize, spectrumBufnum));
}).load(s);
)