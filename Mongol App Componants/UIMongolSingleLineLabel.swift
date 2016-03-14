import UIKit

@IBDesignable
class UIMongolSingleLineLabel: UIView {
    
    private let textLayer = LabelTextLayer()
    let mongolFontName = "ChimeeWhiteMirrored"
    var useMirroredFont = true
    private var oldFrame = CGRectZero
    
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
    
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override var frame: CGRect {
        didSet {
            
            // only update frames if non-zero and changed
            if frame != CGRectZero && frame != oldFrame {
                updateTextLayerFrame()
                oldFrame = frame
            }
        }
    }
    
    func setup() {
        
        
        // Text layer
        textLayer.useMirroredFont = useMirroredFont
        textLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(textLayer)
        
    }
    
    func updateTextLayerFrame() {
        
        let myAttribute = [ NSFontAttributeName: UIFont(name: mongolFontName, size: fontSize )! ]
        let attrString = NSMutableAttributedString(string: textLayer.displayString, attributes: myAttribute )
        let size = dimensionsForAttributedString(attrString)
        
        // This is the frame for the soon-to-be rotated layer
        let x = (layer.bounds.width - size.height) / 2
        let y = (layer.bounds.height - size.width) / 2
        textLayer.frame = CGRect(x: x, y: y, width: size.height, height: size.width)
        textLayer.string = attrString
    }
    
    
    
    func dimensionsForAttributedString(attrString: NSAttributedString) -> CGSize {
        
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var width: CGFloat = 0
        let line: CTLineRef = CTLineCreateWithAttributedString(attrString)
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
    
    override func drawInContext(ctx: CGContext) {
        // A frame is passed in, in which the frame size is already rotated at the center but the content is not.
        
        CGContextSaveGState(ctx)
        
        if useMirroredFont {
            CGContextRotateCTM(ctx, CGFloat(M_PI_2))
            CGContextScaleCTM(ctx, 1.0, -1.0)
        } else {
            CGContextRotateCTM(ctx, CGFloat(M_PI_2))
            CGContextTranslateCTM(ctx, 0, -self.bounds.width)
        }
        
        super.drawInContext(ctx)
        CGContextRestoreGState(ctx)
    }
}


