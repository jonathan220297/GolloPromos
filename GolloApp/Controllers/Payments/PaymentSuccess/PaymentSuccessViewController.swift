//
//  PaymentSuccessViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 29/8/22.
//

import RxSwift
import UIKit

class PaymentSuccessViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var successImage: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var warningImageView: UIImageView!
    @IBOutlet weak var warningDescriptionLabel: UILabel!
    @IBOutlet weak var paymentDescriptionLabel: UILabel!
    
    // MARK: - Constants
    let viewModel: PaymentSuccessViewModel
    let bag = DisposeBag()
    let cartPayment: Bool
    
    // MARK: - Lifecycle
    init(viewModel: PaymentSuccessViewModel, cartPayment: Bool) {
        self.viewModel = viewModel
        self.cartPayment = cartPayment
        super.init(nibName: "PaymentSuccessViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Functions
    func configureRx() {
        backButton
            .rx
            .tap
            .subscribe(onNext: {
                self.popToAccountController()
            })
            .disposed(by: bag)
        
        closeButton
            .rx
            .tap
            .subscribe(onNext: {
                self.popToAccountController()
            })
            .disposed(by: bag)
    }
    
    func popToAccountController() {
        var returnCount: Int = 5
        if cartPayment {
            returnCount = 6
        }
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - returnCount], animated: true)
    }
    
    func configureViews() {
        if viewModel.accountPaymentResponse != nil {
            titleLabel.text = "Pago aplicado con éxito"
            successImage.image = UIImage(named: "ic_payment_success")
            orderNumberLabel.isHidden = true
            paymentDescriptionLabel.text = "Su pago ha sido procesado satisfactoriamente. Por favor esté pendiente de su correo y de las notificaciones que puede recibir en esta plataforma porque por esos medios le notificaremos sobre su factura electrónica."
        } else if let productPaymentResponse = viewModel.productPaymentResponse {
            titleLabel.text = "Orden confirmada"
            successImage.image = UIImage(named: "ic_order_confirmation")
            orderNumberLabel.isHidden = false
            let orderString = "Número de orden: " + (productPaymentResponse.orderId ?? "")
            orderNumberLabel.attributedText = orderString.withBoldText(
                text: (productPaymentResponse.orderId ?? ""),
                fontNormalText: UIFont.systemFont(ofSize: 20),
                fontBoldText: UIFont.systemFont(ofSize: 20, weight: .semibold),
                fontColorBold: .darkGray
            )
            paymentDescriptionLabel.text = "Su orden ha sido enviada satisfactoriamente. Por favor esté pendiente de su correo y de las notificaciones que puede recibir en esta plataforma sobre el estatus de su pedido."
        }
    }
}
