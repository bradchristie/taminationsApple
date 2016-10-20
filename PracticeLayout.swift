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

class PracticeLayout : UIView {
  
  let animationView:AnimationView = AnimationView(frame:CGRect())
  let scoreView = UILabel()
  let finalScore = UILabel()
  let congratsView = UILabel()
  let countdown = UILabel()
  let repeatButton = TamButton()
  let continueButton = TamButton()
  let returnButton = TamButton()
  let definitionButton = TamButton()
  let definitionView = UIWebView()
  let resultsPanel = UIView()
  
  var repeatButtonAction:()->Void = { }
  var continueButtonAction:()->Void = { }
  var returnButtonAction:()->Void = { }
  var definitionButtonAction:()->Void = { }

  override init(frame: CGRect) {
    super.init(frame:frame)
    
    addSubview(animationView)
    animationView.isMultipleTouchEnabled = true
    visualConstraints("|[a]| V:|[a]|")
    
    scoreView.font = UIFont(name:"Helvetica", size: 30)!
    addSubview(scoreView)
    visualConstraints("[b]-20-| V:|-[b]")
    countdown.font = UIFont(name:"Helvetica", size: 60)!
    addSubview(countdown)
    visualConstraints("|-40-[c] V:[c]-|")

    resultsPanel.backgroundColor = UIColor.white
    let line1 = UILabel()
    line1.text = "Animation Complete"
    line1.textAlignment = .center
    resultsPanel.addSubview(line1)
    let line2 = UILabel()
    line2.text = "Your Score"
    line2.textAlignment = .center
    resultsPanel.addSubview(line2)
    finalScore.text = "40 / 40"
    finalScore.textAlignment = .center
    resultsPanel.addSubview(finalScore)
    congratsView.text = "Excellent!"
    congratsView.textAlignment = .center
    resultsPanel.addSubview(congratsView)
    let buttonPanel = UIView()
    repeatButton.setTitle("Repeat", for: UIControlState())
    buttonPanel.addSubview(repeatButton)
    continueButton.setTitle("Continue", for: UIControlState())
    buttonPanel.addSubview(continueButton)
    returnButton.setTitle("Return", for: UIControlState())
    buttonPanel.addSubview(returnButton)
    buttonPanel.visualConstraints("|-[a(==b)]-[b]-[c(==b)]-|", fillVertical:true)
    resultsPanel.addSubview(buttonPanel)
    let definitionPanel = UIView()
    definitionPanel.addSubview(UIView())
    definitionButton.setTitle("Definition", for: UIControlState())
    definitionPanel.addSubview(definitionButton)
    definitionPanel.addSubview(UIView())
    definitionPanel.visualConstraints("|-[a(==b)]-[b]-[c(==b)]-|", fillVertical: true)
    resultsPanel.addSubview(definitionPanel)
    resultsPanel.visualConstraints("V:|-[a]-[b]-[c]-[d]-[e]-[f]",fillHorizontal: true)
    addSubview(resultsPanel)
    visualConstraints("|[d] V:|[d]|")
    
    repeatButton.addTarget(self, action: #selector(PracticeLayout.repeatButtonClick), for: .touchUpInside)
    continueButton.addTarget(self, action: #selector(PracticeLayout.continueButtonClick), for: .touchUpInside)
    returnButton.addTarget(self, action: #selector(PracticeLayout.returnButtonClick), for: .touchUpInside)
    definitionButton.addTarget(self, action: #selector(PracticeLayout.definitionButtonClick), for: .touchUpInside)
  }
  
  func hideExtraStuff() {
    resultsPanel.isHidden = true
    definitionButton.isHidden = true
    definitionView.isHidden = true
  }
  
  @objc func repeatButtonClick() {
    repeatButtonAction()
  }
  
  @objc func continueButtonClick() {
    continueButtonAction()
  }
  
  @objc func returnButtonClick() {
    returnButtonAction()
  }
  
  @objc func definitionButtonClick() {
    definitionButtonAction()
  }
  
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
}
