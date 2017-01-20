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


class SequencerLayout: UIView {

  let animationView:AnimationView
  let animationPanel:AnimationPanelLayout
  let formationButton:TamButton
  let instructionsButton:TamButton
  let copyButton:TamButton
  let pasteButton:TamButton
  let callList:UITableView
  let speakNow:UIButton
  let typeNow: UIButton
  let calltext:UILabel
  let editText:UITextField
  
  override init(frame: CGRect) {
    let graymike = UIImage(contentsOfFile: Bundle.main.path(forResource: "mic-gray", ofType: "png", inDirectory:"files/images")!)
    let redmike = UIImage(contentsOfFile: Bundle.main.path(forResource: "mic-red", ofType: "png", inDirectory:"files/images")!)
    let graykbd = UIImage(contentsOfFile: Bundle.main.path(forResource: "kbd_gray", ofType: "png", inDirectory:"files/images")!)
    let bw = frame.height > frame.width ? frame.width/6 : frame.width/12
    speakNow = UIButton()
    speakNow.setImage(graymike, for: UIControlState())
    speakNow.setImage(redmike, for: .selected)
    typeNow = UIButton()
    typeNow.setImage(graykbd, for:UIControlState())
    calltext = UILabel()
    calltext.font = UIFont(name:"Helvetica Bold", size: frame.size.height/40)
    calltext.text = "Tap the keyboard or microphone to begin"
    calltext.numberOfLines = 0
    editText = UITextField()
    editText.borderStyle = UITextBorderStyle.roundedRect
    editText.font = UIFont(name:"Helvetica", size: frame.size.height/40)
    editText.autocapitalizationType = UITextAutocapitalizationType.none
    let buttonPanel = UIView()
    formationButton = TamButton()
    formationButton.setTitle("Reset", for: UIControlState())
    instructionsButton = TamButton()
    instructionsButton.setTitle("Instructions", for: UIControlState())
    copyButton = TamButton();
    copyButton.setTitle("Copy", for: UIControlState())
    copyButton.isEnabled = false
    pasteButton = TamButton();
    pasteButton.setTitle("Paste", for: UIControlState())
    pasteButton.isEnabled = false
    animationPanel = AnimationPanelLayout()
    animationView = AnimationView(frame:CGRect(x: 0,y: 0,width: frame.width,height: frame.height-160))
    animationView.addSubview(typeNow)
    animationView.addSubview(calltext)
    animationView.addSubview(speakNow)
    animationView.addSubview(editText)
    animationView.visualConstraints("V:|-12-[a] V:|-12-[b] V:|-12-[c] V:|-4-[d] |-12-[a(==\(bw))]-[b]-[c(==\(bw))]-12-| |-[d]-|")
    editText.isHidden = true
    callList = UITableView()
    super.init(frame:frame)
    addSubview(animationView)
    addSubview(animationPanel)
    addSubview(callList)
    buttonPanel.addSubview(formationButton)
    buttonPanel.addSubview(instructionsButton)
    buttonPanel.addSubview(copyButton)
    buttonPanel.addSubview(pasteButton)
    addSubview(buttonPanel)
    buttonPanel.visualConstraints("|-[b]-[a(==c)]-[c(==\(bw))]-[d(==c)]-|",fillVertical:true,spacing:2)
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
