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

class AnimationPanelControl {
  
  var startFun:()->Void = { arg in }
  var backFun:()->Void = { arg in }
  var playFun:()->Void = { arg in }
  var forwardFun:()->Void = { arg in }
  var endFun:()->Void = { arg in }
  var progressFun:(_ beat:CGFloat)->Void = { arg in }
  var sliderFun:()->Void = { arg in }
  
  
  func reset(_ panel:AnimationPanelLayout, view:AnimationView) {
    //  Hook up button actions
    panel.startButton.addTarget(self, action: #selector(AnimationPanelControl.startAction), for: .touchUpInside)
    panel.backButton.addTarget(self, action: #selector(AnimationPanelControl.backAction), for: .touchUpInside)
    panel.playButton.addTarget(self, action: #selector(AnimationPanelControl.playAction), for: .touchUpInside)
    panel.forwardButton.addTarget(self, action: #selector(AnimationPanelControl.forwardAction), for: .touchUpInside)
    panel.endButton.addTarget(self, action: #selector(AnimationPanelControl.endAction), for: .touchUpInside)
    //  Hook up slider
    //view.progressCallback = progressCallback
    view.doneCallback = {
      panel.playButton.isSelected = false
    }
    panel.slider.addTarget(self, action: #selector(AnimationPanelControl.sliderAction), for: .valueChanged)
    //  Set up tic view
    panel.ticview.setTics(view.totalBeats,partstr: view.getParts(), isParts: view.hasParts)
    //  Hook up button and slider functions
    startFun = { view.doRewind() }
    backFun = { view.doBackup() }
    playFun = {
      if (view.isRunning) {
        view.doPause()
        panel.playButton.isSelected = false
      } else {
        view.doPlay()
        panel.playButton.isSelected = true
      }
    }
    forwardFun = { view.doForward() }
    endFun = { view.doEnd() }
    progressFun = { (beat:CGFloat) -> Void in panel.slider.value = Float(beat / view.totalBeats) }
    sliderFun = { view.setTime(CGFloat(panel.slider.value) * view.totalBeats) }
  }
  
  @objc func startAction() {
    startFun()
  }
  @objc func backAction() {
    backFun()
  }
  @objc func playAction() {
    playFun()
  }
  @objc func forwardAction() {
    forwardFun()
  }
  @objc func endAction() {
    endFun()
  }
  
  func progressCallback(_ beat:CGFloat) {
    progressFun(beat)
  }
  @objc func sliderAction() {
    sliderFun()
  }
  
  
}
