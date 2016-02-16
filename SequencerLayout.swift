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


class SequencerLayout: UIView {

  let animationView:AnimationView
  let animationPanel:AnimationPanelLayout
  let formationButton:TamButton
  let instructionsButton:TamButton
  let callList:UITableView
  let speakNow:UIButton
  let calltext:UILabel
  
  override init(frame: CGRect) {
    let graymike = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("mic-gray", ofType: "png", inDirectory:"files/images")!)
    let redmike = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("mic-red", ofType: "png", inDirectory:"files/images")!)
    speakNow = UIButton()
    speakNow.setImage(graymike, forState: .Normal)
    speakNow.setImage(redmike, forState: .Selected)
    calltext = UILabel()
    calltext.font = UIFont(name:"Helvetica Bold", size: frame.size.height/40)
    calltext.text = "Tap the microphone to start recording ->"
    let buttonPanel = UIView()
    formationButton = TamButton()
    formationButton.setTitle("Starting Formation", forState: UIControlState.Normal)
    instructionsButton = TamButton()
    instructionsButton.setTitle("Instructions", forState: UIControlState.Normal)
    animationPanel = AnimationPanelLayout()
    animationView = AnimationView(frame:CGRectMake(0,0,frame.width,frame.height-160))
    animationView.addSubview(calltext)
    animationView.addSubview(speakNow)
    animationView.visualConstraints("V:|-6-[a] V:|-6-[b] |-4-[a] [b]-4-|")
    callList = UITableView()
    super.init(frame:frame)
    addSubview(animationView)
    addSubview(animationPanel)
    addSubview(callList)
    buttonPanel.addSubview(formationButton)
    buttonPanel.addSubview(instructionsButton)
    addSubview(buttonPanel)
    buttonPanel.visualConstraints("|-[a(==b)]-[b]-|",fillVertical:true,spacing:2)
    let availableSpace = frame.height - 140
    let tableheight = availableSpace/3
    if (frame.height > frame.width) {
      visualConstraints("V:|[a][b(==100)]-[c(==\(tableheight))]-[d(==40)]|",fillHorizontal:true,spacing:2)
    } else {
      visualConstraints("|[c]-[a(==c)]| [b(==a)]| [d(==a)]| V:|[c]| V:|[a][b(==100)]-[d(==40)]|",spacing:2)
    }
  }

  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}