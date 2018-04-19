s.options.memSize = 81920;
s.boot;

SynthDef("IASIAR",{
arg inbus = 0, deltime = 50.0, outbus=0, gate=1;
	var sig, delsig, env;
	env = EnvGen.ar(Env.asr(0.03, 1, 13), gate, doneAction:2);
	sig = SoundIn.ar(inbus);
	delsig = DelayN.ar(sig, 120.0, deltime);
	Out.ar(outbus, delsig*env);
}).add;


a = Synth(\IASIAR, [\deltime, 5.0]);
a.set(\gate, 0);



