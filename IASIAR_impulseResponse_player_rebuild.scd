//IASIAR - NOISE/INPUT DRIVEN IMPULSES THAT HAVE BEEN CONVOLVED WITH THEMSELVES AS IN I AM SITTING IN A ROOM

(
// SET INITIAL SERVER CONDITIONS ////////////////////////////////////////////////
~fftsize = 2048;
s.options.memSize = 204800;
//s.options.numOutputBusChannels_(24);
s.meter;
)
(
s.waitForBoot {

~path = thisProcess.nowExecutingPath.dirname +/+ "impulses"; //should point to a folder called "impulses" in the same folder that this document is in
~impulsenames = (~path +/+ "*").pathMatch;  //will generate an Array with the path to all of the impulse files
~numImpulses = ~impulsenames.size;  //get number of impulses from the generated ~impulsenames array
~irSpectrums = Array.newClear(~numImpulses); //make an array to hold all of the impulse response spectrum buffers


//SYNTHDEF ///////////////////////////////////////////////////////////////////////
/*SynthDef( "IASIAR", {
	arg outBus=0, amp=0.5, inAmp=1, fftSize=2048, spectrumBufnum=1, atk=0.08, sus=1.0, rel=0.1, crv=0;
	var input, trig, output, noiseenv;
	trig = \t_tr.kr(0, 0.000001);
	noiseenv = EnvGen.ar( Env.linen(atk, sus, rel, 1, crv), trig, doneAction:0 );
	//input = K2A.ar(trig)*inAmp;
	input = WhiteNoise.ar(inAmp)*noiseenv;
	//input = PinkNoise.ar(inAmp)*noiseenv;
	//input = Crackle.ar(1.95, inAmp) * noiseenv;
	output = PartConv.ar( input, fftSize, spectrumBufnum );
	DetectSilence.ar(output, 0.01, doneAction:2);
	Out.ar( outBus, output*amp );
}).add;*/

SynthDef( "IASIAR", {
	arg outBus=0, in=0, amp=0.5, inAmp=1, fftSize=2048, spectrumBufnum=1, atk=0.03, sus=1.0, rel=0.1, crv=0, gate=1;
	var input, output, env;
	env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate );
	input = SoundIn.ar(in)*inAmp;
	output = PartConv.ar( input, fftSize, spectrumBufnum );
	Out.ar( outBus, [output, output]*amp*env );
}).add;




		s.sendMsg(\g_new, 2000);

	//Prepare Impulse Response Buffers
	~numImpulses.do{ |ix|
		{
			var irbuffer, bufsize;
			irbuffer = Buffer.read(s, ~impulsenames[ix] );  //Read impulse response into a temporary buffer
			s.sync;
			bufsize = PartConv.calcBufSize(~fftsize, irbuffer);  //Calculate buffer size for the spectrum of the buffer
			~irSpectrums[ix] = Buffer.alloc(s, bufsize, 1); //Allocate a buffer for the ir spectrum
			~irSpectrums[ix].preparePartConv(irbuffer, ~fftsize); //Make spectral buffer and store in Array
			s.sync;
			irbuffer.free;  //free temp buffer

		}.fork;

		0.5.wait;  //Might have to increase this as the above takes a while depending on processor speed

	};

};
)
s.queryAllNodes

(
~iasiarSynth = Synth( \IASIAR, [
	\fftSize, ~fftsize,
	\spectrumBufnum, ~irSpectrums[0].bufnum,
	\inAmp, 0.5,
	\amp, 0.15,
] , ~g0);
)

s.sendMsg(\s_new, \IASIAR, 3000, 0, 2000, \spectrumBufnum, ~irSpectrums[0].bufnum, \inAmp, 0.5, \amp, 0.15);

s.sendMsg(\n_set, 3000, \spectrumBufnum, ~irSpectrums[3].bufnum, \inAmp, 0.00, \amp, 0)
~iasiarSynth.set(\spectrumBufnum, ~irSpectrums[2].bufnum);

//Find a way to only 4 instances of these at a time, or use multi core


( // 1
~s1 = Server.default; // assumes localhost default is already running on non-jack device
~s2 = Server( "server2", NetAddr("127.0.0.1",  57111 ) ); // add second server
~s2.options_( s.options ).boot.makeWindow;
)

( // 2
SynthDef( "test-sine", { |freq = 440, amp = 0.1, out = 0|
	Out.ar( out, SinOsc.ar( freq, 0, amp ) );
}).send; // send to both (.add doesn't work for some reason; only sends to the localhost !!)
)

( // 3
Synth( "test-sine", [\amp,  0.1], ~s1 );
Synth( "test-sine", [\amp, -0.1], ~s2 ); // cancel out the first one
)

/// we hear sound ( in 90% of the cases the synths don't cancel out each other )
// now try again from step 2 after starting Jack and this:

(
~s1.options.device = "JackRouter";
~s1.quit;
~s2.quit;
~s1.waitForBoot({ // can't start at the same moment
	~s2.boot;
});
)









