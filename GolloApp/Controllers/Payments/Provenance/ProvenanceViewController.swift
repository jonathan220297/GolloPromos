//
//  ProvenanceViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 18/10/22.
//

import RxSwift
import UIKit
import DropDown

class ProvenanceViewController: UIViewController {

    @IBOutlet weak var nationalityLabel: UILabel!
    @IBOutlet weak var nationalityButton: UIButton!

    @IBOutlet weak var relationshipLabel: UILabel!
    @IBOutlet weak var relationshipButton: UIButton!

    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var originButton: UIButton!

    @IBOutlet weak var goToPaymentButton: UIButton!
    
    // MARK: - Constants
    let viewModel: ProvenanceViewModel
    let paymentData: PaymentData?
    let currentAmount: Double?
    let bag = DisposeBag()

    // MARK: - Lifecycle
    init(viewModel: ProvenanceViewModel, paymentData: PaymentData?, currentAmount: Double?) {
        self.viewModel = viewModel
        self.paymentData = paymentData
        self.currentAmount = currentAmount
        super.init(nibName: "ProvenanceViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Procedencia de fondos"
        configureRx()
        fetchProvenanceData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Functions
    fileprivate func configureRx() {
        nationalityButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayNationalityList()
            })
            .disposed(by: bag)
        relationshipButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayRelationshipList()
            })
            .disposed(by: bag)
        originButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayOriginList()
            })
            .disposed(by: bag)
        goToPaymentButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                if let nationality = self.viewModel.nationalitySubject.value, !nationality.isEmpty, let relation = self.viewModel.relationshipSubject.value, !relation.isEmpty, let origin = self.viewModel.originSubject.value, !origin.isEmpty {
                    self.showPaymentConfirmViewController()
                } else {
                    self.showAlert(alertText: "GolloApp", alertMessage: "Seleccione las opciones requeridas")
                }
            })
            .disposed(by: bag)
    }

    fileprivate func fetchProvenanceData() {
        viewModel
            .fetchProvenanceData()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response else { return }
                self.viewModel.natilonalities = response.nacionalidades
                self.viewModel.relationship = response.parentesco
                self.viewModel.origin = response.origenFondos
            })
            .disposed(by: bag)
    }

    fileprivate func displayNationalityList() {
        let dropDown = DropDown()
        dropDown.anchorView = nationalityButton
        dropDown.dataSource = viewModel.natilonalities.map{ $0.descripcion ?? "" }
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.nationalityLabel.text = item
            self.viewModel.nationalitySubject.accept(self.viewModel.natilonalities[index].idPais)
        }
        dropDown.show()
    }

    fileprivate func displayRelationshipList() {
        let dropDown = DropDown()
        dropDown.anchorView = relationshipButton
        dropDown.dataSource = viewModel.relationship.map{ $0.descripcion ?? "" }
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.relationshipLabel.text = item
            self.viewModel.relationshipSubject.accept(self.viewModel.relationship[index].idParentesco)
        }
        dropDown.show()
    }

    fileprivate func displayOriginList() {
        let dropDown = DropDown()
        dropDown.anchorView = originButton
        dropDown.dataSource = viewModel.origin.map{ $0.descripcion ?? "" }
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.originLabel.text = item
            self.viewModel.originSubject.accept(self.viewModel.origin[index].idOrigen)
        }
        dropDown.show()
    }

    private func showPaymentConfirmViewController() {
        DispatchQueue.main.async {
            self.viewModel.setDataToCar()
            let vc = PaymentConfirmViewController.instantiate(fromAppStoryboard: .Payments)
            vc.modalPresentationStyle = .fullScreen
            vc.paymentAmmount = self.currentAmount ?? 0.0
            vc.paymentData = self.paymentData
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
