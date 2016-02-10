//
//  PanoView.swift
//  AKPano
//
//  Created by Ashif Khan on 08/02/16.

import UIKit
import CoreMotion

// MARK: PanoViewDelegate
@objc protocol PanoViewDelegate{
    optional func panoViewDidPan(panoView:PanoView)
    optional func panoViewDidZoom(panoView:PanoView)
    optional func panoViewWillBeginPanning(panoView:PanoView)
    optional func panoViewWillBeginZooming(panoView:PanoView)
    optional func panoViewDidEndPanning(panoView:PanoView)
    optional func panoViewDidEndZooming(panoView:PanoView)
}

// MARK: PanoView
class PanoView: UIView {
    
    // MARK: Properties
    
    var imageOne:UIImageView?, imageTwo:UIImageView?,
        imageThree:UIImageView?, imageFour:UIImageView?,
        imageFive:UIImageView?, imageSix:UIImageView?
    
    var _referenceSide:Float=0
    var _previousZoomFactor:Float=0
    var _leftLimit:Float=0, _rightLimit:Float=0,
        _upLimit:Float = Float(M_PI_2), _downLimit:Float = Float(M_PI_2)
    var _minZoom:Float=0, _maxZoom:Float=100
    
    var _hotspots:Array<UIView>?;

    var _zoomFactor:Float = 0
    var zoomFactor:Float{
        set{
            var val = newValue
            let minFactor=(_minZoom * 3.5 / 100.0) + 0.5;
            let maxFactor=(_maxZoom * 3.5 / 100.0) + 0.5;
            if (newValue > maxFactor) {
                val = maxFactor;
            }else if (newValue<minFactor) {
                val = minFactor;
            }
            _zoomFactor = val * _referenceSide;
            self.render()
        }
        get{
            return _zoomFactor/_referenceSide;
        }
    }
    
    var _hAngle:Float = 0
    override var hAngle:Float{
        set{
            _hAngle = newValue
            self.render()
        }
        get{
            return _hAngle
        }
    }
    
    var _vAngle:Float = 0
    override var vAngle:Float{
        set{
            _vAngle = newValue
            self.render()
        }
        get{
            return _vAngle
        }
    }
    
    var _delegate:PanoViewDelegate?
    var delegate:PanoViewDelegate?{
        set{
            _delegate = newValue
        }
        get{
            return _delegate
        }
    }
    
    var _panEnabled:Bool=true
    var panEnabled:Bool{
        set{
            _panGestureRecognizer!.enabled = newValue
            self.render()
        }
        get{
            return _panGestureRecognizer!.enabled
        }
    }
    
    var _zoomEnabled:Bool=true
    var zoomEnabled:Bool{
        set{
            _pinchGestureRecognizer!.enabled = newValue
            self.render()
        }
        get{
            return _pinchGestureRecognizer!.enabled
        }
    }
    
    var _pinchGestureRecognizer:UIPinchGestureRecognizer?;
    var pinchGestureRecognizer:UIPinchGestureRecognizer{
        set{
            _pinchGestureRecognizer = newValue
        }
        get{
            return _pinchGestureRecognizer!
        }
    }
    
    var _panGestureRecognizer:UIPanGestureRecognizer?;
    var panGestureRecognizer:UIPanGestureRecognizer{
        set{
            _panGestureRecognizer = newValue
        }
        get{
            return _panGestureRecognizer!
        }
    }
    
    // MARK: Gyroscopic updates
    var _gyroUpdateFreequency:NSTimeInterval = 0.03
    var gyroUpdateFreequency:NSTimeInterval{
        set{
            _gyroUpdateFreequency = newValue
            _motionManager?.gyroUpdateInterval = newValue
        }
        get{
            return _gyroUpdateFreequency
        }
    }
    
