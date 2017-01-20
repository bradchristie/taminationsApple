/*

Taminations Square Dance Animations App for iOS
Copyright (C) 2017 Brad Christie

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
    return UIFont.boldSystemFont(ofSize: max(17,UIScreen.main.bounds.height/40))
  }
  
  override func setTitle(_ title: String?, for state: UIControlState) {
    super.setTitle(title, for: state)
    titleLabel?.adjustsFontSizeToFitWidth = true
    titleLabel?.minimumScaleFactor = 0.1
    titleLabel?.font = buttonFont()
    setTitleColor(UIColor.black, for: UIControlState())
    setTitleColor(UIColor.gray, for: UIControlState.disabled)
  }

  override func sizeToFit() {
    //  Size the button to fit the label's width
    let labelSize = titleLabel?.text!.size(attributes: [NSFontAttributeName:buttonFont()])
    super.sizeToFit()  //  but that leaves no margin on the sides, so ...
    bounds = CGRect(x: 0,y: 0,width: labelSize!.width+20,height: labelSize!.height+10)
   }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
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
    let gradientColors = [bottomColor.cgColor, topColor.cgColor]
    let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors as CFArray, locations: nil)
    let highlightedGradientColors = [bottomColor.cgColor,topColor.cgColor]
    let highligtedGradient = CGGradient(colorsSpace: colorSpace, colors: highlightedGradientColors as CFArray, locations: nil)
    let selectedGradientColors = [bottomColor.cgColor,darkColor.cgColor]
    let selectedGradient = CGGradient(colorsSpace: colorSpace, colors: selectedGradientColors as CFArray, locations: nil)
    
    // Draw rounded rectangle bezier path
    let crad = height < 40 ? height/4 : 12
    let roundedRectanglePath = UIBezierPath(roundedRect: bounds, cornerRadius: crad)
    // Use the bezier as a clipping path
    roundedRectanglePath.addClip()
    
    // Use one of the gradients depending on the state of the button
    let background = isHighlighted ? highligtedGradient : isSelected ? selectedGradient : gradient
    
    // Draw gradient within the path
    context?.drawLinearGradient(background!, start: CGPoint(x: width,y: 0), end: CGPoint(x: width, y: height), options: CGGradientDrawingOptions())
    
    // Draw border
    borderColor.setStroke()
    roundedRectanglePath.lineWidth = 4
    roundedRectanglePath.stroke()
    
    // Draw Inner Glow
    let innerGlowRect = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: width-4, height: height-4), cornerRadius: 10)
    innerGlow.setStroke()
    innerGlowRect.lineWidth = 1
    innerGlowRect.stroke()
    
    // Cleanup
    //  automatically done for Swift ??
    
  }
  
}
