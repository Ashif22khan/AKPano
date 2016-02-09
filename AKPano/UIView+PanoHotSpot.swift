//
//  UIView+PanoHotSpot.swift
//  AKPano
//
//  Created by Ashif Khan on 09/02/16.
//

import UIKit
import ObjectiveC

var kUIViewHotSpotPanoViewObjectKey:Character="c"
var kUIViewHotSpotShouldApplyPerspectiveObjectKey:Character = "c"
var kUIViewHotSpotHAngleObjectKey:Character = "c"
var kUIViewHotSpotVAngleObjectKey:Character = "c"


extension UIView{
    var panoView:PanoView?{
        set{
            objc_setAssociatedObject(self, &kUIViewHotSpotPanoViewObjectKey, panoView, .OBJC_ASSOCIATION_ASSIGN);
        }
        get{
            return objc_getAssociatedObject(self, &kUIViewHotSpotPanoViewObjectKey) as! PanoView?
        }
    }
    var shouldApplyPerspective:Bool{
        set{
            objc_setAssociatedObject(self, &kUIViewHotSpotShouldApplyPerspectiveObjectKey, "\(newValue)", .OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
        get{
            if objc_getAssociatedObject(self, &kUIViewHotSpotShouldApplyPerspectiveObjectKey) != nil {
                return objc_getAssociatedObject(self, &kUIViewHotSpotShouldApplyPerspectiveObjectKey).boolValue
            }
            return false
        }
    }
    var hAngle:Float{
        set{
            objc_setAssociatedObject(self, &kUIViewHotSpotHAngleObjectKey, "\(newValue)", .OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
        get{
            if objc_getAssociatedObject(self, &kUIViewHotSpotHAngleObjectKey) != nil {
                return objc_getAssociatedObject(self, &kUIViewHotSpotHAngleObjectKey).floatValue
            }
            return 0.0
        }
    }
    
    var vAngle:Float{
        set{
            objc_setAssociatedObject(self, &kUIViewHotSpotVAngleObjectKey, "\(newValue)", .OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
        get{
            if objc_getAssociatedObject(self, &kUIViewHotSpotVAngleObjectKey) != nil {
                return objc_getAssociatedObject(self, &kUIViewHotSpotVAngleObjectKey).floatValue
            }
            return 0.0
        }
    }
    
    
    func removeFromPanoView(){
        self.panoView?.removeHotspot(self)
    }
}