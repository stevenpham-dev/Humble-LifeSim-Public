# Humble LifeSim

Humble LifeSim is a 2D life-simulation and management game built in Godot with GDScript. The player manages daily life choices such as eating, sleeping, studying, working, traveling, shopping, saving progress, and improving long-term stats.

This started as my CSC492 Senior Design project and is now being expanded into a long-term portfolio project. The current version is a browser-playable AWS-hosted demo.

## Live demo

Play Humble LifeSim in browser:

https://d2xkf3fwmy4jf9.cloudfront.net

## Project status

AWS-hosted portfolio demo.

Current focus:

- Stable Godot Web export
- Clean public GitHub repo
- AWS static hosting with Amazon S3 and CloudFront
- Terraform-managed infrastructure
- Clear documentation for recruiters and technical reviewers

## Screenshots

### Main menu

![Main menu](screenshots/main-menu.png)

### Home and HUD

![Home HUD](screenshots/home-hud.png)

### Map and travel

![Map travel](screenshots/map-travel.png)

### Store with bulk buying

![Store bulk buy](screenshots/store-bulk-buy.png)

### Inventory

![Inventory items](screenshots/inventory-items.png)

### School and credentials

![School credentials](screenshots/school-credentials.png)

### Save slots

![Save slots](screenshots/save-slots.png)

### Burger Town minigame

![Burger minigame](screenshots/burger-minigame.png)

## AWS deployment architecture

Humble LifeSim is exported from Godot Web and hosted on AWS using a private S3 bucket behind CloudFront. The infrastructure is provisioned with Terraform.

![AWS architecture](screenshots/aws-architecture-cloudfront-s3.png)

Deployment flow:

```text
Player Browser
  -> Amazon CloudFront HTTPS CDN
  -> Origin Access Control
  -> Private Amazon S3 bucket
  -> Godot Web export files