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

class TurnThru : Action {
  
  override var name:String { get { return "Turn Thru" } }
  
  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    //  Can only turn thru with another dancer
    //  in front of this dancer
    //  who is also facing this dancer
    if let d2 = ctx.dancerInFront(d) {
      let dist = CallContext.distance(d,d2)
      return TamUtils.getMove("Extend Left").scale(dist/2,0.5) +
        TamUtils.getMove("Swing Right").scale(0.5,0.5) +
        TamUtils.getMove("Extend Right").scale(dist/2,0.5)
    } else {
      throw CallError("Cannot find dancer to Turn Thru with \(d.number)") as Error;
    }
  }
  
}
