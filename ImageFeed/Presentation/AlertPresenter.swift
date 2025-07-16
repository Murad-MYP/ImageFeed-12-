import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(with model: AlertModel) {
        let alert = UIAlertController (title: model.title,
                                       message: model.message,
                                       preferredStyle: .alert)
        
        let actionOne = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(actionOne)
        
#if DEBUG
        actionOne.setValue("No", forKey: "accessibilityIdentifier")
#endif
        
        if model.hasSecondButton {
            let actionTwo = UIAlertAction(title: model.secondButtonText, style: .cancel) { _ in
                model.secondButtonCompletion?()
            }
            alert.addAction(actionTwo)
            
            // Устанавливаем accessibilityIdentifier для кнопки "Да"
#if DEBUG
            actionTwo.setValue("Yes", forKey: "accessibilityIdentifier")
#endif
            
        }
        
        viewController?.present(alert, animated: true, completion: nil)
        
#if DEBUG
        alert.view.accessibilityIdentifier = "AlertPresenter"
#endif
    }
}
