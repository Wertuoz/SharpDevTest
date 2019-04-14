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

enum TransactionFilter: Int {
    case date = 0
    case name
    case amount
}

class UserTransactionsViewController: BaseViewController, Coordinatable {
    var coordinator: Coordinator!
    lazy var viewController: UIViewController = {
        return self
    }()
    
    let disposeBag = DisposeBag()
    let viewModel = TransactionScreenViewModel()
    
    let refreshControl = UIRefreshControl()
    
    var selectedFilter = TransactionFilter.date
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var isLoading: Bool = false {
        willSet {
            if newValue {
                activityIndicator.startAnimating()
                tableView.alpha = 0.5
                filterSegmentedControl.alpha = 0.5
                view.isUserInteractionEnabled = false
            } else {
                activityIndicator.stopAnimating()
                tableView.alpha = 1
                filterSegmentedControl.alpha = 1
                view.isUserInteractionEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewModel.fetchTransactions()
        viewModel.fetchUserInfo()
    }
    
    func setupView() {
        refreshControl.tintColor = UIColor(red: 191/255, green: 9/255, blue: 66/255, alpha: 1)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        filterSegmentedControl.selectedSegmentIndex = selectedFilter.rawValue
    }
    
    override func setupBindings() {
        refreshControl.rx.controlEvent(.valueChanged)
            .asDriver()
            .drive(onNext: { [unowned self] _ in
                self.viewModel.fetchTransactions()
            }).disposed(by: disposeBag)
        
        filterSegmentedControl.rx.controlEvent(.valueChanged)
            .asDriver()
            .drive(onNext: { [unowned self] _ in
                self.selectedFilter = TransactionFilter(rawValue: self.filterSegmentedControl.selectedSegmentIndex)!
                self.viewModel.refreshFilter()
            }).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(TransactionModel.self)
            .subscribe(onNext: { [unowned self] (element) in
                self.itemSelected(item: element)
            }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] (indexPath) in
                self.tableView.deselectRow(at: indexPath, animated: true)
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
                if !value {
                    self.refreshControl.endRefreshing()
                }
            }).disposed(by: disposeBag)
        
        viewModel.transactionsStore
            .map({ (items) -> [TransactionModel] in
                return items.sorted(by: self.viewModel.getSorter(filter: self.selectedFilter))
            })
            .bind(to: tableView.rx.items(cellIdentifier: "TransactionCell", cellType: TransactionCell.self)) { row, element, cell in
                cell.dateLbl.text = element.date
                cell.nameLbl.text = element.userName
                cell.amountLbl.text = String(element.amount)
                cell.balanceLbl.text = String(element.balance)
            }.disposed(by: disposeBag)
    }
    
    func itemSelected(item: TransactionModel) {
        let alertController = UIAlertController(title: "Transaction to:", message: "Do you want to repeat a new transaction for user: " + item.userName + "?", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Send money", style: .default, handler: { [unowned self] alert -> Void in
            if self.viewModel.isBalanceEnough(value: -item.amount) {
                self.viewModel.createTransaction(name: item.userName, amount: -item.amount)
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
