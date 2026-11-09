# Compatibility record

Target from user's in-game screenshot: Forever 1.60.1 (70862), interface 16001,
built November 6, 2026. Executable inspection matched. No in-game addon run has
been performed by Codex.

## Evidence and sources

Installed WhatsTraining uses C_SpellBook skill lines and FutureSpell items;
installed RXPGuides uses CreateMacro/GetNumMacros. This is evidence of API usage,
not evidence that MacroForge passed runtime tests. No third-party addon code or
spell catalogs were bundled.

Public Blizzard UI source mirror, Forever branch, consulted November 9, 2026:

- https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SpellBookDocumentation.lua
- https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SpellDocumentation.lua
- https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/MacroConstantsDocumentation.lua
- https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_MacroUI
- https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_FrameXML

These are version notes and syntax references for original bundled templates.
Templates are assembled using the selected localized spell name. Focus is a
hostile focus fallback; mouseover is friendly mouseover fallback; Alt targets
self; stopcasting interrupts your own current cast. Choose appropriate spells.
No guide scraping or copied guide templates were used.

## Runtime decisions

- Modern C_Spell / C_SpellBook first; guarded legacy fallbacks.
- Rank text comes from client subtext; numeric picker uses digits in that text.
  Locales without parseable numeric ranks disable Rank 1 discovery rather than
  inventing localized text. Rank X uses the exact available rank subtext.
- Max rank emits an unranked localized name. Whether Forever resolves the highest
  usable learned rank remains unverified. The UI labels that explicitly.
- Explicit ranks and advanced template commands require user confirmation in
  Compatibility after manual tests. Confirmation is not automated validation.
- Macro slot limits come from runtime Constants.MacroConsts or legacy globals.
  If unavailable, creation fails closed. Published Forever constants currently
  describe 120 general and 30 character slots; those numbers are not hardcoded
  into addon creation logic.
- Name/body byte limits use runtime globals when exposed, otherwise conservative
  16/255 defaults. Verify actual Unicode handling and limits in Forever.
- CreateMacro is the sole mutation API. EditMacro is intentionally unused:
  every name collision is rejected, including MacroForge macros. There is no
  update/delete/overwrite path and no gameplay automation.
- Receipts match name, body and storage location, not unstable macro indices.
  Modified/deleted macros cease to appear in My Macros; receipt removal is never
  interpreted as permission to change a native macro.
- Shortcut uses parent visibility hooks only, with slash-command fallback. No
  protected spell buttons or cast handlers are changed.

## Open acceptance work requiring the game

1. Full class catalog: discovery uses player skill lines, flyouts, exposed future
   entries, level-spell API when available, previous discoveries and visited
   trainer links. A client may omit training, talent, quest or hidden ranks.
   Therefore **every ability/rank is not guaranteed**. Validate against the
   actual class trainer/talent trees before declaring this acceptance item done.
2. All rank cast syntax, localized rank subtexts, highest-rank resolution and
   target conditions require controlled action-bar tests.
3. Actual frame templates, events, macro limits/index layout, secure restrictions,
   macro creation return values and shortcut placement need in-game testing.
4. Reload popup must be checked with X, Escape and slash-command closure. Its
   OnAccept calls ReloadUI directly. Reload is optional; macros work immediately.
5. Simulator uses illustrative ranks and spells, not an authoritative Forever
   database, and cannot establish any of the runtime claims above.

## Modifier combo addition (0.3.0)

Source reviewed for the Forever secure CAST and CANCELFORM handlers:
https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ChatFrameBase/Shared/SlashCommands.lua

The handlers parse secure macro options. MacroForge only writes macro text on
Generate; it never invokes CastSpellByName, CancelShapeshiftForm or secure action
handlers itself. Commands remain on the native action bar for a player press.

GetNumShapeshiftForms/GetShapeshiftFormInfo and their fourth return (spell ID)
must be checked in-game. Missing form API data disables form branches/presets.
Preset candidate IDs (768 Cat, 5487 Bear, 9634 Dire Bear, 783 Travel) are only
accepted after matching an exposed live form by ID/localized name; form slot
indices are looked up afresh for each preview and Generate. Existing generated
macros will still embed those indices, so players must recreate the macro if
the form bar's order changes. There is no automatic macro rewrite.

