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

class CallContext {
  
  //  Various static functions for testing dancer relationships
  
  //  Angle of d2 as viewed from d1
  //  If angle is 0 then d2 is in front of d1
  //  Angle returned is in the range -pi to pi
  static func angle(_ d1:Dancer, _ d2:Dancer) -> CGFloat {
    return d2.location.concatenate(Matrix(d1.tx).inverse()).angle
  }
  
  //  Distance between two dancers
  static func distance(_ d1:Dancer, _ d2:Dancer) -> CGFloat {
    return (d1.location - d2.location).length
  }
  
  //  Angle of dancer to the origin
  static func angle(_ d:Dancer) -> CGFloat {
    return Vector3D(x: 0,y: 0).preConcatenate(Matrix(d.tx).inverse()).angle
  }
  
  //  Distance of one dancer to the origin
  static func distance(_ d1:Dancer) -> CGFloat {
    return d1.location.length
  }
  
  //  Other geometric interrogatives
  static func isFacingIn(_ d:Dancer) -> Bool {
    let a = abs(angle(d))
    return !a.isApprox(CG_PI/2) && a < CG_PI / 2
  }
  
  static func isFacingOut(_ d:Dancer) -> Bool {
    let a = abs(angle(d))
    return !a.isApprox(CG_PI/2) && a > CG_PI / 2
  }
  
  //  Test if dancer d2 is directly in front, back. left, right of dancer d1
  static func isInFront(_ d1:Dancer) -> (Dancer) -> Bool {
    return { (d2:Dancer) -> Bool in
      return d1 != d2 && angle(d1,d2).angleEquals(0)
    }
  }
  static func isInBack(_ d1:Dancer) -> (Dancer) -> Bool {
    return { (d2:Dancer) -> Bool in
      return d1 != d2 && angle(d1,d2).angleEquals(CG_PI)
    }
  }
  static func isLeft(_ d1:Dancer) -> (Dancer) -> Bool {
    return { (d2:Dancer) -> Bool in
      return d1 != d2 && angle(d1,d2).angleEquals(CG_PI/2)
    }
  }
  static func isRight(_ d1:Dancer) -> (Dancer) -> Bool {
    return { (d2:Dancer) -> Bool in
      return d1 != d2 && angle(d1,d2).angleEquals(-CG_PI/2)
    }
  }
  
  var callname = ""
  var callstack = [Call]()
  var dancers = [Dancer]()
  let genderMap = ["boy" : Gender.boy, "girl" : Gender.girl, "phantom" : Gender.phantom ]
  var isVertical = false  //  for FourDancerCall
  
  init() { }
  
  //  For cases where creating a new context from a source,
  //  get the dancers from the source and clone them.
  //  The new context contains the dancers in their current location
  //  and no paths.
  convenience init(source:CallContext) {
    self.init()
    dancers = source.dancers.map { Dancer(from:$0) }
  }

  //  Create a context from another array of Dancer
  convenience init(source:[Dancer]) {
    self.init()
    dancers = source.map { $0.animateToEnd(); return Dancer(from:$0) }
  }

  //  Get a specific dancer
  func getDancer(_ i:Int) -> Dancer {
    return dancers[i]
  }
  
  //  Create a context from a formation defined in XML
  convenience init(formation:XMLElement) {
    self.init()
    let fds = formation.xpath("dancer")
    for (i,fd) in fds.enumerated() {
      //  TODO this assumes square geometry
      var m = Matrix().postRotate(CGFloat(Double(fd["angle"]!)!)*CG_PI/180)
      m = m.postTranslate(CGFloat(Double(fd["x"]!)!), y: CGFloat(Double(fd["y"]!)!))
      dancers.append(Dancer(number: "\(i*2+1)", number_couple: "\(i+1)", gender: genderMap[fd["gender"]!]!, fillcolor: UIColor.white, mat: m, geom: GeometryMaker.makeOne(GeometryType.square, r: 0), moves: [Movement]()))
      dancers.append(Dancer(number: "\(i*2+2)", number_couple: "\(i+1)", gender: genderMap[fd["gender"]!]!, fillcolor: UIColor.white, mat: m, geom: GeometryMaker.makeOne(GeometryType.square, r: 1), moves: [Movement]()))
    }
  }
  
