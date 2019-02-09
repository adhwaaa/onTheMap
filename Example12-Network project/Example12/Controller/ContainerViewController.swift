

import UIKit

class ContainerViewController: UIViewController {
    
    var locationsData: LocationsData? 

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadStudentLocations()
    }
    
    func setupUI() {
        let AddButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addLocation(_:)))
        let TherefreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshLocations(_:)))
        let thelogoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(self.logout(_:)))
        
        navigationItem.rightBarButtonItems = [AddButton, TherefreshButton]
        navigationItem.leftBarButtonItem = thelogoutButton
    }
    
    @objc private func addLocation(_ sender: Any) {
        let naviController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddLocationNaviController") as! UINavigationController
        
        present(naviController, animated: true, completion: nil)
    }
    
    @objc private func refreshLocations(_ sender: Any) {
        loadStudentLocations()
    }
    
    @objc private func logout(_ sender: Any) {
     
        API.Parser.deleteSession(completion: { err in })
        dismiss(animated: true, completion: nil)
    }
    
    private func loadStudentLocations() {
        API.Parser.getStudentLocations { (data) in
            guard let dataT = data else {
                self.showAlert(title: "Error", message: " check your internet connection ")
                return
            }
            guard dataT.studentLocations.count > 0 else {
                self.showAlert(title: "Error", message: "No pins located")
                return
            }
            self.locationsData = dataT
        }
        
      
        
    }

}
