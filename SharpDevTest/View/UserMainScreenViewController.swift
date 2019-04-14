//
//  AuthMainScreenViewController.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 10/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ChameleonFramework

class UserMainScreenViewController: BaseViewController, Coordinatable {
    var coordinator: Coordinator!
    lazy var viewController: UIViewController = {
        return self
    }()
    
    let disposeBag = DisposeBag()
    let viewModel = UserViewModel()
    
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var balanceLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var isLoading: Bool = false {
        willSet {
            if newValue {
                activityIndicator.startAnimating()
                topContainer.alpha = 0.5
                bottomContainer.alpha = 0.5
                view.isUserInteractionEnabled = false
            } else {
                activityIndicator.stopAnimating()
                topContainer.alpha = 1
                bottomContainer.alpha = 1
                view.isUserInteractionEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
//        viewModel.fetchUserInfo()
//        viewModel.fetchTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchUserInfo(silent: true)
    }
    
    func setupView() {
//        view.backgroundColor = GradientColor(.topToBottom, frame: UIScreen.main.bounds, colors: [UIColor(hex: 0x31A343), UIColor(hex: 0xBF0942)])
    }
    
    override func setupBindings() {
        searchBar.rx.text.orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
//            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter{!$0.isEmpty}
            .subscribe(onNext: {[unowned self] query in
                self.viewModel.fetchFilteredUsers(filter: query)
            })
            .disposed(by: disposeBag)
        
        viewModel.searchResult
            .bind(to: searchResultTableView.rx.items(cellIdentifier: "SearchCell", cellType: SearchCell.self)) { row, element, cell in
                cell.titleLbl.text = element.name
        }.disposed(by: disposeBag)
        
        tapGestureRecognizer.rx.event
            .bind(onNext: { [unowned self] recognizer in
                self.searchBar.resignFirstResponder()
        }).disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .bind(onNext: { [unowned self] in
                self.searchBar.resignFirstResponder()
        }).disposed(by: disposeBag)
        
        searchResultTableView.rx.modelSelected(UserSearchModel.self)
            .subscribe(onNext: { [unowned self] element in
                self.itemSelected(item: element)
        }).disposed(by: disposeBag)
        
        searchResultTableView.rx
            .itemSelected
            .subscribe(onNext: { [unowned self] (indexPath) in
                self.searchResultTableView.deselectRow(at: indexPath, animated: true)
        }).disposed(by: disposeBag)
    }
    
    override func setupCallbacks() {
        viewModel.errorMsg.asDriver()
            .drive(onNext: { [unowned self] errorMessage in
                if errorMessage.count > 0 {
                    self.showAlertBar(text: errorMessage)
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading.asDriver()
            .drive(onNext: { [unowned self] value in
                self.isLoading = value
            }).disposed(by: disposeBag)
        
        viewModel.user.asDriver()
            .drive(onNext: { [unowned self] value in
                self.balanceLbl.text = String(value.balance)
                self.userNameLbl.text = value.name
            }).disposed(by: disposeBag)
        
        viewModel.transactionSuccess
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [unowned self] value in
                if value {
                    self.showAlertBar(text: "Transaction send success", style: .success)
                }
            }).disposed(by: disposeBag)
    }

    func itemSelected(item: UserSearchModel){
        let alertController = UIAlertController(title: "Transaction to:", message: item.name, preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter money amount"
            textField.keyboardType = .numberPad
        }
        let saveAction = UIAlertAction(title: "Send money", style: .default, handler: { [unowned self] alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            guard let text = firstTextField.text else {
                self.showAlertBar(text: "Empty amount of money, please, enter the number", style: .warning)
                return
            }
            
            guard let amount = Int(text) else {
                self.showAlertBar(text: "Bad number, enter numeric value", style: .warning)
                return
            }
            
            if self.viewModel.isBalanceEnough(value: amount) {
                self.viewModel.createTransaction(name: item.name, amount: amount)
            } else {
                self.showAlertBar(text: "Not enough money to transfer", style: .warning)
                return
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
