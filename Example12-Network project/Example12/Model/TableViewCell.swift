

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var mediaL:UILabel!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