  /**
  * Append the result of processing this CallContext to it source.
  * The CallContext must have been previously cloned from the source.
  */
  @discardableResult func appendToSource() -> CallContext {
    for d in dancers {
      d.clonedFrom!.path.add(d.path)
      d.clonedFrom!.animateToEnd()
    }
    return self
  }
  
  @discardableResult func applyCall(_ calltext:String) throws -> CallContext {
    try interpretCall(calltext)
    try performCall()
    appendToSource()
    return self
  }
  
  func applyCalls(_ calltext:String ...) throws {
    for callstr in calltext {
      try CallContext(source:self).applyCall(callstr)
    }
  }
  
  var actives:[Dancer] { get {
    return dancers.filter { $0.data.active }
  } }
  
  /**
   * This is the main loop for interpreting a call
   * @param calltxt  One complete call, lower case, words separated by single spaces
   */
  func interpretCall(_ calltxt:String) throws {
    var calltext = calltxt
    var err:CallError = CallNotFoundError(calltxt)
    //  Clear out any previous paths from incomplete parsing
    for d in dancers { d.path = Path() }
    callname = ""
    //  If a partial interpretation is found (like 'boys' of 'boys run')
    //  it gets popped off the front and this loop interprets the rest
    while (calltext.length > 0) {
      //  Try chopping off each word from the end of the call until
      //  we find something we know
      if (!calltext.chopped().exists { (callname:String) -> Bool in
        var success = false
        //  First try to find an exact match in Taminations
        //  Then look for a code match
        do {
          try success = self.matchXMLCall(callname)
        } catch let err2 as CallError  {
          err = err2
        } catch { }
        do {
          try success = success || self.matchCodedCall(callname)
        } catch let err3 as CallError {
          err = err3
        } catch { }
        if (success) {
          //  Remove the words we matched, break out of and
          //  the chopped loop, and continue if any words left
          calltext = calltext.replaceFirst(callname, "").trim()
        }
        return success
      }) {
        //  Every combination from callwords.chopped failed
        throw err as Error
      }
    }
  }
  
  func matchXMLCall(_ calltext:String) throws -> Bool {
    var found = false
    var matches = false
    var ctx = self
    let ctx0 = self
    
    //  If there are precursors, run them first so the result
    //  will be used to match formations
    //  Needed for calls like "Explode And ..."
    if (ctx.callstack.nonEmpty) {
      ctx = CallContext(source: self)
      ctx.callstack = callstack
      try ctx.performCall()
    }

    //  If actives != dancers, create another call context with just the actives
    if (ctx.dancers.count != ctx.actives.count) {
      ctx = CallContext(source: ctx.actives)
    }

    //  Try to find a match in the xml animations
    let callquery = TamUtils.callnameQuery(calltext)
    let callfiles = TamUtils.calllistdata.filter { $0.text.matches(callquery) }
    //  Found xml file with call, now look through each animation
    _ = callfiles.exists { (d:CallListDatum) -> Bool in
      let doc = TamUtils.getXMLAsset(d.link)
      let tams = doc.xpath("//tam")
      found = tams.nonEmpty
      return tams.exists { (tam:XMLElement) -> Bool in
        if (tam["title"]!.lowercased().replaceAll("\\W", "").matches(callquery)) {
          let f = tam["formation"] != nil ? TamUtils.getFormation(tam["formation"]!) : tam.xpath("formation").first!
          let ctx2 = CallContext(formation: f)
          let sexy = tam["gender-specific"] != nil
          //  Try to match the formation to the current dancer positions
          if let mm = self.matchFormations(ctx, ctx2, sexy: sexy) {
            matches = true
            // add XMLCall object to the call stack
            ctx0.callstack.append(XMLCall(doc:doc, xelem: tam, xmlmap: mm, ctx: ctx2))
            ctx0.callname += tam["title"]! + " "
          }
        }
        return matches
      }
    }
    if (found && !matches) {
      //  Found the call but formations did not match
      throw FormationNotFoundError(calltext) as Error
    }
    return matches
  }
  
