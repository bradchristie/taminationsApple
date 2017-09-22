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


class SliderTicView: UIView {
  
  var beats:CGFloat = 0
  var parts:[CGFloat] = []
  var isParts = false
  var isCalls = false
  
  override func draw(_ rect: CGRect) {
    //  Draw background
    let ctx = UIGraphicsGetCurrentContext()
    ctx?.addRect(bounds)
    ctx?.setFillColor(UIColor(red: 0, green: 0.5, blue: 0, alpha: 1).cgColor)
    ctx?.fillPath()
    var x:CGFloat = 0
    var y:CGFloat = 0
    let xmargin:CGFloat = 10     // extra space taken by slider ball
    let width = bounds.width - xmargin*2
    let height = bounds.height
    if (beats > 0) {
      //  Draw tic marks
      ctx?.setStrokeColor(UIColor.white.cgColor)
      ctx?.setLineWidth(1)
      for loc in 0 ..< Int(beats) {
        x = width * CGFloat(loc)/beats + xmargin
        ctx?.move(to: CGPoint(x: x, y: 0))
        ctx?.addLine(to: CGPoint(x: x, y: height/4))
      }
      ctx?.strokePath()
      //  Draw tic labels
      let attributes = [
        NSAttributedStringKey.foregroundColor: UIColor.white,
        NSAttributedStringKey.font: UIFont(name: "Helvetica", size: height/2.0)!
      ]
      if (beats > 2) {
        x = width*2/beats + xmargin - height/3   //  hack for centering text
        y = height/3
        let start:NSString = "Start"
        start.draw(at: CGPoint(x:x,y:y), withAttributes: attributes)
        let end:NSString = "End"
        x = width*(beats-2)/beats + xmargin - height/5
        end.draw(at: CGPoint(x:x,y:y), withAttributes: attributes)
      }
      for i in 0 ..< parts.count {
        if (parts[i] < beats-4) {
          x = width*(2+parts[i])/beats + xmargin - (isParts ? height/10 : height/6)
          var text:String = ""
          if (isParts && i == 0) {
            text = "Part 2"
          }
          else if (isParts || isCalls) {
            text = "\(i+2)"
          }
          else {
            text = "\(i+1)/\(parts.count+1)"
          }
          text.draw(at: CGPoint(x:x,y:y), withAttributes: attributes)
        }
      }
    }
  }
  
  func setTics(_ b:CGFloat, partstr:String, isParts:Bool=false, isCalls:Bool=false) {
    self.isParts = isParts
    self.isCalls = isCalls
    self.beats = b
    if (partstr.length > 0) {
      let t = partstr.split(";")
      parts = [CGFloat](repeating: 0, count: t.count)
      var s:CGFloat = 0
      for i in 0..<t.count {
        let p = CGFloat(Double(t[i])!)
        parts[i] = p + s
        s += p
      }
    }
    setNeedsDisplay()
  }

  
}
