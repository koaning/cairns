-- levels.lua
-- the puzzles, in order: { name, fewest moves, board }.
-- the board is 7 squares wide and 5 deep, rows split by "|",
-- the first row is the far side:
--   .  grass   t  pine tree
--   l  big stone   m  small stone   h  flag
-- tests/test_rules.lua solves every level and checks the
-- fewest moves, so keep it right when adding one.
-- (the layouts are snowstack's, from koaning/ps-love2d.)

levels = {
  { "flag day", 2, ".......|...h...|...l...|...m...|......." },
  { "pine stop", 4, ".......|.m.t...|.......|..lh...|......." },
  { "bump", 6, ".......|...l.t.|..m....|.......|..t.h.." },
  { "long way round", 7, ".......|.......|...tm..|.h.....|..t.l.." },
  { "thicket", 9, ".......|.m..t..|.t.....|.....l.|..th..." },
  { "switchback", 10, ".......|.....t.|..t....|.....m.|..th.l." },
  { "either side", 11, ".......|..ltl..|.......|..h.h..|..m.m.." },
  { "two of a kind", 12, ".......|.hml...|.....h.|..m....|.t..l.." },
  { "four pines", 14, "t.....t|.h...h.|.......|.m...m.|t.l.l.t" },
  { "crosswind", 16, ".......|....t..|.h...h.|..tlml.|...m..." },
  { "close ranks", 16, "..l.l..|t.m.m.t|...t...|.h...h.|t.....t" },
  { "wet feet", 17, ".......|.l.ht..|.t...l.|.h.....|.m...m." },
  { "stone circle", 17, ".......|.h.hl..|..mm...|...l.h.|.m...l." },
  { "back to back", 19, "...t...|.......|.hm.mh.|t.....t|.l...l." },
  { "flag to flag", 20, "t.m...t|......m|.......|lh..h..|t...l.t" },
  { "gale", 24, ".......|.m..ml.|.l...l.|.h.m...|.h..h.." },
  { "far shores", 26, "t.mh..t|.......|....h..|l......|t...lmt" },
}
