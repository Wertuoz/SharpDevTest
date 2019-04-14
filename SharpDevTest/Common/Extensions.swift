//
//  Extensions.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 14/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import CommonCrypto

extension UIColor {
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}

extension CGColor {
    class func colorWithHex(hex: Int) -> CGColor {
        return UIColor(hex: hex).cgColor
    }
}

extension UIBarButtonItem {
    static func itemWith(colorfulImage: UIImage?, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let tintedImage = colorfulImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        
        let button = UIButton(type: .custom)
        button.setImage(tintedImage, for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 41, height: 31)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.tintColor = UIColor(red: 191/255, green: 9/255, blue: 66/255, alpha: 1)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 41).isActive = true
        button.heightAnchor.constraint(equalToConstant: 31).isActive = true
        
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
}

extension String {
    var md5Value: String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let d = self.data(using: .utf8) {
            _ = d.withUnsafeBytes { body -> String in
                CC_MD5(body.baseAddress, CC_LONG(d.count), &digest)
                
                return ""
            }
        }
        
        return (0 ..< length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
}

extension UIStoryboard {
    class func instantiateController<T>(for storyboard: StoryboardName, and screen : StoryBoardVCNames) -> T {
        let storyboard = UIStoryboard.init(name: storyboard.rawValue, bundle: nil);
        return storyboard.instantiateViewController(withIdentifier: screen.rawValue) as! T
    }
}

extension UINavigationController {
    
    func initRootViewController(vc: UIViewController, transitionType type: CATransitionType = CATransitionType.fade, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, duration: duration)
        self.viewControllers.removeAll()
        self.pushViewController(vc, animated: false)
        self.popToRootViewController(animated: false)
    }
    
    private func addTransition(transitionType type: CATransitionType = CATransitionType.fade, duration: CFTimeInterval = 0.3) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = type
        self.view.layer.add(transition, forKey: nil)
    }
}

extension URLRequest {
    mutating func addAuthTokenForHeader() {
        self.setValue(ApiHeaders.bearer.rawValue + (ApiManager.authToken ?? ""), forHTTPHeaderField: ApiHeaders.auth.rawValue)
    }
}
