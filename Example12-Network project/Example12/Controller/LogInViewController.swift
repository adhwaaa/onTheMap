

import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToNotificationsObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromNotificationsObserver()
    }
    
    private func setupUI() {
        email.delegate = self
        password.delegate = self
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        if let url = URL(string: "https://www.udacity.com/account/auth#!/signup"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    //username: email.text!, password: password.text!
    @IBAction func logIn(_ sender: UIButton) {
        API.postSession(username: email.text!, password: password.text!) { (errorS) in
            guard errorS == nil else {
                self.showAlert(title: "Error", message: errorS!)
                return
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "Login", sender: nil)
            }
        }
    }
}
