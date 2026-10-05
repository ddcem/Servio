# Servio – Recommender system

Servio suggests **upselling items** to the waiter while an order is being built: when the waiter adds an item,
the app shows up to three items that complete the meal (for example a drink with a steak) together with a
short explanation of *why* each item is suggested.

The approach is **content-based filtering with cosine similarity**, combined with **co-occurrence from order
history** and **feedback on earlier suggestions**. All three signals are collected by the application itself
and all three are used in the score.

Code: [`Servio.Services/Recommendations/RecommendationService.cs`](backend/Servio.Services/Recommendations/RecommendationService.cs)

---

## 1. When suggestions are shown

| Step | What happens |
|---|---|
| Waiter adds an item to the cart (mobile app) | `POST /api/recommendations` with the added item (`sourceMenuItemId`) and the ids already in the cart / on the open order |
| Server scores the candidates | returns up to 3 suggestions with `score`, `reason` and the three partial scores |
| Waiter taps **Add** or ignores the suggestion | the app remembers every suggestion it showed |
| Waiter presses **Send Order** | the shown suggestions are sent with the order round (`shownRecommendations`) and stored as `RecommendationEvents` |

## 2. Candidate selection

Starting from the whole menu, the server removes:

* items that are not available today or were removed from the menu,
* items already in the cart or on the order, and the source item itself.

To complete the meal, it then keeps only items of a **course the table has not ordered yet**
(course types: appetizer, main course, side, dessert, drink). If every course is already present, all remaining
items stay candidates.

This produces the behaviour described in the project proposal: for a steak, a drink is suggested; once a drink
is in the order, the next suggestions are a side or a dessert.

## 3. Item features and content similarity

Every menu item is turned into a binary feature vector:

```
[ course type (5) | price tier (3) | tags (one per tag in the system) ]
```

* **Course type** – from the item's category (appetizer, main course, side, dessert, drink).
* **Price tier** – budget, standard or premium, computed *within the item's course* (items of a course are
  ranked by price and split into thirds), so a premium wine and a premium steak share a tier.
* **Tags** – e.g. *Meat, Fish, Vegetarian, Spicy, Alcoholic, Hot, Cold, Gluten-free, Sweet, Caffeinated*.
  Tags are reference data managed by the admin, so new tags extend the vector automatically.

Content similarity between the source item `s` and a candidate `c` is the cosine similarity:

```
content(s, c) = (v_s · v_c) / (‖v_s‖ · ‖v_c‖)          ∈ [0, 1]
```

The vectors are cached for 10 minutes and the cache is cleared whenever the admin changes a menu item.

## 4. Order history (co-occurrence)

From **paid orders of the last 180 days**:

```
confidence(s → c) = number of orders containing both s and c / number of orders containing s
history(s, c)     = confidence(s → c) / max over candidates of confidence(s → ·)     ∈ [0, 1]
```

Normalising by the strongest pair keeps the history signal on the same 0–1 scale as the other two.
Both counts come from a single `GROUP BY` query and are cached per source item for 10 minutes.

## 5. Feedback (acceptance rate)

Every suggestion the waiter saw is stored in `RecommendationEvents` (order, waiter, source item, suggested
item, score, reason). **Whether it was accepted is decided by the server**: a suggestion counts as accepted if
the suggested item is part of the order round that was sent. The client cannot report acceptance itself.

```
acceptance(s, c) = (accepted + 1) / (shown + 2)          (Laplace smoothing)
```

A pair that was never suggested starts at 0.5 and moves towards its real acceptance rate as feedback arrives.

## 6. Final score

```
score(s, c) = w_content · content(s, c) + w_history · history(s, c) + w_acceptance · acceptance(s, c)
```

The weights depend on how much history exists for the source item (`n` = paid orders containing it):

```
α            = n / (n + 20)
w_content    = 0.6 − 0.3 α
w_history    = 0.1 + 0.4 α
w_acceptance = 0.3 − 0.1 α          (the weights always sum to 1)
```

| Situation | content | history | acceptance |
|---|---|---|---|
| New item, no orders yet (α = 0) | 0.60 | 0.10 | 0.30 |
| 20 orders (α = 0.5) | 0.45 | 0.30 | 0.25 |
| Many orders (α → 1) | 0.30 | 0.50 | 0.20 |

This solves the **cold start** problem: a new menu item is suggested based on its attributes; once guests
order it, real habits take over.

Finally, the best candidate of **each course type** is kept and the top 3 are returned, so the suggestions
cover different parts of the meal (e.g. a drink, a side and a dessert) instead of three similar drinks.

## 7. Explanations

Each suggestion carries a reason that names the signal that contributed most:

| Dominant signal | Example reason |
|---|---|
| History | *Ordered with Ribeye Steak in 66% of orders* |
| Content (shared traits) | *Pairs with Ribeye Steak: same premium price range, both meat* |
| Content (no shared traits) | *Completes the order with a dessert* |
| + feedback, once a pair was suggested at least 5 times | *… · accepted 65% of the times it was suggested* |

The response also returns `contentScore`, `historyScore` and `acceptanceScore`, so the calculation can be
inspected for every suggestion.

## 8. Data the recommender uses

| Signal | Source table | Written by |
|---|---|---|
| Item attributes | `MenuItems`, `MenuCategories`, `ItemTags`, `MenuItemTags` | admin (menu management) |
| Co-occurrence | `Orders`, `OrderItems` (paid orders only) | waiters taking orders, payments closing them |
| Feedback | `RecommendationEvents` | every order round sent from the mobile app |

The seed data contains about three months of orders with realistic pairings (steak with red wine, burgers with
fries and beer, ćevapi with Bosnian coffee and baklava…) and the matching recommendation feedback, so the
history and feedback signals are active right after the first start. The *Staff performance* report shows the
acceptance rate of suggestions per waiter.

## 9. Example

`POST /api/recommendations` as the `mobile` user:

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

With red wine already in the cart, the drink course is filled, so the suggestions become French Fries,
Chicken Wings and Chocolate Lava Cake.
