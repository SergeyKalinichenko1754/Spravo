//
//  PopupVC.swift
//  Spravo
//
//  Created by Onix on 10/17/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit


protocol PopupVCDelegate: class {
    func tapedCancelButtonInPopupVC()
}

class PopupVC: UIScrollView {
    fileprivate lazy var contentViewSize = CGSize(width: self.frame.width, height: self.frame.height * 8)
    fileprivate let indentForIndicator: CGFloat = 40
    fileprivate let indentBetweenItems: CGFloat = 10
    fileprivate lazy var indicatorPositionForItems = [CGFloat]()
    fileprivate lazy var currentTask = 0
    fileprivate let screenHeight = UIScreen.main.bounds.height / 4
    fileprivate let screenWidth = UIScreen.main.bounds.width / 3 * 1.8
    fileprivate weak var mainView: UIView?
    fileprivate let activityIndicator = UIActivityIndicatorView(style: .white)
    weak var cancelButtonDelegate: PopupVCDelegate?
    
    fileprivate lazy var fadeView: UIView = {
        let frame = CGRect(x: 0, y: -50, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
        let view = UIView(frame: frame)
        view.backgroundColor = .lightGray
        return view
    }()
    
    fileprivate lazy var conteinerView: UIView = {
        let view = UIView(frame: .zero)
        view.frame.size = contentViewSize
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSize()
        self.backgroundColor = .lightGray
        self.contentSize = contentViewSize
        self.autoresizingMask = .flexibleHeight
        self.showsHorizontalScrollIndicator = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        self.addSubview(conteinerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSize() {
        self.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    }
    
    fileprivate func addLabel(text: String, top: CGFloat) -> UILabel {
        let label = UILabel()
        label.textColor = .black
        label.frame = CGRect(x: indentForIndicator, y: top, width: screenWidth - indentForIndicator, height: 10)
        label.numberOfLines = 0
        label.text = text
        label.lineBreakMode = .byCharWrapping
        label.sizeToFit()
        return label
    }
    
    fileprivate func addTextView(text: String, top: CGFloat) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        textView.text = text
        textView.backgroundColor = .clear
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.blue]
        textView.frame = CGRect(x: indentForIndicator, y: top, width: screenWidth - indentForIndicator, height: 10)
        textView.sizeToFit()
        return textView
    }
    
    fileprivate func addCancelButton(caption: String, top: CGFloat) -> UIButton {
        let buttonHeight: CGFloat = 40
        let button = UIButton(frame: CGRect(x: 0, y: top, width: 100, height: buttonHeight))
        button.backgroundColor = .blue
        button.setTitle(caption, for: .normal)
        button.contentEdgeInsets.left = 10
        button.contentEdgeInsets.right = 10
        button.contentEdgeInsets.top = 5
        button.contentEdgeInsets.bottom = 5
        button.sizeToFit()
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        let buttonCenterVerticalPosition = top + buttonHeight > screenHeight ? top + buttonHeight : screenHeight - buttonHeight
        button.center = CGPoint(x: conteinerView.frame.width / 2, y: buttonCenterVerticalPosition)
        button.contentHorizontalAlignment = .center
        return button
    }
    
    @objc fileprivate func cancelButtonAction() {
        cancelButtonDelegate?.tapedCancelButtonInPopupVC()
        remove(animated: true)
    }
    
    func showScreen(vc: UIViewController, image: UIImage? = nil, labels: [String]? = nil, textViews: [String]? = nil , buttonCaption: String? = nil,
                    showIndicator: Bool? = false, animated: Bool? = true) {
        guard let view = vc.view else { return }
        cancelButtonDelegate = vc as? PopupVCDelegate
        var itemTop: CGFloat = indentBetweenItems
        if let image = image {
            let imageView = UIImageView(image: image)
            let imageWidth: CGFloat = 60
            imageView.frame = CGRect(x: (screenWidth - imageWidth) / 2 , y: indentBetweenItems, width: imageWidth, height: imageWidth)
            conteinerView.addSubview(imageView)
            itemTop += imageWidth + indentBetweenItems
        }
        if let textViews = textViews {
            for item in textViews {
                let label = addTextView(text: item, top: itemTop)
                conteinerView.addSubview(label)
                let currentItemTop = label.frame.height
                indicatorPositionForItems.append(itemTop + currentItemTop / 2)
                itemTop += currentItemTop + indentBetweenItems
            }
        }
        if let labels = labels {
            for item in labels {
                let label = addLabel(text: item, top: itemTop)
                conteinerView.addSubview(label)
                let currentItemTop = label.frame.height
                indicatorPositionForItems.append(itemTop + currentItemTop / 2)
                itemTop += currentItemTop + indentBetweenItems
            }
        }
        let button = addCancelButton(caption: buttonCaption ?? "Cancel", top: itemTop)
        conteinerView.addSubview(button)
        let viewHeight = itemTop + 70
        if viewHeight > screenHeight {
            let height = viewHeight < UIScreen.main.bounds.height - 100 ? viewHeight : UIScreen.main.bounds.height - 100
            self.frame = CGRect(x: 0, y: 0, width: screenWidth, height: height)
            self.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        }
        if itemTop + 70 > contentViewSize.height {
            contentViewSize = CGSize(width: self.frame.width, height: itemTop + 70)
            self.contentSize = contentViewSize
        }
        if let showIndicator = showIndicator, showIndicator  {
            activityIndicator.center = CGPoint(x: indentForIndicator / 2, y: indicatorPositionForItems[0])
            conteinerView.addSubview(activityIndicator)
        }
        show(view, animated: animated ?? true)
    }
    
    func show(_ view: UIView, animated: Bool) {
        let duration = 0.25
        mainView = view
        updateUIonMainThread { [weak self] in
            guard let self = self else { return }
            view.addSubview(self.fadeView)
            self.activityIndicator.startAnimating()
            if animated {
                UIView.transition(with: view, duration: duration, options: [.curveEaseIn], animations: { [weak self] in
                    guard let self = self else { return }
                    view.addSubview(self)
                    }, completion: nil)
                UIView.animate(withDuration: duration, animations: { [weak self] in
                    guard let self = self else { return }
                    
                    self.fadeView.alpha = 0.3
                    }, completion: nil)
                return
            }
            view.addSubview(self)
        }
    }
    
    func remove(animated: Bool) {
        updateUIonMainThread { [weak self] in
            guard let self = self else { return }
            self.clear()
            let duration = 0.25
            self.activityIndicator.stopAnimating()
            self.setContentOffset(.zero, animated: false)
            self.initSize()
            guard let mainView = self.mainView, animated else {
                self.fadeView.removeFromSuperview()
                self.removeFromSuperview()
                return
            }
            UIView.transition(with: mainView, duration: duration, options: [.transitionCrossDissolve], animations: { [weak self] in
                guard let self = self else { return }
                self.removeFromSuperview()
                }, completion: nil)
            UIView.animate(withDuration: duration, animations: { [weak self] in
                guard let self = self else { return }
                self.fadeView.alpha = 0
            }) { [weak self] _ in
                guard let self = self else { return }
                self.fadeView.removeFromSuperview()
            }
        }
    }
    
    func nextTaskForActivityIndicator() {
        let tasks = indicatorPositionForItems.count
        currentTask += 1
        if currentTask >= tasks {
            remove(animated: true)
            return
        }
        if indicatorPositionForItems[currentTask] > screenHeight {
            let bottomOffset = CGPoint(x: 0, y: indicatorPositionForItems[currentTask - 1])
            self.setContentOffset(bottomOffset, animated: true)
        }
        activityIndicator.center = CGPoint(x: indentForIndicator / 2, y: indicatorPositionForItems[currentTask])
    }
    
    func clear() {
        mainView = nil
        currentTask = 0
        indicatorPositionForItems = []
        for view in conteinerView.subviews {
            view.removeFromSuperview()
        }
    }
}
