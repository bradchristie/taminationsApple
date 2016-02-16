/*

Taminations Square Dance Animations App for iOS
Copyright (C) 2016 Brad Christie

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

import UIKit

class TamButton : UIButton {

  func buttonFont() -> UIFont {
    return UIFont.boldSystemFontOfSize(max(17,UIScreen.mainScreen().bounds.height/40))
  }
  
  override func setTitle(title: String?, forState state: UIControlState) {
    super.setTitle(title, forState: state)
    titleLabel?.adjustsFontSizeToFitWidth = true
    titleLabel?.minimumScaleFactor = 0.1
    titleLabel?.font = buttonFont()
    setTitleColor(UIColor.blackColor(), forState: .Normal)
  }

  override func sizeToFit() {
    //  Size the button to fit the label's width
    let labelSize = titleLabel?.text!.sizeWithAttributes([NSFontAttributeName:buttonFont()])
    super.sizeToFit()  //  but that leaves no margin on the sides, so ...
    bounds = CGRectMake(0,0,labelSize!.width+20,labelSize!.height+10)
   }
  
  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    
    // General Declarations
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = UIGraphicsGetCurrentContext()
    let height = bounds.size.height
    let width = bounds.size.width
    
    // Color Declarations
    let borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    let topColor = UIColor(red: 1, green: 0.95, blue: 0.85, alpha: 1)
    let bottomColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
    let darkColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    let innerGlow = UIColor(white: 1, alpha: 0.5)
    
    // Gradient Declarations
    let gradientColors = [bottomColor.CGColor, topColor.CGColor]
    let gradient = CGGradientCreateWithColors(colorSpace, gradientColors, nil)
    let highlightedGradientColors = [bottomColor.CGColor,topColor.CGColor]
    let highligtedGradient = CGGradientCreateWithColors(colorSpace, highlightedGradientColors, nil)
    let selectedGradientColors = [bottomColor.CGColor,darkColor.CGColor]
    let selectedGradient = CGGradientCreateWithColors(colorSpace, selectedGradientColors, nil)
    
    // Draw rounded rectangle bezier path
    let crad = height < 40 ? height/4 : 12
    let roundedRectanglePath = UIBezierPath(roundedRect: bounds, cornerRadius: crad)
    // Use the bezier as a clipping path
    roundedRectanglePath.addClip()
    
    // Use one of the gradients depending on the state of the button
    let background = highlighted ? highligtedGradient : selected ? selectedGradient : gradient
    
    // Draw gradient within the path
    CGContextDrawLinearGradient(context, background, CGPointMake(width,0), CGPointMake(width, height), CGGradientDrawingOptions())
    
    // Draw border
    borderColor.setStroke()
    roundedRectanglePath.lineWidth = 4
    roundedRectanglePath.stroke()
    
    // Draw Inner Glow
    let innerGlowRect = UIBezierPath(roundedRect: CGRectMake(2, 2, width-4, height-4), cornerRadius: 10)
    innerGlow.setStroke()
    innerGlowRect.lineWidth = 1
    innerGlowRect.stroke()
    
    // Cleanup
    //  automatically done for Swift ??
    
  }
  
}
