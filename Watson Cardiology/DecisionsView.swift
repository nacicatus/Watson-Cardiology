//
//  DecisionsView.swift
//  CognitiveConcierge
//

import UIKit

class DecisionsView: UIView {
    
    @IBOutlet var discussFurtherButton: UIButton!
    @IBOutlet var seeManagementButton: UIButton!
    @IBOutlet var questionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    @IBAction func discussFurtherButtonPressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("discussFurtherButtonPressed", object: nil)
    }
    
    @IBAction func seeManagementButtonPressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("seeEvidenceButtonPressed", object: nil)
    }
    
    /**
     Method that returns an instance of HorizontalOnePartStackView from nib
     
     - returns: HorizontalOnePartStackView
     */
    class func instanceFromNib() -> DecisionsView {
        return UINib(nibName: "DecisionsView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DecisionsView
    }

    func setupView() {
        questionLabel.adjustsFontForContentSizeCategory = true
    }
}
