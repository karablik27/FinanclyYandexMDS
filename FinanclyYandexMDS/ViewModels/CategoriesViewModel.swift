import Foundation
import Combine

@MainActor
final class CategoriesViewModel: ObservableObject {
    
    // MARK: Published
    @Published private(set) var categories: [Category] = []
    @Published var searchText: String = ""
    
    // MARK: Service
    private let service = CategoriesService()
    
    // MARK: Init / load
    init() { Task { await load() } }
    
    func load() async { categories = await service.all() }
    
    // MARK: Fuzzy-filtered list (lazy)
    var filteredCategories: [Category] {
        guard !searchText.isEmpty else { return categories }
        
        let pattern = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        let scored = categories.compactMap { cat -> (Category, Int)? in
            let score = fuzzyScore(source: cat.name.lowercased(),
                                   pattern: pattern)
            return score == .min ? nil : (cat, score)
        }
        
        return scored
            .sorted { lhs, rhs in
                lhs.1 == rhs.1
                ? lhs.0.name < rhs.0.name
                : lhs.1 > rhs.1
            }
            .map(\.0)
    }
}

// MARK: – Fuzzy-score helper
private func fuzzyScore(source: String, pattern: String) -> Int {
    var srcIdx = source.startIndex
    var patIdx = pattern.startIndex
    var score  = 0
    var lastHit = source.startIndex
    
    while patIdx < pattern.endIndex, srcIdx < source.endIndex {
        if source[srcIdx] == pattern[patIdx] {
            let gap = source.distance(from: lastHit, to: srcIdx)
            score += 1 - gap
            lastHit = srcIdx
            patIdx  = pattern.index(after: patIdx)
        }
        srcIdx = source.index(after: srcIdx)
    }
    
    return patIdx == pattern.endIndex ? score : .min
}
