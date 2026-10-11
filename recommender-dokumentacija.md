# Servio – Sistem preporuke

Servio konobaru predlaže **dodatne stavke (upselling)** dok sastavlja narudžbu: kada konobar doda stavku,
aplikacija prikaže do tri stavke koje upotpunjuju obrok (npr. piće uz odrezak), zajedno sa kratkim
objašnjenjem *zašto* se svaka stavka predlaže.

Pristup je **content-based filtriranje sa kosinusnom sličnošću**, kombinovano sa **zajedničkim pojavljivanjem
u historiji narudžbi (co-occurrence)** i **povratnom informacijom o ranijim prijedlozima**. Sva tri signala
prikuplja sama aplikacija i sva tri se koriste u izračunu ocjene.

Kod: [`Servio.Services/Recommendations/RecommendationService.cs`](backend/Servio.Services/Recommendations/RecommendationService.cs)

---

## 1. Kada se prikazuju prijedlozi

| Korak | Šta se dešava |
|---|---|
| Konobar dodaje stavku u korpu (mobilna aplikacija) | `POST /api/recommendations` sa dodanom stavkom (`sourceMenuItemId`) i id-evima stavki koje su već u korpi / na otvorenoj narudžbi |
| Server ocjenjuje kandidate | vraća do 3 prijedloga sa `score`, `reason` i tri djelimične ocjene |
| Konobar dodiruje **Add** (*Dodaj*) ili ignoriše prijedlog | aplikacija pamti svaki prikazani prijedlog |
| Konobar pritiska **Send Order** (*Pošalji narudžbu*) | prikazani prijedlozi se šalju zajedno sa rundom narudžbe (`shownRecommendations`) i spremaju kao `RecommendationEvents` |

## 2. Odabir kandidata

Polazeći od cijelog menija, server uklanja:

* stavke koje danas nisu dostupne ili su uklonjene iz menija,
* stavke koje su već u korpi ili na narudžbi, kao i samu izvornu stavku.

Da bi se obrok upotpunio, zatim se zadržavaju samo stavke **vrste jela koju sto još nije naručio**
(vrste: predjelo, glavno jelo, prilog, desert, piće). Ako su sve vrste već zastupljene, svi preostali artikli
ostaju kandidati.

Time se postiže ponašanje opisano u prijavi teme: uz odrezak se predlaže piće; kada je piće već na narudžbi,
sljedeći prijedlozi su prilog ili desert.

## 3. Osobine stavki i sličnost sadržaja

Svaka stavka menija pretvara se u binarni vektor osobina:

```
[ vrsta jela (5) | cjenovni razred (3) | oznake (po jedna za svaku oznaku u sistemu) ]
```

* **Vrsta jela** – iz kategorije stavke (predjelo, glavno jelo, prilog, desert, piće).
* **Cjenovni razred** – budget, standard ili premium, računa se *unutar vrste jela* (stavke jedne vrste se
  sortiraju po cijeni i dijele na trećine), pa premium vino i premium odrezak dijele isti razred.
* **Oznake** – npr. *Meat, Fish, Vegetarian, Spicy, Alcoholic, Hot, Cold, Gluten-free, Sweet, Caffeinated*.
  Oznake su referentni podaci kojima upravlja administrator, pa nove oznake automatski proširuju vektor.

Sličnost sadržaja između izvorne stavke `s` i kandidata `c` je kosinusna sličnost:

```
content(s, c) = (v_s · v_c) / (‖v_s‖ · ‖v_c‖)          ∈ [0, 1]
```

Vektori se keširaju 10 minuta, a keš se briše čim administrator izmijeni neku stavku menija.

## 4. Historija narudžbi (zajedničko pojavljivanje)

Iz **plaćenih narudžbi u posljednjih 180 dana**:

```
confidence(s → c) = broj narudžbi koje sadrže i s i c / broj narudžbi koje sadrže s
history(s, c)     = confidence(s → c) / najveći confidence(s → ·) među kandidatima     ∈ [0, 1]
```

Normalizacija prema najjačem paru drži signal historije na istoj skali 0–1 kao i ostala dva signala.
Oba broja dolaze iz jednog `GROUP BY` upita i keširaju se po izvornoj stavci 10 minuta.

## 5. Povratna informacija (stopa prihvatanja)

Svaki prijedlog koji je konobar vidio sprema se u `RecommendationEvents` (narudžba, konobar, izvorna stavka,
predložena stavka, ocjena, razlog). **Da li je prijedlog prihvaćen odlučuje server**: prijedlog se smatra
prihvaćenim ako je predložena stavka dio poslane runde narudžbe. Klijent ne može sam prijaviti prihvatanje.

```
acceptance(s, c) = (prihvaćeno + 1) / (prikazano + 2)          (Laplaceovo izglađivanje)
```

