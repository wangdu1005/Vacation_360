/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class VacationViewController: UIViewController {
  
  @IBOutlet weak var imageVRView: GVRPanoramaView!
  @IBOutlet weak var videoVRView: GVRVideoView!
  @IBOutlet weak var imageLabel: UILabel!
  @IBOutlet weak var videoLabel: UILabel!
  
  enum Media {
    static var photoArray = ["sindhu_beach.jpg", "grand_canyon.jpg", "underwater.jpg"]
    static let videoURL = "https://s3.amazonaws.com/ray.wenderlich/elephant_safari.mp4"
  }
  
  var currentView: UIView?
  var currentDisplayMode = GVRWidgetDisplayMode.embedded
  var isPaused = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imageLabel.isHidden = true
    imageVRView.isHidden = true
    videoLabel.isHidden = true
    videoVRView.isHidden = true

    imageVRView.load(UIImage(named: Media.photoArray.first!),
                            of: GVRPanoramaImageType.mono)
    imageVRView.enableCardboardButton = true
    imageVRView.enableFullscreenButton = true
    imageVRView.delegate = self
    
    videoVRView.load(from: URL(string: Media.videoURL))
    videoVRView.enableCardboardButton = true
    videoVRView.enableFullscreenButton = true
    videoVRView.delegate = self    
  }
  
  func refreshVideoPlayStatus() {
    if currentView == videoVRView && currentDisplayMode != GVRWidgetDisplayMode.embedded {
      videoVRView?.resume()
      isPaused = false
    } else {
      videoVRView?.pause()
      isPaused = true
    }
  }
  
  func setCurrentViewFromTouch(touchPoint point:CGPoint) {
    if imageVRView!.frame.contains(point) {
      currentView = imageVRView
    } else  if videoVRView!.frame.contains(point) {
      currentView = videoVRView
    }
  }
}

extension VacationViewController: GVRWidgetViewDelegate {
  func widgetView(_ widgetView: GVRWidgetView!, didLoadContent content: Any!) {
    if content is UIImage {
      imageVRView.isHidden = false
      imageLabel.isHidden = false
    } else if content is NSURL {
      videoVRView.isHidden = false
      videoLabel.isHidden = false
      refreshVideoPlayStatus()
    }
  }

  func widgetView(_ widgetView: GVRWidgetView!, didFailToLoadContent content: Any!, withErrorMessage errorMessage: String!)  {
    print(errorMessage)
  }
  
  func widgetView(_ widgetView: GVRWidgetView!, didChange displayMode: GVRWidgetDisplayMode) {
    currentView = widgetView
    currentDisplayMode = displayMode
    refreshVideoPlayStatus()
    if currentView == imageVRView && currentDisplayMode != GVRWidgetDisplayMode.embedded {
      view.isHidden = true
    } else {
      view.isHidden = false
    }
  }
  
  func widgetViewDidTap(_ widgetView: GVRWidgetView!) {
    guard currentDisplayMode != GVRWidgetDisplayMode.embedded else {return}
    if currentView == imageVRView {
      Media.photoArray.append(Media.photoArray.removeFirst())
      imageVRView?.load(UIImage(named: Media.photoArray.first!), of: GVRPanoramaImageType.mono)
    } else {
      if isPaused {
        videoVRView?.resume()
      } else {
        videoVRView?.pause()
      }
      isPaused = !isPaused
    }
  }
}

extension VacationViewController: GVRVideoViewDelegate {
  func videoView(_ videoView: GVRVideoView!, didUpdatePosition position: TimeInterval) {
    OperationQueue.main.addOperation() {
      if position >= videoView.duration() {
        videoView.seek(to: 0)
        videoView.resume()
      }
    }
  }
}

class TouchView: UIView {
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    if let vacationViewController = viewController() as? VacationViewController , event?.type == UIEventType.touches {
      vacationViewController.setCurrentViewFromTouch(touchPoint: point)
    }
    return true
  }
  
  func viewController() -> UIViewController? {
    if self.next!.isKind(of: VacationViewController.self) {
      return self.next as? UIViewController
    } else {
      return nil
    }
  }
}
