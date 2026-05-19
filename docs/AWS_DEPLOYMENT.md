# AWS Deployment Notes

This document tracks the portfolio deployment path for Humble LifeSim.

## Goal

Deploy a stable browser-playable Godot Web export so the project can be shared from a resume, LinkedIn, and GitHub without asking people to download the source code.

## Target architecture

```text
Godot Web Export
    -> web-build/
    -> Amazon S3 private bucket
    -> CloudFront distribution
    -> optional Route 53 custom domain
```

Do not use EC2 or EKS for the first web demo. The Godot Web build is static files, so S3 plus CloudFront is enough for the first public version.

## Phase 1 - Godot Web export

1. Open the project in Godot.
2. Install the web export template if Godot asks for it.
3. Create a Web export preset.
4. Export to a folder such as `web-build/`.
5. Use `index.html` as the exported HTML file name.
6. Test locally in a browser before uploading to AWS.

Check:

- Main menu loads.
- New game and saved games work.
- Local browser save works.
- Store, inventory, school, jobs, Burger Town, and map travel work.
- Audio does not block gameplay if the browser requires user interaction first.
- UI is acceptable at the target browser size.

## Phase 2 - S3 bucket

Create a private S3 bucket for the web files. Keep Block Public Access enabled.

Example naming pattern:

```text
humble-lifesim-web-prod
```

Upload the exported files:

```bash
aws s3 sync web-build/ s3://YOUR_BUCKET_NAME/ --delete
```

## Phase 3 - CloudFront

Create a CloudFront distribution with the S3 bucket as the origin.

Recommended settings:

- Origin type: S3 bucket origin, not S3 static website endpoint
- Origin Access Control: enabled
- Viewer protocol policy: redirect HTTP to HTTPS
- Default root object: `index.html`
- Cache policy: start with the managed caching policy, then tune later if needed

After CloudFront creates the distribution, update the S3 bucket policy so only that CloudFront distribution can read the objects.

## Phase 4 - Cache invalidation

After uploading a new build, invalidate CloudFront so the latest files appear:

```bash
aws cloudfront create-invalidation   --distribution-id YOUR_DISTRIBUTION_ID   --paths "/*"
```

## Phase 5 - Update portfolio links

After the CloudFront URL works:

- Add the live demo link to `README.md`.
- Add the live demo link to LinkedIn / resume project links if desired.
- Add screenshots of the deployed CloudFront page to `screenshots/`.
- Keep the in-game Project Info wording neutral, because the game may be viewed locally or through the hosted demo.

## Phase 6 - Optional custom domain

After the CloudFront URL works, add a custom domain later with:

- Route 53 hosted zone
- ACM certificate in `us-east-1`
- CloudFront alternate domain name
- Route 53 alias record to CloudFront

## Phase 7 - Optional CI/CD

After manual deployment works, add GitHub Actions.

Possible flow:

```text
merge to main
    -> upload prepared web-build files to S3
    -> invalidate CloudFront cache
```

That lets the project show a controlled release workflow without making the first deployment harder than necessary.

## Notes

The current priority is not cloud save yet. First make the static web demo stable. Then add API Gateway, Lambda, DynamoDB, CloudWatch, and optional Cognito later.
