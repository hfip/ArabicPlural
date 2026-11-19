import Foundation

/// The six plural categories Arabic actually uses.
///
/// Arabic is not "singular vs plural". CLDR defines six forms, and getting them
/// wrong is the most visible localization bug in Arabic apps:
///
/// ```swift
/// 0  -> zero   "لا رسائل"
/// 1  -> one    "رسالة واحدة"
/// 2  -> two    "رسالتان"
/// 3  -> few    "3 رسائل"
/// 11 -> many   "11 رسالة"
/// 100 -> other "100 رسالة"
/// ```
public enum ArabicPluralCategory: String, CaseIterable, Sendable {
    case zero
    case one
    case two
    case few
    case many
    case other
}

/// CLDR plural rules for Arabic, plus a small formatter.
///
/// The rules only depend on the absolute value modulo 100, which is why `103`
/// is `few` and `111` is `many`, while `100` and `101` fall back to `other`.
public enum ArabicPlural {

    /// Resolve the CLDR category for an integer count.
    public static func category(for count: Int) -> ArabicPluralCategory {
        guard count != Int.min else { return .other }
        return category(forMagnitude: abs(count))
    }

    /// Resolve the CLDR category for a count that may be fractional.
    ///
    /// Non-integer values always map to `.other`, matching CLDR: Arabic only
    /// defines `few` and `many` for whole numbers in `3...10` and `11...99`.
    public static func category(for count: Double) -> ArabicPluralCategory {
        guard count.isFinite, count == count.rounded(),
              count <= Double(Int.max), count >= Double(Int.min) else {
            return .other
        }
        return category(for: Int(count))
    }

    private static func category(forMagnitude n: Int) -> ArabicPluralCategory {
        switch n {
        case 0:
            return .zero
        case 1:
            return .one
        case 2:
            return .two
        default:
            let remainder = n % 100
            if (3...10).contains(remainder) {
                return .few
            }
            if (11...99).contains(remainder) {
                return .many
            }
            return .other
        }
    }

    /// Pick the template for `count` and replace every `#` with the formatted number.
    ///
    /// ```swift
    /// let templates: [ArabicPluralCategory: String] = [
    ///     .zero: "لا رسائل",
    ///     .one: "رسالة واحدة",
    ///     .two: "رسالتان",
    ///     .few: "# رسائل",
    ///     .many: "# رسالة",
    ///     .other: "# رسالة",
    /// ]
    /// ArabicPlural.format(templates, count: 11, locale: Locale(identifier: "ar"))
    /// // "١١ رسالة"
    /// ```
    ///
    /// Falls back to `.other` when the exact category has no template, and to an
    /// empty string when there is nothing to fall back to.
    public static func format(
        _ templates: [ArabicPluralCategory: String],
        count: Int,
        locale: Locale = .current
    ) -> String {
        let template = templates[category(for: count)] ?? templates[.other] ?? ""
        return template.replacingOccurrences(of: "#", with: numberString(count, locale: locale))
    }

    /// The localised decimal representation of a count, without grouping separators.
    public static func numberString(_ count: Int, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: count)) ?? String(count)
    }
}
