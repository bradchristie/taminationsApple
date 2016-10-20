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

class XMLCall : Call {
  
  let xelem:JiNode
  let xmlmap:[Int]
  let ctx2:CallContext
  init(xelem:JiNode, xmlmap:[Int], ctx:CallContext) {
    self.xelem = xelem
    self.xmlmap = xmlmap
    self.ctx2 = ctx
  }

  override func performCall(_ ctx: CallContext, index: Int) {
    let allp = TamUtils.getPaths(xelem)
    let xfactor:CGFloat = 0
    let yfactor:CGFloat = 0
     /*
    //  If moving just some of the dancers,
    //  see if we can keep them in the same shape
    if (ctx.actives.count < ctx.dancers.count) {
      //  No animations have been done on ctx2,
      //  so dancers are still at the start points
      let ctx3 = CallContext(source: ctx2)
      //  So ctx3 is a copy of the start point
      let bounds1 = ctx3.bounds()
      //  Now add the paths
      ctx3.dancers.enumerated().forEach { (i,d) in
        d.path.add(Path(allp[i>>1]))
      }
      //  And move it to the end point
      ctx3.analyze()
      let bounds2 = ctx3.bounds()
      //  And see if the shape has changed
      //if let shapemap = ctx2.matchShapes(ctx3) {
      if (ctx2.matchShapes(ctx3) != nil) {
        //  TODO see if mapping is 90 degrees off
        let bounds0 = CallContext(source: ctx.actives).bounds()
        xfactor = (2*bounds0.x)/(bounds1.x + bounds2.x)
        yfactor = (2*bounds0.y)/(bounds1.y + bounds2.y)
      }
    }
    */
  //  let vdif = computeFormationOffsets(ctx,ctx2)
    xmlmap.enumerated().forEach { (i3,m) in
      let p = Path(allp[m>>1])
      //  Scale active dancers to fit the space they are in
      if (xfactor > 0 && yfactor > 0) {
        let vs = Vector3D(x: xfactor, y: yfactor).rotate(Matrix(ctx2.dancers[m].tx).angle)
        p.scale(abs(vs.x),abs(vs.y))
      } else {
        //  Compute difference between current formation and XML formation
  //      let vd = vdif[i3].rotate(-Matrix(ctx.actives[i3].tx).angle)
  //      //  Apply formation difference to first movement of XML path
  //      if (vd.length > 0.1) {
  //        p.movelist[0] = p.movelist[0].skew(-vd.x, -vd.y)
  //      }
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
    //  the current formation.  So try all 4 angles and use the best.
    [CGFloat(0),CG_PI/2,CG_PI,CG_PI*3/2].forEach { angle in
      var dv = [Vector3D](repeating: Vector3D(x:0,y:0), count: ctx1.dancers.count)
      var dtot:CGFloat = 0.0
      ctx1.actives.enumerated().forEach { (i,d1) in
        let v1 = d1.location
        let v2 = ctx2.dancers[xmlmap[i]].location.rotate(angle)
        dv[i] = v1 - v2
        dtot += dv[i].length
      }
      if (dtotbest < 0 || dtotbest > dtot) {
        dvbest = dv
        dtotbest = dtot
      }
    }
    return dvbest
  }
  
  
}
