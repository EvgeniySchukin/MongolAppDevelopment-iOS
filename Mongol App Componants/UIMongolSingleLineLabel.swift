// UIMongolSingleLineLabel
// version 1.1

// supports intrinsic content auto resizing
// supports auto rendering of unicode text

import UIKit

@IBDesignable
class UIMongolSingleLineLabel: UIView {
    
    fileprivate let textLayer = LabelTextLayer()
    let mongolFontName = "ChimeeWhiteMirrored"
    let renderer = MongolUnicodeRenderer.sharedInstance
    var useMirroredFont = true
    //private var oldFrame = CGRectZero
    
    // MARK: Primary input value
    
    @IBInspectable var text: String = "A" {
        didSet {
            textLayer.displayString = text
            updateTextLayerFrame()
        }
    }
    
    @IBInspectable var fontSize: CGFloat = 17 {
        didSet {
            updateTextLayerFrame()
        }
    }
    
    @IBInspectable var textColor: UIColor = UIColor.black {
        didSet {
            updateTextLayerFrame()
        }
    }
    
    @IBInspectable var centerText: Bool = true {
        didSet {
            updateTextLayerFrame()
        }
    }
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        
        
        // Text layer
        textLayer.useMirroredFont = useMirroredFont
        textLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(textLayer)
        
    }
    
    override var intrinsicContentSize : CGSize {
        return textLayer.frame.size
    }
    
    func updateTextLayerFrame() {
        
        let myAttributes = [
            NSFontAttributeName: UIFont(name: mongolFontName, size: fontSize )! ,
            NSForegroundColorAttributeName: textColor
        ] as [String : Any]
        let renderedString = renderer.unicodeToGlyphs(textLayer.displayString)
        let attrString = NSMutableAttributedString(string: renderedString, attributes: myAttributes )
        let size = dimensionsForAttributedString(attrString)
        
        // This is the frame for the soon-to-be rotated layer
        var x: CGFloat = 0
        var y: CGFloat = 0
        if layer.bounds.width > size.height {
            x = (layer.bounds.width - size.height) / 2
        }
        if centerText {
            y = (layer.bounds.height - size.width) / 2
        }
        textLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        textLayer.string = attrString
        invalidateIntrinsicContentSize()
    }
    
    
    
    func dimensionsForAttributedString(_ attrString: NSAttributedString) -> CGSize {
        
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var width: CGFloat = 0
        let line: CTLine = CTLineCreateWithAttributedString(attrString)
        width = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, nil))
        
        // make width an even integer for better graphics rendering
        width = ceil(width)
        if Int(width)%2 == 1 {
            width += 1.0
        }
        
        return CGSize(width: width, height: ceil(ascent+descent))
    }
}

// MARK: - Key Text Layer Class

class LabelTextLayer: CATextLayer {
    
    // set this to false if not using a mirrored font
    var useMirroredFont = true
    var displayString = ""
    
    override func draw(in ctx: CGContext) {
        // A frame is passed in, in which the frame size is already rotated at the center but the content is not.
        
        ctx.saveGState()
        
        if useMirroredFont {
            ctx.rotate(by: CGFloat(M_PI_2))
            ctx.scaleBy(x: 1.0, y: -1.0)
        } else {
            ctx.rotate(by: CGFloat(M_PI_2))
            ctx.translateBy(x: 0, y: -self.bounds.width)
        }
        
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}


