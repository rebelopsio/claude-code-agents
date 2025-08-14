# Secure Configuration Guide

This guide explains how to safely configure hooks with sensitive data like API keys.

## TL;DR - Quick Setup

Choose **ONE** of these methods:

### Method 1: User-Level Settings (Simplest)

```bash
# Copy example to your user settings (outside any git repo)
cp hooks/settings.pushover.example.json ~/.claude/settings.json

# Edit and replace PLACEHOLDER values
nano ~/.claude/settings.json
```

### Method 2: Environment Variables

```bash
# Copy env example to your home directory
cp .env.example ~/.claude/.env

# Edit and replace PLACEHOLDER values
nano ~/.claude/.env

# Add to your shell profile
echo 'source ~/.claude/.env' >> ~/.bashrc  # or ~/.zshrc
```

## Understanding Configuration Locations

Claude Code loads settings from multiple locations:

1. **User-level** (`~/.claude/settings.json`) - Outside any git repo, safe for credentials
2. **Project-level** (`.claude/settings.json`) - Inside repo, DON'T use for credentials
3. **Environment variables** - From your shell environment

## Method 1: User-Level Settings (Recommended)

This is the simplest and safest approach for most users.

### Setup Steps

1. **Choose an example configuration**:

   ```bash
   # For Pushover notifications:
   cp hooks/settings.pushover.example.json ~/.claude/settings.json

   # For all hooks:
   cp hooks/settings.example.json ~/.claude/settings.json

   # For minimal setup:
   cp hooks/settings.minimal.example.json ~/.claude/settings.json
   ```

2. **Edit the file and replace placeholders**:

   ```bash
   nano ~/.claude/settings.json
   ```

   Change:

   - `REPLACE_WITH_YOUR_USER_KEY` → Your actual Pushover user key
   - `REPLACE_WITH_YOUR_APP_TOKEN` → Your actual Pushover app token

3. **Verify it's working**:
   ```bash
   # Start Claude Code and run a command
   sleep 6 && echo "Test complete"
   # Should trigger a notification
   ```

### Example Configuration

`~/.claude/settings.json`:

```json
{
  "environmentVariables": {
    "PUSHOVER_USER_KEY": "u1234567890abcdef",
    "PUSHOVER_APP_TOKEN": "a1234567890abcdef",
    "PUSHOVER_ENABLED": "true",
    "PUSHOVER_MIN_TIME": "5"
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/pushover-notifier.sh"
          }
        ]
      }
    ]
  }
}
```

## Method 2: Environment Variables

Good for users who prefer managing credentials in their shell environment.

### Setup Steps

1. **Copy the example env file**:

   ```bash
   cp .env.example ~/.claude/.env
   ```

2. **Edit with your credentials**:

   ```bash
   nano ~/.claude/.env
   ```

3. **Add to your shell profile**:

   ```bash
   # For bash
   echo 'source ~/.claude/.env' >> ~/.bashrc

   # For zsh
   echo 'source ~/.claude/.env' >> ~/.zshrc
   ```

4. **Reload your shell**:

   ```bash
   source ~/.bashrc  # or source ~/.zshrc
   ```

5. **Configure hooks** (without credentials in JSON):

   ```bash
   # Copy basic hooks config
   cp hooks/settings.example.json ~/.claude/settings.json

   # Remove the environmentVariables section since we're using .env
   ```

## What NOT to Do

❌ **Never** put real credentials in files inside the repository  
❌ **Never** commit `settings.json` files with real credentials  
❌ **Never** use project-level `.claude/settings.json` for sensitive data

## Security Checklist

- [ ] Credentials are in `~/.claude/` (user home), not in the repo
- [ ] Example files only contain PLACEHOLDER values
- [ ] No real API keys in any committed files
- [ ] `.gitignore` includes `settings.json` patterns

## Getting API Credentials

### Pushover

1. Sign up at [pushover.net](https://pushover.net)
2. Note your **User Key** from the main page
3. Create an application to get an **API Token**
4. Use these values in your configuration

## Troubleshooting

### Hooks not getting credentials?

**Check environment variables**:

```bash
# Should show your values
echo $PUSHOVER_USER_KEY
echo $PUSHOVER_APP_TOKEN
```

**Check settings file**:

```bash
# Should be in your home directory, not the repo
ls -la ~/.claude/settings.json
```

**Verify JSON syntax**:

```bash
python -m json.tool < ~/.claude/settings.json
```

### Still seeing warnings about missing credentials?

The hooks will show a warning **once** if not configured. This is normal and won't repeat.

## If You Accidentally Commit Credentials

1. **Immediately revoke the exposed credentials**
2. **Remove from git history** (see [GitHub's guide](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository))
3. **Generate new credentials**
4. **Update your local configuration**

## Summary

- Use `~/.claude/settings.json` for user-level configuration (safest)
- Or use environment variables from `~/.claude/.env`
- Never put credentials in the repository
- Always use example files as templates
- The `.gitignore` protects against accidental commits
