import Foundation

final class BankAccountsService {
    // MARK: - Dependencies
    private let client: NetworkClient

    // MARK: - Init
    init(client: NetworkClient) {
        self.client = client
    }

    // MARK: - Public Methods

    /// Получает первый банковский счёт пользователя
    func getAccount() async throws -> BankAccount {
        let accounts: [BankAccount] = try await client.request(
            path: "accounts",
            method: "GET",
            body: Optional<EmptyRequest>.none
        )

        guard let first = accounts.first else {
            throw NSError(domain: "BankAccountsService", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "У пользователя нет ни одного счёта"
            ])
        }

        return first
    }

    /// Обновляет счёт
    func updateAccount(id: Int, name: String, balance: Decimal, currency: String) async throws -> BankAccount {
        struct UpdateRequest: Encodable {
            let name: String
            let balance: String
            let currency: String
        }

        let body = UpdateRequest(
            name: name,
            balance: "\(balance)", // формат должен быть строкой
            currency: currency
        )

        return try await client.request(
            path: "accounts/\(id)",
            method: "PUT",
            body: body
        )
    }
}

extension BankAccountsService {
    func getAccount(withId id: Int) async throws -> BankAccount {
        let accounts: [BankAccount] = try await client.request(
            path: "accounts",
            method: "GET",
            body: Optional<EmptyRequest>.none
        )
        guard let account = accounts.first(where: { $0.id == id }) else {
            throw NSError(domain: "BankAccountsService", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Счёт с id \(id) не найден"
            ])
        }
        return account
    }
}

