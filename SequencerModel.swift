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

protocol CallNamesListener : NSObjectProtocol {
  func callNamesChanged()->Void
}

class SequencerModel : NSObject, UITableViewDataSource, UITableViewDelegate, OEEventsObserverDelegate, UITextFieldDelegate,
                         AnimationPartListener, AnimationProgressListener {

  var callNames = [String]()
  var callBeats = [CGFloat]()
  let observer = OEEventsObserver()
  weak var layout:SequencerView!
  var formation="Static Square"
  var listening = false
  let panelControl:AnimationPanelControl
  weak var callNamesListener:CallNamesListener!
  var selectedRow = 0
  var insertRow = 0
  var errorLine = -1
  var errorFound = false
  
  override init() {
    panelControl = AnimationPanelControl()
    super.init()
    observer.delegate = self
    OEPocketsphinxController.sharedInstance().requestMicPermission()
  }
  
  func reset(_ layout:SequencerView) {
    self.layout = layout
    layout.callList.delegate = self
    layout.callList.dataSource = self
    layout.speakNow.addTarget(self, action: #selector(SequencerModel.mikeAction), for: .touchUpInside)
    layout.typeNow.addTarget(self, action: #selector(SequencerModel.typeAction), for: .touchUpInside)
    layout.copyButton.addTarget(self, action: #selector(SequencerModel.copyAction), for: .touchUpInside)
    layout.pasteButton.addTarget(self, action: #selector(SequencerModel.pasteAction), for: .touchUpInside)
    layout.animationView.animationPartListener = self
    layout.editText.delegate = self
    panelControl.reset(layout.animationPanel, v: layout.animationView)
    callNames = []
    startSequence()
    layout.animationView.animationProgressListener = self
    //  See if there's useable data in the clipboard
    let pb = UIPasteboard(name:.general,create:false)!
    if (pb.string != nil) {
      layout.pasteButton.isEnabled = true
    }
  }

  func startingFormation(_ f:String) {
    formation = f
    callNames = []
    callBeats = []
    insertRow = 0
    selectedRow = 0
    errorLine = -1
    errorFound = false
    layout!.callList.reloadData()
    startSequence()
    layout!.animationPanel.ticview.setTics(layout!.animationView.totalBeats, partstr: "", isCalls: true)
  }
  
  //  User tapped the mike icon, requesting to speak calls
  @objc func mikeAction() {
    if (listening) {
      layout!.speakNow.isSelected = false
      layout!.typeNow.isHidden = false
      layout!.calltext.text = "Tap the keyboard or microphone to begin"
      listening = false
      stopListening()
    } else {
      layout!.speakNow.isSelected = true
      layout!.typeNow.isHidden = true
      layout!.calltext.text = ""
      listening = true
      startListening()
    }
  }
  
  //  User tapped the keyboard icon, requesting to type calls
  @objc func typeAction() {
    layout!.editText.isHidden = false
    layout!.speakNow.isHidden = true
    layout!.typeNow.isHidden = true
    layout!.editText.becomeFirstResponder()
    layout!.calltext.text = ""
  }
  
  //  User tapped the Copy button
  @objc func copyAction() {
    let pb = UIPasteboard(name:.general,create:false)!
    pb.string = callNames.joined(separator:"\n")
    TamUtils.toast(title:"Calls copied",delay:2)
    layout!.pasteButton.isEnabled = true
  }
  
  //  User tapped the Paste button
  @objc func pasteAction() {
    let pb = UIPasteboard(name:.general,create:false)!
    if (pb.string != nil) {
      let s = pb.string!
      callNames = []
      insertCalls(s.split("\n").filter({ (s:String) -> Bool in
        return s.matches(".*\\w.*")
      }))
    }
  }
  
  //  User tapped the X on the selected row
  @objc func deleteAction() {
    callNames.remove(at: selectedRow)
    layout!.callList.deselectRow(at: IndexPath(row:selectedRow,section:0), animated: true)
    layout!.callList.deleteRows(at: [IndexPath(row: selectedRow, section: 0)], with: UITableViewRowAnimation.none)
    setInsert(selectedRow)
    selectedRow = -1
    interpretCall()
    updateParts()
  }
  
  //  This is called when the user presses the return key
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //  If just return pressed, hide the keyboard
    if (layout!.editText.text?.length == 0) {
      layout!.editText.resignFirstResponder()
      layout!.editText.isHidden = true
      layout!.speakNow.isHidden = false
      layout!.typeNow.isHidden = false
      layout!.calltext.text = "Tap the keyboard or microphone to begin"
    } else {
      insertCalls([layout!.editText.text!])
      layout?.editText.text = ""
    }
    return false
  }
  
  func callFont(_ tableView:UITableView) -> UIFont {
    return UIFont.systemFont(ofSize: max(24,layout!.bounds.size.height/40))
  }
  
  func startListening() {
    try! OEPocketsphinxController.sharedInstance().setActive(true)
    let lmPath = Bundle.main.path(forResource: "1958", ofType: "lmod", inDirectory:"files/src")!
    let dicPath = Bundle.main.path(forResource: "1958", ofType: "dic", inDirectory:"files/src")!
    OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
  }

  @objc func pocketsphinxDidReceiveHypothesis(_ hypothesis: String, recognitionScore: String, utteranceID: String)  {
    //print("The received hypothesis is \(hypothesis) with a score of \(recognitionScore) and an ID of \(utteranceID)")
    //  Get the call and pass it to the sequencer
    let calltext = hypothesis
    insertCalls([calltext])
  }
  
  func setInsert(_ i:Int) {
    insertRow = i
  }
  
  func insertCalls(_ calls:[String]) {
    ////  For now, always insert at the end
    for i in 0..<calls.count {
      callNames.insert(calls[i], at:i+insertRow)
      layout!.callList.insertRows(at: [IndexPath(row: i+insertRow, section: 0)], with: .none)
    }
    if (layout!.animationView.isRunning) {
      selectedRow += calls.count
    }
    let appendingOne = calls.count == 1 && insertRow+1 == callNames.count
    if (appendingOne ? interpretOneCall(insertRow,calls[0]) : interpretCall()) {
      updateParts()
      setInsert(insertRow+calls.count)
      layout!.callList.reloadData()
      layout!.animationView.goToPart(insertRow)
      layout!.animationView.doPlay()
      layout!.copyButton.isEnabled = true
      //  See if there's useable data in the clipboard
      let pb = UIPasteboard(name:.general,create:false)!
      if (pb.string != nil) {
        layout!.pasteButton.isEnabled = true
      }
    } else if (calls.count == 1) {
      //  Call failed. If just one call (not a paste), then it's probably
      //  a typo or mis-speak.  So just remove it.
      callNames.remove(at: insertRow)
      layout!.callList.deleteRows(at: [IndexPath(row: insertRow, section: 0)], with: UITableViewRowAnimation.none)
    }
  }
  
  func interpretOneCall(_ line:Int, _ calltext:String) -> Bool {
    //  Add call as entered, in case parsing fails
    callNames[line] = calltext
    let avdancers = layout!.animationView.dancers
    let cctx = CallContext(source: avdancers)
    do {
      let prevbeats = layout!.animationView.movingBeats
      try cctx.interpretCall(calltext)
      try cctx.performCall()
      for i in 0..<avdancers.count {
        avdancers[i].path.add(cctx.getDancer(i).path)
      }
      layout!.animationView.recalculate()
      let newbeats = layout!.animationView.movingBeats
      if (newbeats > prevbeats) {
        //  Call worked, add it to the list
        callNames[line] = cctx.callname
        callBeats.append(newbeats - prevbeats)
        callNamesListener?.callNamesChanged()
      }
    } catch let err as CallError {
      let toast = UIAlertView(title: err.msg, message: "", delegate: nil, cancelButtonTitle: nil)
      toast.show()
      TamUtils.runAfterDelay(2.0) {
        toast.dismiss(withClickedButtonIndex: 0, animated: true)
      }
      errorFound = true
      return false
    } catch _ {
      //  This callback cannot throw so any exception needs to be handled here
    }
    return true
  }
  
  @discardableResult func interpretCall() -> Bool {
    startSequence()
    errorLine = -1
    callBeats = []
    for line in 0..<callNames.count {
      if (!interpretOneCall(line,callNames[line])) {
        return false
      }
    }
    return true
  }
  
  //  Update parts and tics on animation panel
  func updateParts() {
    let partstr = callBeats.count > 1 ? callBeats.dropLast().map { "\($0)" } .joined(separator: ";") : ""
    layout!.animationView.setParts(partstr)
    layout!.animationPanel.ticview.setTics(layout!.animationView.totalBeats, partstr: partstr, isCalls: true)
  }
  
  func stopListening() {
    OEPocketsphinxController.sharedInstance().stopListening()
  }

  func startSequence() {
    layout!.animationView.setAnimation(TamUtils.getFormation(formation))
  }

  func animationProgress(beat:CGFloat) -> Void {
    layout.animationPanel.slider.value = Float(beat / layout.animationView.totalBeats)
    let b = min(max(0,beat-layout!.animationView.leadin),layout!.animationView.movingBeats)
    layout.beatView.text = "\(Int(b))"
  }
  
  func animationPart(part:Int) {
    if (part > 0 && part <= callNames.count) {
      layout!.calltext.text = callNames[part-1]
      selectedRow = part-1
    } else {
      layout!.calltext.text = ""
      selectedRow = callNames.count-1
    }
    layout!.callList.reloadData()
    layout!.callList.scrollToRow(at: IndexPath(row: selectedRow, section: 0), at: .bottom, animated: false)
  }
  
  func cellFont(_ tableView:UIView) -> UIFont { return UIFont.systemFont(ofSize: max(24,tableView.bounds.size.height/40)) }

  //  Required data source methods
  @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "sequencertablecell") ?? UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "sequencertablecell")
    let callnum = "\(indexPath.row+1)"
    cell.textLabel?.text = callnum + " " + callNames[indexPath.row]
    cell.textLabel?.font = callFont(tableView)
    cell.textLabel?.textColor = UIColor.black
    cell.textLabel?.numberOfLines = 0
    cell.backgroundColor = UIColor.white
    cell.selectionStyle = .blue
    cell.accessoryType = .none
    cell.accessoryView = nil
    if (indexPath.row == selectedRow) {
      cell.backgroundColor = UIColor.yellow
      if (indexPath.row < callNames.count) {
        let x = UIButton()
        x.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        x.backgroundColor = UIColor.red
        x.setTitle("X", for: .normal)
        x.addTarget(self, action: #selector(SequencerModel.deleteAction), for: .touchUpInside)
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = x
      }
    }
    if (indexPath.row == errorLine) {
      cell.backgroundColor = UIColor.red
      cell.textLabel?.textColor = UIColor.white
    }
    return cell
  }
  
  @objc func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return callNames.count
  }
  
  //  Table view delegate
  @objc func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) -> CGFloat {
    let constraintSize = CGSize(width: tableView.bounds.width, height: CGFloat(MAXFLOAT))
    let labelSize = callNames[(indexPath as NSIndexPath).row].boundingRect(with: constraintSize,options:[NSStringDrawingOptions.usesLineFragmentOrigin],
      attributes:[NSAttributedStringKey.font:cellFont(layout!)],context:nil)
    return labelSize.height + 10  }
  
  @objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedRow = indexPath.row
    layout!.callList.reloadData()
  }
  
  
}
