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

class Run : Action {
  
  override var name:String { get { return "Run" } }
  
  override func perform(_ ctx: CallContext, index: Int) throws {
    //  We need to look at all the dancers, not just actives
    //  because partners of the runners need to dodge
    try ctx.dancers.forEach { d in
      if (d.data.active) {
        //  Find dancer to run around
        //  Usually it's the partner
        switch d.data.partner {
        case .some(var d2):
          //  But special case of t-bones, could be the dancer on the other side,
          //  check if another dancer is running around this dancer's "partner"
          if let d3 = d2.data.partner {
            if (d != d3 && d3.data.active) {
              if let d4 = CallContext.isRight(d)(d3) ? ctx.dancerToRight(d) : ctx.dancerToLeft(d) {
                d2 = d4
              } else {
                throw CallError("Dancer \(d.number) has nobody to Run around") as Error
              }
            }
          }
          //  Partner must be inactive
          if (d2.data.active) {
            throw CallError("Dancer \(d.number) has nobody to Run around") as Error
          }
          var m = CallContext.isRight(d)(d2) ? "Run Right" : "Run Left"
          let dist = CallContext.distance(d,d2)
          d.path.add(TamUtils.getMove(m).scale(1.0,dist/2))
          //  Also set path for partner
          m = If (CallContext.isRight(d2)(d))
            .Then ("Dodge Right")
          .ElseIf (CallContext.isLeft(d2)(d))
            .Then ("Dodge Left")
          .ElseIf (CallContext.isInFront(d2)(d))
            .Then ("Forward 2")
          .ElseIf (CallContext.isInBack(d2)(d))
            .Then ("Back 2")   //  really ???
          .Else ("Stand")   // should never happen
          d2.path = TamUtils.getMove(m).scale(1,dist/2)
        default:
          throw CallError("Dancer \(d.number) has nobody to Run around") as Error
        }
      }
    }
  }
}
