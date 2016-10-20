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

class AboutLayout : UIView {
  
  let webview:UIWebView
  
  override init(frame: CGRect) {
    let webframe = CGRect(x: frame.origin.x+4,y: frame.origin.y,width: frame.width-8,height: frame.height-4)
    webview = UIWebView(frame: webframe)
    super.init(frame:frame)
    backgroundColor = UIColor.white
    addSubview(webview)
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  func loadPage(_ link:String) {
    let path = "files/info"
    let filePath = Bundle.main.path(forResource: link, ofType: "html", inDirectory:path)!
    let htmlfile = try? String(contentsOfFile: filePath)
    let baseURL = URL(fileURLWithPath: filePath)
    webview.loadHTMLString(htmlfile!, baseURL: baseURL)    
  }
  
}
