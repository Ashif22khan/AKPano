//
//  ViewController.swift
//  AKPano
//
//  Created by Ashif Khan on 05/02/16.

import UIKit

class ViewController: UIViewController, PanoViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func loadView(){
        let panoView:PanoView=PanoView(frame:CGRectMake(0, 0, 768, 1024))
        self.view=panoView;
        panoView.delegate=self;
        panoView.setImages(UIImage(named:"one_ofront.jpg")!, i2: UIImage(named:"one_oright.jpg")!, i3: UIImage(named:"one_oback.jpg")!, i4: UIImage(named:"one_oleft.jpg")!, i5: UIImage(named:"one_oup.jpg")!, i6: UIImage(named:"one_odown.jpg")!)
        
        ///Uncomment this section of code to check how to add hotspot 
        
        /*let hotspot1:UILabel = UILabel.init(frame:CGRectMake(0, 0, 100, 25))
        hotspot1.backgroundColor=UIColor.clearColor()
        hotspot1.textColor=UIColor.redColor()
        hotspot1.text = "HP1"
        hotspot1.textAlignment = .Center
        hotspot1.shouldApplyPerspective = true;
        panoView.addHotspot(hotspot1, hAngle: 0, vAngle: 0)

        let hotspot2:UIView = UIView.init(frame: CGRectMake(0, 0, 100, 100))
        hotspot2.backgroundColor=UIColor.blueColor()
        hotspot2.alpha = 0.5;
        hotspot2.layer.cornerRadius = 25;
        hotspot2.shouldApplyPerspective = true;
        panoView.addHotspot(hotspot2, hAngle: Float(M_PI_4), vAngle: Float(M_PI_4))
        
        
        let hotspot3:UIButton = UIButton.init(type:.System)
        hotspot3.setTitle("HP2", forState: .Normal)
        hotspot3.frame = CGRectMake(0, 0, 100, 30)
        
        hotspot3.shouldApplyPerspective = true;
        hotspot3.addTarget(self, action: Selector("center:"), forControlEvents: .TouchUpInside)
        panoView.addHotspot(hotspot3, hAngle: Float(-M_PI_2), vAngle: Float(M_PI_4))
        
        let tapgr:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: Selector("tapped:"))
        hotspot2.addGestureRecognizer(tapgr)*/
    }
    /*func tapped(tapGR:UITapGestureRecognizer){
        print("I was tapped without mercy")
    }
    
    func center(sender:AnyObject){
        self.view!.hAngle = Float(-M_PI_2)
        self.view!.hAngle = Float(M_PI_4)
    }

    func panoViewDidEndZooming(panoView: PanoView) {
        
    }
    func panoViewDidZoom(panoView: PanoView) {
        
    }
    func panoViewWillBeginPanning(panoView: PanoView) {
        
    }
    func panoViewWillBeginZooming(panoView: PanoView) {
    }
    func panoViewDidPan(panoView: PanoView) {
        print("Panning happened!")
    }
    func panoViewDidEndPanning(panoView: PanoView) {
        print("Panning ended!")
    }*/

}

