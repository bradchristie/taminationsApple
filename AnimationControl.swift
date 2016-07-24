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

class AnimationControl {
  
  var title:String = ""
  var from:String = ""
  var group:String = ""
  var animname:String = ""
  var progressFun:(beat:CGFloat)->Void = { arg in }
  var optionsFun:(options:String)->Void = { arg in }
  
  func reset(animationLayout:AnimationLayout, _ animationView:AnimationView, link:String, animnum:Int=0) {
    //self.animationView = animationView
    //  Fetch the XML animation and send it to the animation view
    let tamdoc = TamUtils.getXMLAsset(link)
    let tam = TamUtils.tamList(tamdoc).filter{$0["display"] != "none"}[animnum]
    animationView.setAnimation(tam)
    
    //  Calculate name for sharing
    title = tam["title"]!
    from = tam["from"] ?? ""
    group = tam["group"] ?? ""
    animname = (group.length > 1 ? title : title+"from"+from).replaceAll("\\W", "")
    
    //  Show any Taminator text
    let saychild = tam.childrenWithName("taminator")
    animationLayout.tamsays.text = saychild.count > 0 ? saychild[0].content!.trim().replaceAll("\\s+", " ") : ""
    
    progressFun = { (beat:CGFloat) -> Void in
      animationLayout.animationPanel.slider.value = Float(beat / animationView.totalBeats)
      //  Fade out any Taminator text
      //  a ranges from 1 down to 0
      let a = max((2.0-beat)/2.01,0.0)
      animationLayout.tamsays.alpha = a
    }
    animationView.progressCallback = progressFun
    readSettings(animationView)
    
    optionsFun = { (options:String)->Void in
      animationLayout.optionsText.text = options
    }
  }
  
  //  Read settings and apply them to the animation
  func readSettings(animationView:AnimationView) {
    let settings = NSUserDefaults.standardUserDefaults()
    animationView.setGeometry(GeometryType(rawValue:settings.integerForKey("geometry")) ?? GeometryType.SQUARE)
    animationView.setGridVisibility(settings.boolForKey("grid"))
    animationView.setLoop(settings.boolForKey("loop"))
    animationView.setPathVisibility(settings.boolForKey("path"))
    animationView.setSpeed(Speed(rawValue:settings.integerForKey("speed")) ?? Speed.NORMAL)
    animationView.setNumbers(ShowNumbers(rawValue: settings.integerForKey("numbers")) ?? ShowNumbers.NUMBERS_OFF)
    //  Show Loop and Speed options
    var optionstr = ""
    if settings.integerForKey("speed") == Speed.SLOW.rawValue {
      optionstr = " Slow"
    }
    else if settings.integerForKey("speed") == Speed.FAST.rawValue {
      optionstr = " Fast"
    }
    if settings.boolForKey("loop") {
      optionstr += " Loop"
    }
    optionsFun(options: optionstr)
  }
  
  
}