import Foundation
import Combine

protocol CurrencyServiceProtocol {
    func fetchCurrencies() -> AnyPublisher<CurrencyResponse, Error>
}

class CurrencyService: CurrencyServiceProtocol {
    private let urlString = "https://www.cbr-xml-daily.ru/daily_json.js"
    
    func fetchCurrencies() -> AnyPublisher<CurrencyResponse, Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CurrencyResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
