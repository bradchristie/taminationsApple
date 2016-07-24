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

class SequencerControl : NSObject, UITableViewDataSource, UITableViewDelegate, OEEventsObserverDelegate {

  var callNames = [String]()
  var callBeats = [CGFloat]()
  let observer = OEEventsObserver()
  var layout:SequencerLayout? = nil
  var formation="Static Square"
  var listening = false
  let panelControl:AnimationPanelControl
  var callNamesChanged:()->Void = { }
  
  override init() {
    panelControl = AnimationPanelControl()
    super.init()
    observer.delegate = self
    OEPocketsphinxController.sharedInstance().requestMicPermission()
  }
  
  func reset(layout:SequencerLayout) {
    self.layout = layout
    layout.callList.delegate = self
    layout.callList.dataSource = self
    layout.speakNow.addTarget(self, action: #selector(SequencerControl.mikeAction), forControlEvents: .TouchUpInside)
    layout.animationView.partCallback = partCallback
    panelControl.reset(layout.animationPanel, view: layout.animationView)
    startSequence()
  }

  func startingFormation(f:String) {
    formation = f
    callNames = []
    callBeats = []
    layout!.callList.reloadData()
    startSequence()
    layout!.animationPanel.ticview.setTics(layout!.animationView.totalBeats, partstr: "", isCalls: true)
  }
  
  @objc func mikeAction() {
    if layout!.calltext.text!.matches(".*->") {
      layout!.calltext.text = ""
    }
    if (listening) {
      layout!.speakNow.selected = false
      listening = false
      stopListening()
    } else {
      layout!.speakNow.selected = true
      listening = true
      startListening()
    }
  }
  
  func callFont(tableView:UITableView) -> UIFont {
    return UIFont.systemFontOfSize(max(24,layout!.bounds.size.height/40))
  }
  
  func startListening() {
    try! OEPocketsphinxController.sharedInstance().setActive(true)
    let lmPath = NSBundle.mainBundle().pathForResource("1958", ofType: "lmod", inDirectory:"files/src")!
    let dicPath = NSBundle.mainBundle().pathForResource("1958", ofType: "dic", inDirectory:"files/src")!
    OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"), languageModelIsJSGF: false)
  }

  @objc func pocketsphinxDidReceiveHypothesis(hypothesis: String, recognitionScore: String, utteranceID: String)  {
    //print("The received hypothesis is \(hypothesis) with a score of \(recognitionScore) and an ID of \(utteranceID)")
    //  Get the call and pass it to the sequencer
    let calltext = hypothesis
    let avdancers = layout!.animationView.dancers
    let cctx = CallContext(source: avdancers)
    do {
      let prevbeats = layout!.animationView.movingBeats
      try cctx.interpretCall(calltext)
      try cctx.performCall()
      for i in 0..<avdancers.count {
        avdancers[i].path.add(cctx.getDancer(i).path)
      }
      if (layout!.animationView.beat > layout!.animationView.movingBeats) {
        layout!.animationView.beat = layout!.animationView.movingBeats
      }
      layout!.animationView.recalculate()
      let newbeats = layout!.animationView.movingBeats
      if (newbeats > prevbeats) {
        let partstr = callBeats.nonEmpty ? callBeats.map { "\($0)" } .joinWithSeparator(";") : ""
        layout!.animationPanel.ticview.setTics(layout!.animationView.totalBeats, partstr: partstr, isCalls: true)
        layout!.animationView.setParts(partstr)
        layout!.animationView.doPlay()
        //  Call worked, add it to the list
        callNames.append(cctx.callname)
        layout!.callList.insertRowsAtIndexPaths([NSIndexPath(forRow: callNames.count-1, inSection: 0)], withRowAnimation: .None)
        layout!.callList.scrollToRowAtIndexPath(NSIndexPath(forRow: callNames.count-1, inSection: 0), atScrollPosition: .Bottom, animated: false)
        callBeats.append(newbeats - prevbeats)
        callNamesChanged()
      }
      
    } catch let err as CallError {
      let toast = UIAlertView(title: err.msg, message: "", delegate: nil, cancelButtonTitle: nil)
      toast.show()
      TamUtils.runAfterDelay(4.0) {
        toast.dismissWithClickedButtonIndex(0, animated: true)
      }
    } catch _ {
      //  This callback cannot throw so any exception needs to be handled here
    }
  }
  
  func stopListening() {
    OEPocketsphinxController.sharedInstance().stopListening()
  }

  func startSequence() {
    layout!.animationView.setAnimation(TamUtils.getFormation(formation))
  }
  
  func partCallback(part:Int) {
    if (part > 0 && part <= callNames.count) {
      layout!.calltext.text = callNames[part-1]
    } else {
      layout!.calltext.text = ""
    }
  }
  
  func cellFont(tableView:UIView) -> UIFont { return UIFont.systemFontOfSize(max(24,tableView.bounds.size.height/40)) }

  //  Required data source methods
  @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("sequencertablecell") ?? UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "sequencertablecell")
    cell.textLabel?.text = "\(indexPath.row+1) " + callNames[indexPath.row]
    cell.textLabel?.font = UIFont.systemFontOfSize(max(24,tableView.bounds.size.height/40))
    cell.textLabel?.numberOfLines = 0
    return cell
  }
  
  @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return callNames.count
  }
  
  //  Table view delegate
  @objc func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath) -> CGFloat {
    let constraintSize = CGSizeMake(tableView.bounds.width, CGFloat(MAXFLOAT))
    let labelSize = callNames[indexPath.row].boundingRectWithSize(constraintSize,options:[NSStringDrawingOptions.UsesLineFragmentOrigin],
      attributes:[NSFontAttributeName:cellFont(layout!)],context:nil)
    return labelSize.height + 10  }
  
}