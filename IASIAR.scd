s.options.memSize = 81920;
s.boot;
s.meter;


SynthDef("IASIAR",{
arg inbus = 0, deltime = 50.0, outbus=0;
	var sig, delsig;
	sig = SoundIn.ar(inbus);
	delsig = DelayN.ar(sig, 120.0, deltime);
	Out.ar(outbus, delsig);
}).add;

s.prepareForRecord;
(
s.bind({
	a = Synth(\IASIAR, [\deltime, 5.0]);
	s.record;
});
)

s.pauseRecording;
s.record;
s.stopRecording;