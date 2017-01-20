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

class BackgroundPanel : UIView {
  
  /**
  *   Do an animation from one view to another containted in a common parent
  * @param fromView    View currently visible
  * @param toView      View to switch to
  * @param callback    Function to call after currently visible view is gone
  *
  *  The constructor sets up the animation, then start() is called to run it.
  */
  var imageview = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame:frame)
    backgroundColor = UIColor(red: 1, green: 0.9375, blue: 0.875, alpha: 1)
    alpha = 0
    let filePath = Bundle.main.path(forResource: "tam100", ofType: "png", inDirectory:"files/images")!
    imageview = UIImageView(image: UIImage(contentsOfFile: filePath))
    addSubview(imageview)
    var f = imageview.frame
    f.origin.x = (self.bounds.width - imageview.bounds.width) / 2
    f.origin.y = (self.bounds.height - imageview.bounds.height) / 2
    imageview.frame = f
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  func animate(fromView: UIView, toView:UIView, callback:@escaping ()->Void) {
    alpha = 0  // just to make sure
    imageview.transform = CGAffineTransform.identity  // clear previous rotation
    superview?.bringSubview(toFront: self)
    UIView.animate(withDuration: 1.0, animations: {
      self.imageview.transform = CGAffineTransform(rotationAngle: 3.1)
    })
    UIView.animate(withDuration: 0.4, animations: { self.alpha = 1 }, completion: { finished in
      callback()
      self.superview?.bringSubview(toFront: toView)
      self.superview?.bringSubview(toFront: self)
      UIView.animate(withDuration: 0.4, animations: { self.alpha = 0 } )
    } )
  }
  
}
