# MacroForge 0.7.1

WoW Forever macro workshop and interactive simulator. Target verified from the
user's screenshot and local executable: 1.60.1 build 70862, interface 16001.

## Install

Exit WoW. Copy `Interface/AddOns/MacroForge` from this project or
`MacroForge-0.7.1.zip` into:

`C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns`

The final file must be `AddOns/MacroForge/MacroForge.toc` without another nested
MacroForge folder. Enable the addon on character selection. The project was
built in Documents; the game installation has not been changed.

## Use

- `/mf` or `/macroforge`: toggle the window. `/mf diagnostics`: API report.
- Spellbook: search, filter learned/unlearned, and page through discovered ranks.
- Click an ability to open its creation dialog. The rank dropdown offers Max
  (rank-free) and client-exposed ranks, with learned/unlearned status.
- Max rank is a localized rank-free `/cast`. Verify highest-rank resolution in
  Forever before relying on it. No current maximum rank is pinned.
- The old Compatibility panel and manual verification gates have been removed.
  Runtime checks for available data, learned ranks, combat, macro limits, name
  collisions and duplicate bodies remain active.
- Premade Macros contains class-specific, spell-bound premades and shared utility
  macros. Click one to review the actual macro, its prerequisites and source,
  then Generate. Generic templates remain in the spell editor's dropdown.
- Enter a unique name and click Generate. Character slots are preferred; general
  slots are the fallback. Identical bodies and duplicate names are rejected.
- Native Macros opens Blizzard's macro panel, where you can drag icons onto bars.
- My Macros reads every macro available to the logged-in character, including
  character-specific and shared general macros made with or without MacroForge.
  Entries show their storage location; character macros come first. Search
  matches names and body text. Click a macro for a read-only full-text view.
- Closing after successful creation offers Reload Now / Later. Reload is optional
  and can flush SavedVariables. Later clears the prompt until another creation.
- The native spellbook shortcut is optional; slash commands are always available.

## Simulator

Open `sim/index.html` in your browser, or use the inline simulation in the chat.
It includes nine sample classes, search/filter, rank selection, all templates,
preview, Generate, storage fallback, collisions, combat lockdown, My Macros,
simulated native macros, and reload confirmation. Open Test Scenarios to change
slot usage or add a conflicting user macro.

Simulation data is illustrative, not a Forever spell database. Simulation macros
are in memory (chat state may persist through the conversation host); they never
touch WoW. Reload Now simulates a reload rather than reloading the browser.

## Modifier combos (0.3.0)

Select an ability, then **Modifier combos...** in its dialog. Each row has an
action, a spell, a rank and a target. Form/cancel actions and the form preset
appear only for Druids. Every choice is a dropdown, including action, spell,
rank, target, template, filter and form-rule mode. Dropdowns have a search box
and scrollable/paged results; selecting an ability never steps to another one.
Search covers all learned abilities, independent of the main spellbook page.
Enable Combo and return to the regular Generate button.
Configuring or enabling a combo never creates a macro. Selecting a new ability
disables the combo so a previous draft cannot silently replace its macro.
The draft is saved per class; activation is session-only.

- **Alt: focus preset**: normal press casts the selected ability on the current
  target; Alt casts it on an existing, alive focus. Choose a different spell in
  the Alt row for a two-spell macro. The focus branch has no fallback.
- **Druid forms preset**: normal enters Cat, Ctrl enters Bear (Dire Bear preferred
  when present), Alt enters Travel, Shift cancels form. Repeated presses of the
  active form do nothing. All three forms must be exposed by the live form bar.
- Form indices are discovered, never hardcoded. Rebuild a generated form macro
  if learning a new form changes the form bar order. Existing macros are never
  edited automatically.
- Each combo cast has its own rank: Max (rank-free) or an explicitly learned
  rank exposed by the client. Use each branch's rank dropdown. Different branches can cast
  different ranks of the same spell. Changing a branch's spell resets its rank
  to Max. Explicit branch ranks use the same Compatibility verification as normal
  macros and are validated again on Generate. Form/cancel actions have no rank.
- The main dialog's rank buttons and standard templates do not modify an enabled
  combo. Self, current target, focus and mouseover are supported.
- Held modifiers use **Shift > Ctrl > Alt > normal** priority, even if the highest
  held modifier is unassigned (in that case nothing happens). Missing/dead focus
  or mouseover causes no action. The builder never falls through to normal cast.
- Enable advanced conditions in Compatibility after testing. Form/cancel actions
  have an additional verification checkbox in the combo builder. Verify one-press
  form transitions, noform, !Form and /cancelform specifically on Forever.
