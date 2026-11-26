-- Cairns sound: readable scores compiled into the cart's __sfx__ and
-- __music__ sections.
--
--   luajit tools/music.lua              rewrite pico8/cairns.p8
--   luajit tools/music.lua --check      fail if the cart is out of date
--
-- sfx 0-7 are the sound effects (the `effects` table below), sfx 8+ the
-- background music: two calm, original chord loops for an island in the
-- wind (open maj7 voicings, sus4 lifts):
--   title  "high moor"   music(0)  G major
--   game   "sea breeze"  music(G)  D major
-- No lead melody: a soft plucked sine harp arpeggio on channel 0 and a
-- root/fifth triangle bass on channel 1. Channels 2-3 stay free for sfx.

local CART = "pico8/cairns.p8"
local FIRST_SFX = 8

local HARP = { wave = 0, vol = 3 }
local BASS = { wave = 1, vol = 4 }

-------------------------------------------------------------------------------
-- score
-------------------------------------------------------------------------------
-- Four bars per pattern. Chords: one per bar, or two "a/b" sharing the bar.
local chord_tones = {
  maj7 = { 0, 4, 7, 11 }, m7 = { 0, 3, 7, 10 }, ["7"] = { 0, 4, 7, 10 },
  ["6"] = { 0, 4, 7, 9 }, m6 = { 0, 3, 7, 9 }, sus4 = { 0, 5, 7, 12 },
  maj = { 0, 4, 7, 12 },
}

-------------------------------------------------------------------------------
-- sound effects, sfx 0-7
-------------------------------------------------------------------------------
-- One string of notes per effect: "pitch:wave:volume:effect", "-" for a rest.
-- Pitches are PICO-8 tracker notes (c0 is the lowest). Waves: 0 sine,
-- 1 triangle, 2 saw, 3 square, 4 pulse, 5 organ, 6 noise, 7 phaser.
-- Effects: 0 none, 1 slide, 2 vibrato, 3 drop, 4 fade in, 5 fade out.
local effects = {
  { name = "pick up", speed = 3, notes = "e2:1:5:0 a2:1:5:0 e3:1:4:5" },
  { name = "put down", speed = 3, notes = "e3:1:4:0 a2:1:4:0 e2:1:3:5" },
  { name = "roll", speed = 4, notes = "c1:6:4:0 a0:6:3:0 c1:6:2:5" },
  { name = "stack", speed = 3, notes = "g1:1:6:0 d1:1:5:0 c1:6:4:0 c1:6:2:5" },
  { name = "flag", speed = 5, notes = "c3:5:5:0 e3:5:5:0 g3:5:5:0 c4:5:5:0 c4:5:4:0 c4:5:2:5" },
  { name = "bump", speed = 4, notes = "c1:2:5:0 a#0:2:4:0 a0:2:3:5" },
  { name = "undo", speed = 3, notes = "g3:1:4:0 e3:1:4:0 c3:1:3:5" },
  { name = "solved", speed = 7,
    notes = "g2:5:5:0 c3:5:5:0 e3:5:5:0 g3:5:6:0 g3:5:5:0 - e3:5:5:0 g3:5:5:0 c4:5:6:0 c4:5:5:0 c4:5:4:0 c4:5:2:5" },
}

-------------------------------------------------------------------------------
-- music, sfx 8+
-------------------------------------------------------------------------------
local songs = {
  {
    name = "title", title = "high moor", speed = 50,
    patterns = {
      a = { "gmaj7", "em7", "cmaj7", "dsus4/d7" },
      a2 = { "gmaj7", "bm7", "cmaj7", "am7/d7" },
      b = { "em7", "cmaj7", "am7", "dsus4/d7" },
      coda = { "gmaj7", "cmaj7", "am7/d7", "gmaj" },
    },
    order = { "a", "a2", "b", "coda" },
  },
  {
    name = "game", title = "sea breeze", speed = 44,
    patterns = {
      a = { "dmaj7", "gmaj7", "dmaj7", "em7/a7" },
      a2 = { "dmaj7", "bm7", "gmaj7/gm6", "em7/a7" },
      b = { "gmaj7", "f#m7", "em7", "a7" },
      b2 = { "cmaj7", "gmaj7", "cmaj7", "asus4/amaj" },
      coda = { "dmaj7", "gmaj7", "em7/a7", "dmaj" },
    },
    order = { "a", "a2", "b", "b2", "a", "coda" },
  },
}

