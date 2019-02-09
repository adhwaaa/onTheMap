
import UIKit
import MapKit

class ConfirmLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var location: StudentLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMap()
    }
    
    @IBAction func finishButton(_ sender: UIButton) {
        
        API.Parser.postLocation(self.location!) { errs  in
            guard errs == nil else {
                self.showAlert(title: "Error", message: errs!)
                return
            }
            
           

        }
         self.navigationController?.popToRootViewController(animated: true)
         self.dismiss(animated: true, completion: nil)
      
        }
        
    
    
    private func setupMap() {
        guard let loc = location else { return }
        
        let lati = CLLocationDegrees(loc.latitude!)
        let longi = CLLocationDegrees(loc.longitude!)
        
        let coordinate = CLLocationCoordinate2D(latitude: lati, longitude: longi)
        
  
        let annot = MKPointAnnotation()
      
        annot.coordinate = coordinate
        annot.title = loc.mapString
        mapView.addAnnotation(annot)
        
        let reg = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(reg, animated: true)
    }

}

extension ConfirmLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinV = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinV == nil {
            pinV = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinV!.canShowCallout = true
            pinV!.pinTintColor = .red
            pinV!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinV!.annotation = annotation
        }
        
        return pinV
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let tOpen = view.annotation?.subtitle!,
                let url = URL(string: tOpen), app.canOpenURL(url) {
                app.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