- Macros select an action per player press; they don't chain two spell casts or
  bypass cooldowns. Existing modified keybindings and game self-cast settings can
  intercept Alt/Ctrl/Shift; test the actual action-bar key as well as mouse clicks.
- Combos are checked against the client's body-byte limit before creation. Long
  localized spell names may require fewer branches or two separate macros.

In the simulator, expand **Modifier combo builder**, use either preset, then
change individual actions/spells/targets. Test normal, Alt, Ctrl and Shift presses
or hold actual modifiers while clicking Test Macro Press. Current form and target
presence controls let you check no-recast and missing-focus behavior. Simulator
form indices are illustrative; the addon queries your live indices.

## In-game acceptance checklist

### Druid form conditions (0.4.0)

Druids now have an optional **Only when** checkbox on individual spell dialogs
and every active combo branch, including form entry and cancel actions. Choose
**In** or **Not in**, then select a live form or **Caster (no form)**. In the
addon and simulator, use the mode and form dropdowns.
Unchecked means unrestricted. Standalone spell rules are remembered per class
and selected spell; combo branch rules are part of the saved combo draft.

The macro uses `[form:N]` for a selected live form and `[noform:N]` for not being
in it. Caster uses `[noform]`; not-caster uses `[form]`. The live form bar provides
N; saved drafts keep the form spell ID and resolve its index again at Generate.
If the form is unavailable, creation stops. Recreate any previously generated
macro if the form bar order changes.

Form and modifier/target/rank conditions are combined on the same branch. If the
form condition fails, that press does nothing; it never falls back to a different
modifier. A form-entry action still keeps its no-recast guard. A rule requiring
you to already be in the very form you are trying to enter is rejected as
contradictory. Conditions filter a press; they do not shift you automatically to
meet a spell's requirements or cast two spells in sequence.

Standalone targeting templates apply the form check to every fallback clause;
Stopcasting is guarded too. Test form/noform in the actual Forever client, then
record verification in Compatibility before generating conditioned macros.
The simulator's current-form selector is under Modifier combo builder and also
controls Test spell condition. Test Bear vs Cat vs Caster, both In/Not in modes,
explicit ranks, focus/mouseover fallbacks, and conditional Shift-cancel.

### Dropdowns, required forms/stances, equipment and ! (0.5.0)

The combo preview now shows a draft even before you confirm compatibility.
Verification warnings appear separately; Generate still uses strict validation.
Choosing options, searching a dropdown or viewing a draft never creates a macro.

For Druids and Warriors, enable the rule checkbox and choose **Requires form/stance
(enter first)**, then select a live form or stance. Druids also keep the existing
In/Not-in conditions. Warriors see their actual stance bar names, such as Battle,
Defensive or Berserker; the code does not guess names or indices. Required form/
stance works on individual spells and each combo cast branch, preserving rank,
target and modifier selection. Confirm switching behavior in Compatibility.

Example pattern: `/cast [noform:N] !Bear Form; [form:N] Bash`. One press switches
when needed; a later press uses the ability when already in the required form.
The global cooldown, combat rules and the ability's requirements still apply.
This does not guarantee both actions on one press. Spellbook discovery reads
abilities, but automatic form/stance/shield requirement detection is not implemented:
those requirements are explicit user choices, not inferred from localized text.

Warriors have a **1H + shield equipment macro** button below the main list. Select
a carried/equipped one-handed main-hand weapon and a shield from searchable
dropdowns, review the `/equipslot 16 item:ID` and `/equipslot 17 item:ID` preview,
test the commands on the client, then click Generate equipment macro. This makes
a separate equipment-only macro. It does not cast the selected ability, execute
equipping itself, delete gear or choose upgrades. Repeated action-bar presses
may be needed before using an ability. Two-handed and off-hand-only weapons are
excluded; missing/uncached item data requires refreshing rather than guessing.

The **Keep active aura on (!)** checkbox is available per individual spell and per
combo cast branch. For Prowl it emits `/cast !Prowl`; explicit ranks, targets and
other conditions are preserved. Form-entry actions already use `!`. The prefix
prevents cancellation for supported toggle spells; it is not a generic check
that any buff or spell is already active and does not bypass combat/stealth rules.
Confirm Prowl toggle behavior on Forever before relying on spam protection.

### Naming and wording (0.5.1)

New spell macros default to spell initials, without a numeric spell-ID suffix:
Faerie Fire becomes FF, Healing Touch becomes HT. Names remain editable and
collisions are rejected without changing an existing macro. Initials preserve
UTF-8 characters and respect the runtime name-byte limit. Equipment macros default
to EWS (Equip Weapon Shield).

