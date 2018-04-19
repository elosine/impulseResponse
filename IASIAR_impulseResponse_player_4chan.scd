
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

	~path_0 = thisProcess.nowExecutingPath.dirname +/+ "impulses_0"; //should point to a folder called "impulses" in the same folder that this document is in
	~impulsenames_0 = (~path_0 +/+ "*").pathMatch;  //will generate an Array with the path to all of the impulse files
	~numImpulses = ~impulsenames_0.size;  //get number of impulses from the generated ~impulsenames array
	~irSpectrums_0 = Array.newClear(~numImpulses); //make an array to hold all of the impulse response spectrum buffers

	~path_1 = thisProcess.nowExecutingPath.dirname +/+ "impulses_1";
	~impulsenames_1 = (~path_1 +/+ "*").pathMatch;
	~irSpectrums_1 = Array.newClear(~numImpulses);

	~path_2 = thisProcess.nowExecutingPath.dirname +/+ "impulses_2";
	~impulsenames_2 = (~path_2 +/+ "*").pathMatch;
	~irSpectrums_2 = Array.newClear(~numImpulses);

	~path_3 = thisProcess.nowExecutingPath.dirname +/+ "impulses_3";
	~impulsenames_3 = (~path_3 +/+ "*").pathMatch;
	~irSpectrums_3 = Array.newClear(~numImpulses);

	SynthDef( "IASIAR", {
		arg outBus=0, in=0, amp=0.4, inAmp=0.4, fftSize=2048, spectrumBufnum0=0, spectrumBufnum1=1, spectrumBufnum2=2, spectrumBufnum3=3, atk=0.03, sus=1.0, rel=3.1, crv=0, gate=1;
		var input, output0, output1, output2, output3, env;
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate, doneAction:2 );
		input = SoundIn.ar(in)*inAmp;
		output0 = PartConv.ar( input, fftSize, spectrumBufnum0 );
		output1 = PartConv.ar( input, fftSize, spectrumBufnum1 );
		output2 = PartConv.ar( input, fftSize, spectrumBufnum2 );
		output3 = PartConv.ar( input, fftSize, spectrumBufnum3 );
		Out.ar( outBus, [output0, output1, output2, output3]*amp*env );
	}).add;

	//Prepare Impulse Response Buffers
	fork{
		~numImpulses.do{ |ix|
			var irbuffer, bufsize;
			irbuffer = Buffer.read(s, ~impulsenames_0[ix] );  //Read impulse response into a temporary buffer
			s.sync;
			bufsize = PartConv.calcBufSize(2048, irbuffer);  //Calculate buffer size for the spectrum of the buffer
			~irSpectrums_0[ix] = Buffer.alloc(s, bufsize, 1); //All1ocate a buffer for the ir spectrum
			~irSpectrums_0[ix].preparePartConv(irbuffer, 2048); //Make spectral buffer and store in Array
			s.sync;
			irbuffer.free;  //free temp buffer

			2.5.wait; //Might have to increase this as the above takes a while depending on processor speed
		};
		5.wait;
		~numImpulses.do{ |ix|
			var irbuffer, bufsize;
			irbuffer = Buffer.read(s, ~impulsenames_1[ix] );  //Read impulse response into a temporary buffer
			s.sync;
			bufsize = PartConv.calcBufSize(2048, irbuffer);  //Calculate buffer size for the spectrum of the buffer
			~irSpectrums_1[ix] = Buffer.alloc(s, bufsize, 1); //Allocate a buffer for the ir spectrum
			~irSpectrums_1[ix].preparePartConv(irbuffer, 2048); //Make spectral buffer and store in Array
			s.sync;
			irbuffer.free;  //free temp buffer

			2.5.wait; //Might have to increase this as the above takes a while depending on processor speed
		};
		5.wait;
		~numImpulses.do{ |ix|
			var irbuffer, bufsize;
			irbuffer = Buffer.read(s, ~impulsenames_2[ix] );  //Read impulse response into a temporary buffer
			s.sync;
			bufsize = PartConv.calcBufSize(2048, irbuffer);  //Calculate buffer size for the spectrum of the buffer
			~irSpectrums_2[ix] = Buffer.alloc(s, bufsize, 1); //Allocate a buffer for the ir spectrum
			~irSpectrums_2[ix].preparePartConv(irbuffer, 2048); //Make spectral buffer and store in Array
			s.sync;
			irbuffer.free;  //free temp buffer

			2.5.wait; //Might have to increase this as the above takes a while depending on processor speed
		};
		5.wait;
		~numImpulses.do{ |ix|
			var irbuffer, bufsize;
			irbuffer = Buffer.read(s, ~impulsenames_3[ix] );  //Read impulse response into a temporary buffer
			s.sync;
			bufsize = PartConv.calcBufSize(2048, irbuffer);  //Calculate buffer size for the spectrum of the buffer
			~irSpectrums_3[ix] = Buffer.alloc(s, bufsize, 1); //Allocate a buffer for the ir spectrum
			~irSpectrums_3[ix].preparePartConv(irbuffer, 2048); //Make spectral buffer and store in Array
			s.sync;
			irbuffer.free;  //free temp buffer

			2.5.wait; //Might have to increase this as the above takes a while depending on processor speed
		};
	};

	{Server.default.makeGui;}.defer;


	~syix = 3000;

	{
		w = Window.new("Impulse Responses");
		w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
			char.postln;
			switch( unicode,
				49, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnum0, ~irSpectrums_0[0].bufnum, \spectrumBufnum1, ~irSpectrums_1[0].bufnum, \spectrumBufnum2, ~irSpectrums_2[0].bufnum, \spectrumBufnum3, ~irSpectrums_3[0].bufnum);
				},
				50, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnum0, ~irSpectrums_0[1].bufnum, \spectrumBufnum1, ~irSpectrums_1[1].bufnum, \spectrumBufnum2, ~irSpectrums_2[0].bufnum, \spectrumBufnum3, ~irSpectrums_3[0].bufnum);
				},
				51, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnum0, ~irSpectrums_0[2].bufnum, \spectrumBufnum1, ~irSpectrums_1[2].bufnum, \spectrumBufnum2, ~irSpectrums_2[0].bufnum, \spectrumBufnum3, ~irSpectrums_3[0].bufnum);
				},
				52, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnum0, ~irSpectrums_0[3].bufnum, \spectrumBufnum1, ~irSpectrums_1[3].bufnum, \spectrumBufnum2, ~irSpectrums_2[0].bufnum, \spectrumBufnum3, ~irSpectrums_3[0].bufnum);
				},
				53, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnum0, ~irSpectrums_0[4].bufnum, \spectrumBufnum1, ~irSpectrums_1[4].bufnum, \spectrumBufnum2, ~irSpectrums_2[0].bufnum, \spectrumBufnum3, ~irSpectrums_3[0].bufnum);
				},
				54, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnum0, ~irSpectrums_0[5].bufnum, \spectrumBufnum1, ~irSpectrums_1[5].bufnum, \spectrumBufnum2, ~irSpectrums_2[0].bufnum, \spectrumBufnum3, ~irSpectrums_3[0].bufnum);
				},
				55, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnum0, ~irSpectrums_0[6].bufnum, \spectrumBufnum1, ~irSpectrums_1[6].bufnum, \spectrumBufnum2, ~irSpectrums_2[0].bufnum, \spectrumBufnum3, ~irSpectrums_3[0].bufnum);
				},
				56, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnum0, ~irSpectrums_0[7].bufnum, \spectrumBufnum1, ~irSpectrums_1[7].bufnum, \spectrumBufnum2, ~irSpectrums_2[0].bufnum, \spectrumBufnum3, ~irSpectrums_3[0].bufnum);
				},
				57, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnum0, ~irSpectrums_0[8].bufnum, \spectrumBufnum1, ~irSpectrums_1[8].bufnum, \spectrumBufnum2, ~irSpectrums_2[0].bufnum, \spectrumBufnum3, ~irSpectrums_3[0].bufnum);
				},
				48, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnum0, ~irSpectrums_0[9].bufnum, \spectrumBufnum1, ~irSpectrums_1[9].bufnum, \spectrumBufnum2, ~irSpectrums_2[0].bufnum, \spectrumBufnum3, ~irSpectrums_3[0].bufnum);
				},
				113, { s.sendMsg(\n_set, ~syix, \gate, 0); ~syix = ~syix+1; s.sendMsg(\s_new, \IASIAR, ~syix, 0, 2000, \spectrumBufnum0, ~irSpectrums_0[10].bufnum, \spectrumBufnum1, ~irSpectrums_1[10].bufnum, \spectrumBufnum2, ~irSpectrums_2[0].bufnum, \spectrumBufnum3, ~irSpectrums_3[0].bufnum); //'q'
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

