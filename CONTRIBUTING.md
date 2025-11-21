# Contributing to GitDeck

Thank you for your interest in contributing to GitDeck!

## Development Setup

1. Install Sailfish OS SDK
2. Clone the repository
3. Set up OAuth credentials (optional):
   ```bash
   cp .env.example .env
   # Edit .env with your GitHub OAuth app credentials
   ```

## Building

```bash
# Build for armv7hl (default)
./build.sh

# Build for aarch64
./build.sh aarch64

# Build for i486 (emulator)
./build.sh i486
```

## Code Style

- Follow Qt/QML coding conventions
- Use consistent indentation (4 spaces)
- Keep lines under 100 characters when possible
- Comment complex logic

## Pull Request Process

1. Create a feature branch from `main`
2. Make your changes
3. Test on a Sailfish OS device or emulator
4. Submit a pull request with a clear description

## Reporting Issues

Please include:
- Sailfish OS version
- Device model
- Steps to reproduce
- Expected vs actual behavior
- Logs if applicable

## Feature Requests

Open an issue with:
- Clear description of the feature
- Use cases
- Mockups if applicable

Thank you for contributing!
