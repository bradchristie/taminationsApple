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

class CallContext {
  
  //  Various static functions for testing dancer relationships
  
  //  Angle of d2 as viewed from d1
  //  If angle is 0 then d2 is in front of d1
  //  Angle returned is in the range -pi to pi
  static func angle(d1:Dancer, _ d2:Dancer) -> CGFloat {
    return d2.location.concatenate(Matrix(d1.tx).inverse()).angle
  }
  
  //  Distance between two dancers
  static func distance(d1:Dancer, _ d2:Dancer) -> CGFloat {
    return (d1.location - d2.location).length
  }
  
  //  Angle of dancer to the origin
  static func angle(d:Dancer) -> CGFloat {
    return Vector3D(x: 0,y: 0).preConcatenate(Matrix(d.tx).inverse()).angle
  }
  
  //  Distance of one dancer to the origin
  static func distance(d1:Dancer) -> CGFloat {
    return d1.location.length
  }
  
  //  Other geometric interrogatives
  static func isFacingIn(d:Dancer) -> Bool {
    let a = abs(angle(d))
    return !a.isApprox(CG_PI/2) && a < CG_PI / 2
  }
  
  static func isFacingOut(d:Dancer) -> Bool {
    let a = abs(angle(d))
    return !a.isApprox(CG_PI/2) && a > CG_PI / 2
  }
  
  //  Test if dancer d2 is directly in front, back. left, right of dancer d1
  static func isInFront(d1:Dancer)(_ d2:Dancer) -> Bool {
    return d1 != d2 && angle(d1,d2).angleEquals(0)
  }
  static func isInBack(d1:Dancer)(_ d2:Dancer) -> Bool {
    return d1 != d2 && angle(d1,d2).angleEquals(CG_PI)
  }
  static func isLeft(d1:Dancer)(_ d2:Dancer) -> Bool {
    return d1 != d2 && angle(d1,d2).angleEquals(CG_PI/2)
  }
  static func isRight(d1:Dancer)(_ d2:Dancer) -> Bool {
    return d1 != d2 && angle(d1,d2).angleEquals(-CG_PI/2)
  }
  
  var callname = ""
  var callstack = [Call]()
  var dancers = [Dancer]()
  let genderMap = ["boy" : Gender.BOY, "girl" : Gender.GIRL, "phantom" : Gender.PHANTOM ]
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
  func getDancer(i:Int) -> Dancer {
    return dancers[i]
  }
  
  //  Create a context from a formation defined in XML
  convenience init(formation:JiNode) {
    self.init()
    let fds = formation.xPath("dancer")
    for (i,fd) in fds.enumerate() {
      //  TODO this assumes square geometry
      var m = Matrix().postRotate(CGFloat(Double(fd["angle"]!)!)*CG_PI/180)
      m = m.postTranslate(CGFloat(Double(fd["x"]!)!), y: CGFloat(Double(fd["y"]!)!))
      dancers.append(Dancer(number: "\(i*2+1)", number_couple: "\(i+1)", gender: genderMap[fd["gender"]!]!, fillcolor: UIColor.whiteColor(), mat: m, geom: GeometryMaker.makeOne(GeometryType.SQUARE, r: 0), moves: [Movement]()))
      dancers.append(Dancer(number: "\(i*2+1)", number_couple: "\(i+1)", gender: genderMap[fd["gender"]!]!, fillcolor: UIColor.whiteColor(), mat: m, geom: GeometryMaker.makeOne(GeometryType.SQUARE, r: 1), moves: [Movement]()))
    }
  }
  
  /**
  * Append the result of processing this CallContext to it source.
  * The CallContext must have been previously cloned from the source.
  */
  func appendToSource() -> CallContext {
    for d in dancers {
      d.clonedFrom!.path.add(d.path)
      d.clonedFrom!.animateToEnd()
    }
    return self
  }
  
  func applyCall(calltext:String) throws -> CallContext {
    try interpretCall(calltext)
    try performCall()
    appendToSource()
    return self
  }
  