-------------------------------------------------------------------------------
-- compiler
-------------------------------------------------------------------------------
local semis = { c = 0, d = 2, e = 4, f = 5, g = 7, a = 9, b = 11 }

local function parse_chord(c)
  local root, acc, q = c:match("^(%a)(#?)(.*)$")
  return semis[root] + (acc == "#" and 1 or 0), assert(chord_tones[q], "bad chord " .. c)
end

local function blank()
  local t = {}
  for i = 1, 32 do t[i] = { pitch = 0, wave = 0, vol = 0, fx = 0 } end
  return t
end

local function put(t, i, pitch, voice, fx, vol)
  t[i] = { pitch = pitch, wave = voice.wave, vol = vol or voice.vol, fx = fx or 0 }
end

-- harp: plucked broken chords around C3..E4; bass: root/fifth bounce in
-- octave 2. Pitches are PICO-8's: C2 = 0, so C3 = 12.
local harp_full = { 1, 2, 3, 4, 6, 4, 3, 2 } -- 5,6 = chord tones 1,2 an octave up
local harp_half = { 1, 3, 4, 6 }

local function compile_backing(chords)
  assert(#chords == 4, "pattern is not 4 bars")
  local harp, bass = blank(), blank()
  for b, spec in ipairs(chords) do
    local parts = {}
    for c in spec:gmatch("[^/]+") do parts[#parts + 1] = c end
    local base = (b - 1) * 8
    for h, c in ipairs(parts) do
      local root, tones = parse_chord(c)
      local r3 = root + 12
      local seq = #parts == 1 and harp_full or harp_half
      local at = base + (h - 1) * #seq
      for k, idx in ipairs(seq) do
        local p = idx > 4 and tones[idx - 4] + 12 or tones[idx]
        put(harp, at + k, r3 + p, HARP, 5, k == 1 and HARP.vol or HARP.vol - 1)
      end
      local fifth = root + 7 >= 12 and root - 5 or root + 7
      if #parts == 1 then
        put(bass, at + 1, root, BASS); put(bass, at + 2, root, BASS); put(bass, at + 3, root, BASS, 5)
        put(bass, at + 5, fifth, BASS, 0, 3); put(bass, at + 6, fifth, BASS, 5, 3)
        put(bass, at + 7, root + 12, BASS, 0, 3); put(bass, at + 8, root + 12, BASS, 5, 3)
      else
        put(bass, at + 1, root, BASS); put(bass, at + 2, root, BASS); put(bass, at + 3, root, BASS, 5)
        put(bass, at + 4, fifth, BASS, 5, 3)
      end
    end
  end
  return harp, bass
end

-- "c#3:1:5:0" style notes into sfx note tables
local function compile_effect(e)
  local notes = blank()
  local i = 0
  for tok in e.notes:gmatch("%S+") do
    i = i + 1
    assert(i <= 32, e.name .. " has more than 32 notes")
    if tok ~= "-" then
      local name, acc, oct, w, v, fx = tok:match("^(%a)(#?)(%d):(%d):(%d):(%d)$")
      assert(name, "bad note " .. tok .. " in " .. e.name)
      local pitch = semis[name] + (acc == "#" and 1 or 0) + 12 * tonumber(oct)
      assert(pitch <= 63, "note too high in " .. e.name)
      notes[i] = { pitch = pitch, wave = tonumber(w), vol = tonumber(v), fx = tonumber(fx) }
    end
  end
  return notes
end

local function sfx_line(notes, speed)
  local s = string.format("00%02x0000", speed)
  for _, n in ipairs(notes) do
    s = s .. string.format("%02x%x%x%x", n.pitch, n.wave, n.vol, n.fx)
  end
  return s
end

-- Compile songs into sfx lines (from FIRST_SFX) and music lines. Each song
-- loops on itself; `starts[name]` is its first music pattern.
local function build(list)
  local sfx, music, starts = {}, {}, {}
  local function add(line)
    for i, l in ipairs(sfx) do
      if l == line then return FIRST_SFX + i - 1 end
    end
    sfx[#sfx + 1] = line
    return FIRST_SFX + #sfx - 1
  end
  for _, song in ipairs(list) do
    local speed = song.speed
    local ids = {}
    starts[song.name] = #music
    for i, name in ipairs(song.order) do
      if not ids[name] then
        local harp, bass = compile_backing(assert(song.patterns[name], "no pattern " .. name))
        ids[name] = { add(sfx_line(harp, speed)), add(sfx_line(bass, speed)) }
      end
      local flags = (i == 1 and 1 or 0) + (i == #song.order and 2 or 0)
      local c = ids[name] -- channels 2-3 off (0x40), left free for sfx
      music[#music + 1] = string.format("%02x %02x%02x4040", flags, c[1], c[2])
    end
  end
  assert(FIRST_SFX + #sfx <= 64, "out of sfx slots")
  return sfx, music, starts
end

-------------------------------------------------------------------------------
-- cart i/o
-------------------------------------------------------------------------------
local function read(path)
  local f = assert(io.open(path, "rb"))
  local s = f:read("*a")
  f:close()
  return s
end

local function split_sections(src)
  local head, sections, order, cur = {}, {}, {}, nil
  for l in src:gmatch("([^\n]*)\n") do
    local name = l:match("^__(%w+)__$")
    if name then
      cur = {}
      sections[name] = cur
      order[#order + 1] = name
    elseif cur then
      cur[#cur + 1] = l
    else
      head[#head + 1] = l
    end
  end
  for n, body in pairs(sections) do sections[n] = table.concat(body, "\n") end
  return table.concat(head, "\n") .. "\n", sections, order
end

local function updated_cart(src, sfx, music)
  local head, sections, order = split_sections(src)
  local out = {}
  assert(#effects <= FIRST_SFX, "too many sound effects")
  local empty = "00010000" .. string.rep("00000", 32)
  for i = 1, FIRST_SFX do
    local e = effects[i]
    out[i] = e and sfx_line(compile_effect(e), e.speed) or empty
  end
  for i, l in ipairs(sfx) do out[FIRST_SFX + i] = l end
  sections.sfx = table.concat(out, "\n")
  sections.music = table.concat(music, "\n")
  local has_music = false
  for _, n in ipairs(order) do has_music = has_music or n == "music" end
  if not has_music then order[#order + 1] = "music" end
  local parts = { head }
  for _, n in ipairs(order) do
    parts[#parts + 1] = "__" .. n .. "__\n" .. sections[n] .. "\n"
  end
  return table.concat(parts)
end

local sfx, music, starts = build(songs)
local src = read(CART)
local new = updated_cart(src, sfx, music)

if arg[1] == "--check" then
  if new ~= src then
    io.stderr:write("pico8/cairns.p8 sound is stale: run `make music`\n")
    os.exit(1)
  end
  local main = read("pico8/main.lua")
  if not main:find("music%(" .. starts.game .. ",") then
    io.stderr:write("pico8/main.lua should call music(" .. starts.game .. ", ...) for the game song\n")
    os.exit(1)
  end
  print(string.format("music  %d patterns (game starts at %d), sfx %d-%d, up to date",
    #music, starts.game, FIRST_SFX, FIRST_SFX + #sfx - 1))
else
  if new ~= src then
    local f = assert(io.open(CART, "wb"))
    f:write(new)
    f:close()
    print("updated " .. CART)
  end
  print("game music starts at pattern " .. starts.game)
end
