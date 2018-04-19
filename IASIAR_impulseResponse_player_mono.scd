
//Evaluate below
//Use keys 1-9 to change spaces
//See assignment for space description
(
// SET INITIAL SERVER CONDITIONS ////////////////////////////////////////////////
//s.options.memSize = 81920;
// s.options.memSize = 32768;
 s.options.memSize = 163840;

s.waitForBoot{ fork{
	s.sendMsg(\g_new, 2000);

	~path_L = thisProcess.nowExecutingPath.dirname +/+ "impulses_L"; //should point to a folder called "impulses" in the same folder that this document is in
	~impulsenames_L = (~path_L +/+ "*").pathMatch;  //will generate an Array with the path to all of the impulse files
	~numImpulses = ~impulsenames_L.size;  //get number of impulses from the generated ~impulsenames array
	~irSpectrums_L = Array.newClear(~numImpulses); //make an array to hold all of the impulse response spectrum buffers

	SynthDef( /IASIAR_mono, {
		arg outBus=0, in=0, amp=0.4, inAmp=0.4, fftSize=2048, spectrumBufnumL=0, spectrumBufnumR=0, atk=0.03, sus=1.0, rel=3.1, crv=0, gate=1;
		var input, outputL, env;
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate, doneAction:2 );
		input = SoundIn.ar(in)*inAmp;
		outputL = PartConv.ar( input, fftSize, spectrumBufnumL );
		Out.ar( outBus, outputL*amp*env );
	}).add;

	//Prepare Impulse Response Buffers
	fork{
		~numImpulses.do{ |ix|
			var irbuffer, bufsize;
			irbuffer = Buffer.read(s, ~impulsenames_L[ix] );  //Read impulse response into a temporary buffer
			s.sync;
			bufsize = PartConv.calcBufSize(2048, irbuffer);  //Calculate buffer size for the spectrum of the buffer
			~irSpectrums_L[ix] = Buffer.alloc(s, bufsize, 1); //All1ocate a buffer for the ir spectrum
			~irSpectrums_L[ix].preparePartConv(irbuffer, 2048); //Make spectral buffer and store in Array
			s.sync;
			irbuffer.free;  //free temp buffer

			0.5.wait; //Might have to increase this as the above takes a while depending on processor speed
		};
		1.wait;

	};

	{Server.default.makeGui;}.defer;

	~syix = 3000;

	{
		w = Window.new("Impulse Responses");
		w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
			switch( unicode,
				49, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnumL, ~irSpectrums_L[0].bufnum);
				},
				50, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnumL, ~irSpectrums_L[1].bufnum);
				},
				51, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnumL, ~irSpectrums_L[2].bufnum);
				},
				52, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnumL, ~irSpectrums_L[3].bufnum);
				},
				53, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnumL, ~irSpectrums_L[4].bufnum);
				},
				54, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnumL, ~irSpectrums_L[5].bufnum\);
				},
				55, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnumL, ~irSpectrums_L[6].bufnum);
				},
				56, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnumL, ~irSpectrums_L[7].bufnum);
				},
				57, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnumL, ~irSpectrums_L[8].bufnum);
				},
				48, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnumL, ~irSpectrums_L[9].bufnum);
				},
				113, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnumL, ~irSpectrums_L[10].bufnum); //'q'
				}

			);
		};
		w.front;
	}.defer;
}}
)

w = Window.new("Impulse Responses");
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode; unicode.postln};
w.front

