# Premade library sources — 0.6.0

Research date: November 9, 2026 (America/Chicago).
Target: Forever 1.60.1 build 70862 / interface 16001.

76 original compact implementations: eight entries for each of nine classes,
and four shared utility entries. These are bundled offline in Premades.lua.
The library is not an import of guide prose or a claim of guide endorsement.

## Class research

The linked authors publish Forever-specific class macro ideas and code. They
distinguish data inspection from in-game tests. MacroForge likewise does not
claim runtime verification. Each class entry links its corresponding source:

- Druid: https://foreverdb.net/class/Druid/macros
- Warrior: https://foreverdb.net/class/Warrior/macros
- Mage: https://foreverdb.net/class/Mage/macros
- Priest: https://foreverdb.net/class/Priest/macros
- Paladin: https://foreverdb.net/class/Paladin/macros
- Hunter: https://foreverdb.net/class/Hunter/macros
- Rogue: https://foreverdb.net/class/Rogue/macros
- Warlock: https://foreverdb.net/class/Warlock/macros
- Shaman: https://foreverdb.net/class/Shaman/macros

Shared utility inspiration:
https://muchamielwow.github.io/en/comunes/

Additional overview consulted for the common macro patterns:
https://undying.app/guides/macros

The Icy Veins Forever class-guide index was inspected, but is not cited as the
source of macros taken from specific guides that were not reviewed:
https://www.icy-veins.com/wow-forever/class-guides

## Implementation choices and limits

- Original concise notes and macro builders, rather than copied guide text.
- Fixed spell candidates are localized through runtime spell information and
  checked against learned families. Unknown/missing spell data blocks creation.
- Talent-only or later-level spells stay listed but cannot generate until known.
- Form/stance candidates are matched to the live bar; indices are never guessed.
- Entries needing equipment, reagents, correct creature type, range, a pet,
  positional rules or stealth still require those conditions in normal gameplay.
- No cooldown-based rotations, automated decisions, `/run` scripts or protected
  action calls from addon Lua. Every action is in a player-pressed native macro.
- Cursor and channel commands, pet controls, supported toggle protection and
  class transitions still need the player's in-game verification.
- No networking or live scraping in the addon. Source URLs are copyable text.
- Existing duplicate/body/name/capacity/combat checks apply to premades. Browsing,
  opening a preview or closing it never calls CreateMacro.
- Form/stance switching can take one press and the ability a later press.
  No two-global-cooldown cast guarantee is made.
- No tests or simulations were run for this release, per user instruction.
