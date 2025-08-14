import UIKit

extension UIView {

    @IBInspectable var shadowRadius : CGFloat {
        get {
            return self.layer.shadowRadius
        }


        set {
            self.layer.shadowRadius = newValue
        }

    }

    @IBInspectable var shadowOpacity : Float {
        get {
            return self.layer.shadowOpacity
        }

        set {
            self.layer.shadowOpacity = newValue
        }

    }

    @IBInspectable var shadowColor : UIColor {
        get {
            if let shadowColor = self.layer.shadowColor {
                return UIColor(cgColor: shadowColor)
            }
            return UIColor.clear
        }
        set {
            //그림자의 색이 지정됬을 경우
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
            //shadowOffset은 빛의 위치를 지정해준다. 북쪽에 있으면 남쪽으로 그림지가 생기는 것
            self.layer.shadowColor = newValue.cgColor
            //그림자의 색을 지정
        }
    }

    @IBInspectable var maskToBound : Bool{
        get {
            return self.layer.masksToBounds
        }

        set {
            self.layer.masksToBounds = newValue
        }
    }
    
    func addsubviews(_ views: UIView...) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }

    func addsubviews(_ views: [UIView]) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }

    func debugBorder(width: CGFloat = 1.0, color: UIColor = .red) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}

extension UITableViewCell {

    internal static var defaultIdentifier: String {
        String(describing: self)
    }
}
