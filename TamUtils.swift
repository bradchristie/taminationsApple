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

struct CallListDatum {
  let title:String
  let text:String
  let link:String
  let sublevel:String
  let languages:String
}

struct TamXref {
  let doc: Ji
  let xref: JiNode
  
  /**
   *  Returns animation element, looking up cross-reference if needed.
   */
  init(_ tam:JiNode) {
    if let link = tam["xref-link"] {
      self.doc = TamUtils.getXMLAsset(link)
      var s = "//tam"
      if let title = tam["xref-title"] {
        s = s + "[@title='" + title + "']"
      }
      if let from = tam["xref-from"] {
        s = s + "[@from='\(from)']"
      }
      self.xref = self.doc.xPath(s)![0]
    } else {
      self.xref = tam
      self.doc = TamUtils.fdoc
    }
  }
  
}

class TamUtils {
  
  static let fdoc = TamUtils.getXMLAsset("src/formations.xml")
  static let mdoc = TamUtils.getXMLAsset("src/moves.xml")
  static var calllistdata = [CallListDatum]()
  
  class func readinitfiles() {
    //  Read the global list of calls and save in a local list
    //  to speed up searching
    let callindex = getXMLAsset("src/callindex.xml")  // need to keep callindex in memory until calllistdata is filled
    let nodelist = callindex.xPath("//call")!
    calllistdata = nodelist.map { (n:JiNode) -> CallListDatum in
      CallListDatum(title: n["title"]!,text: n["text"]!,link: n["link"]!,sublevel: n["sublevel"]!,languages: n["languages"] ?? "")
    }
  }
  
