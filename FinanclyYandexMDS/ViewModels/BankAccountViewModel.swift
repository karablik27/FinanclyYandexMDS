import SwiftUI
import Foundation

@MainActor
final class BankAccountViewModel: ObservableObject {

    // — Published
    @Published var account: BankAccount?
    @Published var isEditing          = false
    @Published var balanceInput       = ""
    @Published var selectedCurrency   = Currency.rub
    @Published var showCurrencyPicker = false
    @Published var error: Error?

    private let service = BankAccountsService()

    // MARK: init / load
    init() { Task { await loadAccount() } }

    func loadAccount() async {
        let acc = await service.getAccount()
        account            = acc
        selectedCurrency   = Currency(rawValue: acc.currency) ?? .rub
        balanceInput       = Self.format(acc.balance)
    }

    // MARK: Edit toggle
    func toggleEditing() {
        if isEditing {
            Task { await saveChanges() }
        } else if let acc = account {
            balanceInput     = Self.format(acc.balance)
            selectedCurrency = Currency(rawValue: acc.currency) ?? .rub
        }
        isEditing.toggle()
    }

    // MARK: Save
    private func saveChanges() async {
        guard let old = account,
              let newBal = Decimal(string: sanitize(balanceInput))
        else { return }

        let updated = BankAccount(
            id:         old.id,
            userId:     old.userId ?? 0,
            name:       old.name,
            balance:    newBal,
            currency:   selectedCurrency.rawValue,
            createdAt:  old.createdAt ?? Date(),
            updatedAt:  Date()
        )
        await service.updateAccount(updated)
        account      = updated
        balanceInput = Self.format(newBal)
    }

    // MARK: Helpers
    func sanitize(_ text: String) -> String {
        var clean = text
            .replacingOccurrences(of: ",", with: ".")
            .filter { "0123456789.".contains($0) }

        if let dot = clean.firstIndex(of: ".") {
            let after = clean.index(after: dot)
            clean = String(clean[..<after])
                  + clean[after...].replacingOccurrences(of: ".", with: "")
        }
        return clean
    }

    private static func format(_ value: Decimal) -> String {
        let f = NumberFormatter()
        f.numberStyle            = .decimal
        f.maximumFractionDigits  = 0
        return f.string(for: value) ?? "0"
    }
}
