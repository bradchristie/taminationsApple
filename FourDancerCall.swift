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

class FourDancerCall : Action {
  
  func preferFilter(_ ctx:CallContext) -> Bool { return true }
  
  override func perform(_ ctx: CallContext, index: Int) throws {
    //  If there are just 4 dancers, run the call with no modifications
    if (ctx.dancers.count <= 4) {
      try super.perform(ctx,index:index)
    } else {
      //  8 dancers
      //  Divide into 2 alternatives of 2 4-dancer contexts,
      //  trying both vertical and horizontal
      var splitctx = split(ctx, isVertical: false) + split(ctx, isVertical: true)
      splitctx.forEach { preProcess($0) }
      if (splitctx.count > 2) {
        splitctx = splitctx.filter(preferFilter)
      }
      try splitctx.forEach { ctx2 in
        //  Perform the requested call on this 4-dancer unit
        try super.performCall(ctx2, index: 0)
        //  Adjust to fit 8-dancer positions
        postProcess(ctx2)
        //  Now apply the result to the 8-dancer context
        ctx2.dancers.forEach { d in d.clonedFrom!.path.add(d.path) }
      }
    }
    
  }

  override func preProcess(_ ctx: CallContext, index:Int=0) {
    ctx.center()
    // TODO Need to do additional transforms here ??? e.g. expand
    ctx.analyze()
  }
  
  override func postProcess(_ ctx: CallContext, index:Int=0) {
    if (ctx.dancers.count > 4) {
      // And transform the resulting paths back
      ctx.dancers.forEach { d in
        //  First figure out the direction this dancer needs to move
        let v = Vector3D(x: ctx.isVertical ? 0 : round(d.location.x/3),
          y: ctx.isVertical ? round(d.location.y/3) : 0)
        //  Get the dancer's facing angle for the last movement
        let m = d.path.movelist.last!
        d.animate(d.beats - m.beats)
        let tx = Matrix().preRotate(d.tx.angle)
        //  Apply that angle to the direction we need to shift
        let v2 = v.concatenate(tx)
        //  Finally apply it to the last movement
        d.path.movelist.removeLast()
        d.path.movelist.append(m.skew(v2.x, v2.y))
      }
    }
  }
  
  //  This returns an array of 2 contexts, 4 dancers each
  //  divided by an axis
  func split(_ ctx:CallContext, isVertical:Bool) -> [CallContext] {
    func f(_ d:Dancer) -> CGFloat { return isVertical ? d.location.x : d.location.y }
    //  Fail if there are any dancers on the axis
    if (ctx.dancers.exists{f($0).isApprox(0)}) {
      return []
    } else {
      //  Create the two contexts
      let spl = ctx.dancers.partitionAndSplit { f($0) < 0 }
      let ctx1 = CallContext(source: spl[0])
      let ctx2 = CallContext(source: spl[1])
      ctx1.isVertical = isVertical
      ctx2.isVertical = isVertical
      return [ctx1,ctx2]
    }
  }
  
}
