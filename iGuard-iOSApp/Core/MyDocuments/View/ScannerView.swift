import SwiftUI
import AVFoundation

struct ScannerView: UIViewControllerRepresentable {
    let completionHandler: (String) -> Void
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let scannerViewController = ScannerViewController(completionHandler: completionHandler)
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
    }
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let completionHandler: (String) -> Void
    var captureSession: AVCaptureSession!
    let captureSessionQueue = DispatchQueue(label: "com.example.captureSessionQueue", qos: .userInitiated)
    
    init(completionHandler: @escaping (String) -> Void) {
        self.completionHandler = completionHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard let captureDevice = AVCaptureDevice.default(for: .video) else {
                fatalError("No video capture device available")
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                self.captureSession = AVCaptureSession()
                self.captureSession.addInput(input)
                
                let metadataOutput = AVCaptureMetadataOutput()
                self.captureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.pdf417] // Adjust the barcode type as needed
                
                DispatchQueue.main.async {
                    let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    previewLayer.frame = self.view.layer.bounds
                    self.view.layer.addSublayer(previewLayer)
                }
                
                self.captureSession.startRunning()
            } catch {
                fatalError("Failed to initialize capture session: \(error.localizedDescription)")
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else {
            return
        }
        
        completionHandler(stringValue)
        
        // Stop the capture session after successfully scanning the code
        captureSession.stopRunning()
    }
}
