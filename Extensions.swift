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

//  Swift seems to be missing a logical XOR
func ^(b1:Bool, b2:Bool) -> Bool {
  return b1 ? !b2 : b2
}

extension SequenceType {
  
  func every(f:(Self.Generator.Element) -> Bool) -> Bool {
    for e in self {
      if (!f(e)) {
        return false
      }
    }
    return true
  }

  func exists(f:(Self.Generator.Element) -> Bool) -> Bool {
    for e in self {
      if (f(e)) {
        return true
      }
    }
    return false
  }
  
  var head:Self.Generator.Element { get { return find { _ in true }! } }
  
  func find(f:(Self.Generator.Element) -> Bool) -> Self.Generator.Element? {
    for e in self {
      if (f(e)) {
        return e
      }
    }
    return nil
  }
  
  func partition(f:(Self.Generator.Element) -> Bool) -> [[Self.Generator.Element]] {
    var retval:[[Self.Generator.Element]] = []
    retval.append([])
    retval.append([])
    for e in self {
      if (f(e)) {
        retval[0].append(e)
      } else {
        retval[1].append(e)
      }
    }
    return retval
  }
  
  var nonEmpty:Bool { get { return exists { _ in true } } }
  var empty:Bool { get { return !nonEmpty } }

}

extension String {
  
  var length:Int {
    get {
      return characters.count
    }
  }
  
  /**
   * Tests whether this string matches the given regularExpression. This method returns
   * true only if the regular expression matches the <i>entire</i> input string. */
  func matches(query:String) -> Bool {
    return rangeOfString("^"+query+"$", options: .RegularExpressionSearch) != nil
  }
  
  func replaceFirst(query:String, _ replacement:String) -> String {
    var retval = self
    if let r = rangeOfString(query, options: .RegularExpressionSearch) {
      retval.replaceRange(r, with: replacement)
    }
    return retval
  }
  
  func replaceAll(query: String, _ replacement: String) -> String {
    return self.stringByReplacingOccurrencesOfString(query, withString: replacement,
      options: .RegularExpressionSearch, range: nil)
  }
  
  func trim() -> String {
    return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
  }
  
  subscript (i: Int) -> Character {
    return self[self.startIndex.advancedBy(i)]
  }
  
  subscript (i: Int) -> String {
    return String(self[i] as Character)
  }
  
  subscript (r: Range<Int>) -> String {
    return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
  }
  
  func split() -> Array<String> {
    return componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
  }
  func split(c:String) -> [String] {
    return componentsSeparatedByString(c)
  }
  
  // Returns an array of strings, starting with the entire string,
  // and each subsequent string chopping one word off the end
  func chopped() -> [String] {
    var ss = [String]()
    return split().map { (s:String) -> String in
      ss.append(s)
      return ss.reduce("",combine: { "\($0) \($1)" }).trim()
      } .reverse()
  }
  
  // Return an array of strings, each removing one word from the start
  func diced() -> [String] {
    var ss = [String]()
    return split().reverse().map { (s:String) -> String in
      ss.insert(s, atIndex: 0)
      return ss.reduce("",combine: { "\($0) \($1)" }).trim()
    } .reverse()
  }

  /**
   *   Return all combinations of words from a string
   */
  func minced() -> [String] {
    return chopped().flatMap { (s:String) -> [String] in s.diced() }
  }
  
  func indexOf(s:String) -> Int {
    let range = self.rangeOfString(s)
    if (range == nil) {
      return -1
    } else {
      return self.startIndex.distanceTo(range!.startIndex)
    }
  }

}

let CG_PI = CGFloat(M_PI)

extension CGFloat {
  
  func isApprox(y:CGFloat, delta:CGFloat) -> Bool {
    return abs(self-y) < delta
  }
  
  func isApprox(y:CGFloat) -> Bool {
    return isApprox(y, delta: 0.1)
  }
  
  func angleDiff(a2:CGFloat) -> CGFloat {
    return ((((self-a2) % (CG_PI*2)) + (CG_PI*3)) % (CG_PI*2)) - CG_PI
  }
  
  func angleEquals(a2:CGFloat) -> Bool {
    return angleDiff(a2).isApprox(0.0)
  }

  var toRadians:CGFloat { get { return self * CG_PI / 180 } }
    
}

extension UIColor {
  
  static func ORANGE() -> UIColor { return UIColor(red: 1, green: 0.78, blue: 0, alpha: 1) }
  
  static func colorFromHex(hex:UInt) -> UIColor {
    let d:CGFloat = 256
    return UIColor(red: CGFloat((hex&0x00ff0000)>>16)/d,
                   green: CGFloat((hex&0x0000ff00)>>8)/d,
                   blue: CGFloat(hex&0x000000ff)/d,
                   alpha: CGFloat(hex>>24)/d)
  }
  
  func invert() -> UIColor {
    var red:CGFloat = 0
    var green:CGFloat = 0
    var blue:CGFloat = 0
    var alpha:CGFloat = 1
    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return UIColor(red: 1-red, green: 1-green, blue: 1-blue, alpha: alpha)
  }
  
  func darker(f:CGFloat = 0.7) -> UIColor {
    var red:CGFloat = 0
    var green:CGFloat = 0
    var blue:CGFloat = 0
    var alpha:CGFloat = 1
    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return UIColor(red: red*f, green: green*f, blue: blue*f, alpha: alpha)
  }
  
  func brighter() -> UIColor {
    return invert().darker().invert()
  }
  
  func veryBright() -> UIColor {
    return brighter().brighter().brighter().brighter()
  }
  
}

//  This lets a view controller restrict rotation
extension UINavigationController {

  func customNavBar() {
    let navbar = navigationBar
    navbar.translucent = false
    let grad = CAGradientLayer()
    grad.frame = navbar.bounds
    grad.colors = [UIColor(red:0,green:0.75,blue:0,alpha:1).CGColor,UIColor(red:0,green:0.25,blue:0,alpha:1).CGColor]
    UIGraphicsBeginImageContext(grad.frame.size)
    grad.renderInContext(UIGraphicsGetCurrentContext()!)
    let bgimage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    navbar.setBackgroundImage(bgimage, forBarMetrics: UIBarMetrics.Default)
  }
  
  public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return visibleViewController!.supportedInterfaceOrientations()
  }
  public override func shouldAutorotate() -> Bool {
    return visibleViewController!.shouldAutorotate()
  }
}

@available(iOS 8.0, *)
class UIAlertControllerExtension : UIAlertController {
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Portrait
  }
  override func shouldAutorotate() -> Bool {
    return false
  }
}

extension UIView {
  
  func visualConstraints(format:String, fillHorizontal:Bool=false, fillVertical:Bool=false, spacing:Int=(-1)) {
    var alpha = ["a","b","c","d","e","f","g","h","i","j"]
    var d = [String:UIView]()
    var myformat = format
    for v in subviews {
      let letter = alpha.removeFirst()
      d[letter] = v
      v.translatesAutoresizingMaskIntoConstraints = false
      if (fillHorizontal) {
        myformat += " |[\(letter)]|"
      }
      if (fillVertical) {
        myformat += " V:|[\(letter)]|"
      }
    }
    if (spacing >= 0) {
      //  Replace single hyphens e.g. ]-[ but not explicit spacing e.g. ]-5-[
      myformat = myformat.replaceAll("(?<!\\d)-(?!\\d)", "-\(spacing)-")
    }
    for f in myformat.split() {
      if (f.length > 0) {
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(f, options:NSLayoutFormatOptions(rawValue:0), metrics: nil, views:d))
      }
    }
  }
  
}
