//
//  InstructionCollectionViewCell.swift
//  MyTenTenEducation
//
//  Created by Aymen Rebouh on 2018/04/18.
//  Copyright © 2018 Aymen Rebouh. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

enum CellMode {
    case normal, placeholder
}

class InstructionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties -
    
    var disposeBag = DisposeBag()
    var instruction: Instruction?
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var mode: CellMode = .normal {
        didSet {
            switch mode {
            case .placeholder:
                contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                descriptionLabel.alpha = 0.0
            default:
                contentView.backgroundColor = instruction?.color 
                descriptionLabel.alpha = 1.0
            }
        }
    }
    
    // MARK: - Lifecycle -
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 5
    }
    
    func setup(withInstruction instruction: Instruction) {
        self.instruction = instruction
        descriptionLabel.text = instruction.textDescription
        contentView.backgroundColor = instruction.color
    }
}
