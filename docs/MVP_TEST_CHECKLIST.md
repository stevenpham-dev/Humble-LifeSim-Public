# Portfolio MVP Test Checklist

Use this checklist before tagging a release or deploying to AWS.

## Launch and menu

- [ ] Game opens without crashes.
- [ ] Main menu background loads.
- [ ] New Game opens the save slot screen.
- [ ] Saved Games opens the save slot screen.
- [ ] Continue loads the most recent save if one exists.
- [ ] Project Info opens/closes and does not describe the hosted web demo as a future-only phase.
- [ ] Settings opens and returns correctly.

## Save slots

- [ ] Save slots show 16 slots.
- [ ] Empty slots can create a new save.
- [ ] New saves use the typed character name.
- [ ] Existing saves can load.
- [ ] Existing saves can rename without loading the game.
- [ ] Duplicate copies a save into an empty slot.
- [ ] Delete asks for confirmation.
- [ ] Delete Forever removes the save and moves remaining saves upward.

## Core gameplay

- [ ] Home loads correctly.
- [ ] HUD updates after actions.
- [ ] Sleep restores energy and does not unfairly kill the player.
- [ ] Happiness and stress display clearly.
- [ ] Auto-eat works before and after sleep.
- [ ] Protein bars still apply random gym stat bonuses when auto-eaten.

## Store and inventory

- [ ] Store bulk buy defaults to Buy 1.
- [ ] x5, x100, and Custom bulk buy update item buttons.
- [ ] Clicking the selected bulk option again returns to Buy 1.
- [ ] Bought items appear in inventory.
- [ ] Food can be eaten.
- [ ] Energy drinks can be used for energy.
- [ ] Equipped vehicles show Equipped and cannot be equipped again.

## School and jobs

- [ ] School progress displays correctly.
- [ ] Exams check requirements.
- [ ] Learn Too Much behavior still works.
- [ ] Passed credentials still allow book stat gains.
- [ ] Job board opens.
- [ ] Work action gives money and updates the HUD.

## Burger Town

- [ ] Correct burger order gives success.
- [ ] Wrong burger order fails the round.
- [ ] Burger Town gives cashier XP even if current profession is different.
- [ ] Payout scales with cashier progress.

## Web export check

- [ ] Exported web build loads locally.
- [ ] Browser console has no major errors.
- [ ] UI does not overlap at target resolution.
- [ ] Sound does not block gameplay.
- [ ] Local browser save works.
