import UIKit

let imageCache = NSCache<NSString, UIImage>()

//You can put these in a separate file but still should be a global function in your project
func main(transaction: @escaping () -> Void) {
    if Thread.isMainThread {
        transaction()
    } else {
        DispatchQueue.main.sync {
            transaction()
        }
    }
}

func mainAsync(transaction: @escaping () -> Void) {
    if Thread.isMainThread {
        transaction()
    } else {
        DispatchQueue.main.async {
            transaction()
        }
    }
}

extension UIImageView {
    private enum AssociatedKeys {
        static var CurrentTask = "CurrentTask"
    }
    
    var currentTask: URLSessionDataTask? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.CurrentTask) as? URLSessionDataTask
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.CurrentTask,
                    newValue as URLSessionDataTask?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    public func setImage(with url: URL?, placeholder: UIImage? = nil, animated: Bool = true) {
        currentTask?.cancel()
        
        // Set the placeholder meanwhile the image is downloaded
        image = placeholder
        
        guard let url = url else { return }
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            replaceImage(cachedImage, animated: animated)
        } else {
            currentTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data,
                   let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    mainAsync { [weak self] in
                        guard let self = self else { return }
                        self.replaceImage(image, animated: animated)
                    }
                }
            }
            currentTask?.resume()
        }
    }
}

extension UIImageView {
    func replaceImage(_ image: UIImage, animated: Bool) {
        guard animated else {
            self.image = image
            return
        }

        UIView.transition(with: self,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.image = image
                          })
    }
}
