# Environment Setup for Atomic Aether

This guide explains how to set up your API keys for development.

## Method 1: Xcode Scheme Environment Variables (Recommended)

This is the most secure method for development as it keeps your API keys out of the codebase.

### Steps:

1. **Open Xcode** and load the `atomic-aether.xcodeproj`

2. **Access Scheme Settings**:
   - Click on the scheme name next to the Run button (it should say "atomic-aether")
   - Select "Edit Scheme..." from the dropdown

3. **Add Environment Variables**:
   - In the scheme editor, select "Run" from the left sidebar
   - Click on the "Arguments" tab
   - In the "Environment Variables" section, click the "+" button to add each variable:

   | Name | Value |
   |------|-------|
   | `OPENAI_API_KEY` | Your OpenAI API key |
   | `ANTHROPIC_API_KEY` | Your Anthropic API key |
   | `FIREWORKS_API_KEY` | Your Fireworks API key |

4. **Save**: Click "Close" to save your changes

5. **Run**: Build and run the app. You should see:
   ```
   ✅ Loaded environment from Xcode scheme variables
   🔑 API Keys loaded from environment:
     - OpenAI: ✅
     - Anthropic: ✅
     - Fireworks: ✅
   ```

## Method 2: .env File (Alternative)

If you prefer using a `.env` file:

1. Create a `.env` file in the project root:
   ```
   OPENAI_API_KEY=your-openai-key-here
   ANTHROPIC_API_KEY=your-anthropic-key-here
   FIREWORKS_API_KEY=your-fireworks-key-here
   ```

2. Make sure the app sandbox is disabled in `atomic_aether.entitlements`:
   ```xml
   <key>com.apple.security.app-sandbox</key>
   <false/>
   ```

## Security Notes

- **Never commit API keys** to version control
- The `.env` file is already in `.gitignore`
- Xcode scheme environment variables are stored locally and not committed
- For production, use a secure key management service

## Troubleshooting

If you see "❌ No environment variables found":
1. Double-check the environment variable names are exactly as shown
2. Make sure you're editing the correct scheme
3. Try cleaning and rebuilding the project (Cmd+Shift+K, then Cmd+B)
4. Restart Xcode if variables aren't being recognized

## Getting API Keys

- **OpenAI**: https://platform.openai.com/api-keys
- **Anthropic**: https://console.anthropic.com/settings/keys
- **Fireworks**: https://app.fireworks.ai/account/api-keys