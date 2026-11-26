-- Cairns sound: readable scores compiled into pico8/cairns.p8 by `make music`
-- (tools/sfx.lua, which explains the notation).
--
-- sfx 0-7 are the sound effects (kept soft and low: mostly sine tones at
-- volume 1-3 with fades, and stone sounds made of a dull noise tick over a
-- low falling triangle rather than bright blips).
-- sfx 8+ is the background music: one calm, original chord loop for an island
-- in the wind (open maj7 voicings, sus4 lifts), "high moor" in G major,
-- music(0), played on the title screen and in game alike. No lead melody: a
-- soft plucked sine harp arpeggio on channel 0 and a root/fifth triangle bass
-- on channel 1. Channels 2-3 stay free for sfx.

return {
  first_sfx = 8,

  effects = {
    -- a quiet sine lift, and the same falling back
    { name = "pick up", speed = 2, notes = "a2:0:2:0 e3:0:3:0 e3:0:2:5" },
    { name = "put down", speed = 2, notes = "e3:0:2:0 a2:0:2:0 a2:0:1:5" },
    -- gravel under a rolling stone, played once per square
    { name = "roll", speed = 5, notes = "c0:6:2:0 c0:6:1:0 c0:6:1:5" },
    -- stone on stone: a dull tick and a low thump
    { name = "stack", speed = 2, notes = "f3:6:2:5 c1:1:3:3 c1:1:1:5" },
    -- a small bell on an open fifth, ringing out with a little vibrato
    { name = "flag", speed = 6, notes = "a3:0:3:0 e4:0:2:0 e4:0:2:2 e4:0:1:5" },
    -- a muted thud when a piece can't go that way
    { name = "bump", speed = 5, notes = "a0:1:3:3 a0:1:1:5" },
    -- a soft downward glide
    { name = "undo", speed = 3, notes = "e3:0:2:0 b2:0:2:1 b2:0:1:5" },
    -- a slow, quiet G major 9 arpeggio, in the key of the song
    { name = "solved", speed = 10,
      notes = "g2:0:3:0 d3:0:3:0 a3:0:3:0 b3:0:3:0 f#4:0:2:0 f#4:0:2:2 f#4:0:1:2 f#4:0:1:5" },
  },

  songs = {
    {
      name = "song", title = "high moor", speed = 50,
      patterns = {
        a = { "gmaj7", "em7", "cmaj7", "dsus4/d7" },
        a2 = { "gmaj7", "bm7", "cmaj7", "am7/d7" },
        b = { "em7", "cmaj7", "am7", "dsus4/d7" },
        coda = { "gmaj7", "cmaj7", "am7/d7", "gmaj" },
      },
      order = { "a", "a2", "b", "coda" },
    },
  },
}
