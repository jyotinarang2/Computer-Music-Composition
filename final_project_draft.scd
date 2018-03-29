//g = { PinkNoise.ar(0.01) }.play;
(

var midi, dur, midi1, dur1, midi2, dur2, midi3, dur3;

midi = Routine({
    [60, 64, 65, 67, 68, 67, 65, 67, 65, 64, 65, 67, 68, 67, 65, 67  ].do({ |midi| midi.yield });
});
dur = Routine({
    [0.5,0.30, 0.30, 0.5, 0.25, 0.50, 0.5, 0.5, 0.25, 0.5, 0.5, 0.5, 0.25, 0.5, 0.5,0.5].do({ |dur| dur.yield });
});
midi1 = Routine({
    [60, 64, 65, 67, 68, 67, 65, 67, 65, 64, 65, 64, 61, 64, 61, 60  ].do({ |midi1| midi1.yield });
});

dur1 = Routine({
    [0.25,0.30, 0.30, 0.5, 0.25, 0.50, 0.25, 0.5, 0.25, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,0.5].do({ |dur1| dur1.yield });
});
midi2 = Routine({
    [62, 66, 67, 69, 70, 69, 67, 69, 67, 66, 67, 69, 70, 69, 67, 69  ].do({ |midi2| midi2.yield });
});
dur2 = Routine({
    [0.25,0.30, 0.30, 0.5, 0.25, 0.50, 0.5, 0.5, 0.25, 0.5, 0.5, 0.5, 0.25, 0.5, 0.5,0.5].do({ |dur2| dur2.yield });
});
midi3 = Routine({
    [62, 66, 67, 69, 70, 69, 67, 69, 67, 66, 67, 66, 63, 66, 63, 62  ].do({ |midi3| midi3.yield });
});

dur3 = Routine({
    [0.25,0.30, 0.30, 0.5, 0.25, 0.50, 0.25, 0.5, 0.25, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,0.5].do({ |dur3| dur3.yield });
});




r = Task({
    var delta;
    while {
        delta = dur.next;
        delta.notNil
    } {
        Synth(\smooth, [freq: midi.next.midicps, sustain: delta]);
        delta.yield;
    }
});




t = Task({
    var delta1;
    while {
        delta1 = dur1.next;
        delta1.notNil
    } {
        Synth(\smooth, [freq: midi1.next.midicps, sustain: delta1]);
        delta1.yield;
    }
});

l = Task({
    var delta;
    while {
        delta = dur2.next;
        delta.notNil
    } {
        Synth(\smooth, [freq: midi2.next.midicps, sustain: delta]);
        delta.yield;
    }
});
m = Task({
    var delta;
    while {
        delta = dur3.next;
        delta.notNil
    } {
		Synth(\smooth, [freq: midi3.next.midicps, sustain: delta]);
        delta.yield;
    }
});
//PinkNoise.ar(0.01).play;
r.play(quant: TempoClock.default.beats + 1.0);
t.play(quant: TempoClock.default.beats + 8.0);
l.play(quant: TempoClock.default.beats + 16.0);
m.play(quant: TempoClock.default.beats + 24.0);
)

