//
//  ChooseAddressTVCell.swift
//  PassengerApp
//
//  Created by ADMIN on 11/10/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class ChooseAddressTVCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var deleteImgView: UIImageView!
    @IBOutlet weak var addressLbl: MyLabel!
    @IBOutlet weak var selectImgView: UIImageView!
    @IBOutlet weak var serviceNotAvailLbl: MyLabel!
    @IBOutlet weak var selImgCenter: NSLayoutConstraint!
    @IBOutlet weak var addLblCenter: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomSpace: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