Conditional form handling uses noform:<live index> and !<localized name>.
One-press transitions from another active form still require client testing.
Focus/mouseover require exists,nodead but don't infer help/harm suitability;
the player must choose a spell appropriate to that target. Invalid targets do
not trigger an unconditional fallback. Modifier priority is explicit in clauses:
Shift; Ctrl with no Shift; Alt with no Ctrl/Shift; normal only with no modifiers.
This also prevents cancellation on Shift from being followed by a normal cast.

The Lua tests independently evaluate emitted clauses for all eight modifier
combinations and four form states, including already-active Cat and missing focus.
These tests check branch logic, not the client's secure parser or spell rules.

### 0.3.1: class-scoped forms and per-branch ranks

Form data, form/cancel actions, the Druid preset, the form verification checkbox
and simulator current-form controls are available only for Druids. The addon
also rejects form/cancel branches for other classes even if a saved draft contains
one. The simulator updates this visibility when its selected class changes.

Every cast branch can choose Max (rank-free) or a learned client-exposed explicit
rank independently. Combo generation uses the shared CastName rank validator,
including learned-rank checks, exact localized subtext and explicit-rank manual
verification. Saved branch selections are checked again at Generate; changing
the branch spell resets its rank to Max. Existing rank-free drafts remain valid.
Form/cancel actions remain unranked. All body byte limits continue to apply.

### 0.4.0: optional Druid form conditions

Syntax research includes the Forever secure CAST/CANCELFORM handlers linked
above, the Forever secure action-button source:
https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_FrameXML/SecureTemplates.lua
and original macro examples posted by their author on Blizzard's forum:
https://us.forums.blizzard.com/en/wow/t/druid-shifting-help/2271459

The forum examples demonstrate form:N and noform:N syntax on another WoW client;
they do not establish Forever spell behavior. The addon keeps runtime manual
verification and live form indexing. Actual secure-option parsing occurs only
when a player presses the generated native macro.

Optional per-spell and per-combo-branch conditions emit form:N/noform:N for
selected forms, or noform/form for caster/not-caster. Their saved form spell IDs
are resolved against the current form bar on every preview and Generate.
Missing forms, wrong class, invalid mode and unverified form handling block
creation. Disabled conditions leave the original macro unchanged. Every targeting
fallback receives the condition; guarded stopcasting/cancel cannot run when it
fails. A form-entry action guarded by already being in that same form is rejected.
No fallback bypasses a failed condition and no action is cast by addon Lua.

### 0.5.0

UI: every cycling selector was replaced with a dependency-free dropdown using
standard frame/button/editbox APIs already used by the shell. Ability menus
search the entire learned catalog and show up to ten matching results with
scrolling and More/Previous selection pages. Opening a selector never changes
its stored choice. No new WoW menu API or third-party library is assumed.

Draft preview and creation validation are separate. The UI can construct a draft
without compatibility confirmations; Generate never uses draft mode. Structural
errors (missing spells/forms, unlearned ranks) remain errors. Verification warnings
and byte-limit failures are shown separately from draft text.

No complete authoritative per-ability form/stance/equipment requirement API was
established. C_Spell.GetSpellInfo exposes basic spell information; no shapeshift
requirement accessor was found in the consulted Forever SpellDocumentation.
Required form/stance is therefore explicit, not inferred from usability, mana
failure, spell names or translated tooltip text.

Sources consulted:
- https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SpellDocumentation.lua
- https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/ItemDocumentation.lua
- https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/ContainerDocumentation.lua

Required actions use one native `/cast` conditional list: switch via !Form when
noform:N, otherwise cast the configured ability with form:N. This selects one
branch per press; it does not execute two protected casts or wait and cast later.
Global cooldown and cross-form transition behavior still require live testing.
Warrior stances use the same live GetShapeshiftFormInfo lookup without broadening
the Druid-only form/cancel actions to other classes.

Equipment discovery uses GetItemInfoInstant's equip location, carried bag IDs and
equipped slot IDs. Only INVTYPE_WEAPON/INVTYPE_WEAPONMAINHAND plus INVTYPE_SHIELD
are accepted. It creates a separate `/equipslot` text macro; addon Lua never calls
EquipItemByName or a casting function. No automatic item selection or replacement.

The ! option prefixes the localized cast operand, leaving #showtooltip's spell
name unprefixed. It is toggle-off prevention, not aura-state automation or a
universal no-recast guarantee. Prowl/client combat restrictions remain unchanged.
