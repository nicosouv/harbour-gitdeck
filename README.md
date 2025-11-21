# GitDeck

A native GitHub client for Sailfish OS with masterclass UI/UX.

## Features

- 🔐 **Dual Authentication**: OAuth 2.0 and Personal Access Token support
- 🔄 **GitHub Actions**: Monitor workflow runs with detailed step information
- 📦 **Releases**: Browse releases and download assets directly to your device
- 🐛 **Issues & Pull Requests**: Manage your issues and PRs
- 📂 **Repository Browser**: Explore files, commits, and branches
- 🎨 **Native Silica UI**: Beautiful, responsive interface following Sailfish OS design guidelines

## Building

### Prerequisites

- Sailfish OS SDK
- Qt 5.6+
- (Optional) GitHub OAuth App credentials for OAuth authentication

### Setup OAuth Credentials

1. Create a GitHub OAuth App at https://github.com/settings/developers
2. Set Authorization callback URL to: `https://localhost/oauth/callback`
3. Copy `.env.example` to `.env` and fill in your credentials
4. Source the environment: `source .env`

### Build Commands

```bash
# Using Sailfish SDK
mb2 -t SailfishOS-4.5.0.19-armv7hl build

# Or with qmake directly
qmake harbour-gitdeck.pro
make
```

## Installation

Download the RPM file matching your device architecture from the [Releases](https://github.com/yourusername/harbour-gitdeck/releases) page:

- **armv7hl**: Jolla 1, Jolla C, Xperia X, Xperia XA2
- **aarch64**: Xperia 10 II, Xperia 10 III, Xperia 10 IV, Xperia 10 V
- **i486**: Emulator only

### Install via command line:
```bash
devel-su
pkcon install-local harbour-gitdeck-*.rpm
```

### Install via file manager:
Tap the downloaded RPM file and follow the prompts.

## Usage

### Authentication

**Option 1: OAuth (Recommended)**
1. Launch GitDeck
2. Tap "Login with GitHub"
3. Authorize the application in your browser
4. You'll be redirected back to the app

**Option 2: Personal Access Token**
1. Generate a token at https://github.com/settings/tokens
2. Required scopes: `repo`, `workflow`, `read:user`
3. Enter the token in GitDeck settings

## License

GPLv3 - See LICENSE file for details

## Contributing

Contributions are welcome! Please open an issue or pull request.
