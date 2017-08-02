//
//  GradientView.swift
//  SwiftyStoria
//
//  Created by Nikita Rodin on 4/28/17.
//  Copyright © 2017 Frumatic. All rights reserved.
//

import UIKit


/// top-to-bottom gradient view
@IBDesignable
open class GradientView: UIView {

    override open class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
    @IBInspectable open var topColor: UIColor? = nil {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var bottomColor: UIColor? = nil {
        didSet {
            setNeedsLayout()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let colors = [topColor, bottomColor].flatMap { $0?.cgColor }
        gradientLayer.colors = colors
    }
    
    
}
