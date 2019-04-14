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
import NVActivityIndicatorView
import NotificationBannerSwift

class BaseViewController: UIViewController {

    lazy var activityIndicator: NVActivityIndicatorView = {
        NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30),
                                type: NVActivityIndicatorType.lineScale, color: UIColor(hex: 0xBF0942), padding: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicator()
        setupBindings()
        setupCallbacks()
    }
    
    func setupBindings() {
    }
    
    func setupCallbacks() {
    }
    
    func showAlertBar(text: String, style: BannerStyle = .danger) {
        let banner = GrowingNotificationBanner(title: "", subtitle: text, style: style)
        banner.bannerHeight = 50
        banner.applyStyling(titleTextAlign: NSTextAlignment.center, subtitleTextAlign: NSTextAlignment.center)
        banner.show(on: navigationController ?? self)
    }
    
    func setupActivityIndicator() {
        self.view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.widthAnchor.constraint(equalToConstant: activityIndicator.frame.width).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: activityIndicator.frame.height).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }

}