  //  Once a mapping of the current formation to an XML call is found,
  //  we need to compute the difference between the two,
  //  and that difference will be added as an offset to the first movement
  func computeFormationOffsets(_ ctx2:CallContext, _ mapping:[Int]) -> [Vector3D] {
    var dvbest = [Vector3D]()
    var dtotbest:CGFloat = -1
    //  We don't know how the XML formation needs to be turned to overlap
    //  the current formation.  So do an RMS fit to find the best match.
    var bxa:Array<Array<CGFloat>> = [[0,0],[0,0]]
    actives.enumerated().forEach { (i,d1) in
      let v1 = d1.location
      let v2 = ctx2.dancers[mapping[i]].location
      bxa[0][0] += v1.x * v2.x
      bxa[0][1] += v1.y * v2.x
      bxa[1][0] += v1.x * v2.y
      bxa[1][1] += v1.y * v2.y
    }
    let (ua,_,va) = Matrix.svd22(bxa)
    let ut = Matrix()
    ut.putArray(Matrix.transpose(ua))
    let v = Matrix()
    v.putArray(va)
    let rotmat = v.preConcat(ut)
    //  Now rotate the formation and compute any remaining
    //  differences in position
    actives.enumerated().forEach { (j,d2) in
      let v1 = d2.location
      let v2 = ctx2.dancers[mapping[j]].location.concatenate(rotmat)
      dvbest += [v1 - v2]
      dtotbest += dvbest[j].length
    }
    return dvbest
  }
  
  /*
  * Algorithm to match formations
  * Match dancers relative to each other, rather than compare absolute positions
  * Returns integer values for axis and quadrant directions
  *           0
  *         7 | 1
  *       6 --+-- 2
  *         5 | 3
  *           4
  * 2 cases
  *   1.  Dancers facing same or opposite directions
  *       - If dancers are lined up 0, 90, 180, 270 angles must match
  *       - Other angles match by quadrant
  *   2.  Dancers facing other relative directions (commonly 90 degrees)
  *       - Dancers must match quadrant or adj boundary
  *
  *
  *
  */

  func angleBin(_ a:CGFloat) -> Int {
    switch a {
    case let x where x.angleEquals(0) : return 0
    case let x where x.angleEquals(CG_PI / 2) : return 2
    case let x where x.angleEquals(CG_PI) : return 4
    case let x where x.angleEquals(-CG_PI / 2) : return 6
    case let x where x > 0 && x < CG_PI / 2 : return 1
    case let x where x > CG_PI / 2 && x < CG_PI : return 3
    case let x where x < 0 && x > -CG_PI / 2 : return 7
    case let x where x < -CG_PI / 2 && x > -CG_PI : return 5
    default : return -1
    }
  }
  
  func dancerRelation(_ d1:Dancer, _ d2:Dancer) -> Int {
    return angleBin(CallContext.angle(d1,d2))
  }
  
  
  func matchFormations(_ ctx1: CallContext, _ ctx2:CallContext, sexy:Bool, fuzzy:Bool=false) -> [Int]? {
    if (ctx1.dancers.count != ctx2.dancers.count) {
      return nil
    }
    //  Find mapping using DFS
    var mapping = [Int](repeating: -1, count: ctx1.dancers.count)
    var rotated = [Bool](repeating: false, count: ctx1.dancers.count)
    var mapindex = 0
    while (mapindex >= 0 && mapindex < ctx1.dancers.count) {
      var nextmapping = mapping[mapindex] + 1
      var found = false
      while (!found && nextmapping < ctx2.dancers.count) {
        mapping[mapindex] = nextmapping
        mapping[mapindex + 1] = nextmapping ^ 1
        if (testMapping(ctx1, ctx2, mapping: mapping, index: mapindex, sexy: sexy, fuzzy:fuzzy)) {
          found = true
        } else {
          nextmapping += 1
        }
      }
      if (nextmapping >= ctx2.dancers.count) {
        //  No more mappings for this dancer
        mapping[mapindex] = -1
        mapping[mapindex + 1] = -1
        //  If fuzzy, try rotating this dancer
        if (fuzzy && !rotated[mapindex]) {
          ctx1.dancers[mapindex].rotateStartAngle(180.0)
          ctx1.dancers[mapindex+1].rotateStartAngle(180.0)
          rotated[mapindex] = true
        } else {
          rotated[mapindex] = false
          mapindex -= 2
        }
      } else {
        //  Mapping found
        mapindex += 2
      }
    }
    return mapindex < 0 ? nil : mapping
  }
  
