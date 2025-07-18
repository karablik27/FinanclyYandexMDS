import Foundation

final class CategoriesService {
    private let client: NetworkClient

    init(client: NetworkClient) {
        self.client = client
    }

    func all() async throws -> [Category] {
        return try await client.request(
            path: "categories",
            method: "GET",
            body: Optional<EmptyRequest>.none
        )
    }



    func byDirection(_ direction: Direction) async throws -> [Category] {
        let allCategories = try await all()
        return allCategories.filter { $0.direction == direction }
    }
}

extension CategoriesService {
    func getCategory(withId id: Int) async throws -> Category {
        let categories: [Category] = try await all()
        guard let category = categories.first(where: { $0.id == id }) else {
            throw NSError(domain: "CategoriesService", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Категория с id \(id) не найдена"
            ])
        }
        return category
    }
}
