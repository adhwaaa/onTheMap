
import UIKit
import CoreLocation

// This is on the map project used for udacity nano degree


class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var locTextField: UITextField!
    @IBOutlet weak var mediaLTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @IBAction func findLoc(_ sender: UIButton) {
        guard let location = locTextField.text,
              let mediaLink = mediaLTextField.text,
              location != "", mediaLink != "" else {
            self.showAlert(title: "Missing information", message: "Please fill both fields and try again")
            return
        }
        
        let studentLocation = StudentLocation(mapString: location, mediaURL: mediaLink)
        geocodeCoordinates(studentLocation)
    }
    
    private func geocodeCoordinates(_ studentLocation: StudentLocation) {
        
        let point = self.startAnActivityIndicator()
       
        CLGeocoder().geocodeAddressString(studentLocation.mapString!) { (placeMarks, err) in
            point.stopAnimating()
            if let error = err{
                self.showAlert(title: "Error", message: "Geocoding fails")
                return
            }
            
            guard let firstLocation = placeMarks?.first?.location else {
                self.showAlert(title: "Missing information", message: "location not found")
                return }
            
            var location = studentLocation
            location.latitude = firstLocation.coordinate.latitude
            location.longitude = firstLocation.coordinate.longitude

            
            self.performSegue(withIdentifier: "mapS", sender: location)
        }
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapS", let viewC = segue.destination as? ConfirmLocationViewController {
            viewC.location = (sender as! StudentLocation)
        }
    }
    
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.cancel(_:)))
        
        locTextField.delegate = self
        mediaLTextField.delegate = self
    }
    
    @objc private func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}


