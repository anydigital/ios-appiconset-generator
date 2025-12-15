# ios-appiconset-generator

Generate iOS app icons from a source image for Xcode asset catalogs.

## Requirements

- macOS (uses `sips` for image resizing)
- Python 3
- Xcode project with an `.appiconset` directory

## Installation

```bash
npm install -g @anydigital/ios-appiconset-generator
```

Or use directly with npx:

```bash
npx @anydigital/ios-appiconset-generator
```

## Usage

1. Navigate to your `.appiconset` directory:
   ```bash
   cd ios/YourApp/Images.xcassets/AppIcon.appiconset
   ```

2. Place your source icon image as `Icon.png` in that directory (1024x1024 recommended)

3. Run the generator:
   ```bash
   ios-appiconset-generator
   ```

The script will:
- Generate all required icon sizes based on `Contents.json`
- Automatically update `Contents.json` with filenames if missing
- Create a placeholder icon if `Icon.png` doesn't exist

## How it works

The tool reads your `Contents.json` file, extracts the required icon sizes and scales, and uses macOS's `sips` utility to generate properly sized PNG files. It preserves the Xcode formatting of `Contents.json` when updating filenames.

## License

MIT
