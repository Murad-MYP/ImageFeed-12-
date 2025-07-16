import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    /// Анимированное обновление таблицы при изменении количества фотографий
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    
    /// Отображение алерта с ошибкой
    func showErrorAlert(with title: String, message: String)
    
    /// Обновление лайка у конкретной фотографии по её ID
    func updateCellLikeStatus(for photoId: String)
}
protocol ImagesListCellProtocol: AnyObject {
    func setImage(from url: URL)
    func setIsLiked(_ isLiked: Bool)
}

