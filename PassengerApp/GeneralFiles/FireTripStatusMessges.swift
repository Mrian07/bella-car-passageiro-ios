//
//  FireTripStatusMessges.swift
//  PassengerApp
//
//  Created by Tarwinder Singh on 18/12/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit
import GoogleMaps
import AVFoundation
import GoogleSignIn
import Firebase
import Fabric
import Crashlytics
import IQKeyboardManagerSwift
import FBSDKCoreKit
import TwitterCore
import TwitterKit

class FireTripStatusMessges: NSObject {
    
    var isFromPubSub = false
    let generalFunc = GeneralFunctions()
    
    var mainScreenUv:MainScreenUV!
    
    var iDriverId = ""
    var liveTripId = ""
    
    func fireTripMsg(_ messageStr:String, _ isFromPubSub:Bool){
        self.isFromPubSub = isFromPubSub
        
        let result = messageStr.getJsonDataDict()
        
        if(result.count != 0){
            let isMsgExist = GeneralFunctions.isTripStatusMsgExist(msgDataDict: result, isFromPubSub: isFromPubSub)
            
            Utils.printLog(msgData: "isMsgExist:\(isMsgExist)")
            if(isMsgExist == true){
                return
            }
        
        var viewController = Application.window != nil ? (Application.window!.rootViewController != nil ? (Application.window!.rootViewController!) : nil) : nil
        
        if(viewController != nil){
            viewController = GeneralFunctions.getVisibleViewController(viewController, isCheckAll: true)
        }
        if(viewController != nil && viewController!.isKind(of: MainScreenUV.self)){
            self.mainScreenUv = (viewController as! MainScreenUV)
        }else if(viewController != nil && viewController!.navigationController != nil){
            for i in 0..<viewController!.navigationController!.viewControllers.count{
                let currentViewCOntroller = viewController!.navigationController!.viewControllers[i]
                
                if(currentViewCOntroller.isKind(of: MainScreenUV.self)){
                    self.mainScreenUv = (currentViewCOntroller as! MainScreenUV)
                    break
                }
            }
        }
        
        if(viewController?.navigationController != nil && viewController?.navigationController!.viewControllers.count == 1){
//            viewController = nil
        }
        
        let msg_str = result.get("Message")
        let msg_pub_str = result.get("MsgType")
        
        if(msg_pub_str != "" && msg_pub_str == "CHAT"){
            
            if(Application.window != nil && Application.window?.rootViewController != nil){
                if(GeneralFunctions.getVisibleViewController(Application.window!.rootViewController) != nil && GeneralFunctions.getVisibleViewController(GeneralFunctions.getVisibleViewController(nil, isCheckAll: true), isCheckAll: true)?.className != "ChatUV"){
                    
                    self.manageChatScreen(notification: result)
                    return
                    
                }else if(GeneralFunctions.getVisibleViewController(GeneralFunctions.getVisibleViewController(nil, isCheckAll: true), isCheckAll: true)?.className == "ChatUV"){
                    
                    if GeneralFunctions.getValue(key: "ChatAssignedtripId") as! String != result.get("iTripId")
                    {
                        GeneralFunctions.getVisibleViewController(nil, isCheckAll: true)?.dismiss(animated: false, completion: {self.manageChatScreen(notification: result)})
                        
                        return
                    }
                    
                }
            }
            return
        }
        
        let eType = result.get("eType")
        var contentMsg = result.get("vTitle")
        let driverName = result.get("driverName")
        let vRideNo = result.get("vRideNo")
        let iTripId = result.get("iTripId")
        
            // For Cubjek Only
        if(msg_pub_str == "LocationUpdate"){
            let iDriverId = result.get("iDriverId")
            let vLatitude = result.get("vLatitude")
            let vLongitude = result.get("vLongitude")
            
            DispatchQueue.main.async {
                self.mainScreenUv?.updateDriverLocationBeforeTrip(iDriverId: iDriverId, latitude: vLatitude, longitude: vLongitude, dataDict: result)
            }
            
        }else if(msg_pub_str == "TripRequestCancel"){
            self.mainScreenUv?.incCountOfRequestToDriver()
            
        }else if(msg_pub_str == "LocationUpdateOnTrip"){
            let iDriverId = result.get("iDriverId")
            let vLatitude = result.get("vLatitude")
            let vLongitude = result.get("vLongitude")
            
            if(self.mainScreenUv != nil){
                DispatchQueue.main.async {
                    self.mainScreenUv?.updateDriverLocation(iDriverId: iDriverId, latitude: vLatitude, longitude: vLongitude, dataDict: result)
                }
            }
            
        }else if(msg_pub_str == "DriverArrived"){
            
            if(eType == Utils.cabGeneralType_UberX){
                if(contentMsg == ""){
                    contentMsg = "\(generalFunc.getLanguageLabel(origValue: "", key: "LBL_DELIVERY_DRIVER_TXT")) \(driverName)  \(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DRIVER_ARRIVED_NOTIMSG")) \(vRideNo)"
                }
                self.generalFunc.setAlertMessage(uv: viewController, title: "", content: contentMsg, positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                    
                })
            }else{
                if(contentMsg == ""){
                    if(eType == Utils.cabGeneralType_Ride){
                        contentMsg = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DRIVER_ARRIVED_TXT")
                    }else{
                        contentMsg = "\(generalFunc.getLanguageLabel(origValue: "", key: "LBL_DELIVERY_DRIVER_TXT")) \(driverName)  \(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DRIVER_ARRIVED_NOTIMSG")) \(vRideNo)"
                    }
                }
                self.generalFunc.setAlertMessage(uv: viewController, title: "", content: contentMsg, positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                    
                })
            }
            
            if(self.mainScreenUv != nil && eType != Utils.cabGeneralType_UberX){
                DispatchQueue.main.async {
                    self.mainScreenUv?.setDriverArrivedStatus()
                }
            }
            
        }else if(msg_str != ""){
            
            if(msg_str == "TripStarted"){
                if(contentMsg == ""){
                    if(eType == Utils.cabGeneralType_Ride){
                        contentMsg = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_START_TRIP_DIALOG_TXT")
                    }else{
                        contentMsg = "\(generalFunc.getLanguageLabel(origValue: "", key: "LBL_DELIVERY_DRIVER_TXT")) \(driverName)  \(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DRIVER_START_NOTIMSG")) \(vRideNo)"
                    }
                }
                self.generalFunc.setError(uv: viewController, title: "", content:  contentMsg)
                
            }else if(msg_str == "TripCancelledByDriver" || msg_str == "TripEnd"){
                if(contentMsg == ""){
                    
                    if(msg_str == "TripCancelledByDriver"){
                        contentMsg = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PREFIX_TRIP_CANCEL_DRIVER") + " " + result.get("Reason") + " " + self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_TRIP_BY_DRIVER_MSG_SUFFIX")
                        
                    }else{
                        if(eType == Utils.cabGeneralType_Ride){
                            contentMsg = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_END_TRIP_DIALOG_TXT")
                        }else{
                            contentMsg = "\(driverName) \(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DRIVER_END_NOTIMSG")) \(vRideNo)"
                        }
                    }
                }
                
                if(eType != Utils.cabGeneralType_UberX){
                    
                    if(eType != "Multi-Delivery")
                    {
                        GeneralFunctions.postNotificationSignal(key: ConfigPubNub.removeInst_key, obj: self)
                        GeneralFunctions.postNotificationSignal(key: Utils.releaseAllTaskObserverKey, obj: self)
                        GeneralFunctions.postNotificationSignal(key: ConfigSCConnection.removeSCInst_key, obj: self)
                    }
                    
                    viewController = nil
                }else{
                    GeneralFunctions.saveValue(key: Utils.IS_WALLET_AMOUNT_UPDATE_KEY, value: "true" as AnyObject)
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ConfigPubNub.TRIP_COMPLETE_NOTI_OBSERVER_KEY), object: self, userInfo: ["body":String(describing: result.convertToJson())])
                
                
                var viewController = Application.window != nil ? (Application.window!.rootViewController != nil ? (Application.window!.rootViewController!) : nil) : nil
                
                if(viewController != nil){
                    viewController = GeneralFunctions.getVisibleViewController(viewController)
                }
                
                if result.get("Is_Last_Delivery") == "Yes" && eType == "Multi-Delivery"
                {
                    self.generalFunc.setAlertMessage(uv: nil, title: "", content: contentMsg, positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_TXT"), completionHandler: { (btnClickedIndex) in
                        
                        if btnClickedIndex == 0
                        {
                
                            if(viewController != nil && viewController?.className != "RideMultiDetailUV"){
                                return
                            }
                        }else{
                            
                            if( UserDefaults.standard.object(forKey: "OLD_USER_PROFILE_MULTI") != nil){
                                GeneralFunctions.saveValue(key:  Utils.USER_PROFILE_DICT_KEY, value: GeneralFunctions.getValue(key: "OLD_USER_PROFILE_MULTI") as AnyObject)
                            }
                            
                            if self.mainScreenUv != nil{
                                if (self.mainScreenUv.liveTrackTripId != "")
                                {
                                    self.mainScreenUv.liveTrackTripId = ""
                                    self.mainScreenUv.performSegue(withIdentifier: "unwindToMyOnGoingTripsScreen", sender: self)
                                }
                            }
                         
                        }
                    })
                    return
                }
                else
                {
                    if eType != "Multi-Delivery"
                    {
                        self.generalFunc.setAlertMessage(uv: viewController, title: "", content: contentMsg, positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                            
                            if(eType != Utils.cabGeneralType_UberX){
                                let window = Application.window
                                let getUserData = GetUserData(uv: viewController, window: window!)
                                getUserData.getdata()
                            }else{
                                if(viewController != nil && (msg_str == "TripEnd" || (msg_str == "TripCancelledByDriver" && result.get("ShowTripFare").uppercased() == "TRUE"))){
                                 let ratingUV = GeneralFunctions.instantiateViewController(pageName: "RatingUV") as! RatingUV
                                 ratingUV.iTripId = iTripId
                                 viewController!.pushToNavController(uv: ratingUV, isDirect: true)
                                }
                             }
                        })
                        return
                    }else
                    {
                        self.generalFunc.setAlertMessage(uv: nil, title: "", content: contentMsg, positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                            
                            if self.mainScreenUv != nil
                            {
                                if(UserDefaults.standard.object(forKey: "OLD_USER_PROFILE_MULTI") != nil){
                                    GeneralFunctions.saveValue(key:  Utils.USER_PROFILE_DICT_KEY, value: GeneralFunctions.getValue(key: "OLD_USER_PROFILE_MULTI") as AnyObject)
                                }
                                if(self.mainScreenUv.liveTrackTripId != "" && msg_str != "TripCancelledByDriver"){
                                    if self.mainScreenUv.liveTrackTripId == result.get("iTripId")
                                    {
                                        self.mainScreenUv.performSegue(withIdentifier: "unwindToMyOnGoingTripsScreen", sender: self)
                                    }
                                    return
                                }else if (msg_str == "TripCancelledByDriver"){
                                    if (self.mainScreenUv.liveTrackTripId != ""){
                                        
                                        
                                        self.mainScreenUv.performSegue(withIdentifier: "unwindToMyOnGoingTripsScreen", sender: self)
                                    }
                                }
                            }
                        })
                        return
                    }
                    
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Utils.driverCallBackNotificationKey), object: self, userInfo: ["body":String(describing: result.convertToJson())])
          }
        }else if(messageStr.trim() != ""){
            if(Application.window != nil && Application.window?.rootViewController != nil ){
                //&& Utils.isMyAppInBackground() == false
                (GeneralFunctions()).setError(uv: Application.window!.rootViewController!, title: "", content: messageStr)
            }
        }
    }
    
    func manageChatScreen(notification:NSDictionary)
    {
        let receiverName = notification.get("FromMemberName")
        let receiverId = notification.get("iFromMemberId")
        let tripId = notification.get("iTripId")
        let fromMemberImageName = notification.get("FromMemberImageName")
        
        GeneralFunctions.saveValue(key: "ChatAssignedtripId", value:tripId as AnyObject)
        let chatUv = GeneralFunctions.instantiateViewController(pageName: "ChatUV") as! ChatUV
        chatUv.receiverId = receiverId
        chatUv.receiverDisplayName = receiverName
        chatUv.assignedtripId = tripId
        chatUv.bookingNo = notification.get("vBookingNo")
        chatUv.pPicName = fromMemberImageName
        
        let viewController = GeneralFunctions.getVisibleViewController(nil, isCheckAll: true)
        
        if viewController != nil{
            
            viewController?.pushToNavController(uv: chatUv, isDirect: true)
        }else{
            Application.window!.rootViewController?.pushToNavController(uv: chatUv, isDirect: true)
        }
        
    }
}
