import Foundation

// MARK: - Корневая структура ответа
struct CurrencyResponse: Codable {
    let date: String
    let previousDate: String
    let previousURL: String
    let timestamp: String
    let valute: [String: Valute]
    
    enum CodingKeys: String, CodingKey {
        case date = "Date"
        case previousDate = "PreviousDate"
        case previousURL = "PreviousURL"
        case timestamp = "Timestamp"
        case valute = "Valute"
    }
}

// MARK: - Отдельная валюта
struct Valute: Codable, Identifiable {
    let id = UUID()
    let internalID: String
    let numCode: String
    let charCode: String
    let nominal: Int
    let name: String
    let value: Double
    let previous: Double
    
    enum CodingKeys: String, CodingKey {
        case internalID = "ID"
        case numCode = "NumCode"
        case charCode = "CharCode"
        case nominal = "Nominal"
        case name = "Name"
        case value = "Value"
        case previous = "Previous"
    }
    
    var change: Double {
        return value - previous
    }
    
    var changePercentage: Double {
        return (change / previous) * 100
    }
}
