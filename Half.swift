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

class Half : Action {
  
  var prevbeats:CGFloat = 0
  var halfbeats:CGFloat = 0
  var call = Call()
  
  override var name:String { get { return "Half" } }
  
  override func perform(_ ctx: CallContext, index: Int) throws {

    if (index+1 < ctx.callstack.count) {
      //  Steal the next call off the stack
      call = ctx.callstack[index+1]
      //  For XML calls there should be an explicit number of parts
      if let xcall = call as? XMLCall {
        //  Figure out how many beats are in half the call
        if let parts = xcall.xelem["parts"] {
          let partnums = parts.split(";")
          halfbeats = partnums[0..<partnums.count/2].reduce(0, { (n,s) in n + CGFloat(Double(s)!) } )
        }
      }
      prevbeats = ctx.maxBeats
    }
  }
  
  //  Call is performed between these two methods

  override func postProcess(_ ctx: CallContext, index: Int) {
    //  Coded calls so far do not have explicit parts
    //  so just divide them in two
    if (call is CodedCall || halfbeats == 0.0) {
      halfbeats = (ctx.maxBeats - prevbeats) / 2
    }
    //  Chop off the excess half
    ctx.dancers.forEach { d in
      var mo:Movement? = nil
      while (d.path.beats > prevbeats + halfbeats) {
        mo = d.path.pop()
      }
      if let moo = mo {
        if (d.path.beats < prevbeats + halfbeats) {
          d.path.add(moo.clip(prevbeats + halfbeats - d.path.beats))
        }
      }
    }
  }
  
}
