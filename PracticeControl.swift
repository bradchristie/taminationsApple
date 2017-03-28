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

import UIKit

protocol TitleSetter : NSObjectProtocol {
  func setThisTitle(_ newTitle:String)->Void
}

class PracticeControl : NSObject, AnimationReadyListener, AnimationProgressListener, AnimationDoneListener,
                        RepeatButtonListener, ContinueButtonListener {
  
  let calldoc = TamUtils.getXMLAsset("src/calls.xml")
  var link = ""
  
  weak var practiceLayout:PracticeLayout!
  weak var animationView:AnimationView!
  weak var titleSetter:TitleSetter!
  var level:String?
  
  func reset(_ intent:[String:String], layout:PracticeLayout) {
    practiceLayout = layout
    animationView = practiceLayout.animationView
    practiceLayout.repeatButtonListener = self
    practiceLayout.continueButtonListener = self
    practiceLayout.animationView.animationReadyListener = self
    practiceLayout.animationView.animationProgressListener = self
    practiceLayout.animationView.animationDoneListener = self
    level = intent["level"]
  }
 
  func nextAnimation() {
    var tam:JiNode? = nil
    let selector = LevelData.find(level!)!.selector
    let calls = calldoc.xPath(selector)!
    while (tam == nil) {
      let e = calls[(Int)(arc4random_uniform((UInt32)(calls.count)))]
      //  Remember link for definition
      link = e["link"]!
      let tamdoc = TamUtils.getXMLAsset(link)
      let tams = tamdoc.xPath("/tamination/tam")!
        //  For now, skip any "difficult" animations
        .filter{($0["difficulty"] ?? "") != "3"}
        //  Skip any call with parens in the title - it could be a cross-reference
        //  to a concept call from a higher level
        .filter{!$0["title"]!.contains("(")}
      if (tams.nonEmpty) {
        tam = tams[(Int)(arc4random_uniform((UInt32)(tams.count)))]
        let settings = UserDefaults.standard
        animationView.setAnimation(tam!, intdan: settings.integer(forKey: "practicegender")==1 ? Gender.girl.rawValue : Gender.boy.rawValue)
        animationView.setSpeed(Speed(rawValue: settings.integer(forKey: "practicespeed"))!)
        titleSetter?.setThisTitle(tam!["title"]!)
      }
    }
  }
  
  func repeatAction() {
    practiceLayout.hideExtraStuff()
    animationView.doPlay()
  }
  
  func continueAction() {
    practiceLayout.hideExtraStuff()
    nextAnimation()
    animationView.doPlay()
  }
  
  //  These are hooks so the tutorial can get the result
  //  Since the tutorial should not show the Definitions button
  //  we will turn it on in these routines
  func success() {
    practiceLayout.definitionButton.isHidden = false
  }
  func failure() {
    practiceLayout.definitionButton.isHidden = false
  }
  
  //  This is a hook for TutorialActivity, which postpones the start
  //  until the user dismisses the instructions
  func animationReady() {
    practiceLayout.hideExtraStuff()
    animationView.setGridVisibility(true)
    animationView.doPlay()
  }
  
  func animationProgress(beat: CGFloat) {
    practiceLayout.scoreView.text = "\(Int(animationView.getScore()))"
    practiceLayout.countdown.text = beat < animationView.leadin ? "\(Int(beat-animationView.leadin))" : ""
  }
  
  func animationDone() {
    practiceLayout.resultsPanel.isHidden = false
    practiceLayout.continueButton.isHidden = false
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
  
}
