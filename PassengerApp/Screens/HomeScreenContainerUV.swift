//
//  HomeScreenContainerUV.swift
//  PassengerApp
//
//  Created by ADMIN on 30/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class HomeScreenContainerUV: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    var mainScreenUV:MainScreenUV!
    
    var isPageLoad = false
    
    var userProfileJson:NSDictionary!
    
    var deliveryTripId = ""
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.configureRTLView()
        
        if(mainScreenUV != nil && mainScreenUV.isDriverAssigned != true){
            self.navigationController?.navigationBar.isHidden = true
            
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        }
        
        if(deliveryTripId != ""){
            if(Configurations.isRTLMode()){
                self.navigationDrawerController?.isRightPanGestureEnabled = false
            }else{
                self.navigationDrawerController?.isLeftPanGestureEnabled = false
            }
        }else{
            if(Configurations.isRTLMode()){
                self.navigationDrawerController?.isRightPanGestureEnabled = true
            }else{
                self.navigationDrawerController?.isLeftPanGestureEnabled = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        if(Configurations.isRTLMode()){
            self.navigationDrawerController?.isRightPanGestureEnabled = false
        }else{
            self.navigationDrawerController?.isLeftPanGestureEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        
        let navHeight = self.navigationController!.navigationBar.frame.height
        let width = ((navHeight * 350) / 119)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: ((width * 119) / 350)))
        imageView.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_your_logo")
        imageView.image = image
        
        self.navigationItem.titleView = imageView
        
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_trans")!, style: UIBarButtonItem.Style.plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = rightButton
        
        if(userProfileJson.get("ONLYDELIVERALL") == "Yes")
        {
            let serviceCategoryArray = GeneralFunctions.getValue(key: Utils.SERVICE_CATEGORY_ARRAY) as! NSArray
            if serviceCategoryArray.count > 1
            {
            }else
            {
                GeneralFunctions.saveValue(key: Utils.SERVICE_CATEGORY_ID, value: (serviceCategoryArray[0] as! NSDictionary).get("iServiceId") as AnyObject)
            }
        }else
        {
            if(userProfileJson.get("APP_TYPE").uppercased() == "UBERX" || userProfileJson.get("APP_TYPE").uppercased() == Utils.cabGeneralType_Ride_Delivery_UberX.uppercased()) {
                
                if userProfileJson.getObj("TripDetails").get("eType") == "Multi-Delivery" && deliveryTripId == ""
                {
                    self.loadAdvertisementView()
                    NotificationCenter.default.addObserver(self, selector: #selector(self.releaseAllTask), name: NSNotification.Name(rawValue: Utils.releaseAllTaskObserverKey), object: nil)
                    return
                }
                
                let vTripStatus = userProfileJson.get("vTripStatus")
                if((vTripStatus == "Active" || vTripStatus == "On Going Trip") && userProfileJson.getObj("TripDetails").get("eType").uppercased() != "UBERX"){
                    mainScreenUV = (GeneralFunctions.instantiateViewController(pageName: "MainScreenUV") as! MainScreenUV)
                    mainScreenUV.view.frame = self.containerView.frame
                    mainScreenUV.liveTrackTripId = self.deliveryTripId
                    mainScreenUV.navItem = self.navigationItem
                    
                    self.addChild(mainScreenUV)
                    self.addSubview(subView: mainScreenUV.view, toView: self.containerView)
                }else{

                }
            }else if(userProfileJson.get("APP_TYPE").uppercased() == "DELIVERY" || userProfileJson.get("APP_TYPE").uppercased() == "RIDE-DELIVERY" || userProfileJson.get("APP_TYPE").uppercased() == Utils.cabGeneralType_Deliver.uppercased()){
                
                if userProfileJson.getObj("TripDetails").get("eType") == "Multi-Delivery" && deliveryTripId == ""
                {
                    self.loadAdvertisementView()
                    NotificationCenter.default.addObserver(self, selector: #selector(self.releaseAllTask), name: NSNotification.Name(rawValue: Utils.releaseAllTaskObserverKey), object: nil)
                    return
                }
                
                let vTripStatus = userProfileJson.get("vTripStatus")
                if((vTripStatus == "Active" || vTripStatus == "On Going Trip") && userProfileJson.getObj("TripDetails").get("eType").uppercased() != "UBERX"){
                    mainScreenUV = (GeneralFunctions.instantiateViewController(pageName: "MainScreenUV") as! MainScreenUV)
                    mainScreenUV.view.frame = self.containerView.frame
                    mainScreenUV.liveTrackTripId = self.deliveryTripId
                    mainScreenUV.navItem = self.navigationItem
                    
                    self.addChild(mainScreenUV)
                    self.addSubview(subView: mainScreenUV.view, toView: self.containerView)
                }else{
                    
                    if(userProfileJson.get("PACKAGE_TYPE").uppercased() == "STANDARD" && userProfileJson.get("APP_TYPE").uppercased() != "RIDE-DELIVERY"){
                        mainScreenUV = (GeneralFunctions.instantiateViewController(pageName: "MainScreenUV") as! MainScreenUV)
                        mainScreenUV.view.frame = self.containerView.frame
                        mainScreenUV.navItem = self.navigationItem
                        mainScreenUV.liveTrackTripId = self.deliveryTripId
                        
                        self.addChild(mainScreenUV)
                        self.addSubview(subView: mainScreenUV.view, toView: self.containerView)
                    }else{
                    }
                }
            }else{
                
                mainScreenUV = (GeneralFunctions.instantiateViewController(pageName: "MainScreenUV") as! MainScreenUV)
                mainScreenUV.view.frame = self.containerView.frame
                mainScreenUV.navItem = self.navigationItem
                mainScreenUV.liveTrackTripId = self.deliveryTripId
                
                self.addChild(mainScreenUV)
                self.addSubview(subView: mainScreenUV.view, toView: self.containerView)
            }
        }
        
        self.loadAdvertisementView()
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.releaseAllTask), name: NSNotification.Name(rawValue: Utils.releaseAllTaskObserverKey), object: nil)
       
    }
    
    func loadAdvertisementView(){
        /* Load AdvertisementView */
        let advDataDic = userProfileJson.get("advertise_banner_data")
        let dataDict = advDataDic.getJsonDataDict()
        if (userProfileJson.get("ENABLE_RIDER_ADVERTISEMENT_BANNER").uppercased() == "YES" && dataDict.get("image_url") != "" && deliveryTripId == ""){
            
            let userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
            let advDataDic = userProfileJson.get("advertise_banner_data")
            let dataDict = advDataDic.getJsonDataDict()
            var width:CGFloat = 0.0
            let wi = GeneralFunctions.parseDouble(origValue: 0.0, data: dataDict.get("vImageWidth"))
            width = CGFloat.init(wi) / UIScreen.main.scale
            
            var height:CGFloat = 0.0
            let hi = GeneralFunctions.parseDouble(origValue: 0.0, data: dataDict.get("vImageHeight"))
            height = CGFloat.init(hi) / UIScreen.main.scale
            
            if(width < 100){
                width = 100.0
            }
            
            if (height < 100){
                height = 100
            }
            let bgView = UIView()
            bgView.frame = CGRect(x:0, y:0, width: Application.screenSize.width, height: Application.screenSize.height)
            bgView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            Application.keyWindow!.addSubview(bgView)
            Application.keyWindow!.addSubview(AdvertisementView.init(withImgUrlString: dataDict.get("image_url"), withRedirectUrlString: dataDict.get("tRedirectUrl"), vImageWidth: width, vImageHeight: height, bgView: bgView))
        }
        /* Load AdvertisementView */
    }
    
    func openMenu(){
        if(Configurations.isRTLMode()){
            self.navigationDrawerController?.toggleRightView()
        }else{
            self.navigationDrawerController?.toggleLeftView()
        }
    }
    
    deinit {
//        print("HomeDeinit")
    }
    
    @objc func releaseAllTask(){
        if(mainScreenUV == nil){
            return
        }
//        print("HomeScreenReleased")
        mainScreenUV.getAddressFrmLocation?.addressFoundDelegate = nil
        mainScreenUV.getAddressFrmLocation = nil
        
        mainScreenUV.gMapView?.clear()
        mainScreenUV.gMapView?.delegate = nil
        mainScreenUV.gMapView?.removeFromSuperview()
        mainScreenUV.gMapView = nil
        
        mainScreenUV.releaseAllTask()
        mainScreenUV.view.removeFromSuperview()
        mainScreenUV.removeFromParent()
        mainScreenUV.dismiss(animated: true, completion: nil)
        
        mainScreenUV = nil
        
        GeneralFunctions.removeObserver(obj: self)
        
        self.navigationDrawerController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isPageLoad == false){
            
            if(mainScreenUV != nil){
                mainScreenUV.view.frame = self.containerView.frame
            }
            
            isPageLoad = true
        }
    }
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addSubview(subView:UIView, toView parentView:UIView) {
        
        subView.frame = parentView.frame
        subView.center = CGPoint(x: parentView.bounds.midX, y: parentView.bounds.midY)
        
        parentView.addSubview(subView)
    }


}