  func testMapping(_ ctx1: CallContext, _ ctx2:CallContext, mapping:[Int], index i:Int, sexy:Bool, fuzzy:Bool) -> Bool {
    if (sexy && (ctx1.dancers[i].gender != ctx2.dancers[mapping[i]].gender)) {
      return false
    }
    return ctx1.dancers.enumerated().every { (j,d1) in
      if (mapping[j] < 0 || i==j) {
        return true
      } else {
        let relq1 = self.dancerRelation(ctx1.dancers[i], ctx1.dancers[j])
        let relt1 = self.dancerRelation(ctx2.dancers[mapping[i]],ctx2.dancers[mapping[j]])
        let relq2 = self.dancerRelation(ctx1.dancers[j], ctx1.dancers[i])
        let relt2 = self.dancerRelation(ctx2.dancers[mapping[j]],ctx2.dancers[mapping[i]])
        //  If dancers are side-by-side, make sure handholding matches by checking distance
        if (!fuzzy && (relq1 == 2 || relq1 == 6)) {
          let d1 = CallContext.distance(ctx1.dancers[i], ctx1.dancers[j])
          let d2 = CallContext.distance(ctx2.dancers[mapping[i]], ctx2.dancers[mapping[j]])
          if ((d1 < 2.1) != (d2 < 2.1)) {
            return false
          }
        }
        if (fuzzy) {
          let reldif1 = (relt1-relq1).Abs
          let reldif2 = (relt2-relq2).Abs
          return (reldif1==0 || reldif1==1 || reldif1==7) &&
            (reldif2==0 || reldif2==1 || reldif2==7)
        } else {
          return relq1==relt1 && relq2==relt2
        }
      }
    }
  }
  
  
  func matchCodedCall(_ calltext:String) throws -> Bool {
    if let call = CodedCall.getCodedCall(calltext) {
      callstack.append(call)
      callname += call.name + " "
      return true
    } else {
      return false
    }
  }
  
  //  Perform calls by popping them off the stack until the stack is empty.
  //  This doesn't run an animation, rather it takes the stack of calls
  //  and builds the dancer movements.
  func performCall() throws {
    analyze()
    //  Concepts and modifications primarily use the preProcess and
    //  postProcess methods
    callstack.enumerated().forEach { (i,c) in c.preProcess(self, index: i) }
    //  Core calls primarly use the performCall method
    try callstack.enumerated().forEach { (i,c) in try c.performCall(self, index: i) }
    callstack.enumerated().forEach { (i,c) in c.postProcess(self, index: i) }
  }

  //  Re-center dancers
  func center() {
    let xave = dancers.map { $0.location.x } .reduce(0, +) / CGFloat(dancers.count)
    let yave = dancers.map { $0.location.y } .reduce(0, +) / CGFloat(dancers.count)
    dancers.forEach { $0.starttx = $0.starttx.postTranslate(xave, y: yave) }
  }
  
  //  See if the current dancer positions resemble a standard formation
  //  and, if so, snap to the standard
  static let standardFormations = [
    "Normal Lines",
    "Normal Lines Compact",
    "Double Pass Thru",
    "Static Square",
    "Quarter Tag",
    "Tidal Line RH",
    "Diamonds RH Girl Points",
    "Diamonds RH PTP Girl Points",
    "Hourglass RH BP",
    "Galaxy RH GP",
    "Butterfly RH",
    "O RH",
    "Sausage RH"
  ]
  struct BestMapping { let name:String; let mapping:[Int]; let offsets:[Vector3D]; let totOffset:CGFloat }
  func matchStandardFormation() {
    //  Make sure newly added animations are finished
    dancers.forEach { $0.path.recalculate(); $0.animateToEnd() }
    //  Work on a copy with all dancers active, mapping only uses active dancers
    let ctx1 = CallContext(source:self);
    ctx1.dancers.forEach { $0.data.active = true }
    var bestMapping:BestMapping? = nil
    CallContext.standardFormations.forEach { f in
      let ctx2 = CallContext(formation:TamUtils.getFormation(f))
      //  See if this formation matches
      if let mapping = matchFormations(ctx1,ctx2,sexy: false,fuzzy: true) {
        //  If it does, get the offsets
        let offsets = ctx1.computeFormationOffsets(ctx2,mapping)
        let totOffset = offsets.reduce(0.0) { s,v in s+v.length }
        if (bestMapping==nil || totOffset < bestMapping!.totOffset) {
          bestMapping = BestMapping (
            name: f,  // only used for debugging
            mapping: mapping,
            offsets: offsets,
            totOffset: totOffset
          )
        }
      }
    }
    if (bestMapping != nil) {
      for (i,d) in dancers.enumerated() {
        if (bestMapping!.offsets[i].length > 0.1) {
          //  Get the last movement
          let m = d.path.movelist.removeLast()
          //  Transform the offset to the dancer's angle
          d.animateToEnd()
          let vd = bestMapping!.offsets[i].rotate(-d.tx.angle)
          //  Apply it
          d.path.movelist.append(m.skew(-vd.x,-vd.y))
          d.animateToEnd()
        }
      }
    }
  }
  
  
  
