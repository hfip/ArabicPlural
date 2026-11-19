# ArabicPlural

<p align="center">
  <img src="assets/header.svg" alt="ArabicPlural — Arabic's six plural forms, finally correct" width="100%">
</p>

<p align="center">
  <a href="https://github.com/hfip/ArabicPlural/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/hfip/ArabicPlural/actions/workflows/ci.yml/badge.svg"></a>
  <img alt="Swift 5.9+" src="https://img.shields.io/badge/swift-5.9%2B-F05138?logo=swift&logoColor=white">
  <img alt="Platforms" src="https://img.shields.io/badge/iOS%2013%2B%20%7C%20macOS%2010.15%2B%20%7C%20tvOS%2013%2B%20%7C%20watchOS%206%2B-64748b">
  <img alt="MIT license" src="https://img.shields.io/badge/license-MIT-22c55e">
</p>

<p align="center">
  <b>Arabic has six plural forms. Your app probably has two.</b><br>
  A tiny, dependency-free Swift package that applies the CLDR Arabic rules correctly.
</p>

---

## The bug

```swift
// Looks reasonable, reads wrong in Arabic
let text = count == 1 ? "رسالة واحدة" : "\(count) رسائل"
```

That produces `2 رسائل`, `11 رسائل`, and `100 رسائل` — while the correct Arabic is
`رسالتان`, `11 رسالة`, and `100 رسالة`. Arabic is not singular/plural: CLDR defines six
categories, and two of them (`few`, `many`) depend on `n % 100`.

| `n` | Category | Example |
| --- | --- | --- |
| 0 | `zero` | لا رسائل |
| 1 | `one` | رسالة واحدة |
| 2 | `two` | رسالتان |
| 3–10, 103, 1003… | `few` | 3 رسائل |
| 11–99, 111, 199… | `many` | 11 رسالة |
| 0, 100, 101, 102, 1000, 1.5… | `other` | 100 رسالة |

## Install

Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/hfip/ArabicPlural.git", from: "0.1.0")
]
```

```swift
.target(name: "MyApp", dependencies: ["ArabicPlural"])
```

## Usage

```swift
import ArabicPlural

ArabicPlural.category(for: 2)     // .two
ArabicPlural.category(for: 7)     // .few
ArabicPlural.category(for: 42)    // .many
ArabicPlural.category(for: 100)   // .other
ArabicPlural.category(for: 1.5)   // .other
```

Formatting with `#` as the number placeholder:

```swift
let templates: [ArabicPluralCategory: String] = [
    .zero:  "لا رسائل",
    .one:   "رسالة واحدة",
    .two:   "رسالتان",
    .few:   "# رسائل",
    .many:  "# رسالة",
    .other: "# رسالة",
]

ArabicPlural.format(templates, count: 7)   // "٧ رسائل"
ArabicPlural.format(templates, count: 42)  // "٤٢ رسالة"
```

The number is rendered with the given `Locale`, so Arabic-Indic digits appear
automatically in Arabic locales.

## API

| Member | Description |
| --- | --- |
| `ArabicPluralCategory` | `zero`, `one`, `two`, `few`, `many`, `other` |
| `ArabicPlural.category(for: Int)` | CLDR category for a whole number (uses the magnitude) |
| `ArabicPlural.category(for: Double)` | Fractional values resolve to `.other` |
| `ArabicPlural.format(_:count:locale:)` | Picks the template and substitutes `#` |
| `ArabicPlural.numberString(_:locale:)` | Localised digits without grouping separators |

Rules follow the [CLDR plural rules for `ar`](https://www.unicode.org/cldr/charts/45/supplemental/language_plural_rules.html).

## Design notes

- **No dependencies, no Foundation formatters at type level.** The category logic is pure
  integer arithmetic, so it is fast enough to call inside a SwiftUI body.
- **`#` instead of `%d`.** Format strings invite placeholder mismatches; `#` can only be
  replaced, never misinterpreted.
- **`Int.min` is handled.** `abs(Int.min)` traps; the package returns `.other` instead.

## Related

- [rtl-lint](https://github.com/hfip/rtl-lint) — catch left/right layout assumptions before
  your Arabic users do.
- [xcstrings-audit](https://github.com/hfip/xcstrings-audit) — coverage, placeholder and
  Arabic plural checks for `.xcstrings` catalogs.

## بالعربي

<div dir="rtl" align="right">

العربية فيها ست صيغ جمع، مو صيغتين. أغلب التطبيقات تكتب:

```swift
count == 1 ? "رسالة واحدة" : "\(count) رسائل"
```

فتطلع `2 رسائل` و`11 رسائل` و`100 رسائل`، والصحيح `رسالتان` و`11 رسالة` و`100 رسالة`.

هذي الحزمة صغيرة وبدون أي اعتماديات، تطبّق قواعد CLDR للعربية بالضبط:

```swift
ArabicPlural.category(for: 7)    // .few
ArabicPlural.format(templates, count: 7)  // "٧ رسائل"
```

تشتغل على iOS وmacOS وtvOS وwatchOS من iOS 13.

</div>

## License

[MIT](LICENSE) © 2026 Abdulluh.X
