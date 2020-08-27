//
//  RideHistoryTabUV.swift
//  PassengerApp
//
//  Created by ADMIN on 17/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class RideHistoryTabUV: PageTabBarController, PageTabBarControllerDelegate {
    
    let generalFunc = GeneralFunctions()
    
    var isOpenFromMainScreen = false
    var isFromUFXCheckOut = true
    
    override func viewWillAppear(_ animated: Bool) {
        self.configureRTLView()
    }
    
    open override func prepare() {
        super.prepare()
        
        delegate = self
        preparePageTabBar()
        
        self.addBackBarBtn()
        
        let userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        
//        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "Your trips", key: "LBL_YOUR_TRIPS")
//        self.title = self.generalFunc.getLanguageLabel(origValue: "Your trips", key: "LBL_YOUR_TRIPS")
        
        if(userProfileJson.get("APP_TYPE").uppercased() == Utils.cabGeneralType_Ride.uppercased()){
            self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "Your trips", key: "LBL_YOUR_TRIPS")
            self.title = self.generalFunc.getLanguageLabel(origValue: "Your trips", key: "LBL_YOUR_TRIPS")
        }else if(userProfileJson.get("APP_TYPE").uppercased() == "DELIVERY"){
            self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "Your deliveries", key: "LBL_YOUR_DELIVERY")
            self.title = self.generalFunc.getLanguageLabel(origValue: "Your deliveries", key: "LBL_YOUR_DELIVERY")
        }else{
            self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "Your bookings", key: "LBL_YOUR_BOOKING")
            self.title = self.generalFunc.getLanguageLabel(origValue: "Your bookings", key: "LBL_YOUR_BOOKING")
        }
        
        for i in 0..<self.viewControllers.count{
            if(self.viewControllers[i].isKind(of: RideHistoryUV.self)){
                let rideHistoryUv = self.viewControllers[i] as! RideHistoryUV
                rideHistoryUv.navItem = self.navigationItem
            }
        }
    }
    
    override func closeCurrentScreen() {
        
        if(isOpenFromMainScreen || isFromUFXCheckOut == true){
            GeneralFunctions.saveValue(key: "FROMCHECKOUT", value: true as AnyObject)
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            super.closeCurrentScreen()
        }
    }

    
    fileprivate func preparePageTabBar() {
        pageTabBar.lineColor = Color.UCAColor.AppThemeColor
    }
    
    func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController) {
//        print("pageTabBarController", pageTabBarController, "didTransitionTo viewController:", viewController)
    }
}
