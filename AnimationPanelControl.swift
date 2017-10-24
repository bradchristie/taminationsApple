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

class AnimationPanelControl : NSObject, AnimationProgressListener, AnimationDoneListener {
  
  weak var panel:AnimationPanelLayout!
  weak var view:AnimationView!
  
  
  func reset(_ p:AnimationPanelLayout, v:AnimationView) {
    panel = p
    view = v
    //  Hook up button actions
    panel.startButton.addTarget(self, action: #selector(AnimationPanelControl.prevAction), for: .touchUpInside)
    panel.backButton.addTarget(self, action: #selector(AnimationPanelControl.backAction), for: .touchUpInside)
    panel.playButton.addTarget(self, action: #selector(AnimationPanelControl.playAction), for: .touchUpInside)
    panel.forwardButton.addTarget(self, action: #selector(AnimationPanelControl.forwardAction), for: .touchUpInside)
    panel.endButton.addTarget(self, action: #selector(AnimationPanelControl.nextAction), for: .touchUpInside)
    panel.slider.addTarget(self, action: #selector(AnimationPanelControl.sliderAction), for: .valueChanged)
    panel.startButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(AnimationPanelControl.startAction)))
    panel.endButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(AnimationPanelControl.endAction)))
    //  Hook up animation callbacks
    view.animationProgressListener = self
    view.animationDoneListener = self
    //  Set up tic view
    panel.ticview.setTics(view.totalBeats,partstr: view.getParts(), isParts: view.hasParts)
  }
  
  @objc func startAction() {
    view.doRewind()
  }
  @objc func backAction() {
    view.doBackup()
  }
  @objc func prevAction() {
    view.doPrevPart()
  }
  @objc func playAction() {
    if (view.isRunning) {
      view.doPause()
      self.panel.playButton.isSelected = false
    } else {
      view.doPlay()
      self.panel.playButton.isSelected = true
    }
  }
  @objc func forwardAction() {
    view.doForward()
  }
  @objc func nextAction() {
    view.doNextPart()
  }
  @objc func endAction() {
    view.doEnd()
  }
  
  func animationProgress(beat:CGFloat) {
    panel.slider.value = Float(beat / view.totalBeats)
  }
  
  func animationDone() {
    panel.playButton.isSelected = false
  }
  
  @objc func sliderAction() {
    view.setTime(CGFloat(panel.slider.value) * view.totalBeats)
  }
  
  
}
