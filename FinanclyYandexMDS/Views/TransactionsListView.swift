import SwiftUI

private enum Constants {
    static let navigationHorizontalPadding: CGFloat = 16
    static let sectionVerticalSpacing: CGFloat = 16
    static let titleHorizontalPadding: CGFloat = 16
    static let totalVerticalPadding: CGFloat = 12
    static let totalHorizontalPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 12
    static let operationsCaptionHorizontalPadding: CGFloat = 16
    static let cellVerticalPadding: CGFloat = 8
    static let cellHorizontalPadding: CGFloat = 12
    static let iconSize: CGFloat = 32
    static let iconPaddingLeadingOutcome: CGFloat = 44
    static let iconPaddingLeadingIncome: CGFloat = 12
    static let overlayButtonSize: CGFloat = 16
    static let overlayButtonPaddingTrailing: CGFloat = 16
    static let overlayButtonPaddingBottom: CGFloat = 24
    static let overlayButtonFontSize: CGFloat = 20
}

struct TransactionsListView: View {
    let direction: Direction
    @StateObject private var viewModel: TransactionsListViewModel
    @AppStorage("currencyCode") private var currencyCode: String = Currency.rub.rawValue
    @State private var activeForm: AddTransactionForm?

    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(wrappedValue: TransactionsListViewModel(direction: direction))
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: Constants.sectionVerticalSpacing) {
                Text(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                    .font(.largeTitle.bold())
                    .padding(.horizontal, Constants.titleHorizontalPadding)

                HStack {
                    Text("Всего")
                        .font(.headline)
                    Spacer()
                    Text(viewModel.total.formatted(
                        .currency(code: currencyCode)
                            .locale(Locale(identifier: "ru_RU"))
                            .precision(.fractionLength(0))
                    ))
                    .font(.headline)
                }
                .padding(.vertical, Constants.totalVerticalPadding)
                .padding(.horizontal, Constants.totalHorizontalPadding)
                .background(Color(.systemBackground))
                .cornerRadius(Constants.cardCornerRadius)
                .padding(.horizontal, Constants.navigationHorizontalPadding)

                Text("ОПЕРАЦИИ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Constants.operationsCaptionHorizontalPadding)

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.transactions, id: \.id) { tx in
                            Button {
                                activeForm = .edit(transaction: tx)
                            } label: {
                                TransactionRowView(
                                    transaction: tx,
                                    currencyCode: currencyCode,
                                    direction: direction
                                )
                            }
                            .buttonStyle(PlainButtonStyle())

                            if tx.id != viewModel.transactions.last?.id {
                                Divider()
                                    .padding(.leading,
                                        direction == .outcome
                                            ? Constants.iconPaddingLeadingOutcome
                                            : Constants.iconPaddingLeadingIncome
                                    )
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: Constants.cardCornerRadius, style: .continuous))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, Constants.navigationHorizontalPadding)
                }

                Spacer(minLength: Constants.sectionVerticalSpacing)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        HistoryView(direction: direction)
                    } label: {
                        Image(systemName: "clock")
                            .foregroundColor(Color(hex: "#6F5DB7"))
                    }
                }
            }
            .overlay(
                Button {
                    activeForm = .create(direction: direction)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: Constants.overlayButtonFontSize))
                        .foregroundColor(.white)
                        .padding(Constants.overlayButtonSize)
                        .background(Circle().fill(Color.accentColor))
                }
                .padding(.trailing, Constants.overlayButtonPaddingTrailing)
                .padding(.bottom, Constants.overlayButtonPaddingBottom),
                alignment: .bottomTrailing
            )
            .fullScreenCover(item: $activeForm) { form in
                AddTransactionView(mode: form)
            }
        }
    }
}
