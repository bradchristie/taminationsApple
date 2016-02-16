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

class Zoom : Action {
  
  override var name:String { get { return "Zoom" } }
  
  override func performOne(d: Dancer, _ ctx: CallContext) throws -> Path {
    if (d.data.leader) {
      if let d2 = ctx.dancerInBack(d) {
        if (!d2.data.active) {
          throw CallError ("Trailer of dancer $\(d.number) is not active")
        }
        let a = CallContext.angle(d)
        let c = a < 0 ? "Run Left" : "Run Right"
        let dist = CallContext.distance(d,d2)
        return TamUtils.getMove(c).changebeats(2).skew(-dist/2, 0) ++ TamUtils.getMove(c).changebeats(2).skew(dist/2, 0)
      }
      else {
        throw CallError("Dancer \(d.number) cannot Zoom")
      }
    }
    else if (d.data.trailer) {
      if let d2 = ctx.dancerInFront(d) {
        if (!d2.data.active) {
          throw CallError ("Leader of dancer \(d.number) is not active")
        }
        let dist = CallContext.distance(d,d2)
        return TamUtils.getMove("Forward").changebeats(4).scale(dist, 1)
      } else {
        throw CallError("Dancer \(d.number) cannot Zoom")
      }
    } else {
      throw CallError("Dancer \(d.number) cannot Zoom")
    }
  }
  
}