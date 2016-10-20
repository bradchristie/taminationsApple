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


class AnimationPanelLayout: UIView {

  let startButton:StartButton
  let backButton:BackButton
  let playButton:PlayButton
  let forwardButton:ForwardButton
  let endButton:EndButton
  let slider:UISlider
  let ticview:SliderTicView
  
  init() {
    slider = UISlider()
    ticview = SliderTicView()
    let buttonPanel = UIView()
    startButton = StartButton()
    backButton = BackButton()
    playButton = PlayButton()
    forwardButton = ForwardButton()
    endButton = EndButton()
    super.init(frame:CGRect.infinite)
    addSubview(slider)
    addSubview(ticview)
    addSubview(buttonPanel)
    buttonPanel.addSubview(startButton)
    buttonPanel.addSubview(backButton)
    buttonPanel.addSubview(playButton)
    buttonPanel.addSubview(forwardButton)
    buttonPanel.addSubview(endButton)
    buttonPanel.visualConstraints("|-[a]-[b(==a)]-[c(==a)]-[d(==a)]-[e(==a)]-|", fillVertical:true, spacing:2)
    visualConstraints("V:|[a(==23)]-[b]-[c(==40)]|", fillHorizontal:true, spacing:2)
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
}
