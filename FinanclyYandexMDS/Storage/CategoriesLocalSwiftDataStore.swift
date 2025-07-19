import Foundation
import SwiftData

@MainActor
final class CategoriesLocalSwiftDataStore: CategoriesLocalStore {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func saveAll(_ categories: [Category]) async throws {
        let context = container.mainContext

        for category in categories {
            let descriptor = FetchDescriptor<CategoryEntity>(
                predicate: #Predicate { $0.id == category.id }
            )

            if let existing = try context.fetch(descriptor).first {
                existing.name = category.name
                existing.emoji = String(category.emoji)
                existing.direction = category.isIncome
            } else {
                let entity = CategoryEntity(
                    id: category.id,
                    name: category.name,
                    emoji: String(category.emoji),
                    direction: category.isIncome
                )
                context.insert(entity)
            }
        }

        try context.save()
    }

    func getAll() async throws -> [Category] {
        let context = container.mainContext
        let entities = try context.fetch(FetchDescriptor<CategoryEntity>())
        return entities.map { $0.toModel() }
    }
}
