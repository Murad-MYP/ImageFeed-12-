import UIKit

final class TabBarController: UITabBarController {
    static let identifier = "TabBarViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imagesListVC = ImagesListViewController()
        let profileVC = ProfileViewController()
        
        let imagesNavVC = UINavigationController(rootViewController: imagesListVC)
        imagesListVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named:"tab_editorial_active"), tag: 0)
        
        let profileNavVC = UINavigationController(rootViewController: profileVC)
        profileVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named:"tab_profile_active"), tag: 1)
        
        viewControllers = [imagesNavVC, profileNavVC]
        
        setupTabBarController()
        setupNavigationBar(for: imagesNavVC)
        setupNavigationBar(for: profileNavVC)
    }
    
    private func setupTabBarController(){
        tabBar.barTintColor = .ypLightBlack
        tabBar.isTranslucent = false
        tabBar.tintColor = .ypWhite
        tabBar.unselectedItemTintColor = .ypDarkGray
        view.backgroundColor = .ypLightBlack
        navigationController?.navigationBar.barTintColor = .ypLightBlack
        navigationController?.navigationBar.isTranslucent = false
    }
    
    private func setupNavigationBar(for navigationController: UINavigationController) {
        navigationController.navigationBar.isHidden = true
    }
}
