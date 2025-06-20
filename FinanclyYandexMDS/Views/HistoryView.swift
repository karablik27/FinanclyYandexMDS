import SwiftUI

// MARK: - Constants
private enum Constants {
    static let sectionSpacing: CGFloat = 16
    static let horizontalPadding: CGFloat = 16
    static let verticalPaddingPeriod: CGFloat = 6
    static let periodRowHeight: CGSize = CGSize(width: 120, height: 36)
    static let periodRowCornerRadius: CGFloat = 8
    static let segmentPickerWidth: CGFloat = 200
    static let periodVerticalDividerPadding: CGFloat = 12
    static let amountSectionVerticalPadding: CGFloat = 12
    static let captionSpacing: CGFloat = 16
    static let operationIconSize: CGFloat = 32
    static let operationIconOverlayPadding: CGFloat = 12
    static let operationRowSpacing: CGFloat = 12
    static let operationRowVerticalPadding: CGFloat = 8
    static let dividerIndent: CGFloat = 44
}

// MARK: - HistoryView

struct HistoryView: View {

    // MARK: - Properties
    let direction: Direction
    @StateObject private var vm: HistoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var sortBy: SortOption = .date

    private let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"
        f.locale = Locale(identifier: "ru_RU")
        return f
    }()

    // MARK: - Init
    init(direction: Direction) {
        self.direction = direction
        _vm = StateObject(wrappedValue: HistoryViewModel(direction: direction))
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: Constants.sectionSpacing) {
                
                // MARK: - Header
                Text("Моя история")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Constants.horizontalPadding)

                // MARK: - Period & Summary Section
                VStack(spacing: 0) {
                    periodRow(
                        title: "Начало",
                        date: Binding(
                            get: {
                                vm.startDate
                            },
                            set: { new in
                                vm.startDate = new
                                if new > vm.endDate {
                                    vm.endDate = new
                                }
                                Task {
                                    await vm.load()
                                }
                            }
                        )
                    )
                    Divider()
                    periodRow(
                        title: "Конец",
                        date: Binding(
                            get: {
                                vm.endDate
                            },
                            set: { new in
                                vm.endDate = new
                                if new < vm.startDate {
                                    vm.startDate = new
                                }
                                Task {
                                    await vm.load()
                                }
                            }
                        )
                    )
                    Divider()
                    HStack {
                        Text("Сортировка").font(.body)
                        Spacer()
                        Picker("", selection: $sortBy) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: Constants.segmentPickerWidth)
                    }
                    .padding(.vertical, Constants.periodVerticalDividerPadding)
                    .padding(.horizontal, Constants.horizontalPadding)
                    Divider()
                    HStack {
                        Text("Сумма")
                        Spacer()
                        Text(
                            vm.total.formatted(
                                .currency(code: "RUB")
                                    .locale(Locale(identifier: "ru_RU"))
                                    .precision(.fractionLength(0))
                            )
                        )
                    }
                    .padding(.vertical, Constants.amountSectionVerticalPadding)
                    .padding(.horizontal, Constants.horizontalPadding)
                }
                .background(Color(.systemBackground))
                .cornerRadius(Constants.periodRowCornerRadius)
                .padding(.horizontal, Constants.horizontalPadding)

                // MARK: - Operations Header
                Text("ОПЕРАЦИИ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Constants.horizontalPadding)

                // MARK: - Operations List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedTransactions, id: \.id) { tx in
                            operationRow(tx)
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(Constants.periodRowCornerRadius)
                    .padding(.horizontal, Constants.horizontalPadding)
                }

                Spacer(minLength: Constants.sectionSpacing)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                
                // MARK: - Toolbar Buttons
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Назад")
                        }
                        .foregroundColor(Color(hex: "#6F5DB7"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // пока пусто
                    } label: {
                        Image(systemName: "doc")
                    }
                    .foregroundColor(Color(hex: "#6F5DB7"))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Sorted Transactions
    private var sortedTransactions: [Transaction] {
        switch sortBy {
        case .date:
            return vm.transactions.sorted { $0.transactionDate < $1.transactionDate }
        case .amount:
            return vm.transactions.sorted { $0.amount < $1.amount }
        }
    }
    
    // Вот это потом может в отдельный файл вынесу если где-то переиспользовать буду.
    // MARK: - Period Row
    @ViewBuilder
    private func periodRow(title: String, date: Binding<Date>) -> some View {
        HStack {
            Text(title)
            Spacer()
            ZStack {
                Text(df.string(from: date.wrappedValue))
                    .font(.callout)
                    .foregroundColor(.primary)
                    .frame(width: Constants.periodRowHeight.width,
                           height: Constants.periodRowHeight.height)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(Constants.periodRowCornerRadius)

                DatePicker("", selection: date, displayedComponents: [.date])
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(.accentColor)
                    .frame(width: Constants.periodRowHeight.width,
                           height: Constants.periodRowHeight.height)
                    .blendMode(.destinationOver)
                    .onChange(of: date.wrappedValue) { _, _ in}
            }
        }
        .padding(.vertical, Constants.verticalPaddingPeriod)
        .padding(.horizontal, Constants.horizontalPadding)
    }

    // MARK: - Operation Row
    @ViewBuilder
    private func operationRow(_ tx: Transaction) -> some View {
        HStack(spacing: Constants.operationRowSpacing) {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: Constants.operationIconSize, height: Constants.operationIconSize)
                .overlay(Text(String(tx.category.emoji)).font(.body))

            VStack(alignment: .leading, spacing: 2) {
                Text(tx.category.name).font(.body)
                if let c = tx.comment {
                    Text(c).font(.caption2).foregroundColor(.gray)
                }
            }

            Spacer()

            Text(
                tx.amount.formatted(
                    .currency(code: "RUB")
                        .locale(Locale(identifier: "ru_RU"))
                        .precision(.fractionLength(0))
                )
            )
            .font(.body)

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.vertical, Constants.operationRowVerticalPadding)
        .padding(.horizontal, Constants.operationIconOverlayPadding)
        Divider().padding(.leading, Constants.dividerIndent)
    }
}
