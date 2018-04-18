//
//  RoundedButton.swift
//  MyTenTenEducation
//
//  Created by Aymen Rebouh on 2018/04/18.
//  Copyright © 2018 Aymen Rebouh. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 5
    }
}
