//
//  Currency.swift
//  Core
//
//  Created by Klim on 10/11/25.
//
import Foundation

public struct Currency: Identifiable, Codable, Sendable, Equatable, Hashable {
    public var id: String
    public var label: String
    public var emoji: String
    public var continent: String
    public var timezones: [String]

    public init(id: String, label: String, emoji: String, continent: String, timezones: [String]) {
        self.id = id
        self.label = label
        self.emoji = emoji
        self.continent = continent
        self.timezones = timezones
    }

    public var displayLabel: String {
        "\(emoji) \(label)"
    }

    public static func find(by id: String?) -> Currency? {
        guard let id else { return nil }
        return allCurrencies.first { $0.id == id }
    }
}

// MARK: - All Supported Currencies

public extension Currency {
    static let allCurrencies: [Currency] = [
        // North America
        Currency(id: "USD", label: "US Dollars", emoji: "🇺🇸", continent: "North America", timezones: [
            "America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles",
            "America/Phoenix", "America/Anchorage", "Pacific/Honolulu", "America/Detroit",
            "America/Indianapolis", "America/Louisville", "America/Menominee"
        ]),
        Currency(id: "CAD", label: "Canadian Dollars", emoji: "🇨🇦", continent: "North America", timezones: [
            "America/Toronto", "America/Vancouver", "America/Montreal", "America/Calgary",
            "America/Edmonton", "America/Winnipeg", "America/Halifax", "America/St_Johns"
        ]),
        Currency(id: "MXN", label: "Mexican Pesos", emoji: "🇲🇽", continent: "North America", timezones: [
            "America/Mexico_City", "America/Cancun", "America/Merida", "America/Monterrey",
            "America/Mazatlan", "America/Chihuahua", "America/Tijuana"
        ]),

        // South America
        Currency(id: "BRL", label: "Brazilian Real", emoji: "🇧🇷", continent: "South America", timezones: [
            "America/Sao_Paulo", "America/Rio_Branco", "America/Manaus",
            "America/Fortaleza", "America/Recife", "America/Bahia"
        ]),
        Currency(id: "ARS", label: "Argentine Peso", emoji: "🇦🇷", continent: "South America", timezones: [
            "America/Argentina/Buenos_Aires", "America/Argentina/Cordoba", "America/Argentina/Mendoza"
        ]),
        Currency(id: "CLP", label: "Chilean Pesos", emoji: "🇨🇱", continent: "South America", timezones: ["America/Santiago"]),
        Currency(id: "COP", label: "Colombian Peso", emoji: "🇨🇴", continent: "South America", timezones: ["America/Bogota"]),

        // Europe
        Currency(id: "EUR", label: "Euro", emoji: "🇪🇺", continent: "Europe", timezones: [
            "Europe/Berlin", "Europe/Paris", "Europe/Rome", "Europe/Madrid", "Europe/Amsterdam",
            "Europe/Brussels", "Europe/Vienna", "Europe/Prague", "Europe/Budapest", "Europe/Warsaw",
            "Europe/Helsinki", "Europe/Stockholm", "Europe/Copenhagen", "Europe/Oslo", "Europe/Zurich"
        ]),
        Currency(id: "GBP", label: "British Pounds", emoji: "🇬🇧", continent: "Europe", timezones: [
            "Europe/London", "Europe/Belfast", "Europe/Dublin"
        ]),
        Currency(id: "CHF", label: "Swiss Francs", emoji: "🇨🇭", continent: "Europe", timezones: ["Europe/Zurich"]),
        Currency(id: "RUB", label: "Russian Rubles", emoji: "🇷🇺", continent: "Europe", timezones: [
            "Europe/Moscow", "Asia/Yekaterinburg", "Asia/Novosibirsk", "Asia/Krasnoyarsk",
            "Asia/Irkutsk", "Asia/Yakutsk", "Asia/Vladivostok", "Asia/Magadan", "Asia/Kamchatka"
        ]),
        Currency(id: "TRY", label: "Turkish Lira", emoji: "🇹🇷", continent: "Europe", timezones: ["Europe/Istanbul"]),
        Currency(id: "SEK", label: "Swedish Krona", emoji: "🇸🇪", continent: "Europe", timezones: ["Europe/Stockholm"]),
        Currency(id: "NOK", label: "Norwegian Krone", emoji: "🇳🇴", continent: "Europe", timezones: ["Europe/Oslo"]),
        Currency(id: "DKK", label: "Danish Krone", emoji: "🇩🇰", continent: "Europe", timezones: ["Europe/Copenhagen"]),
        Currency(id: "PLN", label: "Polish Zloty", emoji: "🇵🇱", continent: "Europe", timezones: ["Europe/Warsaw"]),
        Currency(id: "CZK", label: "Czech Koruna", emoji: "🇨🇿", continent: "Europe", timezones: ["Europe/Prague"]),
        Currency(id: "HUF", label: "Hungarian Forint", emoji: "🇭🇺", continent: "Europe", timezones: ["Europe/Budapest"]),

        // Middle East
        Currency(id: "AED", label: "UAE Dirham", emoji: "🇦🇪", continent: "Middle East", timezones: ["Asia/Dubai"]),
        Currency(id: "SAR", label: "Saudi Riyal", emoji: "🇸🇦", continent: "Middle East", timezones: ["Asia/Riyadh"]),
        Currency(id: "QAR", label: "Qatari Riyal", emoji: "🇶🇦", continent: "Middle East", timezones: ["Asia/Qatar"]),
        Currency(id: "KWD", label: "Kuwaiti Dinar", emoji: "🇰🇼", continent: "Middle East", timezones: ["Asia/Kuwait"]),
        Currency(id: "OMR", label: "Omani Rial", emoji: "🇴🇲", continent: "Middle East", timezones: ["Asia/Muscat"]),

        // Asia
        Currency(id: "JPY", label: "Japanese Yen", emoji: "🇯🇵", continent: "Asia", timezones: ["Asia/Tokyo", "Asia/Osaka"]),
        Currency(id: "CNY", label: "Chinese Yuan", emoji: "🇨🇳", continent: "Asia", timezones: [
            "Asia/Shanghai", "Asia/Beijing", "Asia/Chongqing", "Asia/Harbin", "Asia/Urumqi"
        ]),
        Currency(id: "INR", label: "Indian Rupees", emoji: "🇮🇳", continent: "Asia", timezones: ["Asia/Kolkata", "Asia/Mumbai", "Asia/Delhi"]),
        Currency(id: "KRW", label: "South Korean Won", emoji: "🇰🇷", continent: "Asia", timezones: ["Asia/Seoul"]),
        Currency(id: "SGD", label: "Singapore Dollars", emoji: "🇸🇬", continent: "Asia", timezones: ["Asia/Singapore"]),
        Currency(id: "HKD", label: "Hong Kong Dollars", emoji: "🇭🇰", continent: "Asia", timezones: ["Asia/Hong_Kong"]),
        Currency(id: "TWD", label: "New Taiwan Dollar", emoji: "🇹🇼", continent: "Asia", timezones: ["Asia/Taipei"]),
        Currency(id: "MYR", label: "Malaysian Ringgit", emoji: "🇲🇾", continent: "Asia", timezones: ["Asia/Kuala_Lumpur"]),
        Currency(id: "THB", label: "Thai Baht", emoji: "🇹🇭", continent: "Asia", timezones: ["Asia/Bangkok"]),
        Currency(id: "IDR", label: "Indonesian Rupiah", emoji: "🇮🇩", continent: "Asia", timezones: [
            "Asia/Jakarta", "Asia/Pontianak", "Asia/Makassar", "Asia/Jayapura"
        ]),
        Currency(id: "PHP", label: "Philippine Peso", emoji: "🇵🇭", continent: "Asia", timezones: ["Asia/Manila"]),
        Currency(id: "VND", label: "Vietnamese Dong", emoji: "🇻🇳", continent: "Asia", timezones: ["Asia/Ho_Chi_Minh"]),

        // Oceania
        Currency(id: "AUD", label: "Australian Dollars", emoji: "🇦🇺", continent: "Oceania", timezones: [
            "Australia/Sydney", "Australia/Melbourne", "Australia/Brisbane",
            "Australia/Perth", "Australia/Adelaide", "Australia/Darwin", "Australia/Hobart"
        ]),
        Currency(id: "NZD", label: "New Zealand Dollars", emoji: "🇳🇿", continent: "Oceania", timezones: ["Pacific/Auckland", "Pacific/Chatham"]),

        // Africa
        Currency(id: "ZAR", label: "South African Rand", emoji: "🇿🇦", continent: "Africa", timezones: ["Africa/Johannesburg"]),
        Currency(id: "EGP", label: "Egyptian Pound", emoji: "🇪🇬", continent: "Africa", timezones: ["Africa/Cairo"]),
    ]
}
