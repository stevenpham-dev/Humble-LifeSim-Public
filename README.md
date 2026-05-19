# Humble LifeSim

Humble LifeSim is a 2D life-simulation and management game built in Godot with GDScript. The player manages daily life choices such as eating, sleeping, studying, working, traveling, shopping, saving progress, and improving long-term stats.

This repository is being prepared as a portfolio project. The immediate goal is a stable browser-playable demo that can be shared from a resume, LinkedIn, and GitHub. Full game balance and larger content expansion can continue after the web demo is live.

## Project status

Portfolio prototype / web-demo preparation.

Live demo:

```text
Add CloudFront or custom domain URL here after deployment.
```

Current focus:

- Stable Godot Web export
- Clean public GitHub repo
- AWS static hosting with Amazon S3 and CloudFront
- Clear documentation for recruiters and technical reviewers

## Features

- Main menu, save slots, and local save/load
- Home screen with daily actions
- HUD with day, time, money, energy, food, happiness/stress, and health
- Map travel between locations
- Store and inventory systems
- Food, books, vehicles, credentials, and special item behavior
- School progress, exams, credentials, and hidden achievement behavior
- Jobs and promotion-style progression
- Burger Town active minigame
- Bank deposits, withdrawals, interest, and transaction history
- Casino, clinic, car shop, gym, phone, logs, achievements, settings, audio, and dim mode

## Tech stack

- Godot Engine
- GDScript
- Godot scene files
- Local JSON save files
- Custom generated image assets
- Custom audio and sound effects
- AWS static hosting with Amazon S3 and CloudFront

## Architecture overview

The project is built around Godot scenes and autoload managers.

- `GameRoot.gd` controls navigation, panel opening, signal wiring, and HUD refreshes.
- `GameState.gd` stores player data and most gameplay rules.
- `SaveManager.gd` handles save slots, save data, migrations, duplicate saves, rename, and delete behavior.
- `AudioManager.gd` handles music and sound effects.
- `SettingsData.gd` stores persistent settings such as audio, dim mode, and tutorial preferences.
- Location and panel scenes keep the project modular so new areas can be added over time.

## Repository layout

```text
assets/       Images, fonts, music, and sound effects
scenes/       Godot scene files
scripts/      GDScript files
screenshots/  Screenshots for README and portfolio presentation
docs/         Deployment notes and test checklists
project.godot Godot project file
```

## Running locally

1. Install Godot 4.x.
2. Open the project folder in Godot.
3. Run the main scene from the editor.
4. Use New Game or Saved Games to create or load a save.

## Web deployment

The public portfolio version is intended to use a Godot Web export hosted as a static site.

Target AWS architecture:

```text
Godot Web Export -> Amazon S3 private bucket -> CloudFront -> optional Route 53 domain
```

The first deployment can be manual. After the site is working, GitHub Actions can be added to sync the exported web build to S3 and invalidate CloudFront on stable releases.

## Later cloud upgrade

A later version can add cloud-integrated save functionality with:

- API Gateway
- Lambda
- DynamoDB
- Optional Cognito login
- CloudWatch logs and metrics

This would turn the project from an AWS-hosted static demo into a cloud-integrated game platform with serverless persistence.

## Prototype note

This is not a final commercial release. Some balance areas such as hunger, happiness, stress, job scaling, casino odds, and economy pacing are still expected to change. The current public-demo goal is to show a stable, playable, connected software project.
