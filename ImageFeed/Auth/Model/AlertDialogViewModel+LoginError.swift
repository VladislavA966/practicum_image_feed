import Foundation

extension AlertDialogViewModel {
    static func loginError() -> AlertDialogViewModel {
        return AlertDialogViewModel(
            title: "Что то пошло не так",
            subTitle: "Не удалось войти в систему",
            actionTitle: "OK",
            action: {}
        )
    }
}
