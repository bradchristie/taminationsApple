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

class LogoButton : UIButton {
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    //  Draw floor
    let floor = UIColor(red: 1, green: 0.94, blue: 0.88, alpha: 1)
    floor.setFill()
    let path0 = UIBezierPath(rect:CGRect(x:0,y:0,width:bounds.width,height:bounds.height))
    path0.fill()
    let s = bounds.width / 175.0

    //  Draw handhold
    UIColor.orange.setFill()
    UIBezierPath(rect: CGRect(x: 37*s,y:82*s,width: 92*s,height: 10*s)).fill()
    
    //  Draw boy
    UIColor(red:0,green:0,blue:0.5,alpha:1).setFill()
    let path1 = UIBezierPath(arcCenter:CGPoint(x:37*s,y:61*s),radius: 13*s,startAngle: 0,endAngle: CG_PI*2,clockwise: true)
    path1.close()
    path1.fill()
    UIColor.blue.setFill()
    UIBezierPath(rect: CGRect(x: 11*s,y:61*s,width: 52*s,height: 52*s)).fill()
    
    //  Draw girl
    UIColor(red:0.5,green:0,blue:0,alpha:1).setFill()
    let path2 = UIBezierPath(arcCenter:CGPoint(x:129*s,y:113*s),radius: 13*s,startAngle: 0,endAngle: CG_PI*2,clockwise: true)
    path2.close()
    path2.fill()
    let red = UIColor.red
    red.setFill()
    let path3 = UIBezierPath(arcCenter:CGPoint(x:129*s,y:87*s),radius: 26*s,startAngle: 0,endAngle: CG_PI*2,clockwise: true)
    path3.close()
    path3.fill()

  }
  
}
