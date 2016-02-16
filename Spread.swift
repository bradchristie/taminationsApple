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

class Spread : Action {
  
  override var name:String { get { return "and Spread" } }
  
  override func performOne(d: Dancer, _ ctx: CallContext) throws -> Path {
    //  This is for waves only TODO tandem couples, single dancers (C-1)
    let v = Vector3D(x: 0, y: d.data.belle ? 2 : d.data.beau ? -2 : 0)
    let m = d.path.pop()
    let tx = m.rotate()
    let v2 = v.concatenate(tx)
    d.path.add(m.skew(v2.x,v2.y).useHands(Hands.NOHANDS))
    return Path()   // empty path for return value
  }
}