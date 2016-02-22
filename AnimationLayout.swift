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

class AnimationLayout: UIView {

  let animationView:AnimationView
  let animationPanel:AnimationPanelLayout
  let definitionButton:TamButton
  let settingsButton:TamButton
  let tamsays:UILabel
  let optionsText:UILabel
  
  override init(frame: CGRect) {
    let buttonPanel = UIView()
    definitionButton = TamButton()
    definitionButton.setTitle("Definition", forState: UIControlState.Normal)
    settingsButton = TamButton()
    settingsButton.setTitle("Settings", forState: UIControlState.Normal)
    animationPanel = AnimationPanelLayout()
    animationView = AnimationView(frame:CGRectMake(0,0,frame.width,frame.height-160))
    tamsays = UILabel()
    optionsText = UILabel()
    super.init(frame:frame)
    addSubview(animationView)
    addSubview(animationPanel)
    buttonPanel.addSubview(definitionButton)
    buttonPanel.addSubview(settingsButton)
    addSubview(buttonPanel)
    buttonPanel.visualConstraints("|-[a(==b)]-[b]-|",fillVertical:true,spacing:2)
    visualConstraints("V:|[a][b(==100)]-2-[c(==40)]|",fillHorizontal:true)
    
    tamsays.font = UIFont.italicSystemFontOfSize(frame.height/30)
    tamsays.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.5)
    tamsays.numberOfLines = 0
    addSubview(tamsays)
    visualConstraints("V:|[d]",fillHorizontal: true)
    
    optionsText.font = UIFont.systemFontOfSize(frame.height/20)
    addSubview(optionsText)
    visualConstraints("V:[e]-142-|",fillHorizontal: true)
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}