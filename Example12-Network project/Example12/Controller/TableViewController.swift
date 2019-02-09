
import UIKit

class TableViewController: ContainerViewController {
    
    @IBOutlet weak var tView: UITableView!
    
    override var locationsData: LocationsData? {
        didSet {
            guard let locationsData = locationsData else { return }
            locations = locationsData.studentLocations
        }
    }
    var locations: [StudentLocation] = [] {
        didSet {
            tView.reloadData()
        }
    }

}


extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    
 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as!
        TableViewCell
        c.mediaL?.text = locations[indexPath.row].mediaURL
        c.nameL?.text = locations[indexPath.row].firstName
        return c
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt iPath: IndexPath) {
        
        tableView.deselectRow(at: iPath,animated: true)
        let sL = locations[iPath.row]
        let media = sL.mediaURL!
        let mediaUrl = URL(string: media)!
        UIApplication.shared.open(mediaUrl, options: [:], completionHandler: nil)
    }
    
}
