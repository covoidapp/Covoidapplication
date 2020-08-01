//
//  ViolationCell.swift
//  iosapp
//
//  Created by Dev Manaktala on 22/07/20.
//  Copyright © 2020 IBM. All rights reserved.
//

import UIKit

class ViolationCell: UITableViewCell {

    @IBOutlet weak var ViolationType: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var ContestedLabel: UILabel!
    @IBOutlet weak var Timed: UILabel!
    
    @IBOutlet weak var ViolationImage: UIImageView!
    @IBOutlet weak var ContestButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ContestButton.layer.cornerRadius = 10.0
        ContestButton.layer.masksToBounds = true
        ContestButton.SetGradientBackground(start: CustomColors.skyblue, end: CustomColors.warmblue)
    }
    
    static func nib() ->UINib{
        return UINib(nibName: "ViolationCell", bundle: nil)
    }
    
    public func configure(with Title: String, Dated: String, Contest: String, TimeOfViolation: String, Image: UIImage?){
        ViolationType.text = Title
        Date.text = Dated
        ContestedLabel.text = Contest
        Timed.text = TimeOfViolation
        if Image != nil{
            ViolationImage.image = Image
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func ContestClicked(_ sender: UIButton) {
        ContestButton.isHidden = true
        ContestedLabel.text = "Contested"
        ContestedLabel.textColor = UIColor.red
    }
}
