import XCTest

@testable import ArabicPlural

final class ArabicPluralTests: XCTestCase {

    func testZero() {
        XCTAssertEqual(ArabicPlural.category(for: 0), .zero)
    }

    func testOne() {
        XCTAssertEqual(ArabicPlural.category(for: 1), .one)
    }

    func testTwo() {
        XCTAssertEqual(ArabicPlural.category(for: 2), .two)
    }

    func testFew() {
        for value in 3...10 {
            XCTAssertEqual(ArabicPlural.category(for: value), .few, "\(value) should be few")
        }
    }

    func testMany() {
        for value in 11...99 {
            XCTAssertEqual(ArabicPlural.category(for: value), .many, "\(value) should be many")
        }
    }

    func testHundredsUseTheRemainder() {
        XCTAssertEqual(ArabicPlural.category(for: 100), .other)
        XCTAssertEqual(ArabicPlural.category(for: 101), .other)
        XCTAssertEqual(ArabicPlural.category(for: 102), .other)
        XCTAssertEqual(ArabicPlural.category(for: 103), .few)
        XCTAssertEqual(ArabicPlural.category(for: 111), .many)
        XCTAssertEqual(ArabicPlural.category(for: 200), .other)
        XCTAssertEqual(ArabicPlural.category(for: 999), .many)
        XCTAssertEqual(ArabicPlural.category(for: 1000), .other)
    }

    func testNegativeCountsUseMagnitude() {
        XCTAssertEqual(ArabicPlural.category(for: -1), .one)
        XCTAssertEqual(ArabicPlural.category(for: -2), .two)
        XCTAssertEqual(ArabicPlural.category(for: -7), .few)
        XCTAssertEqual(ArabicPlural.category(for: -42), .many)
    }

    func testIntMinDoesNotOverflow() {
        XCTAssertEqual(ArabicPlural.category(for: Int.min), .other)
    }

    func testWholeDoublesBehaveLikeIntegers() {
        XCTAssertEqual(ArabicPlural.category(for: 1.0), .one)
        XCTAssertEqual(ArabicPlural.category(for: 3.0), .few)
        XCTAssertEqual(ArabicPlural.category(for: 11.0), .many)
    }

    func testFractionalDoublesAreOther() {
        XCTAssertEqual(ArabicPlural.category(for: 1.5), .other)
        XCTAssertEqual(ArabicPlural.category(for: 3.5), .other)
        XCTAssertEqual(ArabicPlural.category(for: 0.5), .other)
    }

    func testNonFiniteDoublesAreOther() {
        XCTAssertEqual(ArabicPlural.category(for: .infinity), .other)
        XCTAssertEqual(ArabicPlural.category(for: .nan), .other)
    }

    func testFormatReplacesHash() {
        let templates: [ArabicPluralCategory: String] = [
            .zero: "لا رسائل",
            .one: "رسالة واحدة",
            .two: "رسالتان",
            .few: "# رسائل",
            .many: "# رسالة",
            .other: "# رسالة",
        ]
        XCTAssertEqual(
            ArabicPlural.format(templates, count: 5, locale: Locale(identifier: "en")),
            "5 رسائل"
        )
        XCTAssertEqual(
            ArabicPlural.format(templates, count: 11, locale: Locale(identifier: "en")),
            "11 رسالة"
        )
        XCTAssertEqual(
            ArabicPlural.format(templates, count: 0, locale: Locale(identifier: "en")),
            "لا رسائل"
        )
    }

    func testFormatFallsBackToOther() {
        let templates: [ArabicPluralCategory: String] = [.other: "# item"]
        XCTAssertEqual(
            ArabicPlural.format(templates, count: 3, locale: Locale(identifier: "en")),
            "3 item"
        )
    }

    func testFormatWithoutTemplatesIsEmpty() {
        XCTAssertEqual(ArabicPlural.format([:], count: 3), "")
    }

    func testNumberStringHasNoGroupingSeparator() {
        XCTAssertEqual(
            ArabicPlural.numberString(1234, locale: Locale(identifier: "en_US")),
            "1234"
        )
    }

    func testEveryCategoryExistsInOrder() {
        XCTAssertEqual(ArabicPluralCategory.allCases.map(\.rawValue), [
            "zero", "one", "two", "few", "many", "other",
        ])
    }
}
