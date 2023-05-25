//
//  ProductScannerViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 19/5/23.
//

import UIKit
import AVFoundation
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
    
    var captureSession: AVCaptureSession
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var stringURL = String()
    var selectedBodega = 1
    var storeSelected: ShopData?
    var selectedStoreId: String = ""
    
    // MARK: - Constants
    let bag = DisposeBag()
    enum error: Error {
        case noCameraAvailable
        case videoInputInitFail
    }

    // MARK: - Lifecycle
    init() {
        self.captureSession = AVCaptureSession()
        super.init(nibName: "ProductScannerViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Código de barra del artículo"
        
        configureRx()
        scanQRCode()
//        do {
//            try scanQRCode()
//        } catch {
//            self.showAlert(alertText: "GolloApp", alertMessage: "Error al escanear el código.")
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
//    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects:[Any]!, from connection: AVCaptureConnection!) {
//        if metadataObjects.count > 0 {
//            if #available(iOS 15.4, *) {
//                if let matchineReadableCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject, matchineReadableCode.type == AVMetadataObject.ObjectType.codabar {
//                    stringURL = matchineReadableCode.stringValue ?? ""
//                    self.articleCodeTextField.text = stringURL
//                    if let code = matchineReadableCode.stringValue, !code.isEmpty {
//                        let sku = String(code.suffix(4))
//                        let store = code.subString(from: 0, to: 3)
//                        let bodega = code.subString(from: 3, to: 4)
//                        if self.storeSwitch.isOn {
//                            self.storeTextField.text = store
//                            selectedStoreId = store
//                        } else {
//                            getSKU(with: sku, bodega: bodega)
//                        }
//                    }
//                }
//            } else {
//                if let matchineReadableCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject, matchineReadableCode.type == AVMetadataObject.ObjectType.qr {
//                    stringURL = matchineReadableCode.stringValue ?? ""
//                    self.articleCodeTextField.text = stringURL
//                    if let code = matchineReadableCode.stringValue, !code.isEmpty {
//                        let sku = String(code.suffix(4))
//                        let store = code.subString(from: 0, to: 3)
//                        let bodega = code.subString(from: 3, to: 4)
//                        if self.storeSwitch.isOn {
//                            self.storeTextField.text = store
//                            selectedStoreId = store
//                        } else {
//                            getSKU(with: sku, bodega: bodega)
//                        }
//                    }
//                }
//            }
//
//        }
//    }
    
//    func scanQRCode() throws {
//        let avCaptureSession = AVCaptureSession()
//
//        guard let avCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
//            print("No camera.")
//            throw error.noCameraAvailable
//        }
//
//        guard let avCaptureInput = try? AVCaptureDeviceInput(device: avCaptureDevice) else {
//            print("Fail to init camera.")
//            throw error.videoInputInitFail
//        }
//
//        let avCaptureMetadataOutput = AVCaptureMetadataOutput()
//        avCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//
//        avCaptureSession.addInput(avCaptureInput)
//        avCaptureSession.addOutput(avCaptureMetadataOutput)
//
//        if #available(iOS 15.4, *) {
//            avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.codabar]
//        } else {
//            avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
//        }
//
//        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
//        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        avCaptureVideoPreviewLayer.frame = videoPreviewView.bounds
//        self.videoPreviewView.layer.addSublayer(avCaptureVideoPreviewLayer)
//
//        avCaptureSession.startRunning()
//    }
    
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
            
            if self.captureSession.canAddInput(videoInput) {
                self.captureSession.addInput(videoInput)
            } else {
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if self.captureSession.canAddOutput(metadataOutput) {
                self.captureSession.addOutput(metadataOutput)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
            } else {
                return
            }
            
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            
            if let previewLayer = self.previewLayer {
                previewLayer.frame = self.videoPreviewView.bounds
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.videoPreviewView.layer.addSublayer(previewLayer)
                print("Start running")
                self.captureSession.startRunning()
            } else {
                self.showAlert(alertText: "GolloApp", alertMessage: "Fail to start scan process.")
            }
        })
    }
    
    private func configureRx() {
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
                } else if storeSelected == nil {
                    self.showAlert(alertText: "GolloApp", alertMessage: "Debe seleccionar tienda.")
                } else {
                    if let code = self.articleCodeTextField.text, code.count == 14 {
                        sku = String(code.suffix(4))
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
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.skuProduct = sku
        vc.bodegaProduct = bodega
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
            validateBarCode(with: stringValue)
        } else {
            self.showAlert(alertText: "GolloApp", alertMessage: "No able to read the code, please try again or be keepyout device on Bar Code!")
        }
    }
    
    func validateBarCode(with code: String) {
        if !code.isEmpty {
            self.articleCodeTextField.text = code
            let sku = String(code.suffix(4))
            let store = code.subString(from: 0, to: 3)
            let bodega = code.subString(from: 3, to: 4)
            if self.storeSwitch.isOn {
                self.storeTextField.text = store
                self.selectedStoreId = store
            } else {
                self.getSKU(with: sku, bodega: bodega)
            }
        }
    }
}
