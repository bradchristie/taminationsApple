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

class SequencerViewController : TamViewController {

  let sequencerControl = SequencerControl()
  
  override init(_ intent:[String:String]) {
    super.init(intent)
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  override func loadView() {
    title = "Sequencer"
    let layout = SequencerLayout(frame: contentFrame)
    view = layout
    sequencerControl.reset(layout)
    layout.instructionsButton.addTarget(self, action: #selector(SequencerViewController.instructionsSelector), for: .touchUpInside)
    layout.formationButton.addTarget(self,action:#selector(SequencerViewController.formationSelector), for: .touchUpInside)
    sequencerControl.callNamesChanged = {
      self.setShareButton(self.sequencerControl.callNames.joined(separator: "\n"))
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    sequencerControl.stopListening()
  }

  @objc func instructionsSelector() {
    self.navigationController?.pushViewController(SequencerInstructionsViewController(intent), animated: true)
  }
  
  @objc func formationSelector() {
    let alert = UIAlertView(title: "Select Starting Formation", message: "", delegate: self, cancelButtonTitle: nil)
    alert.addButton(withTitle: "Facing Couples")
    alert.addButton(withTitle: "Squared Set")
    alert.show()
  }
  
  @objc func alertView(_ alertView:UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    sequencerControl.startingFormation(buttonIndex==0 ? "Facing Couples" : "Static Square")
  }
  
  override var shouldAutorotate : Bool {
    return false
  }
  override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    //  Don't do anything
  }

}
