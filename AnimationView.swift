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

import UIKit

enum Speed:Int {
  case slow = 1
  case normal = 0
  case moderate = 3
  case fast = 2
}

enum SpeedValues:CGFloat {
  case slowspeed = 1500
  case moderatespeed = 1000
  case normalspeed = 500
  case fastspeed = 200
}


class AnimationView: UIView {
  
  var lasttime:CFTimeInterval =  CFAbsoluteTimeGetCurrent()
  var beat:CGFloat = 0
  var beats:CGFloat = 0
  var prevbeat:CGFloat = 0
  var leadin:CGFloat = 2
  var leadout:CGFloat = 2
  var isRunning:Bool = false
  var iscore:CGFloat = 0
  var parts:String = ""
  var partbeats:[CGFloat] = []
  var currentPart = 0
  var showGrid:Bool = false
  var showPhantoms:Bool = false
  var showPaths:Bool = false
  var looping:Bool = false
  var dancers:[Dancer] = []
  var interactiveDancer:Int = -1
  var speed:SpeedValues = .normalspeed
  var geometry:GeometryType = .square
  var tam:JiNode?
  var hasParts = false
  var idancer:InteractiveDancer? = nil
  
  //  callbacks
  var readyCallback:()->() = { }
  var progressCallback:(_ beat:CGFloat)->() = { arg in }
  var partCallback:(_ part:Int)->() = { arg in }
  var doneCallback:()->() = { }
  
  
  override init(frame: CGRect) {
    super.init(frame:frame)
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  /**
   *   Starts the animation
   */
  func doPlay() {
    lasttime = CFAbsoluteTimeGetCurrent()
    if (beat > beats) {
      beat = -leadin
    }
    isRunning = true
    iscore = 0
    setNeedsDisplay()
  }
  
  /**
   * Pauses the dancers update & animation.
   */
  func doPause() {
    isRunning = false
  }
  
  /**
   *  Rewinds to the start of the animation, even if it is running
   */
  func doRewind() {
    beat = -leadin
    setNeedsDisplay()
  }
  
  /**
   *   Moves the animation back a little
   */
  func doBackup() {
    beat = max(beat-0.1,-leadin)
    setNeedsDisplay()
  }
  
  /**
   *   Moves to the end of the animation
   */
  func doEnd() {
    beat = beats
    setNeedsDisplay()
  }

   /**
   *   Moves the animation forward a little
   */
  func doForward() {
    beat = min(beat+0.1,beats)
    setNeedsDisplay()
  }
  
  /**
   *   Build an array of floats out of the parts of the animation
   */
  func partsValues() -> Array<CGFloat> {
    if (parts.length == 0) {
      return [-2,0,beats-2,beats]
    } else {
      var b:CGFloat = 0
      let t = parts.split(";")
      var retval = [CGFloat]()
      for i in -2 ..< t.count+2 {
        switch i {
        case -2 : retval.append(-leadin)
        case -1 : retval.append((0))
        case t.count : retval.append(beats-2.0)
        case t.count+1 : retval.append(beats)
        default : b = b + CGFloat(Double(t[i])!); retval.append(b)
        }
      }
      return retval
    }
  }
  
  /**
   *   Moves the animation to the next part
   */
  func doNextPart() {
    if (beat < beats) {
      beat = partsValues().filter({$0 <= beat})[0]
      setNeedsDisplay()
    }
  }
  
  /**
   *   Moves the animation to the previous part
   */
  func doPrevPart() {
    if (beat > -leadin) {
      beat = partsValues().reversed().filter({$0 >= beat})[0]
      setNeedsDisplay()
    }
  }
  
  /**
   *   Set the visibility of the grid
   */
  func setGridVisibility(_ show:Bool) {
    showGrid = show
    setNeedsDisplay()
  }
  
  /**
   *   Set the visibility of phantom dancers
   */
  func setPhantomVisibility(_ show:Bool) {
    showPhantoms = show
    for d in dancers {
      d.hidden = d.isPhantom && !show
    }
  }
  
  /**
   *  Turn on drawing of dancer paths
   */
  func setPathVisibility(_ show:Bool) {
    showPaths = show
    setNeedsDisplay()
  }
  
  /**
   *   Set animation looping
   */
  func setLoop(_ loopit:Bool) {
    looping = loopit
    setNeedsDisplay()
  }
  
  /**
   *   Set display of dancer numbers
   */
  func setNumbers(_ numberem:ShowNumbers) {
    let n = interactiveDancer >= 0 ? .numbers_OFF : numberem
    for d in dancers {
      d.showNumber = n
    }
  }
  func setNumbers(_ numberstr:String) {
    switch numberstr {
    case "1-8" : setNumbers(.numbers_DANCERS)
    case "1-4" : setNumbers(.numbers_COUPLES)
    default : setNumbers(.numbers_OFF)
    }
  }
  
  /**
   *   Set speed of animation
   */
  func setSpeed(_ myspeed:Speed) {
    switch myspeed {
    case .slow : speed = .slowspeed
    case .moderate : speed = .moderatespeed
    case .normal : speed = .normalspeed
    case .fast : speed = .fastspeed
    }
  }
  func setSpeed(_ myspeed:String) {
    switch myspeed {
    case "Slow" : speed = .slowspeed
    case "Moderate" : speed = .moderatespeed
    case "Fast" : speed = .fastspeed
    default : speed = .normalspeed
    }
  }
  
  /**  Set hexagon geometry  */
  func setHexagon() {
    geometry = .hexagon
    resetAnimation()
  }
  
  /**  Set bigon geometry  */
  func setBigon() {
    geometry = .bigon
    resetAnimation()
  }
  
  /**  Set square geometry  */
  func setSquare() {
    geometry = .square
    resetAnimation()
  }
  
  func setGeometry(_ g:GeometryType) {
    if (geometry != g) {
      geometry = g
      resetAnimation()
    }
  }
  
  func setGeometry(_ g:Int) {
    setGeometry(GeometryType(rawValue: g)!)
  }
  
  var totalBeats:CGFloat {
    get {
      return leadin + beats
    }
  }
  var movingBeats:CGFloat {
    get {
      return beats - leadout
    }
  }
  
  /**
   *   Set time of animation as offset from start including leadin
   */
  func setTime(_ b:CGFloat) {
    beat = b - leadin
    setNeedsDisplay()
  }
  
  @nonobjc func setParts(_ p:String) {
    parts = p
    partbeats = partsValues()
  }
  
  func getParts() -> String {
    return parts
  }
  func getScore() -> CGFloat {
    return iscore
  }
  
  //  Interactive functions to process touch
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //  For interactive dancer, pass all touch events through to its handler
    if (idancer != nil) {
      for t in touches {
        idancer!.doTouch(t, inView: self)
      }
    } else if (touches.count > 0) {
      //  If no interactive dancer, tap on a dancer shows its path
      let t = touches.first!
      let p = t.location(in: self)
      //  Convert to dancer's coordinate system
      let range = min(bounds.width,bounds.height)
      let s = range/13.0
      let x = -(p.y - bounds.height/2.0)/s
      let y = -(p.x - bounds.width/2.0)/s
      var bestdist:CGFloat = 0.5
      var bestd:Dancer? = nil
      for d in dancers {
        if (!d.hidden) {
          let dp = d.location
          let distsq = (dp.x-x)*(dp.x-x) + (dp.y-y)*(dp.y-y)
          if (distsq < bestdist) {
            bestd = d
            bestdist = distsq
          }
        }
      }
      if (bestd != nil) {
        bestd!.showPath = !bestd!.showPath
        setNeedsDisplay()
      }
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if (idancer != nil) {
      for t in touches {
        idancer!.doTouch(t, inView: self)
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if (idancer != nil) {
      for t in touches {
        idancer!.doTouch(t, inView: self)
      }
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    if (idancer != nil) {
      for t in touches {
        idancer!.doTouch(t, inView: self)
      }
    }
  }
  
  
  func isInteractiveDancerOnTrack() -> Bool {
    //  Get where the dancer should be
    let computetx = idancer!.computeMatrix(beat)
    //  Get computed and actual location vectors
    let ivu = idancer!.tx.location
    let ivc = computetx.location
    
    //  Check dancer's facing direction
    let au = idancer!.tx.angle
    let ac = computetx.angle
    if (abs(Vector3D.angleDiff(au, a2: ac)) > CG_PI/4) {
      return false
    }
    
    //  Check relationship with the other dancers
    for d in dancers {
      if (d != idancer!) {
        let dv = d.tx.location
        //  Compare angle to computed vs actual
        let d2ivu = dv.vectorTo(ivu)
        let d2ivc = dv.vectorTo(ivc)
        let a = d2ivu.angleDiff(d2ivc)
        if (abs(a) > CG_PI/4) {
          return false
        }
      }
    }
    return true
  }
  
  
  override func draw(_ rect: CGRect) {
    if (tam != nil) {
     
      //  Update the animation time
      let now = CFAbsoluteTimeGetCurrent()
      let diff = CGFloat(now - lasttime)*1000  // seconds to milliseconds
      if (isRunning) {
        beat = beat + diff/speed.rawValue
      }
      lasttime = now
      
      //  Move the dancers
      updateDancers()
      //  Draw the dancers
      doDraw(rect)
     
      //  Remember time of this update, and handle loop and end
      prevbeat = beat
      if (beat >= beats) {
        if (looping && isRunning) {
          prevbeat = -leadin
          beat = -leadin
        } else {
          isRunning = false
          doneCallback()
        }
      }
      progressCallback(beat+leadin)
      //  Continually epeat by telling the system to re-draw
      if (isRunning) {
        //  setNeedsDispay needs to be called after current processing is done
        //   otherwise the system ignores the request
        //perform(#selector(UIView.setNeedsDisplay(_:)),with: self, afterDelay: 0)
        //setNeedsDisplay()
        DispatchQueue.main.async {
          self.setNeedsDisplay()
        }
      }
    }
  }
  
  func doDraw(_ rect: CGRect) {
    //  Draw background
    let ctx = UIGraphicsGetCurrentContext()!
    ctx.addRect(bounds)
    ctx.setFillColor(UIColor(red: 1, green: 0.94, blue: 0.88, alpha: 1).cgColor)
    ctx.fillPath()
    //  Note loop and dancer speed
    //  TODO
    let range = min(bounds.width,bounds.height)

    //  Scale coordinate system to dancer's size
    ctx.translateBy(x: bounds.width/2, y: bounds.height/2)
    //  Flip and rotate
    let s = range/13
    ctx.scaleBy(x: s, y: -s)
    ctx.rotate(by: CG_PI/2)
    //  Draw grid if on
    if (showGrid) {
      GeometryMaker.makeOne(geometry).drawGrid(ctx)
    }
    //  Always show bigon center mark
    if geometry == GeometryType.bigon {
      ctx.setStrokeColor(UIColor.black.cgColor)
      ctx.setLineWidth(0.05)
      ctx.move(to: CGPoint(x: -0.5, y: 0.0))
      ctx.addLine(to: CGPoint(x: 0.5, y: 0.0))
      ctx.move(to: CGPoint(x: 0.0, y: -0.5))
      ctx.addLine(to: CGPoint(x: 0.0, y: 0.5))
      ctx.strokePath()
    }
    //  Draw paths if requested
    for d in dancers {
      if (!d.hidden && (showPaths || d.showPath)) {
        d.drawPath(ctx)
      }
    }
    
    //  Draw handholds
    ctx.setStrokeColor(UIColor.orange.cgColor)
    ctx.setFillColor(UIColor.orange.cgColor)
    ctx.setLineWidth(0.05)
    for d in dancers {
      let loc = d.location
      if (d.rightHandVisibility) {
        if (d.rightdancer == nil) {  // hexagon center
          ctx.move(to: CGPoint(x: loc.x, y: loc.y))
          ctx.addLine(to: CGPoint(x: 0, y: 0))
          ctx.strokePath()
          ctx.addArc(center:CGPoint(x:0,y:0), radius:0.125,startAngle:0, endAngle:CG_PI*2, clockwise:false)
          ctx.fillPath()
        } else if (d.rightdancer!.compare(d) < 0) {
          let loc2 = d.rightdancer!.location
          ctx.move(to: CGPoint(x: loc.x, y: loc.y))
          ctx.addLine(to: CGPoint(x: loc2.x, y: loc2.y))
          ctx.strokePath()
          ctx.addArc(center:CGPoint(x:(loc.x+loc2.x)/2, y:(loc.y+loc2.y)/2), radius:0.125, startAngle:0, endAngle:CG_PI*2, clockwise:false)
          ctx.fillPath()
        }
      }
      if (d.leftHandVisibility) {
        if (d.leftdancer == nil) {  // hexagon center
          ctx.move(to: CGPoint(x: loc.x, y: loc.y))
          ctx.addLine(to: CGPoint(x: 0, y: 0))
          ctx.strokePath()
          ctx.addArc(center:CGPoint(x:0, y:0), radius:0.125, startAngle:0, endAngle:CG_PI*2, clockwise:false)
          ctx.fillPath()
        } else if (d.leftdancer!.compare(d) < 0) {
          let loc2 = d.leftdancer!.location
          ctx.move(to: CGPoint(x: loc.x, y: loc.y))
          ctx.addLine(to: CGPoint(x: loc2.x, y: loc2.y))
          ctx.strokePath()
          ctx.addArc(center:CGPoint(x:(loc.x+loc2.x)/2, y:(loc.y+loc2.y)/2), radius:0.125, startAngle:0, endAngle:CG_PI*2, clockwise:false)
          ctx.fillPath()
        }
      }
    }
    
    //  Draw dancers
    for d in dancers.filter({!$0.hidden}) {
      ctx.saveGState()
      ctx.concatenate(d.tx.mat)
      d.draw(ctx)
      ctx.restoreGState()
    }
    
  }

  /**
   * Updates dancers positions based on the passage of realtime.
   * Called at the start of drawRect().
   */
  func updateDancers() {
    //  Move dancers
    //  For big jumps, move incrementally -
    //  this helps hexagon and bigon compute the right location
    let delta = beat - prevbeat
    let incs = Int(ceil(abs(delta)))
    if (incs >= 1) {
      for j in 1...incs {
        for d in dancers {
          d.animate(prevbeat + CGFloat(j)*delta/CGFloat(incs))
        }
      }
    }
    
    //  Find the current part, and send a message if it's changed
    var thispart = 0
    if (beat >= 0 && beat <= beats) {
      let p = partbeats.enumerated().reversed().find { (i,b) in b < self.beat }
      if let pp = p {
        thispart = pp.offset
      }
    }
    if (thispart != currentPart) {
      currentPart = thispart
      partCallback(currentPart)
    }
    
    //  Compute handholds
    var hhlist = [Handhold]()
    for d0 in dancers {
      d0.rightdancer = nil
      d0.leftdancer = nil
      d0.rightHandVisibility = false
      d0.leftHandVisibility = false
    }
    for i1 in 0..<dancers.count-1 {
      let d1 = dancers[i1]
      if (!d1.isPhantom || showPhantoms) {
        for i2 in i1+1..<dancers.count {
          let d2 = dancers[i2]
          if (!d2.isPhantom || showPhantoms) {
            if let hh = Handhold.apply(d1, d2, geometry: geometry) {
              hhlist.append(hh)
            }
          }
        }
      }
    }
    //  Sort the array to put best scores first
    hhlist.sort { $0.score < $1.score }
    //  Apply the handholds in order from best to worst
    //  so that if a dancer has a choice it gets the best handhold
    for hh in hhlist {
      //  Check that the hands aren't already used
      let incenter = geometry == GeometryType.hexagon && hh.inCenter()
      if (incenter ||
        (hh.hold1==Hands.righthand && hh.dancer1.rightdancer==nil ||
          hh.hold1==Hands.lefthand && hh.dancer1.leftdancer==nil) &&
        (hh.hold2==Hands.righthand && hh.dancer2.rightdancer==nil ||
          hh.hold2==Hands.lefthand && hh.dancer2.leftdancer==nil)) {
            //      	Make the handhold visible
            //  Scale should be 1 if distance is 2
            //  float scale = hh.distance/2f;
            if (hh.hold1==Hands.righthand || hh.hold1==Hands.gripright) {
              hh.dancer1.rightHandVisibility = true
              hh.dancer1.rightHandNewVisibility = true
            }
            if (hh.hold1==Hands.lefthand || hh.hold1==Hands.gripleft) {
              hh.dancer1.leftHandVisibility = true
              hh.dancer1.leftHandNewVisibility = true
            }
            if (hh.hold2==Hands.righthand || hh.hold2==Hands.gripright) {
              hh.dancer2.rightHandVisibility = true
              hh.dancer2.rightHandNewVisibility = true
            }
            if (hh.hold2==Hands.lefthand || hh.hold2==Hands.gripleft) {
              hh.dancer2.leftHandVisibility = true
              hh.dancer2.leftHandNewVisibility = true
            }
            
            if (!incenter) {
              if (hh.hold1 == Hands.righthand) {
                hh.dancer1.rightdancer = hh.dancer2
                if ((hh.dancer1.hands & Hands.gripright) == Hands.gripright) {
                  hh.dancer1.rightgrip = hh.dancer2
                }
              } else {
                hh.dancer1.leftdancer = hh.dancer2
                if ((hh.dancer1.hands & Hands.gripleft) == Hands.gripleft) {
                  hh.dancer1.leftgrip = hh.dancer2
                }
              }
              if (hh.hold2 == Hands.righthand) {
                hh.dancer2.rightdancer = hh.dancer1
                if ((hh.dancer2.hands & Hands.gripright) == Hands.gripright) {
                  hh.dancer2.rightgrip = hh.dancer1
                }
              } else {
                hh.dancer2.leftdancer = hh.dancer1
                if ((hh.dancer2.hands & Hands.gripleft) == Hands.gripleft) {
                  hh.dancer2.leftgrip = hh.dancer1
                }
              }
            }
      }
    }
    //  Clear handholds no longer visible
    for d in dancers {
      if (d.leftHandVisibility && !d.leftHandNewVisibility) {
        d.leftHandVisibility = false
      }
      if (d.rightHandVisibility && !d.rightHandNewVisibility) {
        d.rightHandVisibility = false
      }
    }
    
    //  Update interactive dancer score
    if (idancer != nil && beat > 0.0 && beat < beats-leadout) {
      idancer!.onTrack = isInteractiveDancerOnTrack()
      if (idancer!.onTrack) {
        iscore += (beat - max(prevbeat,0.0)) * 10.0
      }
    }
    
    
  }
  
  
  func setAnimation(_ xtam:JiNode, intdan:Int = -1) {
    tam = TamUtils.tamXref(xtam)
    interactiveDancer = intdan
    resetAnimation()
  }
  
  func resetAnimation() {
    if (tam != nil) {
      leadin = interactiveDancer < 0 ? 2 : 3
      leadout = interactiveDancer < 0 ? 2 : 1
      if (isRunning) {
        doneCallback()
      }
      isRunning = false
      beats = 0
      let tlist = tam!.childrenWithName("formation")
      let formation = tlist.count > 0 ? tlist[0]
        : tam!["formation"] != nil ? TamUtils.getFormation(tam!["formation"]!)
        : tam!
      let flist = formation.childrenWithName("dancer")
      let paths = tam!.childrenWithName("path")
      dancers = [Dancer]()
      
      //  Except for the phantoms, these are the standard colors
      //  used for teaching callers
      let dancerColor = geometry == .hexagon ?
        [UIColor.red, UIColor.green, UIColor.magenta,
         UIColor.blue, UIColor.yellow, UIColor.cyan,
         UIColor.lightGray, UIColor.lightGray, UIColor.lightGray, UIColor.lightGray]
      :
        [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow,
         UIColor.lightGray, UIColor.lightGray, UIColor.lightGray, UIColor.lightGray]

      //  Get numbers for dancers and couples
      //  This fetches any custom numbers that might be defined in
      //  the animation to match a Callerlab or Ceder Chest illustration
      let numbers = geometry == .hexagon ?
        ["A","E","I",
         "B","F","J",
         "C","G","K",
         "D","H","L",
         "u","v","w","x","y","z"]
        : geometry == .bigon ? ["1", "2", "3", "4", "5", "6", "7", "8"]
        : paths.count == 0 ? [ "1", "2", "3", "4", "5", "6", "7", "8" ]
        : TamUtils.getNumbers(tam!)
      let couples = geometry == .hexagon ?
        ["1", "3", "5", "1", "3", "5",
         "2", "4", "6", "2", "4", "6",
         "7", "8", "7", "8", "7", "8"]
      : geometry == .bigon ? [ "1", "2", "3", "4", "5", "6", "7", "8" ]
      : paths.count == 0 ? [ "1", "3", "1", "3", "2", "4", "2", "4" ]
      : TamUtils.getCouples(tam!)
      let geoms = GeometryMaker.makeAll(geometry)

      //  Select a random dancer of the correct gender for the interactive dancer
      var icount = -1
      var im = Matrix()
      if (interactiveDancer > 0) {
        let selector = interactiveDancer == Gender.boy.rawValue ? "dancer[@gender='boy']" : "dancer[@gender='girl']"
        let glist = formation.xPath(selector)
        icount = (Int)(arc4random_uniform((UInt32)(glist.count)))
        //  If the animations starts with "Heads" or "Sides"
        //  then select the first dancer.
        //  Otherwise the formation could rotate 90 degrees
        //  which would be confusing
        let title = tam!["title"]!
        if (title.contains("Heads") || title.contains("Sides")) {
          icount = 0
        }
        //  Find the angle the interactive dancer faces at start
        //  We want to rotate the formation so that direction is up
        let iangle = CGFloat(Double(glist[icount]["angle"]!)!)
        im = im.preRotate(-iangle.toRadians)
        icount = icount * geoms.count + 1
      }
      
      //  Create the dancers and set their starting positions
      var dnum = 0
      for i in 0 ..< flist.count {
        let fd = flist[i]
        let x = CGFloat(Double(fd["x"]!)!)
        let y = CGFloat(Double(fd["y"]!)!)
        let angle = CGFloat(Double(fd["angle"]!)!)
        let gender = fd["gender"]
        let g:Gender = gender=="boy" ? .boy : gender=="girl" ? .girl : .phantom
        let movelist = paths.count > i ? TamUtils.translatePath(tam!.childrenWithName("path")[i]) : [Movement]()
        //  Each dancer listed in the formation corresponds to
        //  one, two, or three real dancers depending on the geometry
        for geom in geoms {
          let m = Matrix().postRotate(angle.toRadians).postTranslate(x, y: y)
          let nstr = g == .phantom ? " " : numbers[dnum]
          let cstr = g == .phantom ? " " : couples[dnum]
          let cnum = g == .phantom ? UIColor.lightGray : dancerColor[Int(cstr)!-1]
          //  add one dancer
          if (g.rawValue == interactiveDancer) {
            icount -= 1
          }
          if (g.rawValue == interactiveDancer && icount == 0) {
            idancer = InteractiveDancer(number: nstr, number_couple: cstr, gender: g, fillcolor: cnum, mat: m, geom: geom.clone(), moves: movelist)
            dancers.append(idancer!)
          } else {
            dancers.append(Dancer(number: nstr, number_couple: cstr, gender: g, fillcolor: cnum, mat: m, geom: geom.clone(), moves: movelist))
            if (g == .phantom && !showPhantoms) {
              dancers[dnum].hidden = true
            }
          }
          beats = max(beats,dancers[dnum].beats+leadout)
          dnum += 1
        }
      }  //  All dancers added
      
      //  Initialize other instance variables
      parts = tam!["parts"] ?? tam!["fractions"] ?? ""
      hasParts = (tam!["parts"] ?? "").length > 0
      partbeats = partsValues()
      isRunning = false
      beat = -leadin
      prevbeat = -leadin
      setNeedsDisplay()
      readyCallback()
      
    }  // yes we have a tam xml to work with
  }
  
  func recalculate() {
    dancers.forEach { d in
      beats = max(beats,d.beats + leadout)
    }
  }
  
  
}