Par koji nikada nije predložen počinje sa 0,5 i približava se stvarnoj stopi prihvatanja kako stižu povratne
informacije.

## 6. Konačna ocjena

```
score(s, c) = w_content · content(s, c) + w_history · history(s, c) + w_acceptance · acceptance(s, c)
```

Težine zavise od toga koliko historije postoji za izvornu stavku (`n` = broj plaćenih narudžbi koje je sadrže):

```
α            = n / (n + 20)
w_content    = 0.6 − 0.3 α
w_history    = 0.1 + 0.4 α
w_acceptance = 0.3 − 0.1 α          (zbir težina je uvijek 1)
```

| Situacija | content | history | acceptance |
|---|---|---|---|
| Nova stavka, još bez narudžbi (α = 0) | 0,60 | 0,10 | 0,30 |
| 20 narudžbi (α = 0,5) | 0,45 | 0,30 | 0,25 |
| Mnogo narudžbi (α → 1) | 0,30 | 0,50 | 0,20 |

Ovim se rješava problem **hladnog starta (cold start)**: nova stavka menija predlaže se na osnovu svojih
osobina, a kada je gosti počnu naručivati, prevladavaju stvarne navike.

Na kraju se zadržava najbolji kandidat **svake vrste jela** i vraćaju se 3 najbolja, tako da prijedlozi
pokrivaju različite dijelove obroka (npr. piće, prilog i desert) umjesto tri slična pića.

## 7. Objašnjenja

Svaki prijedlog sadrži razlog koji navodi signal koji je najviše doprinio ocjeni. Razlog je napisan na jeziku
koji konobar koristi u aplikaciji (engleski ili bosanski):

| Dominantni signal | Primjer razloga (engleski) | Na bosanskom |
|---|---|---|
| Historija | *Ordered with Ribeye Steak in 66% of orders* | *Naručuje se uz Ribeye Steak u 66% narudžbi* |
| Sadržaj (zajedničke osobine) | *Pairs with Ribeye Steak: same premium price range, both meat* | *Slaže se uz Ribeye Steak: isti cjenovni razred (premium), zajedničke oznake: meat* |
| Sadržaj (bez zajedničkih osobina) | *Completes the order with a dessert* | *Upotpunjuje narudžbu: desert* |
| + povratna informacija, kada je par predložen bar 5 puta | *… · accepted 65% of the times it was suggested* | *… · prihvaćeno u 65% slučajeva kad je predloženo* |

Odgovor vraća i `contentScore`, `historyScore` i `acceptanceScore`, pa se izračun može provjeriti za svaki
prijedlog.

## 8. Podaci koje koristi sistem preporuke

| Signal | Izvorna tabela | Ko upisuje podatke |
|---|---|---|
| Osobine stavki | `MenuItems`, `MenuCategories`, `ItemTags`, `MenuItemTags` | administrator (upravljanje menijem) |
| Zajedničko pojavljivanje | `Orders`, `OrderItems` (samo plaćene narudžbe) | konobari primanjem narudžbi, plaćanja njihovim zatvaranjem |
| Povratna informacija | `RecommendationEvents` | svaka runda narudžbe poslana iz mobilne aplikacije |

Seed podaci sadrže oko tri mjeseca narudžbi sa realnim kombinacijama (odrezak uz crno vino, burgeri uz pomfrit
i pivo, ćevapi uz bosansku kafu i baklavu…) i odgovarajuće povratne informacije o prijedlozima, tako da su
signali historije i povratne informacije aktivni odmah nakon prvog pokretanja. Izvještaj o uposlenicima
(*Staff*) prikazuje stopu prihvatanja prijedloga po konobaru.

## 9. Primjer

`POST /api/recommendations` kao korisnik `mobile`:

```json
{ "sourceMenuItemId": 6, "cartMenuItemIds": [] }
```

```json
[
  {
    "name": "Red Wine", "categoryName": "Alcoholic Drinks", "score": 0.7061,
    "contentScore": 0.2887, "historyScore": 1.0, "acceptanceScore": 0.6462,
    "reason": "Ordered with Ribeye Steak in 66% of orders · accepted 65% of the times it was suggested"
  },
  {
    "name": "French Fries", "categoryName": "Sides", "score": 0.6141,
    "reason": "Ordered with Ribeye Steak in 57% of orders · accepted 56% of the times it was suggested"
  },
  {
    "name": "Chicken Wings", "categoryName": "Appetizers", "score": 0.3598,
    "reason": "Pairs with Ribeye Steak: same premium price range, both meat"
  }
]
```

Kada je crno vino već u korpi, vrsta „piće” je popunjena, pa prijedlozi postaju French Fries, Chicken Wings i
Chocolate Lava Cake.
