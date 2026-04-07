# 8-bit Sound Candidates

Downloaded for audition on 2026-04-07.

All files here are for selection only. I did not wire any of them into the app yet.

## Sources

- `Fupi/`
  - Source: https://opengameart.org/content/8bit-menu-highlight
  - Source: https://opengameart.org/content/8bit-menu-select
  - License: CC0
  - Format: WAV
- `Joth/`
  - Source: https://opengameart.org/content/7-assorted-sound-effects-menu-level-up
  - License: CC0
  - Format: MP3
- `Basto/`
  - Source: https://opengameart.org/content/nes-sounds
  - License: CC0
  - Format: OGG
- `Jute/`
  - Source: https://opengameart.org/content/interface-beeps
  - License: CC0
  - Format: WAV
- `StumpyStrust/`
  - Source: https://opengameart.org/content/ui-sounds
  - License: CC0
  - Format: OGG
- `ButtonClicks/`
  - Source: https://opengameart.org/content/16-button-clicks
  - License: CC0
  - Format: FLAC

## Picked So Far

Your current favorites are copied into `picked-so-far/`.

- `attention_or_failure__vgmenuselect.wav`
- `complete__vgmenuhighlight.wav`
- `error__hurt.ogg`

## Start Here

If you want the fastest review pass, listen to the files in `shortlist/` first.

The shortlist is grouped by the five app events we discussed:

- `processing_started`
- `attention_required`
- `task_completed`
- `task_error`
- `resource_limit`

Each event currently has 3 candidates.

## Shortlist Notes

- `processing_started__fupi__vgmenuhighlight.wav`
  - Clean and light. Good default if you want a classic UI blip.
- `processing_started__joth__menu_move.mp3`
  - Slightly more game-like. Good if you want more movement.
- `processing_started__basto__stair_up.ogg`
  - More retro-console flavored.
- `attention_required__joth__transition.mp3`
  - Dramatic. Better if attention prompts should feel unmistakable.
- `attention_required__basto__secret.ogg`
  - More mysterious and longer.
- `attention_required__basto__magic.ogg`
  - Shorter and more restrained than `secret`.
- `task_completed__fupi__vgmenuselect.wav`
  - Strong candidate for the default completion sound.
- `task_completed__joth__menu_confirm.mp3`
  - Very short and clean confirmation.
- `task_completed__basto__achieved.ogg`
  - More reward-like and celebratory.
- `task_error__joth__menu_error.mp3`
  - Clean UI error.
- `task_error__basto__hurt.ogg`
  - Sharper retro failure feel.
- `task_error__basto__nearly_dead.ogg`
  - Stronger warning tone, more dramatic.
- `resource_limit__basto__coin.ogg`
  - Noticeable without sounding too negative.
- `resource_limit__basto__bling.ogg`
  - Light alert style.
- `resource_limit__joth__ability_learn.mp3`
  - More distinct, but longer than the others.

## Current Status

- Downloaded and extracted: `Fupi`, `Joth`, `Basto`
- Added and extracted: `Jute`, `StumpyStrust`, `ButtonClicks`
- Still optional if you want an even larger pool later: `retro-synth`, `Kenney`, `wobbleboxx`

## Next Step

Once you pick 5 files, I can:

1. Convert everything to a consistent WAV format if needed.
2. Trim loudness and leading/trailing silence.
3. Rename them to the app's final resource names.
4. Wire them into the built-in sound picker.
