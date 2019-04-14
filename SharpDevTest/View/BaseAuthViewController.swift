//
//  BaseViewController.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 08/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseAuthViewController: BaseViewController {
    
    @IBOutlet weak var mainContainer: RoundedView!
    @IBOutlet weak var contentContainer: UIStackView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityBtn: RoundedButton!

    func keyboardHeight() -> Observable<CGFloat> {
        return Observable
            .from([
                NotificationCenter.default.rx
                    .notification(UIResponder.keyboardWillShowNotification)
                    .map { notification -> CGFloat in
                        (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                },
                NotificationCenter.default.rx
                    .notification(UIResponder.keyboardWillHideNotification)
                    .map { _ -> CGFloat in
                        0
                }]).merge()
    }

    func moveViewForKeyboard(keyboardHeight: CGFloat) {
        let bottomCornerContainer = mainContainer.frame.origin.y + mainContainer.frame.size.height
        let windowBottom = view.frame.origin.x + view.frame.size.height
        let delta = windowBottom - bottomCornerContainer
        if keyboardHeight == 0 {
            self.bottomConstraint.constant = 0
            UIView.animate(withDuration: 2) {
                self.view.layoutIfNeeded()
            }
        } else if delta < keyboardHeight {
            print(keyboardHeight, delta)
            self.bottomConstraint.constant = -(keyboardHeight - delta) - self.activityBtn.frame.size.height / 2 - 5
            UIView.animate(withDuration: 2) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
