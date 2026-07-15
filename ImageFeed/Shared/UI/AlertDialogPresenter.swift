import Foundation
import UIKit

enum AlertDialogPresenter {
    static func show(vc: UIViewController, model: AlertDialogViewModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.subTitle,
            preferredStyle: .alert
        )

        let alertAction = UIAlertAction(
            title: model.actionTitle,
            style: .default,
            handler: { _ in
                model.action()
            }
        )

        if let cancelTitle = model.cancelTitle {
            let cancelAction = UIAlertAction(
                title: cancelTitle,
                style: .cancel,
                handler: nil
            )
            alert.addAction(cancelAction)
        }

        alert.addAction(alertAction)
        vc.present(alert, animated: true, completion: nil)
    }
}

struct AlertDialogViewModel {
    let title: String
    let subTitle: String
    let actionTitle: String
    var cancelTitle: String? = nil
    let action: () -> Void

    static func defaultError() -> AlertDialogViewModel {
        AlertDialogViewModel(
            title: "Что то пошло не так",
            subTitle: "Попробуйте чуть позже",
            actionTitle: "OK",
            action: {}
        )
    }
}
