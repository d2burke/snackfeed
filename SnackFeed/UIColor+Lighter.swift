//
//  UIColor+Lighter.swift
//  SnackFeed
//
//  Created by Daniel Burke on 1/13/19.
//  Copyright © 2019 SnackFeed. All rights reserved.
//

import UIKit

extension UIColor {
    
    var lighter: UIColor {
        return lighterColor(removeSaturation: 0.5, resultAlpha: -1)
    }
    
    func lighterColor(removeSaturation val: CGFloat, resultAlpha alpha: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0
        
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            else {return self}
        
        return UIColor(hue: h,
                       saturation: max(s - val, 0.0),
                       brightness: b,
                       alpha: alpha == -1 ? a : alpha)
    }
}
