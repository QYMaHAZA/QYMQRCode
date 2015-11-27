
import UIKit
import FFAutoLayout

class QRCodeCreateViewController: UIViewController {

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        
        title = "我的名片"
        view.addSubview(iconView)
        
        iconView.ff_AlignInner(ff_AlignType.CenterCenter, referView: view, size: CGSize(width: 200, height: 200))
        iconView.backgroundColor = UIColor.lightGrayColor()
    }
    
    lazy var iconView: UIImageView = {
        return UIImageView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(CIFilter.filterNamesInCategory(kCICategoryBuiltIn))
        
        iconView.image = generateQRCodeImage()
    }
    
    /// 生成二维码
    private func generateQRCodeImage() -> UIImage {
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setDefaults()
        qrFilter.setValue("I'm  QYMa".dataUsingEncoding(NSUTF8StringEncoding), forKey: "inputMessage")
        let ciImage = qrFilter.outputImage
        
        let transform = CGAffineTransformMakeScale(10, 10)
        
        let transformImage = ciImage!.imageByApplyingTransform(transform)
        
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(transformImage, forKey: "inputImage")
        // 前景色
        colorFilter.setValue(CIColor(color: UIColor.blackColor()), forKey: "inputColor0")
        // 背景色
        colorFilter.setValue(CIColor(color: UIColor.whiteColor()), forKey: "inputColor1")
        
        let outputImage = colorFilter.outputImage
        
        return insertAvatarImage(UIImage(CIImage: outputImage!), avatar: UIImage(named: "avatar")!)
    }
    
    func insertAvatarImage(qrimage: UIImage, avatar: UIImage) -> UIImage {
        
        UIGraphicsBeginImageContext(qrimage.size)
        
        let rect = CGRect(origin: CGPointZero, size: qrimage.size)
        qrimage.drawInRect(rect)
        
        let w = rect.width * 0.2
        let x = (rect.width - w) * 0.5
        let y = (rect.height - w) * 0.5
        avatar.drawInRect(CGRect(x: x, y: y, width: w, height: w))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
