# GitHub OAuth Setup Guide

To enable OAuth authentication in GitDeck, you need to create a GitHub OAuth App.

## Step 1: Create a GitHub OAuth App

1. Go to https://github.com/settings/developers
2. Click "OAuth Apps" in the left sidebar
3. Click "New OAuth App"
4. Fill in the following details:
   - **Application name**: GitDeck (or your preferred name)
   - **Homepage URL**: https://github.com/yourusername/harbour-gitdeck
   - **Authorization callback URL**: `https://localhost/oauth/callback`
   - **Application description**: Native GitHub client for Sailfish OS

5. Click "Register application"
6. You'll see your **Client ID** on the next page
7. Click "Generate a new client secret" to get your **Client Secret**

⚠️ **Important**: Save both the Client ID and Client Secret securely!

## Step 2: Configure Build Environment

### For Local Development

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your credentials:
   ```bash
   GITDECK_CLIENT_ID=your_client_id_here
   GITDECK_CLIENT_SECRET=your_client_secret_here
   ```

3. Source the environment file before building:
   ```bash
   source .env
   ./build.sh
   ```

### For GitHub Actions CI/CD

1. Go to your GitHub repository settings
2. Navigate to "Secrets and variables" → "Actions"
3. Add two repository secrets:
   - `GITDECK_CLIENT_ID`: Your OAuth App Client ID
   - `GITDECK_CLIENT_SECRET`: Your OAuth App Client Secret

The GitHub Actions workflows will automatically use these secrets during builds.

## Step 3: Building Without OAuth

If you don't want to use OAuth, you can still build GitDeck:

```bash
# The app will build with empty OAuth credentials
./build.sh
```

Users can still authenticate using Personal Access Tokens.

## OAuth Flow

1. User taps "Login with GitHub OAuth" in the app
2. Browser opens to GitHub authorization page
3. User authorizes the app
4. GitHub redirects to the callback URL with a code
5. User copies the code back to the app
6. App exchanges code for access token
7. User is authenticated!

## Troubleshooting

**"OAuth not configured" error**
- Make sure you've set the environment variables correctly
- Rebuild the app after setting credentials

**Authorization fails**
- Verify the callback URL is exactly: `https://localhost/oauth/callback`
- Check that your OAuth app is not suspended

**Alternative: Use Personal Access Token**
- Users can always use a GitHub Personal Access Token instead
- This doesn't require OAuth app setup
