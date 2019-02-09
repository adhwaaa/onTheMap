

import UIKit
import MapKit

class MapViewController: ContainerViewController, MKMapViewDelegate {
    
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var mapView: MKMapView!
    
    override var locationsData: LocationsData? {
        didSet {
            updateMyPins()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func updateMyPins() {
        guard let locations = locationsData?.studentLocations else { return }
        
        
        var annotations = [MKPointAnnotation]()
        
       
        for loc in locations {
        
            guard let latitude = loc.latitude, let longitude = loc.longitude else { continue }
            let lati = CLLocationDegrees(latitude)
            let longi = CLLocationDegrees(longitude)
            
            let coordination = CLLocationCoordinate2D(latitude: lati, longitude: longi)
            
            let firstL = loc.firstName
            let lastL = loc.lastName
            let mediaURL = loc.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordination
            annotation.title = "\(firstL ?? "") \(lastL ?? "")"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reUsedId = "pin"
        
        var pinV = mapView.dequeueReusableAnnotationView(withIdentifier: reUsedId) as? MKPinAnnotationView

        if pinV == nil {
            pinV = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reUsedId)
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
            let MyApp = UIApplication.shared
            if let OpenIt = view.annotation?.subtitle!,
                let url = URL(string: OpenIt), MyApp.canOpenURL(url) {
                MyApp.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