    var _motionManager:CMMotionManager?
    var _enableGyroMotion:Bool=false
    var enableGyroUpdates:Bool{
        set{
            _enableGyroMotion = newValue
            if newValue {
                _motionManager = CMMotionManager.init();
                _motionManager!.accelerometerUpdateInterval = gyroUpdateFreequency
                _motionManager!.startGyroUpdatesToQueue(NSOperationQueue.mainQueue(),
                    withHandler:{(gyroData:CMGyroData?, error:NSError?)->Void in
                        self.doGyroUpdate()
                })
            }else{
                _motionManager?.stopGyroUpdates()
                _motionManager=nil
            }
        }
        get{
            return _enableGyroMotion
        }
    }
    
    func doGyroUpdate() {
        let x:Float = Float((_motionManager?.gyroData!.rotationRate.x)!)
        let y:Float = Float((_motionManager?.gyroData!.rotationRate.y)!)
        var newHAngle:Float = self.hAngle+(x/(_zoomFactor/10));
        var newVAngle:Float = self.vAngle+(y/(_zoomFactor/10));
        
        if newHAngle > 0.0 && _rightLimit != 0.0 {
            if newHAngle > _rightLimit {
                newHAngle = _rightLimit;
            }
        }else if newHAngle < 0.0 && _leftLimit != 0.0 {
            if newHAngle < (-_leftLimit) {
                newHAngle = -_leftLimit;
            }
        }
        if newVAngle > 0.0 && _upLimit != 0.0 {
            if newVAngle > _upLimit {
                newVAngle = _upLimit;
            }
        }else if newVAngle < 0 && _downLimit != 0 {
            if newVAngle < (-_downLimit) {
                newVAngle = -_downLimit;
            }
        }
        _hAngle = newHAngle
        _vAngle = newVAngle
        self.render()
    }
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.defaultValues()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.defaultValues()
    }
    
    func defaultValues(){
        _hotspots=Array<UIView>()
        if (self.bounds.size.width>self.bounds.size.height) {
            _referenceSide  =  Float(self.bounds.size.width) / 2;
        }else {
            _referenceSide = Float(self.bounds.size.height) / 2;
        }
        let rect:CGRect = CGRectMake(0, 0, CGFloat(_referenceSide*2), CGFloat(_referenceSide*2))
        
        // Initialization code.
        self.imageOne=UIImageView(frame: rect)
        self.imageTwo=UIImageView(frame: rect)
        self.imageThree=UIImageView(frame: rect)
        self.imageFour=UIImageView(frame: rect)
        self.imageFive=UIImageView(frame: rect)
        self.imageSix=UIImageView(frame: rect)
        let centerPoint:CGPoint=CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        self.imageOne!.center=centerPoint;
        self.imageTwo!.center=centerPoint;
        self.imageThree!.center=centerPoint;
        self.imageFour!.center=centerPoint;
        self.imageFive!.center=centerPoint;
        self.imageSix!.center=centerPoint;
        
        self.imageOne!.contentMode = .ScaleToFill
        self.imageTwo!.contentMode = .ScaleToFill
        self.imageThree!.contentMode = .ScaleToFill
        self.imageFour!.contentMode = .ScaleToFill
        self.imageFive!.contentMode = .ScaleToFill
        self.imageSix!.contentMode = .ScaleToFill
        
        
        self.addSubview(self.imageOne!)
        self.addSubview(self.imageTwo!)
        self.addSubview(self.imageThree!)
        self.addSubview(self.imageFour!)
        self.addSubview(self.imageFive!)
        self.addSubview(self.imageSix!)
        _zoomFactor=_referenceSide
        _hAngle=0
        _vAngle=0
        _leftLimit=0;
        _rightLimit=0;
        _upLimit=Float(M_PI_2)
        _downLimit=Float(M_PI_2)
        _minZoom=0
        _maxZoom=100
        self.userInteractionEnabled=true
        let panGR=UIPanGestureRecognizer(target: self, action: "didPan:")
        self.addGestureRecognizer(panGR)
        self.panGestureRecognizer=panGR;
        
        let pinchGR=UIPinchGestureRecognizer(target: self, action: "didPinch:")
        self.addGestureRecognizer(pinchGR)
        self.pinchGestureRecognizer=pinchGR;
    }
    
    func setImages(i1:UIImage, i2:UIImage, i3:UIImage, i4:UIImage, i5:UIImage, i6:UIImage){
        self.imageOne?.image=i1;
        self.imageTwo?.image=i2;
        self.imageThree?.image=i3;
        self.imageFour?.image=i4;
        self.imageFive?.image=i5;
        self.imageSix?.image=i6;
    }
    
    override func layoutSubviews(){
        let tempZoomFactor:Float=self.zoomFactor
        if (self.bounds.size.width>self.bounds.size.height) {
            _referenceSide = Float(self.bounds.size.width)/2
        }else {
            _referenceSide = Float(self.bounds.size.height)/2
        }
        //recalculate zoomFactor as a function of dim
        self.zoomFactor=tempZoomFactor
        let rect:CGRect = CGRectMake(0, 0, CGFloat(_referenceSide*2), CGFloat(_referenceSide*2))
        
        // Initialization code.
        self.imageOne?.frame = rect
        self.imageTwo?.frame = rect
        self.imageThree?.frame = rect
        self.imageFour?.frame = rect
        self.imageFive?.frame = rect
        self.imageSix?.frame = rect
        
        
        let centerPoint:CGPoint=CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        self.imageOne!.center=centerPoint;
        self.imageTwo!.center=centerPoint;
        self.imageThree!.center=centerPoint;
        self.imageFour!.center=centerPoint;
        self.imageFive!.center=centerPoint;
        self.imageSix!.center=centerPoint;
        self.render()
    }

    // MARK: Rendering
    func render(){
        var transform3D:CATransform3D = CATransform3DIdentity
        
        var tempHAngle = _hAngle
        var tempVAngle = _vAngle
        transform3D = CATransform3DIdentity;
        transform3D.m34 = CGFloat(1.0 / -_zoomFactor)
        transform3D=CATransform3DTranslate(transform3D,
									   CGFloat(_referenceSide*sinf(-tempHAngle)),
									   CGFloat(-_referenceSide*cosf(-tempHAngle)*sinf(-tempVAngle)),
									   CGFloat(-(_referenceSide*cosf(-tempHAngle)*cosf(-tempVAngle)-_zoomFactor))
        );
        transform3D=CATransform3DRotate(transform3D, CGFloat(tempHAngle), 0, 1, 0);
        imageOne!.layer.transform=CATransform3DRotate(transform3D, CGFloat(tempVAngle), CGFloat(cosf(tempHAngle)), 0, CGFloat(sinf(tempHAngle)))
        
        tempHAngle = _hAngle - Float(M_PI/2)
        tempVAngle = _vAngle
        transform3D = CATransform3DIdentity
        transform3D.m34 = CGFloat(1.0 / -_zoomFactor)
        transform3D=CATransform3DTranslate(transform3D,
									   CGFloat(_referenceSide*sinf(-tempHAngle)),
									   CGFloat(-_referenceSide*cosf(-tempHAngle)*sinf(-tempVAngle)),
									   CGFloat(-(_referenceSide*cosf(-tempHAngle)*cosf(-tempVAngle)-_zoomFactor)))
        transform3D=CATransform3DRotate(transform3D, CGFloat(tempHAngle), 0, 1, 0);
        imageTwo!.layer.transform=CATransform3DRotate(transform3D, CGFloat(tempVAngle), CGFloat(cosf(tempHAngle)), 0, CGFloat(sinf(tempHAngle)))
        
        tempHAngle = _hAngle - Float(M_PI)
        tempVAngle = _vAngle
        transform3D = CATransform3DIdentity
        transform3D.m34 = CGFloat(1.0 / -_zoomFactor);
        transform3D=CATransform3DTranslate(transform3D,
									   CGFloat(_referenceSide*sinf(-tempHAngle)),
									   CGFloat(-_referenceSide*cosf(-tempHAngle)*sinf(-tempVAngle)),
									   CGFloat(-(_referenceSide*cosf(-tempHAngle)*cosf(-tempVAngle)-_zoomFactor)))
        transform3D=CATransform3DRotate(transform3D, CGFloat(tempHAngle), 0, 1, 0);
        imageThree!.layer.transform=CATransform3DRotate(transform3D, CGFloat(tempVAngle), CGFloat(cosf(tempHAngle)), 0, CGFloat(sinf(tempHAngle)))
        
        tempHAngle = _hAngle - Float(3*M_PI/2)
        tempVAngle = _vAngle
        transform3D = CATransform3DIdentity
        transform3D.m34 = CGFloat(1.0 / -_zoomFactor)
        transform3D=CATransform3DTranslate(transform3D,
									   CGFloat(_referenceSide*sinf(-tempHAngle)),
									   CGFloat(-_referenceSide*cosf(-tempHAngle)*sinf(-tempVAngle)),
									   CGFloat(-(_referenceSide*cosf(-tempHAngle)*cosf(-tempVAngle)-_zoomFactor)))
        transform3D=CATransform3DRotate(transform3D, CGFloat(tempHAngle), 0, 1, 0);
        imageFour!.layer.transform=CATransform3DRotate(transform3D, CGFloat(tempVAngle), CGFloat(cosf(tempHAngle)), 0, CGFloat(sinf(tempHAngle)))
        
        tempHAngle = _hAngle;
        tempVAngle = _vAngle - Float(M_PI/2)
        transform3D = CATransform3DIdentity;
        transform3D.m34 = CGFloat(1.0 / -_zoomFactor)
        transform3D=CATransform3DTranslate(transform3D,
									   0,
									   CGFloat(-_referenceSide*sinf(-tempVAngle)),
									   CGFloat(-(_referenceSide*cosf(-tempVAngle)-_zoomFactor)))
        
        transform3D=CATransform3DRotate(transform3D, CGFloat(tempVAngle), 1,0,0)
        imageFive!.layer.transform=CATransform3DRotate(transform3D, CGFloat(tempHAngle), 0, 0, 1)
        
        tempHAngle = _hAngle;
        tempVAngle = _vAngle + Float(M_PI/2);
        transform3D = CATransform3DIdentity;
        transform3D.m34 = CGFloat(1.0 / -_zoomFactor)
        transform3D = CATransform3DTranslate(transform3D,
									   0,
									   CGFloat(-_referenceSide*sinf(-tempVAngle)),
									   CGFloat(-(_referenceSide*cosf(-tempVAngle)-_zoomFactor)))
        
        transform3D=CATransform3DRotate(transform3D, CGFloat(tempVAngle), 1,0,0);
        imageSix!.layer.transform=CATransform3DRotate(transform3D, CGFloat(-tempHAngle), 0, 0, 1)
        
        let hotspotReference:CGFloat=CGFloat(_referenceSide)
        for hotspot in _hotspots! {
            tempHAngle=hotspot.hAngle;
            tempVAngle=hotspot.vAngle;
            
            var x:CGFloat = CGFloat(sinf(tempHAngle) * cosf(tempVAngle))
            var y:CGFloat = CGFloat(sinf(tempVAngle))
            var z:CGFloat = CGFloat(cosf(tempVAngle) * cosf(tempHAngle))
        
            
            var transformedPoint:CGPoint=CGPointApplyAffineTransform(CGPointMake(x, z), CGAffineTransformMakeRotation(CGFloat(_hAngle)))
            x=transformedPoint.x
            z=transformedPoint.y
            transformedPoint=CGPointApplyAffineTransform(CGPointMake(z, y), CGAffineTransformMakeRotation(CGFloat(-_vAngle)))
            y=transformedPoint.y;
            z=transformedPoint.x;
            
            transform3D = CATransform3DIdentity;
            transform3D.m34 = CGFloat(1.0 / -_zoomFactor)
            transform3D=CATransform3DTranslate(transform3D,
                hotspotReference*x,
                -(hotspotReference*y),
                -((hotspotReference)*z-CGFloat(_zoomFactor))
            );
            if (hotspot.shouldApplyPerspective) {
                transform3D=CATransform3DRotate(transform3D, CGFloat(_hAngle), 0, 1, 0);
                transform3D=CATransform3DRotate(transform3D, CGFloat(_vAngle), CGFloat(cosf(_hAngle)), 0, CGFloat(sinf(_hAngle)))
                transform3D=CATransform3DRotate(transform3D, CGFloat(-hotspot.hAngle), 0, 1, 0);
                transform3D=CATransform3DRotate(transform3D, CGFloat(-hotspot.vAngle), 1, 0, 0);
            }
            hotspot.layer.transform=transform3D;
        }
    }
    
    // MARK: Gesture recognizer start
    
    func didPan(gestureRecognizer:UIPanGestureRecognizer ){
        if gestureRecognizer.state == .Began && _delegate!.panoViewWillBeginPanning != nil{
            _delegate?.panoViewWillBeginPanning!(self)
        }
        if gestureRecognizer.state == .Began ||
            gestureRecognizer.state == .Changed {
            let translation:CGPoint=gestureRecognizer.translationInView(self)
            var newHAngle = self.hAngle - (Float(translation.x)/(_zoomFactor/1.5))
            var newVAngle = self.vAngle + (Float(translation.y)/(_zoomFactor/1.5))
            if newHAngle > 0.0 && _rightLimit != 0.0 {
                if newHAngle > _rightLimit {
                    newHAngle = _rightLimit
                }
            }else if newHAngle < 0.0 && _leftLimit != 0.0 {
                // negative angle to the left, but limit is always positive (absolute value)
                if newHAngle < (-_leftLimit) {
                    newHAngle = -_leftLimit
                }
            }
            if newVAngle > 0.0 && _upLimit != 0.0 {
                if newVAngle > _upLimit {
                    newVAngle=_upLimit
                }
            }else if newVAngle < 0.0 && _downLimit != 0.0 {
                // negative angle to the bottom, but limit is always positive (absolute value)
                if newVAngle < (-_downLimit) {
                    newVAngle = -_downLimit
                }
            }
            _hAngle = newHAngle
            _vAngle = newVAngle
            self.render()
            gestureRecognizer.setTranslation(CGPointZero, inView:self)
            if _delegate!.panoViewDidPan != nil {
                _delegate?.panoViewDidPan!(self)
            }
        }
        if gestureRecognizer.state == .Ended && _delegate!.panoViewDidEndPanning != nil{
            _delegate?.panoViewDidEndPanning!(self)
        }
    }
    
    func didPinch(gestureRecognizer:UIPinchGestureRecognizer){
        if gestureRecognizer.state == .Began{
            _previousZoomFactor = self.zoomFactor
            if _delegate!.panoViewWillBeginZooming != nil {
                _delegate?.panoViewWillBeginZooming!(self)
            }
        }
        if gestureRecognizer.state == .Began ||
            gestureRecognizer.state == .Changed {
            let newFactor = _previousZoomFactor * Float(gestureRecognizer.scale);
            self.zoomFactor = newFactor;
            if _delegate!.panoViewDidZoom != nil {
                _delegate?.panoViewDidZoom!(self)
            }
        }
        if gestureRecognizer.state == .Ended && _delegate!.panoViewDidEndZooming != nil{
            _delegate?.panoViewDidEndZooming!(self)
        }
    }
    // MARK: Gesture recognizer end
    
    // MARK: Hotspot handlers start
    func addHotspot(hotspotView:UIView, hAngle:Float, vAngle:Float){
        hotspotView.removeFromPanoView()
        hotspotView.panoView = self
        hotspotView.hAngle = hAngle
        hotspotView.vAngle = vAngle
        _hotspots?.append(hotspotView)
        self.addSubview(hotspotView)
    }
    
    func removeHotspot(hotspot:UIView){
        if hotspot.panoView == self {
            hotspot.removeFromSuperview()
            _hotspots?.removeAtIndex((_hotspots?.indexOf(hotspot))!)
            hotspot.panoView=nil;
        }
    }
    // MARK: Hotspot handlers end
}
