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
class BoxCounterRotate : BoxCall {
  
  override var name:String { get { return "Box Counter Rotate" } }
  
  override func performOne(d: Dancer, _ ctx: CallContext) throws -> Path {
    let v = d.location
    var v2 = v
    var cy4:CGFloat = 0
    var y4:CGFloat = 0
    let a1 = d.tx.angle
    let a2 = v.angle
    //  Determine if this is a rotate left or right
    let angdif = a2.angleDiff(a1)
    if (angdif < 0) {
      // Left
      v2 = v.rotate(CG_PI/2)
      cy4 = 0.45
      y4 = 1
    } else {
      // Right
      v2 = v.rotate(-CG_PI/2)
      cy4 = -0.45
      y4 = -1
    }
    //  Compute the control points
    let dv = (v2-v).rotate(-a1)
    let cv1 = (v2*0.5).rotate(-a1)
    let cv2 = (v*0.5).rotate(-a1) + dv
    let m = Movement(fullbeats: 2.0, hands: .NOHANDS, cx1: cv1.x, cy1: cv1.y, cx2: cv2.x, cy2: cv2.y, x2: dv.x, y2: dv.y,
      cx3: 0.55, cx4: 1.0, cy4: cy4, x4: 1, y4: y4, beats: 2.0)
    return Path(m)
  }
  
}