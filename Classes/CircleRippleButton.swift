//
//  CircleRippleButton.swift
//  CircleRippleButton
//
//  Created by Chase Zhang on 5/20/15.
//  Copyright (c) 2015 io-meter. All rights reserved.
//

import UIKit

@IBDesignable
class CircleRippleButton: UIButton {
	
	@IBInspectable var circleRadius: CGFloat = 5.0
	@IBInspectable var rippleLineWidth: CGFloat = 1.0
	
	@IBInspectable var circleBorderWidth: CGFloat {
		get {
			return circleLayer.borderWidth
		}
		
		set (newWidth) {
			circleLayer.borderWidth = newWidth
		}
	}
	
	@IBInspectable var circleBackgroundColor: UIColor? {
		get {
			return UIColor(CGColor: circleLayer.backgroundColor)
		}
		
		set (newColor) {
			circleLayer.backgroundColor = newColor?.CGColor
		}
	}
	
	@IBInspectable var circleBorderColor: UIColor? {
		get {
			return UIColor(CGColor: circleLayer.borderColor)
		}
		
		set (newColor) {
			circleLayer.borderColor = newColor?.CGColor
		}
	}
	
	@IBInspectable var rippleStrokeColor: UIColor! = UIColor.blackColor()
	
	@IBInspectable var rippleOnAction: Bool = true
	
	@IBInspectable var rippleDuration: Float = 0.5
	
	private let circleLayer = CALayer()
	private let	ripplesLayer = CALayer()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
	}
	
	override func layoutSublayersOfLayer(layer: CALayer!) {
		super.layoutSublayersOfLayer(layer);
		
		if (layer == self.layer) {
			let cRadius = circleRadius ?? 5.0
			let maxRadius = min(bounds.width, bounds.height) / 2;
			let radius = min(cRadius, maxRadius)
			
			circleLayer.bounds = CGRectMake(0, 0, radius * 2, radius * 2)
			circleLayer.position = convertPoint(center, fromView: nil)
			circleLayer.cornerRadius = radius
			
			ripplesLayer.bounds = CGRectMake(0, 0, maxRadius * 2, maxRadius * 2)
			ripplesLayer.position = convertPoint(center, fromView: nil)
			
			if (circleLayer.superlayer == nil) {
				layer.addSublayer(circleLayer)
			}
			if (ripplesLayer.superlayer == nil) {
				layer.addSublayer(ripplesLayer)
			}
		}
	}
	
	override func sendAction(action: Selector, to target: AnyObject?, forEvent event: UIEvent?) {
		super.sendAction(action, to: target, forEvent: event)
		
		if (rippleOnAction) {
			addRipple()
		}
		
		fadeCircle()
	}
	
	func addRipple() {
		
		let circlePathFrame = CGRectMake(
			-circleRadius,
			-circleRadius,
			circleRadius * 2,
			circleRadius * 2)
		
		
		let ripplePath = UIBezierPath(roundedRect: circlePathFrame, cornerRadius: circleRadius).CGPath
		
		let rippleLayer = CAShapeLayer()
		rippleLayer.path = ripplePath
		rippleLayer.strokeColor = rippleStrokeColor.CGColor
		rippleLayer.lineWidth = rippleLineWidth
		rippleLayer.fillColor = nil
		rippleLayer.opacity = 0
		rippleLayer.position = convertPoint(center, fromView: nil)
		ripplesLayer.addSublayer(rippleLayer)
		
		let opacityAnimiation = CABasicAnimation(keyPath: "opacity")
		opacityAnimiation.fromValue = 1.0
		opacityAnimiation.toValue = 0.0
		
		let scaleAnimation = CABasicAnimation(keyPath: "path")
		let finalScale = min(self.frame.width, self.frame.height) * 0.5 / circleRadius
		var finalTransform = CGAffineTransformMakeScale(finalScale, finalScale)
		var finalPath = CGPathCreateCopyByTransformingPath(ripplePath, &finalTransform)
		scaleAnimation.fromValue = ripplePath
		scaleAnimation.toValue = finalPath
		
		let rippleAnimation = CAAnimationGroup()
		rippleAnimation.duration = CFTimeInterval(rippleDuration)
		rippleAnimation.animations = [opacityAnimiation, scaleAnimation]
		rippleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		
		CATransaction.setCompletionBlock { () -> Void in
			rippleLayer.removeFromSuperlayer()
		}
		rippleLayer.addAnimation(rippleAnimation, forKey: nil)
		
		CATransaction.commit()
	}
	
	func fadeCircle() {
		let circleAnimation = CABasicAnimation(keyPath: "opacity")
		circleAnimation.fromValue = 0.2
		circleAnimation.toValue = 1.0
		circleAnimation.duration = 0.4
		circleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		
		circleLayer.addAnimation(circleAnimation, forKey: nil)
	}
}
