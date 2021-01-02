Engine_Fiahod : CroneEngine {
    var delayBus;
    var scale;
    var delay;

    var synths;
    var stalks;

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
		var server = Crone.server;
        var def;

        delayBus = Bus.audio(server, 2);
        scale = Scale.minorPentatonic;
        // I'm too stupid to figure out how the nested arrays work out
        // fudging it and doing a .collect
        // fix PRs welcome ;)
        "defining delay".postln;
        delay = {
            var inSig = In.ar(delayBus, 2);
            var lfoSpeeds = (4..11).nthPrime / 100;
            var delays = lfoSpeeds.collect({|lfoSpeed|
                var delayTime = SinOsc.kr(lfoSpeed, 0, 0.02 * lfoSpeeds.max / lfoSpeed, 0.1.rrand(0.9));
                var panPos = 0.3.rand2;
                var delay = AllpassL.ar(inSig, 1, 0.1.rrand(0.9), 25, 1.6);
                Pan2.ar(delay, panPos);
            });
            // inSig + Mix.ar(delays / delays.size);
            Out.ar(0, inSig + Mix.ar(delays / delays.size * 1.6));
            // Out.ar(0, CombN.kr(in: 0.0, maxdelaytime: 0.2, delaytime: 0.2, decaytime: 1.0))
            // Out.ar(0, inSig + CombN.ar(inSig, 1, 0.2, 5));
        }.play;

        "defining synth".postln;
        // def = SynthDef.new(\fiahod, {|
        SynthDef(\fiahod, {|
            amp=0.1, 
            carDust=0.5,
            delayOut, 
            delayRatio=0.8, 
            dust=0, 
            envRadius=1, 
            feedback=1, 
            filterHarmonic=1,
            freq=55, 
            modDust=2,
            modSemiOffset=0,
            pan=0,
            pw=0.5,
            rq=5,
            t_trig=0
            |

            var ampEnv = EnvGen.ar(Env.perc(envRadius, envRadius), t_trig);

            var modFreq, carFreq;
            var mod, car, sig;
            var ampDust, dustEnv, dustTrig;

            //amp = amp * brightness;
            //feedback = feedback * brightness;

            dustTrig = Dust.kr(dust).sign;
            dustEnv = EnvGen.ar(
                Env.perc(
                    Demand.kr(dustTrig, 0, Dwhite(0, 0.1)),
                    Demand.kr(dustTrig, 0, Dwhite(0.01, 0.4)),
                    Demand.kr(dustTrig, 0, Dwhite(0.1, dust / 10))
                ),
                dustTrig
            );
            ampDust = 1 - dustEnv;

            modFreq = ((freq/2).cpsmidi + modSemiOffset + (modDust * dustEnv)).midicps;
            // modFreq = freq/2;
            mod = Pulse.ar(modFreq, pw /*SinOsc.kr(pwLfoSpeed, 0, pwLfoDepth, pw) */);
            mod = BPF.ar(mod, modFreq * filterHarmonic, rq) * 4;
            // mod = (mod * 4).tanh;
            // mod = 0;
            // carFreq = (freq.cpsmidi + detuneSemi + (dustEnv * carDust)).midicps;
            // carFreq = freq;
            // car = SinOscFB.ar(carFreq, feedback * ampEnv * ampDust);
            car = SinOscFB.ar(freq, feedback * ampEnv * ampDust, amp * ampEnv);
            car = (mod.tanh * ampEnv + car.asin).sin;
            // sig = Pan2.ar(car * ampEnv * amp * ampDust, pan);
            sig = Pan2.ar(car, pan);
            Out.ar(0, sig * (1 - delayRatio));
            Out.ar(delayOut, sig * (delayRatio));
            // Out.ar(0, car ! 2);
        // });
        }).add;
        // "done defining. sending to server.".postln;
		// def.send(server); 
        "syncing with server.".postln;
		server.sync;

        // Waste CPU to support both 0- and 1- based indexing!
        stalks = (0..6);
        stalks.do({|i| this.setStalk(i) });
        synths = { Synth(\fiahod) } ! 6;
        synths.do({|i| i.postln; });

        this.addCommand("pluck_stalk", "if", {|msg|
            var index = msg[1];
            var height = msg[2];
            // "pluck stalk".postln;
            // msg.postln;
            this.pluckStalk(index, height)
        });

        this.addCommand("set_stalk", "if", {|msg|
            var index = msg[1];
            var pan = msg[2];
            "set stalk".postln;
            msg.postln;
            this.setStalk(index, pan)
        });
    }

    getParams {|index, height|
        var s, freq, overrides;
        var pw = 0.01.rrand(0.99);
        var baseParams, detuneSemi;
        // "in getParams with arguments:".postln;
        // ("index: " ++ index ++ " height: " ++ height).postln;

        detuneSemi = 0.15.rand2;
        baseParams = (
            delayRatio: 0.8,
            envRadius: 1.0.rand(6.0),
            delayOut: delayBus.index,
            modSemiOffset: detuneSemi * 2,
            pw: pw,
            pwLfoDepth: 0.0.rrand(0.5 - (0.5 - pw).abs),
            pwLfoSpeed: 0.01.rrand(0.8),
            rq: 0.01.rrand(0.2),
            carDust: 1.0.rand2,
            modDust: 5.0.rand2,
        );
        // "getParams has set up base params".postln;

        s = stalks[index];
        // "getParams setting frequency with arguments (scale, s, s.degrees, s.degreeindex):".postln;
        // scale.postln;
        // s.postln;
        // s.degrees.postln;
        // s.degreeIndex.postln;
        freq = scale.degreeToFreq(
            s.degrees[s.degreeIndex],
            55, // root note
            -1 // octave (REQUIRED)
        );
        // "getParams has set up first part of frequency".postln;
        freq = (freq.cpsmidi + detuneSemi).midicps;
        // "getParams has set up frequency".postln;
        overrides = (
            freq: freq, 
            feedback: 0.9.rrand(2.0) * (128 - freq.cpsmidi / 128 ** 0.5),
            dust: s.dust, 
            pan: s.pan, 
            amp: height / 40 ** 0.7 * 0.3,
            filterHarmonic: 1.rrand(7) / 2,
            t_trig: 1
        );
        // "getParams has set up overrides".postln;

        ^ baseParams ++ overrides;
    }

    pluckStalk {|index, height|
        // "in pluckStalk".postln;
        if(1.0.rand < 0.6, {
            var params; 
            // ("calling getParams with index " ++ index ++ " and height " ++ height).postln;
            params = this.getParams(index, height);
            // ("plucking stalk " ++ index ++ " with frequency " ++ params.freq).postln;
            // "got params. they are:".postln;
            // params.class.postln;
            // params.postln;
            synths[index].set(*params.getPairs);

            stalks[index].degreeIndex = stalks[index].degreeIndex + 1 % stalks[index].degrees.size;
            stalks[index].dust = 2.0.rand;
        });
    }

    setStalk {|index, pan=0|
        var degreeRange = (0..0.rrand(3));
        stalks[index] = (
            pan: pan, 
            degrees: 3 + (scale.size * 4).rand + degreeRange,
            degreeIndex: degreeRange.choose,
            dust: 2.0.rrand(20.0)
        );
        ("made new stalk at index " ++ index).postln;
        stalks[index].postln;
    }

    free {
        delay.free;
        synths.do({|s| s.free });
    }
}