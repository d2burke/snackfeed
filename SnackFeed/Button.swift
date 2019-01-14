//
//  Button.swift
//  Handshake
//
//  Created by Daniel Burke on 1/1/17.
//  Copyright © 2017 Daniel Burke. All rights reserved.
//

import UIKit
import SnapKit

typealias TapAction = (_ button: Button) -> ()
typealias TouchAction = (_ touches: Set<UITouch>, _ event: UIEvent?) -> ()

class Button: UIButton {
    fileprivate var normalFont: UIFont? = nil
    fileprivate var highlightedFont: UIFont? = nil
    fileprivate var selectedFont: UIFont? = nil
    fileprivate var disabledFont: UIFont? = nil
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    let disclosureArrow: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.transform = CGAffineTransform.identity.rotated(by: -.pi/2)
        imageView.isHidden = true
        return imageView
    }()
    
    internal var defaultBackgroundColor: UIColor? = nil {
        didSet {
            backgroundColor = defaultBackgroundColor
            
            //Setting a default color will give the
            //user a very nice highlighted state
            //of a lighter shade of the same color
            if highlightColor == nil {
                highlightColor = defaultBackgroundColor?.lighter
                internalHighlightColor = defaultBackgroundColor?.lighter
            }
        }
    }
    
    var tapAction: TapAction? = nil
    var touchesBegan: TouchAction? = nil
    var touchesEnded: TouchAction? = nil
    var internalHighlightColor: UIColor? = nil
    
    /**
     *  Displays an arrow at the right edge of the button
     */
    var showDisclosureIndicator: Bool = false {
        didSet {
            disclosureArrow.isHidden = !showDisclosureIndicator
        }
    }
    
    /**
     *  This icon will be placed just to the left of the
     *  button title
     */
    var titleIcon: UIImage? = nil {
        didSet {
            setImage(titleIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
            imageEdgeInsets = titleIcon == nil ? .zero : UIEdgeInsetsMake(4, 0, 0, 10)
            titleEdgeInsets = titleIcon == nil ? .zero : UIEdgeInsetsMake(0, 0, 0, 8)
        }
    }
    
    var loading: Bool = false {
        didSet {
            titleLabel?.alpha = loading ? 0 : 1
            isUserInteractionEnabled = !loading
            disclosureArrow.isHidden = loading ? true : !showDisclosureIndicator
            
            if loading {
                isEnabled = false
                imageView?.isHidden = true
                activityIndicator.color = defaultTitleColor
                activityIndicator.startAnimating()
                activityIndicator.isHidden = false
            } else {
                isEnabled = true
                imageView?.isHidden = titleIcon == nil
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
            }
        }
    }
    
    var highlightColor: UIColor? = nil {
        didSet {
            //Since this property is `nil` to begin with
            //we set it here if the user sets a highlightColor
            //to be sure the button returns to what the user
            //intended, which was no background
            if backgroundColor == nil {
                backgroundColor = .clear
            }
        }
    }
    
    var selectedColor: UIColor? = nil {
        didSet {
            //Since this property is `nil` to begin with
            //we set it here if the user sets a highlightColor
            //to be sure the button returns to what the user
            //intended, which was no background
            if backgroundColor == nil {
                backgroundColor = .clear
            }
        }
    }
    
    var disabledBackgroundColor: UIColor?
    var disabledTitleColor: UIColor?
    
    var defaultTitleColor: UIColor? = .black {
        didSet {
            setTitleColor(defaultTitleColor, for: .normal)
        }
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = nil
        layer.cornerRadius = 3
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        addSubview(activityIndicator)
        addSubview(disclosureArrow)
        adjustsImageWhenDisabled = false
        adjustsImageWhenHighlighted = false
        
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.size.equalTo(30)
        }
        
        disclosureArrow.snp.makeConstraints { (make) in
            make.size.equalTo(25)
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-25)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFont(font: UIFont, state: UIControlState) {
        switch state {
        case UIControlState.normal:
            normalFont = font
            titleLabel?.font = font
        case UIControlState.highlighted:
            highlightedFont = font
        case UIControlState.selected:
            selectedFont = font
        case UIControlState.disabled:
            disabledFont = font
        default: ()
        }
    }
    
    func didTapButton(button: Button) {
        if let action = tapAction {
            action(button)
        }
    }
    
}

//MARK: Overrides
extension Button {
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            if defaultBackgroundColor == nil {
                defaultBackgroundColor = backgroundColor
            }
            
            if selectedColor == nil {
                selectedColor = defaultBackgroundColor
            }
            
            backgroundColor = isSelected ? selectedColor : defaultBackgroundColor
            imageView?.tintColor = titleColor(for: state)
            
            if let font = selectedFont {
                titleLabel?.font = isSelected ? font : normalFont
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            
            //We need to set the default here to be able to
            //return the button to a normal state once it's
            //enabled again
            if defaultBackgroundColor == nil {
                defaultBackgroundColor = backgroundColor
            }
            
            if isEnabled {
                layer.borderWidth = 0
                backgroundColor = defaultBackgroundColor
                setTitleColor(defaultTitleColor, for: .normal)
            } else {
                //"Hide" button title when in loading state
                //to reveal the loading spinner
                if loading {
                    setTitleColor(.clear, for: .disabled)
                } else {
                    setTitleColor(disabledTitleColor == nil ? .gray : disabledTitleColor, for: .disabled)
                    layer.borderWidth = 1
                    layer.borderColor = UIColor.gray.cgColor
                    backgroundColor = disabledBackgroundColor == nil ? .white : disabledBackgroundColor
                }
            }
            
            if let font = disabledFont {
                titleLabel?.font = isEnabled ? normalFont : font
            }
        }
    }
    
    
    override func setTitleColor(_ color: UIColor?, for state: UIControlState) {
        super.setTitleColor(color, for: state)
        if defaultTitleColor == nil {
            defaultTitleColor = color
        }
        imageView?.tintColor = titleColor(for: .normal)
        disclosureArrow.tintColor = titleColor(for: .normal)
    }
    
    override var isHighlighted: Bool {
        didSet {
            super.isHighlighted = isHighlighted
            
            if defaultBackgroundColor == nil {
                defaultBackgroundColor = backgroundColor
            }
            
            if highlightColor == nil {
                highlightColor = defaultBackgroundColor?.lighter
                internalHighlightColor = highlightColor
            }
            
            if isSelected {
                if highlightColor == nil { //User did not supply a highlight color
                    backgroundColor = isHighlighted ? internalHighlightColor : selectedColor
                } else {
                    backgroundColor = isHighlighted ? highlightColor : selectedColor
                }
            } else {
                if highlightColor == nil { //User did not supply a highlight color
                    backgroundColor = isHighlighted ? internalHighlightColor : defaultBackgroundColor
                } else {
                    backgroundColor = isHighlighted ? highlightColor : defaultBackgroundColor
                }
            }
            
            imageView?.tintColor = titleColor(for: state)
            
            if let font = highlightedFont {
                titleLabel?.font = isHighlighted ? font : normalFont
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let action = touchesBegan {
            action(touches, event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let action = touchesEnded {
            action(touches, event)
        }
    }
}
