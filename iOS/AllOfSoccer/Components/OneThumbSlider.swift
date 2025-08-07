import UIKit

class OneThumbSlider: UISlider {

    @IBInspectable var trackHeight: CGFloat = 3

    @IBInspectable var thumbDiameter: CGFloat = 20

    @IBInspectable var interval: Int = 1

    private lazy var thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1)
        thumb.layer.borderWidth = 0
        thumb.layer.borderColor = UIColor.darkGray.cgColor
        return thumb
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSlider()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSlider()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let thumb = thumbImage(diameter: thumbDiameter)
        setThumbImage(thumb, for: .normal)
        setThumbImage(thumb, for: .highlighted)
    }

    private func thumbImage(diameter: CGFloat) -> UIImage {
        thumbView.frame = CGRect(x: 0, y: diameter / 2, width: diameter, height: diameter)
        thumbView.layer.cornerRadius = diameter / 2

        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }

    private func setupSlider() {
        addTarget(self, action: #selector(valueChanged(sender:)), for: .valueChanged)
    }

    @objc func valueChanged(sender: UISlider) {
        let newValue =  (sender.value / Float(interval)).rounded() * Float(interval)
                setValue(Float(newValue), animated: false)
    }
}
