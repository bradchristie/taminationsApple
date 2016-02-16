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

class StartButton : TamButton {

  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    
    let ctx = UIGraphicsGetCurrentContext()
    CGContextTranslateCTM(ctx, bounds.minX+bounds.width/2, bounds.minY+bounds.height/2)
    CGContextScaleCTM(ctx, bounds.height/4, bounds.height/4)
    CGContextSetLineWidth(ctx, 0.2)
    CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
    
    //  <<  to start
    CGContextMoveToPoint(ctx, -0.433, -0.5)
    CGContextAddLineToPoint(ctx, -1.3, 0)
    CGContextAddLineToPoint(ctx, -0.433, 0.5)
    CGContextMoveToPoint(ctx, -1.433, -0.5)
    CGContextAddLineToPoint(ctx, -2.3, 0)
    CGContextAddLineToPoint(ctx, -1.433, 0.5)
    CGContextStrokePath(ctx)
    
    //  |<  back one part
    CGContextMoveToPoint(ctx, 2.3, -0.5)
    CGContextAddLineToPoint(ctx, 1.433, 0)
    CGContextAddLineToPoint(ctx, 2.3, 0.5)
    CGContextStrokePath(ctx)
    CGContextSetLineWidth(ctx, 0.3)
    CGContextMoveToPoint(ctx, 1.3, 0.7)
    CGContextAddLineToPoint(ctx, 1.3, -0.7)
    CGContextStrokePath(ctx)
    
  }


}
