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

protocol TutorialFinishedListener : NSObjectProtocol {
  func tutorialFinished()->Void
}

class TutorialControl : PracticeControl {
  
  var tutnum = 0
  weak var tutorialFinishedListener:TutorialFinishedListener!
  var isSuccess:Bool = false
  
  let tutdata = [
    "Use your %primary% Finger on the %primary% side of the screen."
      + "  Do not put your finger on the dancer."
      + "  Slide your finger forward to move the dancer forward."
      + "  Try to keep pace with the adjacent dancer.",
    
    "Use your %primary% Finger to follow the turning path."
      + "  Try to keep pace with the adjacent dancer.",
    
    "Normally your dancer faces the direction you are moving.  "
      + "  But you can use your %secondary% Finger to hold or change the facing direction."
      + "  Press and hold your %secondary% finger on the %secondary% side"
      + " of the screen.  This will keep your dancer facing forward."
      + "  Then use your %primary% finger on the %primary% side"
      + " of the screen to slide your dancer horizontally.",
    
    "Use your %secondary% finger to turn in place."
      + "  To U-Turn Left, make a 'C' movement with your %secondary% finger."]
  
  override func nextAnimation() {
    if (tutnum >= tutdata.count) {
      tutnum = 0
    }
    let tamdoc = TamUtils.getXMLAsset("src/tutorial.xml")
    let settings = UserDefaults.standard
    let gender = settings.integer(forKey: "practicegender")==1 ? Gender.girl : Gender.boy
    let offset = gender == .boy ? 0 : 1
    let tamlist = tamdoc.xPath("/tamination/tam")
    let tam = tamlist![tutnum*2+offset]
    titleSetter?.setThisTitle(tam["title"]!)
    practiceLayout.animationView.setAnimation(tam, intdan: gender.rawValue)
    practiceLayout.animationView.setSpeed(Speed(rawValue: settings.integer(forKey: "practicespeed"))!)
    showInstructions()
  }
  
  func showInstructions() {
    let settings = UserDefaults.standard
    let primaryIsLeft = settings.integer(forKey: "primarycontroller") == 0
    let instructions = tutdata[tutnum].replaceAll("%primary%", primaryIsLeft ? "Left" : "Right")
      .replaceAll("%secondary%",primaryIsLeft ? "Right" : "Left")
    let title = "Tutorial \(tutnum+1) of \(tutdata.count)"
    isSuccess = false
    if #available(iOS 8, *) {
      let alert = UIAlertControllerExtension(title: title, message: instructions, preferredStyle: .alert)
      let handler:(UIAlertAction)->Void = { [unowned self] arg in self.dismissedInstructions() }
      let ok = UIAlertAction(title: "OK", style: .default, handler: handler)
      alert.addAction(ok)
      let nav = UIApplication.shared.keyWindow!.rootViewController! as! UINavigationController
      nav.visibleViewController!.present(alert, animated: true, completion: nil)
    } else {
      let alert = UIAlertView(title: title, message: instructions, delegate: self, cancelButtonTitle: "OK")
      alert.show()
    }
  }
  
  //  This overrides the parent method which starts the animation
  //  Do not start the animation until the instructions are dismissed
  override func animationReady() {
    practiceLayout.hideExtraStuff()
    animationView.setGridVisibility(true)
  }
  
  override func repeatAction() {
    practiceLayout.hideExtraStuff()
    nextAnimation()
  }
  
  override func continueAction() {
    tutnum += 1
    practiceLayout.hideExtraStuff()
    nextAnimation()
  }
  
  func dismissedInstructions() {
    if (isSuccess) {
      tutorialFinishedListener?.tutorialFinished()
    } else {
      practiceLayout.animationView.doPlay()
    }
  }
  
  override func success() {
    if (tutnum+1 >= tutdata.count) {
      practiceLayout.congratsView.text = "Tutorial Complete"
      practiceLayout.continueButton.isHidden = false
      isSuccess = true
      let message =  "Congratulations!  You have successfully completed the tutorial." +
      "  Now select the level you would like to practice."
      if #available(iOS 8, *) {
        let alert = UIAlertControllerExtension(title: "Tutorial Complete", message: message, preferredStyle: .alert)
        let handler:(UIAlertAction)->Void = { [unowned self] arg in self.dismissedInstructions() }
        let ok = UIAlertAction(title: "Return", style: .default, handler: handler)
        alert.addAction(ok)
        let nav = UIApplication.shared.keyWindow!.rootViewController! as! UINavigationController
        nav.visibleViewController!.present(alert, animated: true, completion: nil)
      } else {
        let alert = UIAlertView(title: "Tutorial Complete", message: message, delegate: self, cancelButtonTitle: "Return")
        alert.show()
      }
      tutnum = 0
    }
  }
  
  override func failure() {
    practiceLayout.continueButton.isHidden = true
  }
  
  @objc func alertView(_ alertView:UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    dismissedInstructions()
  }
  
}
