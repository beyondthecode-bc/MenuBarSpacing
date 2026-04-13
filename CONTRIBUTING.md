# Contributing to Menu Bar Spacing

## Translations

Menu Bar Spacing translations are stored as `.xml` files in the [languages](/languages) folder.

### Updating an existing translation

1. Fork this repository
2. Edit the `.xml` file for your language in the `languages/` folder
3. Submit a pull request with a brief description of what you changed

### Adding a new language

1. Copy `languages/English.xml` and rename it to the English name of your language (e.g., `Italian.xml`, `Turkish.xml`)
2. Translate all string values between the XML tags
3. Submit a pull request

### Guidelines

- **Keep format specifiers intact**: `%@`, `%lld`, `%1$lld`, `%2$lld` are replacement patterns used by the program — do not translate or remove them
- **Escape XML special characters**: use `&amp;` for &, `&lt;` for <, `&gt;` for >
- **Technical terms** stay in English: macOS, GitHub
- **App name** "Menu Bar Spacing" is never translated
- Follow Apple's official localization glossary for your language

## Bug Reports

Found a bug? [Open an issue](../../issues/new) with:
- Your Mac model and chip (e.g., MacBook Pro M4 Pro)
- macOS version
- Steps to reproduce
- Screenshots if applicable

## Feature Requests

Have an idea? [Open an issue](../../issues/new) and describe what you'd like to see.
