//
//  ProductScannerViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 19/5/23.
//

import AVFoundation
import UIKit
import DropDown
import RxSwift

class ProductScannerViewController: UIViewController {
    
    @IBOutlet weak var storeTextField: UITextField!
    @IBOutlet weak var searchStoreButton: UIButton!
    @IBOutlet weak var bodegaLabel: UILabel!
    @IBOutlet weak var bodegaButton: UIButton!
    @IBOutlet weak var articleCodeTextField: UITextField!
    @IBOutlet weak var searchProduct: UIButton!
    @IBOutlet weak var storeSwitch: UISwitch!
    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var articleCodeStackView: UIStackView!
    
    var captureSession: AVCaptureSession
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var stringURL = String()
    var selectedBodega = 1
    var storeSelected: ShopData?
    
    // MARK: - Constants
    var viewModel: GolloStoresViewModel
    let bag = DisposeBag()
    enum error: Error {
        case noCameraAvailable
        case videoInputInitFail
    }

    // MARK: - Lifecycle
    init(viewModel: GolloStoresViewModel) {
        self.viewModel = viewModel
        self.captureSession = AVCaptureSession()
        super.init(nibName: "ProductScannerViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Código de barra del artículo"
        self.videoPreviewView.backgroundColor = UIColor.black
        self.hideKeyboardWhenTappedAround()
        
        configureRx()
        scanQRCode()
        fetchShops()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        configureNavBar()
        
        if (self.captureSession.isRunning == false) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.captureSession.startRunning()
            })
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        if (self.captureSession.isRunning == true) {
            DispatchQueue.background(delay: 3.0, completion:{
                self.captureSession.stopRunning()
            })
        }
    }
    
    fileprivate func fetchShops() {
        view.activityStartAnimatingFull()
        viewModel
            .fetchShops()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response else { return }
                self.view.activityStopAnimatingFull()
                let responseData = response.sorted { $0.nombre < $1.nombre }
                self.viewModel.data = responseData
                self.viewModel.processStates(with: responseData)
                self.viewModel.processShops(with: self.viewModel.states.first ?? "")
            })
            .disposed(by: bag)
    }
    
    func scanQRCode() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
                self.showAlert(alertText: "GolloApp", alertMessage: "Your device is not aplicable for video procesing.")
                print("Your device is not aplicable for video procesing.")
                return
            }
            
            guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
                self.showAlert(alertText: "GolloApp", alertMessage: "Fail to init camera.")
                print("Fail to init camera.")
                return
            }
            
            if (self.captureSession.canAddInput(videoInput)) {
                self.captureSession.addInput(videoInput)
            } else {
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if self.captureSession.canAddOutput(metadataOutput) {
                self.captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.upce, .code39, .code39Mod43, .code93, .code128, .ean8, .ean13, .aztec, .pdf417, .itf14, .interleaved2of5, .dataMatrix]
            } else {
                return
            }
            
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            
            if let previewLayer = self.previewLayer {
                previewLayer.frame = self.videoPreviewView.bounds
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.videoPreviewView.layer.addSublayer(previewLayer)
                DispatchQueue.background(delay: 3.0, completion:{
                    self.captureSession.startRunning()
                })
            } else {
                self.showAlert(alertText: "GolloApp", alertMessage: "Fail to start scan process.")
            }
        })
    }
    
    private func configureRx() {
        storeSwitch
            .rx
            .isOn
            .subscribe(onNext: {[weak self] value in
                guard let self = self else { return }
                
                if value {
                    self.articleCodeStackView.isHidden = false
                } else {
                    self.articleCodeStackView.isHidden = true
                }
            })
            .disposed(by: bag)
        
        bodegaButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayBodegaList()
            })
            .disposed(by: bag)
        
        searchStoreButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                let golloStoresViewController = GolloStoresViewController(
                    viewModel: GolloStoresViewModel()
                )
                golloStoresViewController.delegate = self
                golloStoresViewController.modalPresentationStyle = .overCurrentContext
                golloStoresViewController.modalTransitionStyle = .crossDissolve
                self.present(golloStoresViewController, animated: true)
            })
            .disposed(by: bag)
        
        searchProduct
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                var sku = ""
                if self.articleCodeTextField.text == nil || self.articleCodeTextField.text?.isEmpty == true {
                    self.showAlert(alertText: "GolloApp", alertMessage: "Debe ingresar código de artículo.")
                } else {
                    if let code = self.articleCodeTextField.text, code.count == 14 {
                        sku = String(code.dropFirst(4))
                        _ = code.subString(from: 0, to: 3)
                        let bodega = code.subString(from: 3, to: 4)
                        self.selectedBodega = Int(bodega) ?? 1
                    } else {
                        sku = self.articleCodeTextField.text ?? ""
                    }
                    getSKU(with: sku, bodega: String(self.selectedBodega))
                }
            })
            .disposed(by: bag)
    }

    fileprivate func displayBodegaList() {
        let dropDown = DropDown()
        dropDown.anchorView = bodegaButton
        dropDown.dataSource = ["1", "2", "3"]
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.bodegaLabel.text = item
            self.selectedBodega = Int(item) ?? 1
        }
        dropDown.show()
    }
    
    fileprivate func getSKU(with sku: String, center: String = "144", bodega: String) {
        if (self.captureSession.isRunning == true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.captureSession.stopRunning()
            }
        }
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.skuProduct = sku
        vc.bodegaProduct = bodega
        vc.scannerFlowActivate = true
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ProductScannerViewController: GolloStoresDelegate {
    func storeSelected(with selected: ShopData) {
        self.storeSelected = selected
        self.storeTextField.text = selected.nombre
    }
}

extension ProductScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let first = metadataObjects.first {
            guard let readableObject = first as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
            validateBarCode(with: stringValue)
        }
    }
    
    func validateBarCode(with code: String) {
        if !code.isEmpty {
            let sku = String(code.dropFirst(4))
            let store = code.subString(from: 0, to: 3)
            let bodega = code.subString(from: 3, to: 4)
            if self.storeSwitch.isOn {
                if let searchStore = self.viewModel.shops.first(where: { $0.idTienda == store }) {
                    self.storeSelected = searchStore
                    self.storeTextField.text = searchStore.nombre
                    if (self.captureSession.isRunning == true) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.captureSession.stopRunning()
                        }
                    }
                }
            } else {
                self.getSKU(with: sku, bodega: bodega)
            }
        }
    }
}