  //  Return max number of beats among all the dancers
  var maxBeats:CGFloat { get { return dancers.reduce(0, { max($0,$1.path.beats) } ) } }

  //  Return all dancers, ordered by distance, that satisfies a conditional
  func dancersInOrder(_ d:Dancer, _ f:(Dancer)->Bool) -> [Dancer] {
    return dancers.filter(f).sorted { CallContext.distance($0,d) < CallContext.distance($1,d) }
  }
  
  //  Return closest dancer that satisfies a given conditional
  func dancerClosest(_ d:Dancer, _ f:(Dancer)->Bool) -> Dancer? {
    return dancersInOrder(d,f).first
  }
  
  //  Return dancer directly in front of given dancer
  func dancerInFront(_ d:Dancer) -> Dancer? {
    return dancerClosest(d,CallContext.isInFront(d))
  }
  
  //  Return dancer directly in back of given dancer
  func dancerInBack(_ d:Dancer) -> Dancer? {
    return dancerClosest(d,CallContext.isInBack(d))
  }
  
  //  Return dancer directly to the right of given dancer
  func dancerToRight(_ d:Dancer) -> Dancer? {
    return dancerClosest(d,CallContext.isRight(d))
  }
  
  //  Return dancer directly to the left of given dancer
  func dancerToLeft(_ d:Dancer) -> Dancer? {
    return dancerClosest(d,CallContext.isLeft(d))
  }
  
  //  Return dancer that is facing the front of this dancer
  func dancerFacing(_ d:Dancer) -> Dancer? {
    if let d2 = dancerInFront(d) {
      //  Found dancer d2 in front of d
      //  d must also be the dancer in front of d2
      return dancerInFront(d2) == d ? d2 : nil
    } else {
      return nil
    }
  }

  //  Return dancers that are in between two other dancers
  func inBetween(_ d1:Dancer, _ d2:Dancer) -> [Dancer] {
    return dancers.filter { d in
      return d != d1 && d != d2 && (CallContext.distance(d, d1) + CallContext.distance(d, d2)).isApprox(CallContext.distance(d1, d2))
    }
  }
  
  //  Return all the dancers to the right, in order
  func dancersToRight(_ d:Dancer) -> [Dancer] {
    return dancersInOrder(d,CallContext.isRight(d))
  }
  
  //  Return all the dancers to the left, in order
  func dancersToLeft(_ d:Dancer) -> [Dancer] {
    return dancersInOrder(d,CallContext.isLeft(d))
  }
  
  func dancersInFront(_ d:Dancer) -> [Dancer] {
    return dancersInOrder(d,CallContext.isInFront(d))
  }
  
  func dancersInBack(_ d:Dancer) -> [Dancer] {
    return dancersInOrder(d,CallContext.isInBack(d))
  }
  
  //  Return true if this dancer is in a wave or mini-wave
  func isInWave(_ d:Dancer) -> Bool {
    if let d2 = d.data.partner {
      return CallContext.angle(d,d2).angleEquals(CallContext.angle(d2,d))
    } else {
      return false
    }
  }
  
  //  Return true if this dancer is part of a couple facing same direction
  func isInCouple(_ d:Dancer) -> Bool {
    if let d2 = d.data.partner {
      return d.tx.angle.angleEquals(d2.tx.angle)
    }
    else {
      return false
    }
  }
  
  //  Return true if this is 4 dancers in a box
  var isBox:Bool { get {
    //  Must have 4 dancers
    return dancers.count == 4 &&
    //  Each dancer must have a partner
    //  and must be either a leader or a trailer
      dancers.every { d in d.data.partner != nil && (d.data.leader || d.data.trailer) }
    } }
  
