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


class SliderTicView: UIView {
  
  var beats:CGFloat = 0
  var parts:[CGFloat] = []
  var isParts = false
  var isCalls = false
  
  override func drawRect(rect: CGRect) {
    //  Draw background
    let ctx = UIGraphicsGetCurrentContext()
    CGContextAddRect(ctx, bounds)
    CGContextSetFillColorWithColor(ctx, UIColor(red: 0, green: 0.5, blue: 0, alpha: 1).CGColor)
    CGContextFillPath(ctx)
    var x:CGFloat = 0
    let xmargin:CGFloat = 10     // extra space taken by slider ball
    let width = bounds.width - xmargin*2
    let height = bounds.height
    if (beats > 0) {
      //  Draw tic marks
      CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor().CGColor)
      CGContextSetLineWidth(ctx, 1)
      for loc in 0 ..< Int(beats) {
        x = width * CGFloat(loc)/beats + xmargin
        CGContextMoveToPoint(ctx, x, 0)
        CGContextAddLineToPoint(ctx, x, height/4)
      }
      CGContextStrokePath(ctx)
      //  Draw tic labels
      let attributes = [
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "Helvetica", size: height/2.0)!
      ]
      x = width*2/beats + xmargin - height/3   //  hack for centering text
      let y:CGFloat = height/3
      let start:NSString = "Start"
      start.drawAtPoint(CGPoint(x:x,y:y), withAttributes: attributes)
      let end:NSString = "End"
      x = width*(beats-2)/beats + xmargin - height/5
      end.drawAtPoint(CGPoint(x:x,y:y), withAttributes: attributes)
      for i in 0 ..< parts.count {
        if (parts[i] < beats-4) {
          x = width*(2+parts[i])/beats + xmargin - (isParts ? height/10 : height/6)
          let text:NSString = (isParts && i == 0) ? "Part 2"
            : (isParts || isCalls) ? "\(i+2)"
            : "\(i+1)/\(parts.count+1)"
          text.drawAtPoint(CGPoint(x:x,y:y), withAttributes: attributes)
        }
      }
    }
  }
  
  func setTics(b:CGFloat, partstr:String, isParts:Bool=false, isCalls:Bool=false) {
    self.isParts = isParts
    self.isCalls = isCalls
    self.beats = b
    if (partstr.length > 0) {
      let t = partstr.split(";")
      parts = [CGFloat](count:t.count, repeatedValue:0)
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