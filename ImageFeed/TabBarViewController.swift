import UIKit

final class TabBarViewController: UITabBarController {

    override func awakeFromNib() {
        super.awakeFromNib()

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
              withIdentifier: "ImagesListViewController"
          )

//        let imageListViewController = ImagesListViewController()
        let profileViewController = ProfileViewController()

//        imageListViewController.tabBarItem = UITabBarItem(
//            title: "",
//            image: UIImage(named: "tab_editorial_active"),
//            selectedImage: nil
//        )

        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }

}
