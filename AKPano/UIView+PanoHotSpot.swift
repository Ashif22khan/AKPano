//
//  UIView+PanoHotSpot.swift
//  AKPano
//
//  Created by Ashif Khan on 09/02/16.
//

import UIKit
import ObjectiveC

var kUIViewPanoViewObjectKey:Character="c"
var kUIViewShouldApplyPerspectiveObjectKey:Character = "c"
var kUIViewHAngleObjectKey:Character = "c"
var kUIViewVAngleObjectKey:Character = "c"


extension UIView{
    var panoView:PanoView?{
        set{
            objc_setAssociatedObject(self, &kUIViewPanoViewObjectKey, panoView, .OBJC_ASSOCIATION_ASSIGN);
        }
        get{
            return objc_getAssociatedObject(self, &kUIViewPanoViewObjectKey) as! PanoView?
        }
    }
    var shouldApplyPerspective:Bool{
        set{
            objc_setAssociatedObject(self, &kUIViewShouldApplyPerspectiveObjectKey, "\(newValue)", .OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
        get{
            if objc_getAssociatedObject(self, &kUIViewShouldApplyPerspectiveObjectKey) != nil {
                return objc_getAssociatedObject(self, &kUIViewShouldApplyPerspectiveObjectKey).boolValue
            }
            return false
        }
    }
    var hAngle:Float{
        set{
            objc_setAssociatedObject(self, &kUIViewHAngleObjectKey, "\(newValue)", .OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
        get{
            if objc_getAssociatedObject(self, &kUIViewHAngleObjectKey) != nil {
                return objc_getAssociatedObject(self, &kUIViewHAngleObjectKey).floatValue
            }
            return 0.0
        }
    }
    
    var vAngle:Float{
        set{
            objc_setAssociatedObject(self, &kUIViewVAngleObjectKey, "\(newValue)", .OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
        get{
            if objc_getAssociatedObject(self, &kUIViewVAngleObjectKey) != nil {
                return objc_getAssociatedObject(self, &kUIViewVAngleObjectKey).floatValue
            }
            return 0.0
        }
    }
    
    
    func removeFromPanoView(){
        self.panoView?.removeHotspot(self)
    }
}