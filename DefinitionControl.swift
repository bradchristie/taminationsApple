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

class DefinitionControl {
  
  var defstyleAction:()->Void = { }
  var setPart:(part:Int)->Void = { arg in }
  var setTitle:(title:String)->Void = { arg in }
  
  func reset(view:DefinitionLayout, link:String) {
    let pathparts = NSURL(string: link)?.pathComponents
    //  We can assume that the file has just one directory and then the filename
    let path = "files/" + pathparts![0]
    var filename = pathparts![1].replaceAll("\\..*", "")
    
    //  See if the page is available in user's language
    //  Just use the first part of language e.g. "en" not "en-US"
    let lang = NSLocale.preferredLanguages()[0].replaceFirst("[-_].*", "")
    let localefilename = filename + ".lang-" + lang
    if NSBundle.mainBundle().pathForResource(localefilename, ofType: "html", inDirectory: path) != nil {
      filename = localefilename
    }
    let filePath = NSBundle.mainBundle().pathForResource(filename, ofType: "html", inDirectory:path)!
    let htmlfile = try? String(contentsOfFile: filePath)
    let baseURL = NSURL.fileURLWithPath(filePath)
    view.webview.loadHTMLString(htmlfile!, baseURL: baseURL)

    //  Inject javascript to highlight current part
    let jsfunction =
      "   function setPart(part)   {" +
      "      var nodes = document.getElementsByTagName('span'); " +
      "      for (var i=0; i<nodes.length; i++) { " +
      "        var elem = nodes.item(i); " +
      "        var classstr = ' '+elem.className+' '; " +
      "        classstr = classstr.replace('definition-highlight',''); " +
      "        var teststr = ' '+classstr+' '+elem.id+' '; " +
      "        if (teststr.indexOf(' '+currentcall+part+' ') > 0 || " +
      "            teststr.indexOf('Part'+part+' ') > 0) " +
      "          classstr += 'definition-highlight'; " +
      "        classstr = classstr.replace(/^\\s+|\\s+$/g,''); " +
      "        elem.className = classstr;      }   }  "
    view.webview.stringByEvaluatingJavaScriptFromString(jsfunction)
    //  Function to show either full or abbrev
    let jsfunction2 =
      "    function setAbbrev(isAbbrev) {" +
      "      var nodes = document.getElementsByTagName('*');" +
      "      for (var i=0; i<nodes.length; i++) {" +
      "        var elem = nodes.item(i);" +
      "        if (elem.className.indexOf('abbrev') >= 0)" +
      "          elem.style.display = isAbbrev ? '' : 'none';" +
      "        if (elem.className.indexOf('full') >= 0)" +
      "          elem.style.display = isAbbrev ? 'none' : '';" +
      "      }" +
      "    }"
    view.webview.stringByEvaluatingJavaScriptFromString(jsfunction2)

    //  Show abbrev/full buttons only for Basic and Mainstream
    view.defstyle.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().boolForKey("abbrev") ? 0 : 1
    view.defstyle.addTarget(self, action: #selector(DefinitionControl.defstyleSelector), forControlEvents: .ValueChanged)
    defstyleAction = {
      let s = view.defstyle.selectedSegmentIndex
      view.webview.stringByEvaluatingJavaScriptFromString(s==0 ? "setAbbrev(true)" : "setAbbrev(false)")
      NSUserDefaults.standardUserDefaults().setBool(s==0, forKey: "abbrev")
    }
    if (link.matches("(b1|b2|ms).*")) {
      defstyleAction()
    } else {
      view.defstyle.removeFromSuperview()
      view.visualConstraints("V:|[a]|",fillHorizontal: true)
    }
    setPart = { (part:Int) in
      view.webview.stringByEvaluatingJavaScriptFromString("setPart(\(part))")
    }
    setTitle = { (title:String) in
      let t = title.replaceAll("\\s+", "")
      view.webview.stringByEvaluatingJavaScriptFromString("var currentcall = '\(t)'")
    }
    //  This is needed for highlighting definitions that contain several calls
    //  such as Swing Thru and Left Swing Thru
    let title = TamUtils.getTitle(link).replaceAll("\\s+","")
    view.webview.stringByEvaluatingJavaScriptFromString("var currentcall = '\(title)'")
  }
  
  @objc func defstyleSelector() {
    defstyleAction()
  }
  
}
