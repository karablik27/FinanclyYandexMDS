import SwiftUI
import UIKit

// MARK: - Constants
private enum Constants {
    static let sidePadding: CGFloat = 16
    static let rowPadding: CGFloat = 12
    static let cornerRadius: CGFloat = 12
    static let verticalGap: CGFloat = 16
    static let rowGap: CGFloat = 8
}

// MARK: - BankAccount View
struct BankAccountView: View {

    // Dependencies
    @StateObject private var vm = BankAccountViewModel()

    // State
    @AppStorage("currencyCode") private var currencyCode = Currency.rub.rawValue
    @FocusState private var isFocused: Bool
    @State private var showCurrencyDialog = false
    @State private var hideBalance = true

    // MARK: Body
    var body: some View {
        NavigationView {
            VStack(spacing: Constants.verticalGap) {

                // Header
                Text("Мой счёт")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Constants.sidePadding)

                // Rows + Pull-to-Refresh
                ScrollView {
                    VStack(spacing: Constants.rowGap) {
                        balanceRow
                        currencyRow
                            .onTapGesture {
                                if vm.isEditing { showCurrencyDialog = true }
                            }
                    }
                    .padding(.horizontal, Constants.sidePadding)
                    .padding(.top, Constants.verticalGap)
                }
                .refreshable { await vm.loadAccount() }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)

            // Toolbar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(vm.isEditing ? "Сохранить" : "Редактировать") {

                        if vm.isEditing {                        // tapped “Save”
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil, from: nil, for: nil
                            )
                            hideBalance = true                   // hide again
                        }
                        vm.toggleEditing()
                        isFocused = false
                    }
                    .foregroundColor(Color(hex: "#6F5DB7"))
                }
            }

            // Currency picker dialog
            .confirmationDialog(
                "Валюта",
                isPresented: $showCurrencyDialog,
                titleVisibility: .visible
            ) {
                ForEach(Currency.allCases) { cur in
                    Button(cur.displayName) {
                        if cur.rawValue != currencyCode {
                            currencyCode = cur.rawValue
                        }
                    }
                    .foregroundColor(Color(hex: "#6F5DB7"))
                }
            }
            .tint(Color(hex: "#6F5DB7"))

            // Swipe anywhere → hide keyboard
            .gesture(
                DragGesture().onChanged { _ in
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
            )

            // Shake detector
            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in
                withAnimation { hideBalance.toggle() }
            }
            .overlay(
                ShakeDetectorView()
                    .allowsHitTesting(false)
                    .id(vm.isEditing)
            )
        }
        // Ensure balance is hidden when leaving edit mode
        .onChange(of: vm.isEditing) { _, editing in
            if !editing { hideBalance = true }
        }
    }

    // MARK: Balance Row
    private var balanceRow: some View {
        HStack {
            Text("💰 Баланс")
            Spacer()

            if vm.isEditing {
                TextField("", text: $vm.balanceInput)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused($isFocused)
                    .onChange(of: vm.balanceInput) { _, new in
                        vm.balanceInput = vm.sanitize(new)
                    }
            } else {
                Text(
                    (vm.account?.balance ?? 0).formatted(
                        .currency(code: currencyCode)
                            .locale(Locale(identifier: "ru_RU"))
                            .precision(.fractionLength(0))
                    )
                )
                .foregroundColor(.black)
                .spoiler(isOn: $hideBalance)        // тг эффект лол
            }
        }
        .padding(Constants.rowPadding)
        .frame(maxWidth: .infinity)
        .background(
            vm.isEditing ? Color(.systemBackground) : Color.accentColor
        )
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .contentShape(Rectangle())
        .onTapGesture { if vm.isEditing { isFocused = true } }
    }

    // MARK: Currency Row
    private var currencyRow: some View {
        HStack {
            Text("Валюта")
            Spacer()
            Text(Currency(rawValue: currencyCode)?.symbol ?? "₽")
                .foregroundColor(vm.isEditing ? Color(hex: "#6F5DB7") : .primary)

            if vm.isEditing {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding(Constants.rowPadding)
        .frame(maxWidth: .infinity)
        .background(
            vm.isEditing
            ? Color(.systemBackground)
            : Color.accentColor.opacity(0.20)
        )
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
    }
}
