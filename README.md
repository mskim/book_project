# Book Processor

Automated FlipBook generation and GitHub Pages hosting using GitHub Actions.

## Overview

This project automates the conversion of markdown content into interactive web-based FlipBooks, hosted on GitHub Pages. It supports multiple trigger methods including webhook integration with Bee recording devices.

## Features

- **Automated Build Pipeline** - GitHub Actions workflow for continuous deployment
- **Multiple Triggers** - Push, manual dispatch, webhook, and scheduled builds
- **Interactive FlipBooks** - Responsive HTML flipbook with keyboard and touch navigation
- **GitHub Pages Hosting** - Automatic deployment to GitHub Pages
- **Bee Integration** - Webhook support for Bee recording device content

## Directory Structure

```
book-processor/
├── .github/
│   └── workflows/
│       └── build-flipbook.yml    # GitHub Actions workflow
├── bin/
│   └── doc_processor             # Pre-built Swift binary (add your own)
├── content/
│   └── stories/
│       └── my-story/             # Story content folders
│           ├── metadata.yml      # Story metadata
│           ├── 01-chapter.md     # Chapter files
│           └── 02-chapter.md
├── templates/
│   └── flipbook/                 # FlipBook HTML/CSS/JS templates
├── scripts/
│   ├── build-flipbook.sh         # Fallback build script
│   └── generate-index.sh         # Index page generator
├── docs/                         # GitHub Pages output (auto-generated)
└── output/                       # Build output (gitignored)
```

## Setup Instructions

### 1. Fork/Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/book-processor.git
cd book-processor
```

### 2. Add doc_processor Binary

Place your pre-built Swift `doc_processor` binary in the `bin/` directory:

```bash
cp /path/to/doc_processor bin/
chmod +x bin/doc_processor
```

### 3. Configure GitHub Pages

1. Go to repository **Settings** > **Pages**
2. Source: Select **GitHub Actions**
3. The workflow will automatically deploy to Pages

### 4. Add Content

Create a new story:

```bash
mkdir -p content/stories/my-life-story
```

Add metadata file `content/stories/my-life-story/metadata.yml`:

```yaml
title: "My Life Story"
author: "John Doe"
created: "2025-01-01"
language: "en"
```

Add chapter files (numbered for ordering):

```bash
# content/stories/my-life-story/01-childhood.md
# Childhood Years

Growing up in Boston was an adventure...
```

### 5. Trigger Build

**Option A: Push to main branch**
```bash
git add .
git commit -m "Add new story content"
git push origin main
```

**Option B: Manual trigger**
1. Go to **Actions** tab
2. Select **Build and Deploy FlipBook**
3. Click **Run workflow**
4. Optionally specify a story ID

**Option C: Webhook (from Bee)**
```bash
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token YOUR_GITHUB_TOKEN" \
  https://api.github.com/repos/OWNER/REPO/dispatches \
  -d '{"event_type": "bee-recording-ready", "client_payload": {"story_id": "my-story"}}'
```

## Bee Server Integration

To integrate with your Bee recording device:

### 1. Create GitHub Personal Access Token

1. Go to GitHub **Settings** > **Developer settings** > **Personal access tokens**
2. Generate new token with `repo` scope
3. Save the token securely

### 2. Configure Bee Webhook

Set up your Bee server to send webhooks:

```bash
POST https://api.github.com/repos/YOUR_USER/book-processor/dispatches
Headers:
  Accept: application/vnd.github.v3+json
  Authorization: token YOUR_TOKEN
Body:
  {
    "event_type": "bee-recording-ready",
    "client_payload": {
      "story_id": "recording-2025-01-15",
      "recording_url": "https://bee-server/recordings/123",
      "transcript": "..."
    }
  }
```

### 3. Process Recording Content

The workflow can be extended to:
1. Fetch recording from Bee server
2. Process transcript with AI for diarization
3. Convert to markdown format
4. Build FlipBook

## Workflow Triggers

| Trigger | Event | Use Case |
|---------|-------|----------|
| Push | `push` to `main` | Auto-build on content changes |
| Manual | `workflow_dispatch` | On-demand builds |
| Webhook | `repository_dispatch` | Bee server integration |
| Schedule | `cron: '0 2 * * *'` | Daily rebuilds |

## Customization

### FlipBook Template

Edit files in `templates/flipbook/`:
- `index.html` - Page structure
- `flipbook.css` - Styling
- `flipbook.js` - Navigation logic

### Build Script

Modify `scripts/build-flipbook.sh` for custom markdown processing.

## Environment Variables / Secrets

| Secret | Description |
|--------|-------------|
| `BEE_WEBHOOK_URL` | (Optional) URL to notify Bee server on completion |
| `BEE_API_TOKEN` | (Optional) Token for Bee server API |

Add secrets in repository **Settings** > **Secrets and variables** > **Actions**.

## Troubleshooting

### Build fails with "doc_processor not found"

Upload your pre-built binary to `bin/doc_processor` or the fallback shell script will be used.

### GitHub Pages not updating

1. Check Actions tab for workflow status
2. Verify Pages is configured to use GitHub Actions
3. Check the `docs/` folder contains generated content

### Webhook not triggering

1. Verify the `event_type` matches (`bee-recording-ready` or `process-story`)
2. Check GitHub token has `repo` scope
3. Review Actions tab for failed runs

## License

MIT License - See LICENSE file for details.
