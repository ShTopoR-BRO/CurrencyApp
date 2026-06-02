import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CurrencyViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон с поддержкой темы
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.currencies.isEmpty {
                    ProgressView("Загрузка курсов валют...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                } else if let error = viewModel.errorMessage, viewModel.currencies.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Ошибка загрузки")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(error)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        Button("Повторить") {
                            viewModel.refresh()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                    }
                    .padding()
                } else {
                    List(viewModel.currencies) { currency in
                        CurrencyRow(currency: currency)
                            .listRowBackground(Color(UIColor.secondarySystemBackground))
                    }
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Курсы валют ЦБ РФ")
            .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                // Кнопка переключения темы
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                
                // Кнопка обновления
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refresh()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.accentColor)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .overlay(alignment: .bottom) {
                if !viewModel.lastUpdateDate.isEmpty {
                    Text("Обновлено: \(viewModel.lastUpdateDate)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                        .padding(.horizontal)
                        .background(
                            Color(UIColor.systemBackground)
                                .opacity(0.9)
                                .cornerRadius(8)
                        )
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct CurrencyRow: View {
    let currency: Valute
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(currency.charCode)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(width: 50, alignment: .leading)
                
                Text(currency.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Text("\(currency.nominal) ед.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("\(currency.value, specifier: "%.4f") ₽")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                ChangeIndicator(change: currency.change, percentage: currency.changePercentage)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ChangeIndicator: View {
    let change: Double
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                .font(.caption)
            
            Text("\(change, specifier: "%+.4f")")
                .font(.caption)
                .fontWeight(.medium)
            
            Text("(\(percentage, specifier: "%+.2f")%)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .foregroundColor(change >= 0 ? .green : .red)
    }
}

#Preview {
    ContentView()
}
