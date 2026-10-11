# Servio – shared package

Code used by both apps: API client, models, providers, live updates (SignalR), theme, common widgets and the
translations.

Translations: the English and Bosnian texts are in `lib/l10n/app_en.arb` and `lib/l10n/app_bs.arb`. After
changing them, regenerate the Dart code:

```bash
flutter gen-l10n
```
