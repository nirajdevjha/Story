//
//  CSLoadingView.swift
//  Story
//
//  Created by Niraj Jha on 24/09/2018.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

let kLoadingViewOffset:CGFloat      = 50
class CSLoadingView: UIView {
    override var layer: CAShapeLayer {
        get {
            return super.layer as! CAShapeLayer
        }
    }
    
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.fillColor = nil
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 4
        setPath()
    }
    
    override func didMoveToWindow() {
        animate()
    }
    
    private func setPath() {
        layer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: layer.lineWidth / 2, dy: layer.lineWidth / 2)).cgPath
    }
    
    struct Pose {
        let secondsSincePriorPose: CFTimeInterval
        let start: CGFloat
        let length: CGFloat
        init(_ secondsSincePriorPose: CFTimeInterval, _ start: CGFloat, _ length: CGFloat) {
            self.secondsSincePriorPose = secondsSincePriorPose
            self.start = start
            self.length = length
        }
    }
    
    class var poses: [Pose] {
        get {
            return [
                Pose(0.0, 0.000, 0.7),
                Pose(0.6, 0.500, 0.5),
                Pose(0.6, 1.000, 0.3),
                Pose(0.6, 1.500, 0.1),
                Pose(0.2, 1.875, 0.1),
                Pose(0.2, 2.250, 0.3),
                Pose(0.2, 2.625, 0.5),
                Pose(0.2, 3.000, 0.7),
            ]
        }
    }
    
    func animate() {
        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var start: CGFloat = 0
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()
        
        let poses = type(of: self).poses
        let totalSeconds = poses.reduce(0) { $0 + $1.secondsSincePriorPose }
        
        for pose in poses {
            time += pose.secondsSincePriorPose
            times.append(time / totalSeconds)
            start = pose.start
            rotations.append(start * 2 * .pi)
            strokeEnds.append(pose.length)
        }
        
        times.append(times.last!)
        rotations.append(rotations[0])
        strokeEnds.append(strokeEnds[0])
        
        animateKeyPath(keyPath: "strokeEnd", duration: totalSeconds, times: times, values: strokeEnds)
        animateKeyPath(keyPath: "transform.rotation", duration: totalSeconds, times: times, values: rotations)
        
        animateStrokeHueWithDuration(duration: totalSeconds * 5)
    }
    
    func animateKeyPath(keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times as [NSNumber]?
        animation.values = values
        animation.calculationMode = kCAAnimationLinear
        animation.duration = duration
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
    
    func animateStrokeHueWithDuration(duration: CFTimeInterval) {
        let count = 1
        let animation = CAKeyframeAnimation(keyPath: "strokeColor")
        animation.keyTimes = (0 ... count).map { NSNumber(value: CFTimeInterval($0) / CFTimeInterval(count)) }
        animation.values = (0 ... count).map {_ in
            UIColor(red: 55/255, green: 78/255, blue: 196/255, alpha: 1.0).cgColor
        }
        animation.duration = duration
        animation.calculationMode = kCAAnimationLinear
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
}

extension CSLoadingView {
    class func show() {
        let window:UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let view = UIView.init(frame: window.bounds)
        
        let xAxis:CGFloat = view.frame.width/2 - 30
        let yAxis:CGFloat = view.frame.height/2 - 30
        
        let loadingView = CSLoadingView(frame: CGRect(x: xAxis, y: yAxis,
                                                      width: kLoadingViewOffset, height: kLoadingViewOffset))
        view.addSubview(loadingView)
        view.tag = 999
        
        window.addSubview(view)
    }
    
    class func hide() {
        let window:UIWindow = ((UIApplication.shared.delegate?.window)!)!
        for view in window.subviews {
            if view.tag == 999 {
                view.removeFromSuperview()
                break
            }
        }
    }
}



