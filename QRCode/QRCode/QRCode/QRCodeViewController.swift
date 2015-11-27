
import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, UITabBarDelegate, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var scanImage: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var weithConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBAction func close(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showMyCard() {
        navigationController?.pushViewController(QRCodeCreateViewController(), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 默认选中第一项
        tabBar.selectedItem = tabBar.items![0]
        
        // 设置会话
        setupSession()
        setupLayers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        startAnimation()
        startScan()
    }

    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        heightConstraint.constant = weithConstraint.constant * (item.tag == 1 ? 0.5 : 1)
        
        scanImage.layer.removeAllAnimations()
        startAnimation()
    }
    
    /// 开始动画
    private func startAnimation() {
        topConstraint.constant = -heightConstraint.constant
        view.layoutIfNeeded()
        
        UIView.animateWithDuration(3.0, animations: { () -> Void in
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.topConstraint.constant = self.heightConstraint.constant
            self.view.layoutIfNeeded()
        });
    }
    
    // MARK: - 二维码扫描
    ///  开始扫描
    private func startScan() {
        session.startRunning()
    }
    
    /// 设置会话
    private func setupSession() {
        // 1. 判断是否能够添加设备
        if !session.canAddInput(inputDevice) {
            print("无法添加输入设备")
            return
        }
        
        // 2. 判断能否添加输出数据
        if !session.canAddOutput(outputData) {
            print("无法添加输出数据")
            return
        }
        
        // 3. 添加设备
        session.addInput(inputDevice)
        session.addOutput(outputData)
        print(outputData.availableMetadataObjectTypes)
        
        // 4. 设置扫描数据类型
        outputData.metadataObjectTypes = outputData.availableMetadataObjectTypes
        // 5. 设置输出代理
        outputData.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
    }
    
    /// 设置图层
    func setupLayers() {
        drawLayer.frame = view.bounds
        view.layer.insertSublayer(drawLayer, atIndex: 0)
        
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, atIndex: 0)
    }
    
    // MARK: - 扫描数据代理
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        clearDrawLayer()
        
        for object in metadataObjects {
            
            if object is AVMetadataMachineReadableCodeObject {
                let dataObject = previewLayer.transformedMetadataObjectForMetadataObject(object as! AVMetadataObject) as! AVMetadataMachineReadableCodeObject
                
                drawCornersShape(dataObject)
                resultLabel.text = dataObject.stringValue
            }
        }
    }
    
    /// 清空绘图图层
    private func clearDrawLayer() {
        if drawLayer.sublayers == nil {
            return
        }
        
        for layer in drawLayer.sublayers! {
            layer.removeFromSuperlayer()
        }
    }
    
    /// 绘制条码形状
    private func drawCornersShape(dataObject: AVMetadataMachineReadableCodeObject) {
        // 判断数组是否为空
        if dataObject.corners.isEmpty {
            return
        }
        
        let layer = CAShapeLayer()
        layer.lineWidth = 4
        layer.strokeColor = UIColor.greenColor().CGColor
        layer.fillColor = UIColor.clearColor().CGColor
        layer.path = cornersPath(dataObject.corners)
        
        // 添加到绘图图层
        drawLayer.addSublayer(layer)
    }

    ///  创建边线路径
    ///
    ///  -parameter corners: 边角顶点数组
    private func cornersPath(corners: NSArray) -> CGPathRef {
        let path = UIBezierPath()
        var point = CGPoint()
        
        // 1. 移动到第一个点
        var index = 0
        CGPointMakeWithDictionaryRepresentation((corners[index++] as! CFDictionaryRef), &point)
        path.moveToPoint(point)
        
        // 2. 遍历剩余的点
        while index < corners.count {
            CGPointMakeWithDictionaryRepresentation((corners[index++] as! CFDictionaryRef), &point)
            path.addLineToPoint(point)
        }
        
        // 3. 关闭路径
        path.closePath()
        
        return path.CGPath
    }
    
    /// 绘制图层
    lazy var drawLayer: CALayer = {
        return CALayer()
    }()
    
    /// 预览图层
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        return AVCaptureVideoPreviewLayer(session: self.session)
    }()

    /// 会话
    lazy var session: AVCaptureSession = {
        return AVCaptureSession()
    }()
    
    /// 输入设备
    lazy var inputDevice: AVCaptureDeviceInput? = {

        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            return try AVCaptureDeviceInput(device: device)
        } catch {
            print(error)
            return nil
        }
    }()
    
    /// 输出数据
    lazy var outputData: AVCaptureMetadataOutput = {
        return AVCaptureMetadataOutput()
    }()
}
