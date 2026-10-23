# MySpots

MySpots je mobilná aplikácia vytvorená vo Flutteri na zaznamenávanie
obľúbených miest. Používateľ môže pridať miesto s názvom, fotografiou,
kategóriou a geografickou polohou, zobraziť jeho detail, vyhľadávať a
filtrovať miesta, upravovať ich a vymazávať. Údaje sa uchovávajú lokálne
v SQLite databáze.

## Splnenie požiadaviek zadania

### 1. Minimálne tri obrazovky a navigácia

Aplikácia obsahuje päť samostatných obrazoviek:

  Obrazovka             Účel
  --------------------- ------------------------------------
  `PlacesScreen`        Hlavná obrazovka so zoznamom miest
  `AddPlaceScreen`      Formulár na pridanie miesta
  `PlaceDetailScreen`   Detail uloženého miesta
  `EditPlaceScreen`     Úprava existujúceho miesta
  `MapScreen`           Výber polohy na mape

Navigácia používa `Navigator.push()` a `Navigator.pop()`. Pri otvorení
detailu sa odovzdáva objekt miesta a pri výbere polohy na mape sa
vybraná poloha vracia na predchádzajúcu obrazovku.

### 2. Formuláre a používateľský vstup

V súbore `lib/screens/add_place_screen.dart` sa používa:

-   `TextFormField` na zadanie názvu miesta;
-   `DropdownButtonFormField<PlaceCategory>` na výber kategórie.

Ďalšie interaktívne prvky zahŕňajú vyhľadávanie pomocou `TextField` v
`places_screen.dart`, výber obrázka a výber geografickej polohy.

### 3. Správa stavu pomocou Riverpod

V súbore `lib/main.dart` sa Riverpod inicializuje cez `ProviderScope`:

``` dart
runApp(const ProviderScope(child: MySpotsApp()));
```

V `lib/providers/places_provider.dart` je trieda `PlacesNotifier`, ktorá
dedí z `AsyncNotifier<List<Place>>`, a provider:

``` dart
final placesProvider = AsyncNotifierProvider<PlacesNotifier, List<Place>>(
  PlacesNotifier.new,
);
```

Provider spravuje načítanie, pridávanie, úpravu a mazanie miest.
Obrazovky využívajú `ref.watch()` na sledovanie stavu a `ref.read()` na
vykonávanie operácií. Riverpod zabezpečuje aktuálny stav používateľského
rozhrania; trvalé uloženie dát zabezpečuje SQLite.

### 4. Vlastný dátový model

V súbore `lib/models/place.dart` sú definované:

-   `Place` -- údaje o mieste;
-   `PlaceLocation` -- geografická poloha a adresa;
-   `PlaceCategory` -- kategórie miest.

Model miesta obsahuje názov, obrázok, geografickú polohu, adresu a
kategóriu.

### 5. Odovzdávanie dát medzi widgetmi a callbacky

V `lib/widgets/location_input.dart` sa otvára obrazovka mapy a očakáva
sa výsledok typu `PlaceLocation`:

``` dart
final selectedLocation = await Navigator.of(context).push<PlaceLocation>(
  // ...
);
```

V `MapScreen` sa vybraná poloha vracia:

``` dart
Navigator.of(context).pop(location);
```

Tým aplikácia demonštruje navigáciu aj odovzdávanie výsledku z jednej
obrazovky do druhej.

### 6. Responzívne rozloženie

V `lib/screens/places_screen.dart` sa používajú widgety `Column`, `Row`,
`Expanded` a horizontálny `ListView`. V `lib/widgets/places_list.dart`
sa používa `ListView.builder` na zobrazenie zoznamu miest.

Tieto widgety zabezpečujú flexibilné rozloženie obsahu. Samostatné
testovanie na viacerých veľkostiach obrazovky nie je v tomto prehľade
zdokumentované.

### 7. Externé funkcionality

  ---------------------------------------------------------------------------
  Funkcionalita                       Súbor / knižnica
  ----------------------------------- ---------------------------------------
  Fotoaparát a galéria                `lib/widgets/image_input.dart` --
                                      `image_picker`

  GPS poloha                          `lib/widgets/location_input.dart` --
                                      `location`

  Google Maps                         `lib/screens/map_screen.dart` --
                                      `google_maps_flutter`

  HTTP API na získanie adresy         `lib/services/geocoding_service.dart`
  ---------------------------------------------------------------------------

Zadanie vyžaduje aspoň jednu externú funkcionalitu; aplikácia
implementuje viacero.

### 8. Bonus -- lokálne ukladanie dát pomocou SQLite

Aplikácia používa balík `sqflite` a funkciu `openDatabase()` na
vytvorenie a otvorenie lokálnej databázy `myspots.db`.

Používateľ môže miesta uložiť, opätovne načítať po reštarte aplikácie,
aktualizovať a vymazať. Ide o perzistentné ukladanie dát, ktoré pokrýva
bonusovú požiadavku zadania.

  --------------------------------------------------------------------------
  Súbor                                  Funkcionalita
  -------------------------------------- -----------------------------------
  `lib/services/places_database.dart`    Vytvorenie SQLite databázy a CRUD
                                         operácie

  `lib/providers/places_provider.dart`   Prepojenie Riverpod stavu s
                                         databázou

  `lib/models/place.dart`                Dátový model ukladaných miest
  --------------------------------------------------------------------------

## Testovanie

-   `dart format lib` -- formátovanie zdrojového kódu.
-   `flutter analyze` -- statická analýza; pri poslednom overení bez
    nálezov.
-   `flutter test` -- sedem úspešných automatických testov modelu a
    kategórií.
-   Manuálne overené pridávanie, úprava, mazanie, vyhľadávanie,
    filtrovanie a opätovné načítanie miest.

