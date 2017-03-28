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

class XMLCall : Call {
  
  let doc:Ji
  let xelem:JiNode
  let xmlmap:[Int]
  let ctx2:CallContext
  init(doc:Ji, xelem:JiNode, xmlmap:[Int], ctx:CallContext) {
    self.doc = doc
    self.xelem = xelem
    self.xmlmap = xmlmap
    self.ctx2 = ctx
  }

  override func performCall(_ ctx: CallContext, index: Int) {
    let allp = TamUtils.getPaths(xelem)
    //  If moving just some of the dancers,
    //  see if we can keep them in the same shape
    if (ctx.actives.count < ctx.dancers.count) {
      //  No animations have been done on ctx2,
      //  so dancers are still at the start points
      let ctx3 = CallContext(source:ctx2)
      //  So ctx3 is a copy of the start point
      //  Now add the paths
      ctx3.dancers.enumerated().forEach { (i,d) in
        d.path.add(allp[i >> 1])
      }
      //  And move it to the end point
      ctx3.levelBeats()
      ctx3.analyze()
    }
    
    let vdif = computeFormationOffsets(ctx,ctx2)
    xmlmap.enumerated().forEach { (i3,m) in
      let p = Path(allp[m>>1])
      if (p.movelist.isEmpty) {
        p.add(TamUtils.getMove("Stand"))
      }
      //  Scale active dancers to fit the space they are in
      //  Compute difference between current formation and XML formation
      let vd = vdif[i3].rotate(-ctx.actives[i3].tx.angle)
      //  Apply formation difference to first movement of XML path
      if (vd.length > 0.1) {
        p.skewFirst(-vd.x,-vd.y)
      }
      //  Add XML path to dancer
      ctx.actives[i3].path.add(p)
      //  Move dancer to end so any subsequent modifications (e.g. roll)
      //  use the new position
      ctx.actives[i3].animateToEnd()
    }
    ctx.levelBeats()
    ctx.analyze()
  }
  
  
  //  Once a mapping of the current formation to an XML call is found,
  //  we need to compute the difference between the two,
  //  and that difference will be added as an offset to the first movement
  func computeFormationOffsets(_ ctx1:CallContext, _ ctx2:CallContext) -> [Vector3D] {
    var dvbest = [Vector3D]()
    var dtotbest:CGFloat = -1
    //  We don't know how the XML formation needs to be turned to overlap
    //  the current formation.  So do an RMS fit to find the best match.
    var bxa:Array<Array<CGFloat>> = [[0,0,0],[0,0,0],[0,0,0]]
    ctx1.actives.enumerated().forEach { (i,d1) in
      let v1 = d1.location
      let v2 = ctx2.dancers[xmlmap[i]].location
      bxa[0][0] += v1.x * v2.x
      bxa[0][1] += v1.y * v2.x
      bxa[1][0] += v1.x * v2.y
      bxa[1][1] += v1.y * v2.y
    }
    let (ua,_,va) = Matrix.SVD(&bxa)
    let ut = Matrix()
    ut.putArray(Matrix.transpose(ua))
    let v = Matrix()
    v.putArray(va)
    let rotmat = v.preConcat(ut)
    //  Now rotate the formation and compute any remaining
    //  differences in position
    ctx1.actives.enumerated().forEach { (j,d2) in
      let v1 = d2.location
      let v2 = ctx2.dancers[xmlmap[j]].location.concatenate(rotmat)
      dvbest += [v1 - v2]
      dtotbest += dvbest[j].length
    }
    
    return dvbest
  }
  
  
}