  class func runAfterDelay(_ delay: TimeInterval, block: @escaping ()->()) {
    let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time, execute: block)
  }
  
  class func toast(title:String="", message:String="", delay:TimeInterval=4) {
    let toastview = UIAlertView(title: title, message:message, delegate: nil, cancelButtonTitle: nil)
    toastview.show()
    TamUtils.runAfterDelay(delay) {
      toastview.dismiss(withClickedButtonIndex: 0, animated: true)
    }
  }
  
  class func getXMLAsset(_ name:String) -> Ji {
    //  Strip off any extension
    let pathparts = (name as NSString).pathComponents
    //  We can assume that the file has just one directory and then the filename
    let path = "files/" + pathparts[0]
    let filename = pathparts[1].characters.split{$0 == "."}.map(String.init)[0]
    let filePath = Bundle.main.path(forResource: filename, ofType: "xml", inDirectory:path)!
    let xmlfile = try! Data(contentsOf: URL(fileURLWithPath: filePath))
    let doc = Ji(data: xmlfile, isXML: true)!
    return doc
  }
 
  
  /**
  *    Returns list of animations from an xml document
  */
  class func tamList(_ doc:Ji) -> [JiNode] {
    return doc.xPath("//tam | //tamxref")!
  }
  
  
  //  From a tam element, look up any cross-references, then
  //  return all the processed paths
  class func getPaths(_ tam:JiNode) -> [[Movement]] {
    return TamXref(tam).xref.xPath("path").map(translatePath)
  }
  
  //  Return the main title from an animation xml doc
  class func getTitle(_ link:String) -> String {
    let doc = getXMLAsset(link)
    return doc.rootNode!["title"]!
  }
  
  class func getFormation(_ fname:String) -> JiNode {
    let xpath = "/formations/formation[@name='\(fname)']"
    return fdoc.xPath(xpath)![0]
  }
  
  class func translate(_ elem:JiNode) -> [Movement]? {
    switch elem.tag! {
    case "path" : return TamUtils.translatePath(elem)
    case "move" : return TamUtils.translateMove(elem)
    case "movement" : return TamUtils.translateMovement(elem)
    case _ : return []
    }
  }
  
  //  Takes a path, which is an XML element with children that
  //  are moves or movements.
  //  Returns an array of movements
  class func translatePath(_ pathelem:JiNode) -> [Movement] {
    return pathelem.children.filter{$0.name != "path"}.flatMap{TamUtils.translate($0)!}
  }
  
  //  Accepts a movement element from a XML file, either an animation definition
  //  or moves.xml
  //  Returns an array of a single movement
  class func translateMovement(_ move:JiNode) -> [Movement]? {
    return [Movement(element:move)]
  }
  
  //  Takes a move, which is an XML element that references another XML
  //  path with its "select" attribute
  //  Returns an array of movements
  class func translateMove(_ move:JiNode) -> [Movement]? {
    //  First retrieve the requested path
    let movename = move["select"]!
    let xpath = "/moves/path[@name='\(movename)']"
    let plist = mdoc.xPath(xpath)!
    let pathelem = plist[0]
    //  Get the list of movements
    let movements = TamUtils.translatePath(pathelem)
    //  Now apply any modifications
    let reflect:CGFloat = move["reflect"] != nil ? -1 : 1
    let scaleX = move["scaleX"] != nil ? CGFloat(Double(move["scaleX"]!)!) : 1
    let scaleY = (move["scaleY"] != nil ? CGFloat(Double(move["scaleY"]!)!) : 1) * reflect
    let offsetX = move["offsetX"] != nil ? CGFloat(Double(move["offsetX"]!)!) : 0
    let offsetY = move["offsetY"] != nil ? CGFloat(Double(move["offsetY"]!)!) : 0
    let hands = move["hands"]
    //  Sum up the total beats so if beats is given as a modification
    //  we know how much to change each movement
    let oldbeats = movements.reduce(0.0, { $0 + $1.beats })
    let beatfactor = move["beats"] != nil ? CGFloat(Double(move["beats"]!)!) / oldbeats : 1.0
    //  Now go through the movements applying the modifications
    //  The resulting list is the return value
    return movements.map{$0.useHands(hands != nil ? Movement.getHands(hands!) : $0.hands)
      .scale(scaleX,scaleY)
      .skew(offsetX,offsetY)
      .time($0.beats*beatfactor) }
  }
  
  /**
  *   Gets a named path (move) from the file of moves
  */
  class func getMove(_ name:String) -> Path {
    return Path(TamUtils.translate(mdoc.xPath("/moves/path[@name='\(name)']")!.first!)!)
  }
  
  /**
  *   Returns an array of numbers to use numering the dancers
  */
  class func getNumbers(_ tam:JiNode) -> [String] {
    let paths = tam.childrenWithName("path")
    var retval = Array(repeating: "", count: paths.count*2)
    let np = paths.count > 4 ? 4 : paths.count
    (0..<paths.count).forEach { (i:Int) -> () in
      let p = paths[i]
      let n = p["numbers"]
      if (n != nil) {
        retval[i*2] = String(n!.characters.first!)
        retval[i*2+1] = String(n!.characters.last!)
      }
      else if (i > 3) { // phantoms
        retval[i*2] = " "
        retval[i*2+1] = " "
      }
      else {
        retval[i*2] = String(i+1)
        retval[i*2+1] = String(i+1+np)
      }
    }
    return retval
  }
  
  
  class func getCouples(_ tam:JiNode) -> [String] {
    var retval = ["1","3","1","3",
                  "2","4","2","4",
                  "5","6","5","6",
                  " "," "," "," "]
    let paths = tam.childrenWithName("path")
    (0..<paths.count).forEach { (i:Int) -> () in
      let p = paths[i]
      let c = p["couples"]
      if (c != nil) {
        retval[i*2] = String(c!.characters.first!)
        retval[i*2+1] = String(c!.characters.last!)
      }
    }
    return retval
  }
  
  /**
  *   Take a plain text call and convert it to a regex
  *   to match the call index or other lists of calls
  */
  class func callnameQuery(_ query:String) -> String {
    return query.lowercased()
      //  Use upper case and dup numbers while building regex
      //  so expressions don't get compounded
      //  Through => Thru
      .replaceAll("\\bthrou?g?h?\\b","THRU")
      //  Process fractions 1/2 3/4 1/4 2/3
      .replaceAll("\\b1/2|(one.)?half\\b","(HALF|1122)")
      .replaceAll("\\b(three.quarters?|3/4)\\b","(THREEQUARTERS|3344)")
      .replaceAll("\\b((one.)?quarter|1/4)\\b","((ONE)?QUARTER|1144)")
      .replaceAll("\\btwo.thirds?\\b","(TWOTHIRDS|2233)")
      //  One and a half
      .replaceAll("\\b1.5\\b","ONEANDAHALF")
      //  Process any other numbers
      .replaceAll("\\b(1|onc?e)\\b","(11|ONE)")
      .replaceAll("\\b(2|two)\\b","(22|TWO)")
      .replaceAll("\\b(3|three)\\b","(33|THREE)")
      .replaceAll("\\b(4|four)\\b","(44|FOUR)")
      .replaceAll("\\b(5|five)\\b","(55|FIVE)")
      .replaceAll("\\b(6|six)\\b","(66|SIX)")
      .replaceAll("\\b(7|seven)\\b","(77|SEVEN)")
      .replaceAll("\\b(8|eight)\\b","(88|EIGHT)")
      .replaceAll("\\b(9|nine)\\b","(99|NINE)")
      //  Accept single and plural forms of some words
      .replaceAll("\\bboys?\\b","BOYS?")
      .replaceAll("\\bgirls?\\b","GIRLS?")
      .replaceAll("\\bends?\\b","ENDS?")
      .replaceAll("\\bcenters?\\b","CENTERS?")
      .replaceAll("\\bheads?\\b","HEADS?")
      .replaceAll("\\bsides?\\b","SIDES")
      //  Accept optional "dancers" e.g. "head dancers" == "heads"
      .replaceAll("\\bdancers?\\b","(DANCERS?)?")
      //  Misc other variations
      .replaceAll("\\bswap(\\s+around)?\\b","SWAP (AROUND)?").lowercased().replaceAll("([0-9])\\1", "$1").replaceAll("\\s+","")
    
  }
  
  
}
