enum AddTransactionForm: Identifiable, Equatable {
    case create(direction: Direction)
    case edit(transaction: Transaction)

    var isCreate: Bool {
        if case .create = self { true } else { false }
    }

    var isEdit: Bool { !isCreate }

    var direction: Direction {
        switch self {
        case .create(let dir): return dir
        case .edit(let tx):    return tx.category.direction
        }
    }

    var transaction: Transaction? {
        switch self {
        case .edit(let tx): return tx
        case .create:       return nil
        }
    }

    var id: String {
        switch self {
        case .create(let dir): return "create-\(String(describing: dir))"
        case .edit(let tx):    return "edit-\(tx.id)"
        }
    }
    
    static func == (lhs: AddTransactionForm, rhs: AddTransactionForm) -> Bool {
            switch (lhs, rhs) {
            case let (.create(ld), .create(rd)):
                return ld == rd
            case let (.edit(ltx), .edit(rtx)):
                return ltx.id == rtx.id
            default:
                return false
            }
        }
}
