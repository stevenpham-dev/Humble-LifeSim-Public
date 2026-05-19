# Humble LifeSim HUD Icon Filenames

Place these PNG files in:

```text
assets/images/icons/
```

Current HUD icons:

```text
hud_day.png
hud_time.png
hud_money.png
hud_energy.png
hud_food.png
hud_health.png
```

Mood icons use three dynamic files:

```text
hud_moodHappy.png
hud_moodNormal.png
hud_moodSad.png
```

The filename capitalization matters for web/AWS exports. Use the exact names above.

Mood switching logic:

```text
Happy  = Happiness >= 75 and Stress <= 25
Sad    = Happiness <= 30 or Stress >= 70
Normal = anything between those ranges
```

Optional fallback:

```text
hud_mood.png
```

If a specific mood file is missing, the HUD tries `hud_mood.png` as a fallback. If no icon exists, the HUD still works with plain text.
