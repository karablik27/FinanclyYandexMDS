enum SortOption: String, CaseIterable, Identifiable {
    case date = "По дате"
    case amount = "По сумме"
    var id: Self {
        self
    }
}
