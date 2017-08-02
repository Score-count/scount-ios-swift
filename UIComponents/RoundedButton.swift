//
//  RoundedButton.swift
//  SwiftyStoria
//
//  Created by Nikita Rodin on 3/17/17.
//  Copyright © 2017 Frumatic. All rights reserved.
//

import UIKit

@IBDesignable
open class RoundedButton: UIButton {
    
    /// normal state
    @IBInspectable open var borderColor: UIColor = UIColor.storiaRed {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// normal state
    @IBInspectable open var bgColor: UIColor = UIColor.storiaRed {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// normal state
    @IBInspectable open var titleColor: UIColor = UIColor.white {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// make the view rounded
    @IBInspectable open var makeRound: Bool = true {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// disabled state
    @IBInspectable open var disabledColor: UIColor = UIColor.lightGray {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// highligted state
    @IBInspectable open var highlightedColor: UIColor = UIColor.storiaLightGray {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// highligted state
    @IBInspectable open var titleHighlightedColor: UIColor = UIColor.black {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderWidth = 1
        if makeRound {
            self.layer.cornerRadius = self.bounds.height / 2
        }
        self.layer.borderColor = isEnabled ? isHighlighted || isSelected ? highlightedColor.cgColor : borderColor.cgColor : disabledColor.cgColor
        self.backgroundColor = isHighlighted || isSelected ? highlightedColor : bgColor
        self.setTitleColor(titleColor, for: .normal)
        self.setTitleColor(disabledColor, for: .disabled)
    }
    
    open override var isHighlighted: Bool {
        didSet {
            if !isSelected {
                self.backgroundColor = isHighlighted ? highlightedColor : bgColor
            }
            self.layer.borderColor = isHighlighted ? highlightedColor.cgColor : borderColor.cgColor
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            self.tintColor = isSelected ? titleHighlightedColor : titleColor
            self.backgroundColor = isSelected ? highlightedColor : bgColor
            self.layer.borderColor = isSelected ? highlightedColor.cgColor : borderColor.cgColor
        }
    }
    
}