The requirement mode is labeled **Form** for Druids and **Stance** for Warriors.
**Mouseover (hostile)** is available as a template and combo target: it adds
`@mouseover,harm,nodead`. The template retains its normal-target fallback; the
combo target does nothing when no living hostile mouseover exists.

The aura checkbox is labeled **Keep active aura on (!)** rather than promising
that a spell is cast only when its aura is absent. The supported macro syntax
adds toggle protection; it cannot perform a generic aura-absence condition.
Hover over the checkbox for this distinction. No simulations or tests were run
for this update, as requested.

### Single-word names and immediate collision checks (0.5.2)

Single-word spells keep their full name (Prowl, Growl, Rebirth). Multi-word spells
use initials (Faerie Fire -> FF, Healing Touch -> HT). A long single-word name is
not silently shortened; enter a shorter name if it exceeds the client byte limit.

The name is checked against both character and general macros when the editor
opens and whenever you edit it. An existing name, including an ASCII case-only
variation, shows a warning and disables Generate until you enter a unique name.
Generation checks again immediately before CreateMacro. Existing macros are never
overwritten, including MacroForge macros. Equipment names receive the same checks.
No simulations or tests were run for this update.

### Premade library and requirement explanation (0.6.0)

**Premade Macros** replaces Useful Macros. It bundles 76 original implementations:
eight per class for all nine classes, plus four shared utilities. Your tab shows
your eight class entries and the shared four, with search and the existing pages.
Unlike the old generic-template list, these entries already specify their spells
and actions and open directly into a dedicated preview dialog.

Examples include Druid mouseover healing/cures, Bear Focus Bash and protected
Prowl; Warrior stance-specific Charge, Taunt and interrupts; Mage crowd control,
interrupts and cursor spells; Priest and Paladin mouseover support; Hunter pet
commands and shots; Rogue stealth, interrupts and survival; Warlock focus control,
DoTs and pet commands; and Shaman healing, shocks, cures and shields. Shared entries
set/clear focus, assist focus, select the previous target or stop the current cast.

Every premade displays its source URL, source review date, usage note and target
client version. Names resolve from candidate spell IDs through the client and
learned spellbook families; casts are rank-free. A missing learned spell, unavailable
form/stance, unverified command category, combat, duplicate, taken name or excessive
localized body length blocks creation. No source page is fetched inside WoW.
No source guide prose was copied into the addon; implementations and concise notes
were written for MacroForge. Sources and limitations are in
`docs/PREMADE-SOURCES.md`. Source review does not establish in-game correctness.

Requires Form/Stance now has explanatory hover text. When enabled, the spell
editor also states which named form/stance the macro switches into before the
ability. The combo builder carries the same explanation. Because the macro selects
one cast branch per press, a later press may be needed after switching/global
cooldown. Enabling the option never executes a cast or creates a macro by itself.

Tests and simulations remain stopped at your request. Install this version and
verify desired premades in game before relying on them in a group.

### Square spellbook shortcut (0.6.1)

The spellbook's MacroForge text button is now a 34-by-34 square icon using the
client's own `Interface/MacroFrame/MacroFrame-Icon` artwork. Its dark backing,
thin gold outline, inset icon, hover highlight and open-state glow match the
installed What's Training? button style. It sits four pixels above that addon's
book shortcut when present. No What's Training? files or libraries are required
or changed. Hover displays MacroForge's name; click toggles the window.

All buttons previously labeled Native Macros now read **Open Macro Window**.
No tests or simulations were run for this update.

### Minimap, simpler navigation and feedback (0.7.0)

The Compatibility panel is removed. The remaining three tabs fill the navigation
row. Manual verification checkboxes no longer block macro creation; actual
runtime validation remains, and no saved flag is relabeled as a successful test.
Earlier release notes describing those checkboxes are historical.

A minimap icon opens/closes MacroForge. Drag it around the minimap to reposition;
its angle is saved. `/mf minimap` hides/shows it; `/mf minimap reset` restores its
default position and visibility. The existing spellbook shortcut remains.

The bottom footer provides a copyable GitHub Issues link for bug reports and
feature suggestions. WoW does not open an external browser from this button.
No reports are submitted automatically. The URL is configured in Feedback.lua.

This repository contains only the installable addon source and documentation.
Local simulator files, test/development tooling, dependencies and generated ZIPs
are excluded. Tests and simulations remain stopped at the user's request.

### Active abilities only (0.7.1)