  func applyCalls(calltext:String ...) throws {
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
  func interpretCall(calltxt:String) throws {
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
        throw err
      }
    }
  }
  
  func matchXMLCall(calltext:String) throws -> Bool {
    var found = false
    var matches = false
    var ctx = self
    
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
    //  First read and extract all the animations to a list
    let tams = callfiles.flatMap { (d:CallListDatum) -> [JiNode] in
      TamUtils.getXMLAsset(d.link).xPath("/tamination/tam")!
    }
    found = tams.nonEmpty
    //  Now find the animations that match the name and formation
    tams.filter { (tam:JiNode) -> Bool in
      tam["title"]!.lowercaseString.replaceAll("\\W", "").matches(callquery)
    }.exists { (tam:JiNode) -> Bool in
      let f = tam["formation"] != nil ? TamUtils.getFormation(tam["formation"]!) : tam.xPath("formation").first!
      let sexy = tam["gender-specific"] != nil
      //  Try to match the formation to the current dancer positions
      if let mm = self.matchFormations(ctx, CallContext(formation: f), sexy) {
        matches = true
        // add XMLCall object to the call stack
        ctx.callstack.append(XMLCall(xelem: tam, xmlmap: mm, ctx: ctx))
        self.callname += tam["title"]! + " "
      }
      return matches   // so exists() exits on 1st match
    }
    if (found && !matches) {
      //  Found the call but formations did not match
      throw FormationNotFoundError(calltext)
    }
    return matches
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

  func angleBin(a:CGFloat) -> Int {
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
  
  func dancerRelation(d1:Dancer, _ d2:Dancer) -> Int {
    return angleBin(CallContext.angle(d1,d2))
  }
  
  
  func matchFormations(ctx1: CallContext, _ ctx2:CallContext, _ sexy:Bool) -> [Int]? {
    if (ctx1.dancers.count != ctx2.dancers.count) {
      return nil
    }
    //  Find mapping using DFS
    var mapping = [Int](count:ctx1.dancers.count, repeatedValue: -1)
    var mapindex = 0
    while (mapindex >= 0 && mapindex < ctx1.dancers.count) {
      var nextmapping = mapping[mapindex] + 1
      var found = false
      while (!found && nextmapping < ctx2.dancers.count) {
        mapping[mapindex] = nextmapping
        mapping[mapindex + 1] = nextmapping ^ 1
        if (testMapping(ctx1, ctx2, mapping: mapping, index: mapindex, sexy: sexy)) {
          found = true
        } else {
          nextmapping++
        }
      }
      if (nextmapping >= ctx2.dancers.count) {
        //  No more mappings for this dancer
        mapping[mapindex] = -1
        mapping[mapindex + 1] = -1
        mapindex -= 2
      } else {
        //  Mapping found
        mapindex += 2
      }
    }
    return mapindex < 0 ? nil : mapping
  }
  
  func testMapping(ctx1: CallContext, _ ctx2:CallContext, mapping:[Int], index i:Int, sexy:Bool) -> Bool {
    if (sexy && ctx1.dancers[i].gender != ctx2.dancers[mapping[i]].gender) {
      return false
    }
    return ctx1.dancers.enumerate().every { (j,d1) in
      if (mapping[j] < 0 || i==j) {
        return true
      } else {
        let relq1 = self.dancerRelation(ctx1.dancers[i], ctx1.dancers[j])
        let relt1 = self.dancerRelation(ctx2.dancers[mapping[i]],ctx2.dancers[mapping[j]])
        let relq2 = self.dancerRelation(ctx1.dancers[j], ctx1.dancers[i])
        let relt2 = self.dancerRelation(ctx2.dancers[mapping[j]],ctx2.dancers[mapping[i]])
        //  If dancers are side-by-side, make sure handholding matches by checking distance
        if (relq1 == 2 || relq1 == 6) {
          let d1 = CallContext.distance(ctx1.dancers[i], ctx1.dancers[j])
          let d2 = CallContext.distance(ctx2.dancers[mapping[i]], ctx2.dancers[mapping[j]])
          return relq1==relt1 && relq2==relt2 && (d1 < 2.1) == (d2 < 2.1)
        } else {
          return relq1==relt1 && relq2==relt2
        }
      }
    }
  }
  
  
  func matchCodedCall(calltext:String) throws -> Bool {
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
    callstack.enumerate().forEach { (i,c) in c.preProcess(self, index: i) }
    //  Core calls primarly use the performCall method
    try callstack.enumerate().forEach { (i,c) in try c.performCall(self, index: i) }
    callstack.enumerate().forEach { (i,c) in c.postProcess(self, index: i) }
  }
  
  //  This is used to match XML calls
  func matchShapes(ctx2:CallContext) -> [Int]? {
    let ctx1 = self
    if (ctx1.dancers.count != ctx2.dancers.count) {
      return nil
    }
    var mapping = [Int](count:ctx1.dancers.count, repeatedValue:0)
    var reversemap = [Int](count:ctx1.dancers.count, repeatedValue:0)
    ctx1.dancers.enumerate().forEach { (i,d1) in
      var bestd2 = -1
      var bestdistance:CGFloat = 100
      let v1 = d1.location
      ctx2.dancers.enumerate().forEach { (j,d2) in
        let d = (v1 - d2.location).length
        if (d.isApprox(bestdistance)) {
          bestd2 = -1
        } else if (d < bestdistance) {
          bestdistance = d
          bestd2 = j
        }
      }
      if (bestd2 >= 0) {
        mapping[i] = bestd2
        reversemap[bestd2] = i
      }
    }
    //  Make sure we have a 1:1 mapping
    return mapping.every { $0 >= 0 } && reversemap.every { $0 >= 0 } ? mapping : nil
  }


  //  Re-center dancers
  func center() {
    let xave = dancers.map { $0.location.x } .reduce(0, combine: +) / CGFloat(dancers.count)
    let yave = dancers.map { $0.location.y } .reduce(0, combine: +) / CGFloat(dancers.count)
    dancers.forEach { $0.starttx.postTranslate(xave, y: yave) }
  }
  
  //  Return max number of beats among all the dancers
  var maxBeats:CGFloat { get { return dancers.reduce(0, combine: { max($0,$1.path.beats) } ) } }

  //  Return all dancers, ordered by distance, that satisfies a conditional
  func dancersInOrder(d:Dancer, _ f:(Dancer)->Bool) -> [Dancer] {
    return dancers.filter(f).sort { CallContext.distance($0,d) < CallContext.distance($1,d) }
  }
  
  //  Return closest dancer that satisfies a given conditional
  func dancerClosest(d:Dancer, _ f:(Dancer)->Bool) -> Dancer? {
    return dancersInOrder(d,f).first
  }
  
  //  Return dancer directly in front of given dancer
  func dancerInFront(d:Dancer) -> Dancer? {
    return dancerClosest(d,CallContext.isInFront(d))
  }
  
  //  Return dancer directly in back of given dancer
  func dancerInBack(d:Dancer) -> Dancer? {
    return dancerClosest(d,CallContext.isInBack(d))
  }
  
  //  Return dancer directly to the right of given dancer
  func dancerToRight(d:Dancer) -> Dancer? {
    return dancerClosest(d,CallContext.isRight(d))
  }
  
  //  Return dancer directly to the left of given dancer
  func dancerToLeft(d:Dancer) -> Dancer? {
    return dancerClosest(d,CallContext.isLeft(d))
  }
  
  //  Return dancer that is facing the front of this dancer
  func dancerFacing(d:Dancer) -> Dancer? {
    if let d2 = dancerInFront(d) {
      //  Found dancer d2 in front of d
      //  d must also be the dancer in front of d2
      return dancerInFront(d2) == d ? d2 : nil
    } else {
      return nil
    }
  }

  //  Return dancers that are in between two other dancers
  func inBetween(d1:Dancer, _ d2:Dancer) -> [Dancer] {
    return dancers.filter { d in
      return d != d1 && d != d2 && (CallContext.distance(d, d1) + CallContext.distance(d, d2)).isApprox(CallContext.distance(d1, d2))
    }
  }
  
  //  Return all the dancers to the right, in order
  func dancersToRight(d:Dancer) -> [Dancer] {
    return dancersInOrder(d,CallContext.isRight(d))
  }
  
  //  Return all the dancers to the left, in order
  func dancersToLeft(d:Dancer) -> [Dancer] {
    return dancersInOrder(d,CallContext.isLeft(d))
  }
  
  func dancersInFront(d:Dancer) -> [Dancer] {
    return dancersInOrder(d,CallContext.isInFront(d))
  }
  
  func dancersInBack(d:Dancer) -> [Dancer] {
    return dancersInOrder(d,CallContext.isInBack(d))
  }
  
  //  Return true if this dancer is in a wave or mini-wave
  func isInWave(d:Dancer) -> Bool {
    if let d2 = d.data.partner {
      return CallContext.angle(d,d2).angleEquals(CallContext.angle(d2,d))
    } else {
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
  
  //  Find the range of the dancers current position
  //  For now we assume the dancers are centered
  //  and return a vector to the max 1st quadrant rectangle point
  func bounds() -> Vector3D {
    return dancers.map { $0.location }
      .reduce(Vector3D(x: 0,y: 0), combine: { (v1,v2) in
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
    let dorder = dancers.sort { $0.location.length < $1.location.length }
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