  //  Return true if this is 4 dancers in a line
  var isLine:Bool { get {
    //  Must have 4 dancers
    return dancers.count == 4 &&
    //  Each dancer must have right or left shoulder to origin
      dancers.every { d in abs(CallContext.angle(d)).isApprox(CG_PI/2) } &&
      //  All dancers must either be on the y axis
      (dancers.every { d in d.location.x.isApprox(0) } ||
      //  or on the x axis
       dancers.every { d in d.location.y.isApprox(0) } )
    } }
  
  //  Level off the number of beats for each dancer
  func levelBeats() {
    //  get the longest number of beats
    let maxb = maxBeats
    //  add that number as needed by using the "Stand" move
    dancers.forEach { d in
      let b = maxb - d.path.beats
      if (b > 0) {
        d.path.add(TamUtils.getMove("Stand").changebeats(b))
      }
    }
  }
  
  //  Return true if 8 dancers are in 2 general lines of 4 dancers each
  func isLines() -> Bool {
    return dancers.every { d in dancersToRight(d).count + dancersToLeft(d).count == 3 }
  }
  
  //  Return true if 8 dancers are in 2 general columns of 4 dancers each
  func isColumns() -> Bool {
    return dancers.every { d in dancersInFront(d).count + dancersInBack(d).count == 3 }
  }
  
  
  //  Find the range of the dancers current position
  //  For now we assume the dancers are centered
  //  and return a vector to the max 1st quadrant rectangle point
  func bounds() -> Vector3D {
    return dancers.map { $0.location }
      .reduce(Vector3D(x: 0,y: 0), { (v1,v2) in
        return Vector3D(x: max(v1.x,v2.x),y: max(v1.y,v2.y)) })
  }
  
  func analyze() {
    dancers.forEach { d in
      d.animateToEnd()
      d.data.beau = false
      d.data.belle = false
      d.data.leader = false
      d.data.trailer = false
      d.data.partner = nil
      d.data.center = false
      d.data.end = false
      d.data.verycenter = false
    }
    var istidal = false
    dancers.forEach { d1 in
      let bestleft:Dancer? = dancerToLeft(d1)
      let bestright:Dancer? = dancerToRight(d1)
      let leftcount = dancersToLeft(d1).count
      let rightcount = dancersToRight(d1).count
      let frontcount = dancersInFront(d1).count
      let backcount = dancersInBack(d1).count
      //  Use the results of the counts to assign belle/beau/leader/trailer
      //  and partner
      if (leftcount % 2 == 1 && rightcount % 2 == 0 && CallContext.distance(d1,bestleft!) < 3) {
        d1.data.partner = bestleft
        d1.data.belle = true
      }
      else if (rightcount % 2 == 1 && leftcount % 2 == 0 && CallContext.distance(d1,bestright!) < 3) {
        d1.data.partner = bestright
        d1.data.beau = true
      }
      if (frontcount % 2 == 0 && backcount % 2 == 1) {
        d1.data.leader = true
      }
      else if (frontcount % 2 == 1 && backcount % 2 == 0) {
        d1.data.trailer = true
      }
      //  Assign ends
      if (rightcount == 0 && leftcount > 1) {
        d1.data.end = true
      }
      else if (leftcount == 0 && rightcount > 1) {
        d1.data.end = true
      }
      //  The very centers of a tidal wave are ends
      //  Remember this special case for assigning centers later
      if (rightcount == 3 && leftcount == 4 || rightcount == 4 && leftcount == 3) {
        d1.data.end = true
        istidal = true
      }
    }
    //  Analyze for centers and very centers
    //  Sort dancers by distance from center
    let dorder = dancers.sorted { $0.location.length < $1.location.length }
    //  The 2 dancers closest to the center
    //  are centers (4 dancers) or very centers (8 dancers)
    if (!dorder[1].location.length.isApprox(dorder[2].location.length)) {
      if (dancers.count == 4) {
        dorder[0].data.center = true
        dorder[1].data.center = true
      } else {
        dorder[0].data.verycenter = true
        dorder[1].data.verycenter = true
      }
    }
    // If tidal, then the next 4 dancers are centers
    if (istidal) {
      [2,3,4,5].forEach { dorder[$0].data.center = true }
    }
    //  Otherwise, if there are 4 dancers closer to the center than the other 4,
    //  they are the centers
    else if (dancers.count > 4 && !CallContext.distance(dorder[3]).isApprox(CallContext.distance(dorder[4]))) {
      [0,1,2,3].forEach { dorder[$0].data.center = true }
    }
  }
  
}







