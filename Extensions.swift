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

//  Swift seems to be missing a logical XOR
func ^(b1:Bool, b2:Bool) -> Bool {
  return b1 ? !b2 : b2
}

extension Sequence {
  
  func every(_ f:(Self.Iterator.Element) -> Bool) -> Bool {
    for e in self {
      if (!f(e)) {
        return false
      }
    }
    return true
  }

  func exists(_ f:(Self.Iterator.Element) -> Bool) -> Bool {
    for e in self {
      if (f(e)) {
        return true
      }
    }
    return false
  }
  
  var head:Self.Iterator.Element { get { return find { _ in true }! } }
  
  func find(_ f:(Self.Iterator.Element) -> Bool) -> Self.Iterator.Element? {
    for e in self {
      if (f(e)) {
        return e
      }
    }
    return nil
  }
  
  func partitionAndSplit(_ f:(Self.Iterator.Element) -> Bool) -> [[Self.Iterator.Element]] {
    var retval:[[Self.Iterator.Element]] = []
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
  func matches(_ query:String) -> Bool {
    return range(of: "^"+query+"$", options: .regularExpression) != nil
  }
  
  func replaceFirst(_ query:String, _ replacement:String) -> String {
    var retval = self
    if let r = range(of: query, options: .regularExpression) {
      retval.replaceSubrange(r, with: replacement)
    }
    return retval
  }
  
  func replace(_ query:String, _ replacement: String) -> String {
    return self.replacingOccurrences(of: query, with: replacement)
  }
  
  func replaceAll(_ query: String, _ replacement: String) -> String {
    return self.replacingOccurrences(of: query, with: replacement,
      options: .regularExpression, range: nil)
  }
  
  func trim() -> String {
    return self.trimmingCharacters(in: CharacterSet.whitespaces)
  }
  
  subscript (i: Int) -> Character {
    return self[self.characters.index(self.startIndex, offsetBy: i)]
  }
  
  subscript (i: Int) -> String {
    return String(self[i] as Character)
  }
  
  subscript (r: Range<Int>) -> String {
    return substring(with: characters.index(startIndex, offsetBy: r.lowerBound) ..< characters.index(startIndex, offsetBy: r.upperBound))
  }
  
  func split() -> Array<String> {
    return components(separatedBy: CharacterSet.whitespaces)
  }
  func split(_ c:String) -> [String] {
    return components(separatedBy: c)
  }
  
  func substr(_ i:Int, _ j:Int) -> String {
    let start = self.characters.index(self.startIndex, offsetBy: i)
    let end = self.characters.index(self.startIndex, offsetBy: j)
    return self.substring(with: start..<end)
  }
  
  // Returns an array of strings, starting with the entire string,
  // and each subsequent string chopping one word off the end
  func chopped() -> [String] {
    var ss = [String]()
    return split().map { (s:String) -> String in
      ss.append(s)
      return ss.reduce("",{ "\($0) \($1)" }).trim()
      } .reversed()
  }
  
  // Return an array of strings, each removing one word from the start
  func diced() -> [String] {
    var ss = [String]()
    return split().reversed().map { (s:String) -> String in
      ss.insert(s, at: 0)
      return ss.reduce("",{ "\($0) \($1)" }).trim()
    } .reversed()
  }

  /**
   *   Return all combinations of words from a string
   */
  func minced() -> [String] {
    return chopped().flatMap { (s:String) -> [String] in s.diced() }
  }
  
  func indexOf(_ s:String) -> Int {
    let range = self.range(of: s)
    if (range == nil) {
      return -1
    } else {
      return self.characters.distance(from: self.startIndex, to: range!.lowerBound)
    }
  }

}


extension Int {
  var Abs:Int { get { return self < 0 ? -self : self } }
}

let CG_PI = CGFloat(Double.pi)

extension CGFloat {
  
  func isApprox(_ y:CGFloat, delta:CGFloat) -> Bool {
    return (self-y).Abs < delta
  }
  
  func isApprox(_ y:CGFloat) -> Bool {
    return isApprox(y, delta: 0.1)
  }
  
  func angleDiff(_ a2:CGFloat) -> CGFloat {
    return ((((self-a2).truncatingRemainder(dividingBy:CG_PI*2)) + (CG_PI*3)).truncatingRemainder(dividingBy: (CG_PI*2))) - CG_PI
  }
  
  func angleEquals(_ a2:CGFloat) -> Bool {
    return angleDiff(a2).isApprox(0.0)
  }

  var Sign:CGFloat { get { return self < 0.0 ? -1.0 : self > 0.0 ? 1.0 : 0.0 } }
  var Floor:CGFloat { get { return self.rounded(.down) } }
  var Ceil:CGFloat { get { return self.rounded(.up) } }
  var Round:CGFloat { get { return self.rounded(.toNearestOrAwayFromZero) } }
  var Abs:CGFloat { get { return self < 0 ? -self : self } }
  var Sin:CGFloat { get { return sin(self) } }
  var Cos:CGFloat { get { return cos(self) } }
  var Sqrt:CGFloat { get { return sqrt(self) } }
  var Sq:CGFloat { get { return self * self } }
  var toRadians:CGFloat { get { return self * CG_PI / 180 } }
  var toDegrees:CGFloat { get { return self * 180 / CG_PI } }
  var d:Double { get { return Double(self) } }
  
}

extension Double {
  
  var cg:CGFloat { get { return CGFloat(self) } }
  
}

extension Array {
  
  func sumByCGFloat(f:(Element) -> CGFloat) -> CGFloat {
    var s:CGFloat = 0
    for e in self {
      s += f(e)
    }
    return s
  }
  
}

extension UIColor {
  
  static func ORANGE() -> UIColor { return UIColor(red: 1, green: 0.78, blue: 0, alpha: 1) }
  
  static func colorFromHex(_ hex:UInt) -> UIColor {
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
  
  func darker(_ f:CGFloat = 0.7) -> UIColor {
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
    navbar.isTranslucent = false
    let grad = CAGradientLayer()
    grad.frame = navbar.bounds
    grad.colors = [UIColor(red:0,green:0.75,blue:0,alpha:1).cgColor,UIColor(red:0,green:0.25,blue:0,alpha:1).cgColor]
    UIGraphicsBeginImageContext(grad.frame.size)
    grad.render(in: UIGraphicsGetCurrentContext()!)
    let bgimage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    navbar.setBackgroundImage(bgimage, for: UIBarMetrics.default)
  }
  
  open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    return visibleViewController!.supportedInterfaceOrientations
  }
  open override var shouldAutorotate : Bool {
    return visibleViewController!.shouldAutorotate
  }
}

@available(iOS 8.0, *)
class UIAlertControllerExtension : UIAlertController {
  override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.portrait
  }
  override var shouldAutorotate : Bool {
    return false
  }
}

extension UIView {
  //  Convenience method to set several constraints at once
  func visualConstraints(_ format:String, fillHorizontal:Bool=false, fillVertical:Bool=false, spacing:Int=(-1)) {
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
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: f, options:NSLayoutFormatOptions(rawValue:0), metrics: nil, views:d))
      }
    }
  }
  
}
