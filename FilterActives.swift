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

/**
*   Parent class of all classes that select a group of dancers
*   such as boys, leaders, centers, belles
*/
class FilterActives : CodedCall {
  
  /**
  *  Child classes need to define one of these isActive methods
  *  according to which dancers should be selected
  * @param d Dancer
  * @param ctx CallContext
  * @return true to select dancer
  */
  func isActive(_ d:Dancer, _ ctx:CallContext) -> Bool {
    return isActive(d)
  }
  func isActive(_ d:Dancer) -> Bool {
    return true
  }

  /**
  *   Set the active dancers based on the predicate
  *   defined by the child class
  * @param ctx contains dancers to select
  */
  override func preProcess(_ ctx: CallContext, index: Int) {
    ctx.dancers.filter{$0.data.active}.forEach { d in
      d.data.active = isActive(d,ctx)
    }
  }
  
}