Passive abilities are excluded from the spellbook catalog and rank families;
combo spell selectors continue to exclude passives as well. Discovery uses the
modern spellbook passive API/item flag, then spell-ID passive data, preserving
known passive status across repeated discovery sources and cached entries. Legacy
spellbooks check passive status by book slot rather than passing a spell ID as
a slot. Learned and unlearned active abilities remain searchable. Existing saved
macros are preserved. No tests or simulations were run for this update.

### Spellbook-style lists and character macro window (0.6.3)

Spellbook, Premade Macros and My Macros now share a two-column, six-row layout:
12 entries per page, larger 44-pixel icons, the name on the first line and rank,
storage or premade type beneath it. This uses both halves of the existing window.
Hover shows full names, secondary text and premade usage notes when available.

Premades use the first spell's client-provided icon, including unlearned spells
when their data is available. Shared utilities or unavailable icon data use the
native macro artwork. User macros retain their saved native icons. Unlearned
spellbook abilities are desaturated.

Every Open Macro Window button now opens Blizzard's macro UI and selects the
character-specific tab after its OnShow handler. A guarded legacy tab-button
fallback is included; an unavailable tab API leaves the window open with a note
to select the character tab manually. Combat restrictions remain unchanged.
No tests or simulations were run for this update.

### All current-character macros (0.6.2)

My Macros now reads the native macro inventory instead of filtering it by
MacroForge receipts. It lists this character's macros and general/shared macros
available to this character, with storage labels and counts. Other characters'
private macros are not read. Native macro updates refresh the list through the
existing UPDATE_MACROS event; the Refresh button and reopening also reread it.

Selecting an entry opens a read-only text snapshot with an Open Macro Window
button. Native edits require reopening that snapshot to view the updated text.
Browsing these macros never claims ownership, creates a receipt, edits a macro,
or marks the session dirty. Duplicate-name/body and no-overwrite protection still
apply to every existing native macro, regardless of who created it.
No tests or simulations were run for this update.

1. `/console scriptErrors 1`, then `/reload`. Confirm no Lua errors on login.
2. `/mf`: check window, search, filter, all three tabs, paging, drag, X, Escape,
   `/macroforge`, reopening, saved tab/template, and shortcut visibility.
3. Compare learned/future abilities and rank text against your native spellbook,
   trainer and talents. Visit a trainer, refresh, and compare again. Full class
   coverage remains unverified and is explicitly labeled in the addon.
4. Inspect native macros before and after opening, selecting, changing ranks,
   selecting templates and canceling. There must be zero automatic mutations.
5. Generate a uniquely named max-rank test macro. Confirm native icon/body and
   character location. Drag it onto an action bar and test out of combat.
6. Test an explicit-rank macro manually in the native UI. Once verified, enable
   the corresponding Compatibility setting. Compare MacroForge Rank 1 and X.
   Unlearned/invalid ranks must stay blocked. Check your client locale.
7. Learn a higher rank and test the same rank-free macro. Record whether it uses
   the highest learned usable rank; only then mark it verified in Compatibility.
8. Manually verify focus/mouseover/modifier/stopcasting conditions before enabling
   templates. Verify fallback targeting with no focus/mouseover and invalid ones.
9. Generate an identical body under another name, then reuse an existing name
   with a different body. Both must fail without overwriting any native macro.
10. Test character-full -> general fallback and both-full -> clear error with
    Native Macros available. Use a disposable test character; don't delete user
    macros just to free slots. Offline tests cover these branches safely too.
11. Enter combat with the editor open. Generate must disable; clicking through
    any stale UI must still be rejected. Leave combat and check recovery.
12. Close after creation: Later must clear the prompt; close again without changes
    and expect no prompt. Create another macro and choose Reload Now. Check saved
    metadata after login. Existing macros work without reload.
13. Edit/delete/rename a generated macro in native UI and confirm refresh never
    recreates, overwrites or deletes it. Confirm no changes on subsequent login.

## Verification performed

`tools/verify.py` loads every TOC module under Lua 5.1 with mocked WoW APIs and
tests UI construction, no implicit mutations, rank/template validation, combat,
slot fallback/full behavior, duplicate protection, ownership, reload and byte
limits. It also rebuilds the zip and standalone/inline simulation sources.

`tools/test_sim.py` uses Playwright Chromium to test interactive creation,
duplicates, collisions, full/fallback slots, unlearned ranks, combat, templates,
ownership and close/reload behavior; checks JavaScript errors and overflow at
1000, 736, 390 and 320 pixels. Desktop/mobile screenshots are in `sim/`.

Development dependencies are local to `tools/deps`; the addon requires no
third-party libraries. Re-run with `python tools/verify.py` and
`python tools/test_sim.py`. The latter uses browsers in `tools/browsers`.
