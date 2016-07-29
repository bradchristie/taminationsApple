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

class PracticeControl {
  
  var setTitle:(title:String)->Void = { arg in }
  var nextAnimation:()->Void = { }
  var animationReady:()->Void = { }
  var success:()->Void = { }
  var failure:()->Void = { }
  let calldoc = TamUtils.getXMLAsset("src/calls.xml")
  var link = ""
  
  func reset(intent:[String:String], practiceLayout:PracticeLayout) {
    let animationView = practiceLayout.animationView
    
    nextAnimation = {
      var tam:JiNode? = nil
      let selector = LevelData.find(intent["level"]!)!.selector
      let calls = self.calldoc.xPath("/calls/call[@\(selector)]")!
      while (tam == nil) {
        let e = calls[(Int)(arc4random_uniform((UInt32)(calls.count)))]
        //  Remember link for definition
        self.link = e["link"]!
        let tamdoc = TamUtils.getXMLAsset(self.link)
        let tams = tamdoc.xPath("/tamination/tam")!
          //  For now, skip any "difficult" animations
          .filter{($0["difficulty"] ?? "") != "3"}
          //  Skip any call with parens in the title - it could be a cross-reference
          //  to a concept call from a higher level
          .filter{!$0["title"]!.containsString("(")}
        if (tams.nonEmpty) {
          tam = tams[(Int)(arc4random_uniform((UInt32)(tams.count)))]
          let settings = NSUserDefaults.standardUserDefaults()
          animationView.setAnimation(tam!, intdan: settings.integerForKey("practicegender")==1 ? Gender.GIRL.rawValue : Gender.BOY.rawValue)
          animationView.setSpeed(Speed(rawValue: settings.integerForKey("practicespeed"))!)
          self.setTitle(title: tam!["title"]!)
        }
      }
    }  // end of nextAnimation

    //  This is a hook for TutorialActivity, which postpones the start
    //  until the user dismisses the instructions
    animationReady = {
      animationView.doPlay()
    }
    
    animationView.readyCallback = {
      practiceLayout.hideExtraStuff()
      // set speed
      animationView.setGridVisibility(true)
      self.animationReady()
    }
    
    animationView.progressCallback = { (beat:CGFloat) in
      practiceLayout.scoreView.text = "\(Int(animationView.getScore()))"
      practiceLayout.countdown.text = beat < animationView.leadin ? "\(Int(beat-animationView.leadin))" : ""
    }
    
    animationView.doneCallback = {
      practiceLayout.resultsPanel.hidden = false
      practiceLayout.continueButton.hidden = false
      let score = ceil(animationView.getScore())
      let perfect = animationView.movingBeats * 10
      let result = "\(Int(score)) / \(Int(perfect))"
      practiceLayout.finalScore.text = result
      if (score / perfect >= 0.9) {
        self.success()
        practiceLayout.congratsView.text = "Excellent!"
      } else if (score / perfect >= 0.7) {
        self.success()
        practiceLayout.congratsView.text = "Very Good!"
      } else {
        self.failure()
        practiceLayout.congratsView.text = "Poor"
      }
    }

    //  These are hooks so the tutorial can get the result
    //  Since the tutorial should not show the Definitions button
    //  we will turn it on in these routines
    success = {
      practiceLayout.definitionButton.hidden = false
    }
    failure = {
      practiceLayout.definitionButton.hidden = false      
    }
    
    practiceLayout.repeatButtonAction = {
      practiceLayout.hideExtraStuff()
      animationView.doPlay()
    }
    
    practiceLayout.continueButtonAction = {
      practiceLayout.hideExtraStuff()
      self.nextAnimation()
      animationView.doPlay()
    }
    
  }  // end of reset
  
}