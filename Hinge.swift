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

class Hinge : BoxCall {
  
  override var name:String { get { return "Hinge" } }
  
  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    //  Find the dancer to hinge with
    let d3 = ctx.dancerToRight(d)
    let d4 = ctx.dancerToLeft(d)
    let d2 = d.data.partner != nil && d.data.partner!.data.active ? d.data.partner
             : d3 != nil && d3!.data.active ? d3
             : d4 != nil && d4!.data.active ? d4 : nil
    if let d1 = d2 {
      if (CallContext.isRight(d)(d1)) {
        return TamUtils.getMove("Hinge Right")
      } else {
        return TamUtils.getMove("Hinge Left")
      }
    } else {
      throw CallError("No dancer to hinge with \(d.number)") as Error
    }
  }
}
