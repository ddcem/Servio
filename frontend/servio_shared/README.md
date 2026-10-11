# Servio – zajednički paket

Kod koji koriste obje aplikacije: API klijent, modeli, provideri, uživo ažuriranja (SignalR), tema, zajednički
widgeti i prijevodi.

Prijevodi: engleski i bosanski tekstovi nalaze se u `lib/l10n/app_en.arb` i `lib/l10n/app_bs.arb`. Nakon
izmjene potrebno je ponovo generisati Dart kod:

```bash
flutter gen-l10n
```
