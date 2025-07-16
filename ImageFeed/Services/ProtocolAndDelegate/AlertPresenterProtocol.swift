import Foundation

protocol AlertPresenterProtocol: AnyObject {
    func showAlert(with model: AlertModel)
}
