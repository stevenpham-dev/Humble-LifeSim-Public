# Release Workflow

Recommended branch strategy:

```text
main = stable deployed version
dev = active development
tags = release snapshots
```

## First portfolio release

After testing the MVP build:

```bash
git checkout main
git merge dev
git tag v1.0-portfolio-demo
git push origin main --tags
```

Only deploy from `main`.

## After deployment

Continue bigger changes on `dev`:

- balance changes
- new jobs
- new items
- new events
- cloud save
- more AWS features

Merge to `main` only after the local build and web export pass the checklist.
