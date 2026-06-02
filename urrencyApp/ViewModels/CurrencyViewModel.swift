import Foundation
import Combine
import SwiftUI

class CurrencyViewModel: ObservableObject {
    @Published var currencies: [Valute] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdateDate: String = ""
    
    private let service: CurrencyServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(service: CurrencyServiceProtocol = CurrencyService()) {
        self.service = service
        loadCurrencies()
    }
    
    func loadCurrencies() {
        isLoading = true
        errorMessage = nil
        
        service.fetchCurrencies()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] response in
                self?.currencies = Array(response.valute.values).sorted { $0.charCode < $1.charCode }
                self?.lastUpdateDate = self?.formatDate(response.date) ?? ""
            })
            .store(in: &cancellables)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd.MM.yyyy HH:mm"
            return displayFormatter.string(from: date)
        }
        return dateString
    }
    
    func refresh() {
        loadCurrencies()
    }
}
