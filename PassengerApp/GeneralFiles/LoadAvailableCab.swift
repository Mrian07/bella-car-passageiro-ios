//
//  LoadAvailableCab.swift
//  PassengerApp
//
//  Created by ADMIN on 30/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit
import GoogleMaps


class LoadAvailableCab: NSObject, OnTaskRunCalledDelegate {
    
    var gMapView:GMSMapView!
    var mainScreenUv:MainScreenUV!
    var isTaskKilled = false
    
    let generalFunc = GeneralFunctions()
    
    var selectedCabTypeId = ""
    var selectedCabCategoryType = ""
    
    var pickUpLocation:CLLocation!
    
    var pickUpAddress = ""
//    var currentGeoCodeResult = ""
    
    var updateDriverListTask:UpdateFreqTask!
    
    var RESTRICTION_KM_NEAREST_TAXI:Double = 4
    var ONLINE_DRIVER_LIST_UPDATE_TIME_INTERVAL:Double = 60
    var DRIVER_ARRIVED_MIN_TIME_PER_MINUTE:Double = 3
    
    var listOfDrivers = [NSDictionary]()
    var driverMarkerList = [GMSMarker]()
    
    var currentWebTask:ExeServerUrl!
    var userProfileJson:NSDictionary!
    
    var loaderView:UIView!
    
    var isFirstZoomlevel = true
    
    var selctedFilterType = "eIsFeatured"
    
    init(gMapView:GMSMapView, mainScreenUv:MainScreenUV){
        self.gMapView = gMapView
        self.mainScreenUv = mainScreenUv
        
        userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)

        RESTRICTION_KM_NEAREST_TAXI = GeneralFunctions.parseDouble(origValue: 4, data: userProfileJson.get("RESTRICTION_KM_NEAREST_TAXI"))
        ONLINE_DRIVER_LIST_UPDATE_TIME_INTERVAL = GeneralFunctions.parseDouble(origValue: 1, data: userProfileJson.get("ONLINE_DRIVER_LIST_UPDATE_TIME_INTERVAL")) * 60
        DRIVER_ARRIVED_MIN_TIME_PER_MINUTE = GeneralFunctions.parseDouble(origValue: 3, data: userProfileJson.get("DRIVER_ARRIVED_MIN_TIME_PER_MINUTE"))
        
        super.init()
    }
    
    func setCabTypeId(selectedCabTypeId:String){
        self.selectedCabTypeId =  selectedCabTypeId
    
    }
    
    func setPickUpLocation(pickUpLocation:CLLocation){
        self.pickUpLocation = pickUpLocation
        self.changeCabs()
    }
    
    func setTaskKilledValue(isTaskKilled:Bool){
        self.isTaskKilled = isTaskKilled
        
        if (isTaskKilled == true) {
            onPauseCalled()
        }
    }
    
    func changeCabs(){
        if(driverMarkerList.count > 0){
            filterDrivers(isCheckAgain: true)
        }else{
            checkAvailableCabs()
        }
    }
    
    func initializeUpdateDriverListTask(){
        if(updateDriverListTask == nil){
            updateDriverListTask = UpdateFreqTask(interval: ONLINE_DRIVER_LIST_UPDATE_TIME_INTERVAL)
            updateDriverListTask.currInst = updateDriverListTask
            updateDriverListTask.setTaskRunListener(onTaskRunCalled: self)
            updateDriverListTask.isAvoidFirstRun = true
            updateDriverListTask.startRepeatingTask()
        }
    }
    
    func checkAvailableCabs(){
        
        if(pickUpLocation == nil || pickUpAddress == ""){
            return
        }
        
        initializeUpdateDriverListTask()
        
        if(listOfDrivers.count > 0){
            self.listOfDrivers.removeAll()
        }
        
        if(self.mainScreenUv != nil){
            self.mainScreenUv.notifyCarSearching()
        }
        
        if(currentWebTask != nil){
            self.currentWebTask.cancel()
            self.currentWebTask = nil
        }
        
        if(mainScreenUv != nil && mainScreenUv.requestPickUpView != nil){
            if(self.loaderView != nil){
                self.loaderView.removeFromSuperview()
            }
            
            loaderView =  self.generalFunc.addMDloader(contentView: mainScreenUv.requestPickUpView)
            
            loaderView.center = CGPoint(x: mainScreenUv.requestPickUpView.bounds.midX, y: mainScreenUv.cabTypeCollectionView.bounds.midY)
            loaderView.backgroundColor = UIColor.clear
            
            mainScreenUv.requestNowBtn.setButtonTitleColor(color: UIColor(hex: 0x6b6b6b))
            mainScreenUv.requestNowBtn.setButtonEnabled(isBtnEnabled: false)
            mainScreenUv.rideLaterImgView.isUserInteractionEnabled = false
            mainScreenUv.noCabTypeLbl.isHidden = true
            mainScreenUv.cabTypeCollectionView.isUserInteractionEnabled = false
        }
        
        self.mainScreenUv.cabTypesBasedOnCategoryDict.removeAll()
        
        /* For Pool */
        var destLat = ""
        var destLong = ""
        if (mainScreenUv != nil && self.mainScreenUv.destLocation != nil){
            
            destLat = "\(self.mainScreenUv.destLocation!.coordinate.latitude)"
            destLong = "\(self.mainScreenUv.destLocation!.coordinate.longitude)"
        }
        /* For Pool. */
        
        var parameters = ["type":"loadAvailableCab","PassengerLat": "\(self.pickUpLocation!.coordinate.latitude)", "PassengerLon": "\(self.pickUpLocation!.coordinate.longitude)","iUserId": GeneralFunctions.getMemberd(), "PickUpAddress": self.pickUpAddress, "eType": mainScreenUv != nil ? mainScreenUv.currentCabGeneralType : "", "SelectedCabType": mainScreenUv != nil ? mainScreenUv.currentCabGeneralType : "", "sortby" : self.mainScreenUv.selctedFilterType, "DestLat":destLat, "DestLong": destLong]
//        , "currentGeoCodeResult": currentGeoCodeResult.condenseWhitespace()
        if(mainScreenUv != nil && mainScreenUv.ufxSelectedVehicleTypeId != ""){
            parameters["iVehicleTypeId"] = mainScreenUv.ufxSelectedVehicleTypeId
            if(mainScreenUv.selectedDate != ""){
                parameters["scheduleDate"] = mainScreenUv.selectedDate
            }
        }
        
        if(mainScreenUv != nil && (mainScreenUv.selectedCabCategoryType == Utils.rentalCategoryType || mainScreenUv.eShowOnlyRental == true)){
             parameters["eRental"] = "Yes"
        }
        
        if(mainScreenUv != nil && mainScreenUv.eShowOnlyMoto == true){
            parameters["eShowOnlyMoto"] = "Yes"
        }
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.mainScreenUv.view, isOpenLoader: false)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: true)
        exeWebServerUrl.currInstance = exeWebServerUrl
        
        self.currentWebTask = exeWebServerUrl
        
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(self.mainScreenUv.rideLaterImgView != nil){
                self.mainScreenUv.rideLaterImgView.isUserInteractionEnabled = true
            }
            
            if(self.mainScreenUv.requestPickUpView != nil){
                self.mainScreenUv.cabTypeCollectionView.isUserInteractionEnabled = true
                
            }

            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                let cabTypesArr = dataDict.getArrObj("VehicleTypes")
                
                if(self.mainScreenUv != nil){
                    
                    var cabCategoriesArr = [NSMutableDictionary]()
                    var listOfLoadedCategoriesNames = [String]()
                    
                    if self.mainScreenUv.eShowOnlyRental{
                        //Show only one rental category
                        listOfLoadedCategoriesNames = [Utils.rentalCategoryType]
                    }else{
                        //One Static Category for all
                        listOfLoadedCategoriesNames = [Utils.dailyRideCategoryType]
                        
                        //Get Other categories if any
                        for i in 0..<cabTypesArr.count {
                            
                            let tempItem = cabTypesArr[i] as! NSDictionary
                            let eRental = tempItem.get("eRental")
                            
                            //Add Rental category if eRental is Yes
                            if (eRental.uppercased() == "YES") && (tempItem.get("eType") == self.mainScreenUv.currentCabGeneralType){
                                listOfLoadedCategoriesNames.append(Utils.rentalCategoryType)
                                break
                            }
                        }
                    }
                  
                    //Get Vehicletypes for categories
                    for i in 0..<listOfLoadedCategoriesNames.count {
                        
                        let eCategoryType = listOfLoadedCategoriesNames[i]
                        
                        var categoryCabTypesArr = [NSDictionary]()
                        
                        let cabCategoryItem = NSMutableDictionary()
                        cabCategoryItem["eCategoryType"] = eCategoryType
                        
                        if (eCategoryType == Utils.dailyRideCategoryType){
                            cabCategoryItem["vTitle"] = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DAILYRIDES_CATEGORY_TXT")
                            cabCategoryItem["vDescription"] = self.generalFunc.getLanguageLabel(origValue: "", key: "LBl_DAILYRIDES_DESCRIPTION_TXT")
                        }else if(eCategoryType == Utils.rentalCategoryType){
                            cabCategoryItem["vTitle"] = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RENTAL_CATEGORY_TXT")
                            cabCategoryItem["vDescription"] = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RENTAL_DESCRIPTION_TXT")
                        }
                        
                        for j in 0..<cabTypesArr.count {
                            
                            let tempItem = cabTypesArr[j] as! NSDictionary
                            let eRental = tempItem.get("eRental")
                            
                            if tempItem.get("eType") == self.mainScreenUv.currentCabGeneralType{
                                //Add all vehicle types for DailyRide and if eRental yes than add to Rentals
                                if (eCategoryType == Utils.dailyRideCategoryType){
                                    categoryCabTypesArr += [tempItem]
                                }else if(eCategoryType == Utils.rentalCategoryType && eRental.uppercased() == "YES"){
                                    categoryCabTypesArr += [tempItem]
                                }
                            }
                        }
                        
                        cabCategoryItem["CabTypes"] = categoryCabTypesArr
                        cabCategoriesArr += [cabCategoryItem]
                    }
                    
                    //Set category dictionary
                    self.mainScreenUv.listOfLoadedCategories = cabCategoriesArr
                    
                    //Filter cars based on category selected and pass in main screen
                    var filterdCarTypes = [NSDictionary]()
                    
                    if(cabCategoriesArr.count > 0){
                        if(self.mainScreenUv.selectedCabCategoryType == ""){
                            self.mainScreenUv.selectedCabCategoryType = listOfLoadedCategoriesNames[0]
                            self.selectedCabCategoryType = listOfLoadedCategoriesNames[0]
                            let tempCabTypesArr = (cabCategoriesArr[0] as NSDictionary).getArrObj("CabTypes") as! [NSDictionary]
                            filterdCarTypes.append(contentsOf: tempCabTypesArr)
                        }else{
                            let index = listOfLoadedCategoriesNames.index(of: self.mainScreenUv.selectedCabCategoryType)
                            if(index != nil){
                                let tempCabTypesArr = (cabCategoriesArr[index!] as NSDictionary).getArrObj("CabTypes") as! [NSDictionary]
                                filterdCarTypes.append(contentsOf: tempCabTypesArr)
                            }else{
                                let tempCabTypesArr = (cabCategoriesArr[0] as NSDictionary).getArrObj("CabTypes") as! [NSDictionary]
                                filterdCarTypes.append(contentsOf: tempCabTypesArr)
                            }
                        }
                    }
                    
                    //If different category than carTypeChanged = yes else check based on array objects count
                    var isCarTypeChanged = false
                    if self.selectedCabCategoryType != self.mainScreenUv.selectedCabCategoryType{
                        isCarTypeChanged = true
                        self.selectedCabCategoryType = self.mainScreenUv.selectedCabCategoryType
                    }else{
                        isCarTypeChanged = self.mainScreenUv.isCarTypesArrChanged(carTypes: filterdCarTypes as NSArray)
                    }
                    
                    if(isCarTypeChanged == true){
                        self.mainScreenUv.cabTypesArr.removeAll()
                        self.mainScreenUv.cabTypesFareArr.removeAll()
                        
                        if(self.mainScreenUv.requestPickUpView != nil){
                            self.mainScreenUv.cabTypeCollectionView.reloadData()
                        }
                        
                        for i in 0..<filterdCarTypes.count {
                            let tempItem = filterdCarTypes[i]
                            
                            if(tempItem.get("eType") == self.mainScreenUv.currentCabGeneralType){
                                self.mainScreenUv.cabTypesArr += [tempItem]
                            }
                        }
                        
                        self.mainScreenUv.selectedCabTypeId = self.mainScreenUv.getFirstCarTypeID()
                        self.setCabTypeId(selectedCabTypeId: self.mainScreenUv.getFirstCarTypeID())
                        self.mainScreenUv.selectedCabTypeLogo = self.mainScreenUv.getFirstCarTypeLogo()
                        self.mainScreenUv.selectedCabTypeName = self.mainScreenUv.getFirstCarTypeName()
                        
                        if(self.mainScreenUv.requestPickUpView != nil){
                            self.mainScreenUv.cabTypeCollectionView.reloadData()
                            
                            //If rental is selected than call estimate fare even if destination is not added to get the basic package prices
                            if(self.mainScreenUv.destAddress != "DEST_SKIPPED"){
                                self.mainScreenUv.estimateFare()
                            }else{
                                if self.mainScreenUv.selectedCabCategoryType == Utils.rentalCategoryType{
                                    self.mainScreenUv.continueEstimateFare(distance: "", time: "")
                                }
                            }
                        }
                    }
                    
                    if(self.mainScreenUv.cabTypesArr.count < 1 && self.mainScreenUv.requestPickUpView != nil){
                        self.mainScreenUv.noCabTypeLbl.isHidden = false
                    }
                    
                    if(self.mainScreenUv.cabTypesArr.count > 0 && self.mainScreenUv.requestPickUpView != nil){
                        self.mainScreenUv.requestNowBtn.setButtonEnabled(isBtnEnabled: true)
                        self.mainScreenUv.requestNowBtn.setButtonTitleColor(color: UIColor.UCAColor.AppThemeTxtColor)
                        //                        self.mainScreenUv.requestNowBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "REQUEST NOW", key: "LBL_REQUEST_NOW"))
                        if(self.mainScreenUv.currentCabGeneralType == Utils.cabGeneralType_Deliver){
                            self.mainScreenUv.requestNowBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "Next", key: "LBL_BTN_NEXT_TXT"))
                        }else{
                            self.mainScreenUv.requestNowBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "Request Now", key: "LBL_REQUEST_NOW"))
                        }
                        self.mainScreenUv.noCabTypeLbl.isHidden = true
                    }
                }
                
                
                if(self.listOfDrivers.count > 0){
                    self.listOfDrivers.removeAll()
                }
                
                var cabListArr = dataDict.getArrObj("AvailableCabList")
//                let cabListArr = [String]() as NSArray
                
                for i in 0..<cabListArr.count {
                    
                    let tempDict = cabListArr[i] as! NSDictionary
                    
                    let carDetails = tempDict.getObj("DriverCarDetails")
                    
                    var dict = [String: String]()
                    
                    dict["driver_id"] = tempDict.get("iDriverId")
                    
                    dict["Name"] = tempDict.get("vName")
                    dict["LastName"] = tempDict.get("vLastName")
                    dict["Latitude"] = tempDict.get("vLatitude")
                    dict["Longitude"] = tempDict.get("vLongitude")
                    dict["GCMID"] = tempDict.get("iGcmRegId")
                    dict["iAppVersion"] = tempDict.get("iAppVersion")
                    dict["driver_img"] = tempDict.get("vImage")
                    dict["average_rating"] = tempDict.get("vAvgRating")
                    dict["vPhone_driver"] = tempDict.get("vPhone")
                    dict["eFemaleOnlyReqAccept"] = tempDict.get("eFemaleOnlyReqAccept")
                    dict["DriverGender"] = tempDict.get("eGender")
                    dict["tProfileDescription"] = tempDict.get("tProfileDescription")
                    dict["ACCEPT_CASH_TRIPS"] = tempDict.get("ACCEPT_CASH_TRIPS")
                    dict["PROVIDER_RADIUS"] = tempDict.get("PROVIDER_RADIUS")
                    dict["PROVIDER_RATING_COUNT"] = tempDict.get("PROVIDER_RATING_COUNT")
                    dict["eIsFeatured"] = tempDict.get("eIsFeatured")
                    dict["IS_PROVIDER_ONLINE"] = tempDict.get("IS_PROVIDER_ONLINE")
                    
                    dict["fAmount"] = carDetails.get("fAmount")
                    dict["vCarType"] = carDetails.get("vCarType")
                    dict["vRentalCarType"] = carDetails.get("vRentalCarType")
                    dict["vLicencePlate"] = carDetails.get("vLicencePlate")
                    dict["make_title"] = carDetails.get("make_title")
                    dict["model_title"] = carDetails.get("model_title")
                    dict["vColour"] = carDetails.get("vColour")
                    dict["eHandiCapAccessibility"] = carDetails.get("eHandiCapAccessibility")
                    dict["eChildSeatAvailable"] = carDetails.get("eChildSeatAvailable")
                    dict["eWheelChairAvailable"] = carDetails.get("eWheelChairAvailable")
                    dict["fMinHour"] = carDetails.get("fMinHour")
                    dict["eFareType"] = carDetails.get("eFareType")
                    dict["eTripStatusActive"] = tempDict.get("eTripStatusActive")  // POOL CHANGES
                    dict["eFavDriver"] = tempDict.get("eFavDriver")  /* FAV DRIVERS CHANGES*/
                    dict["eDestinationMode"] = tempDict.get("eDestinationMode")  /* Driver Destinations CHANGES*/
                
                    self.listOfDrivers += [dict as NSDictionary]
                }
                
                if(self.mainScreenUv.cabTypesArr.count < 1 && self.mainScreenUv.currentCabGeneralType.uppercased() != Utils.cabGeneralType_UberX.uppercased() ){
                    cabListArr = NSArray()
                    self.listOfDrivers.removeAll()
                }
                
                if(cabListArr.count == 0){
                    self.removeDriversFromMap(isUnSubscribeAll: true)
                    if(self.mainScreenUv != nil){
                        self.mainScreenUv.notifyNoCabs()
                    }
                    
                    
                    if(self.mainScreenUv.requestPickUpView != nil){
//                        self.mainScreenUv.requestNowBtn.setButtonEnabled(isBtnEnabled: false)
                        self.mainScreenUv.requestNowBtn.setButtonEnabled(isBtnEnabled: true)
//                        self.mainScreenUv.requestNowBtn.setButtonTitleColor(color: UIColor(hex: 0x6b6b6b))
                        self.mainScreenUv.requestNowBtn.setButtonTitleColor(color: UIColor.UCAColor.AppThemeTxtColor_1)
                        self.mainScreenUv.requestNowBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "NO CARS", key: "LBL_NO_CARS"))
                    }
                    
                    
                }else{
                    
                    self.filterDrivers(isCheckAgain: false)
                    
                }
                
            }else{
//                self.generalFunc.setError(uv: self.uv)
                self.removeDriversFromMap(isUnSubscribeAll: true)
                if(self.mainScreenUv != nil){
                    self.mainScreenUv.notifyNoCabs()
                }
                
                if(self.mainScreenUv.requestPickUpView != nil){
//                    self.mainScreenUv.requestNowBtn.setButtonEnabled(isBtnEnabled: false)
                    self.mainScreenUv.requestNowBtn.setButtonEnabled(isBtnEnabled: true)
//                    self.mainScreenUv.requestNowBtn.setButtonTitleColor(color: UIColor(hex: 0x6b6b6b))
                    self.mainScreenUv.requestNowBtn.setButtonTitleColor(color: UIColor.UCAColor.AppThemeTxtColor_1)
                    self.mainScreenUv.requestNowBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "NO CARS", key: "LBL_NO_CARS"))
                }
//                Utils.showSnakeBar(msg: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_NO_INTERNET_TXT"), uv: self.mainScreenUv)
            }
            
            if(self.loaderView != nil){
                
                self.loaderView.isHidden = true
                 self.loaderView.removeFromSuperview()
            }
            
            // LOAD REQUEST PICKUP VIEW FOR MULTI DELIVERY
            if self.mainScreenUv.vTitleFromUFX == self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_MULTI_OPTION_TITLE_TXT"){
                
                if(self.mainScreenUv.requestPickUpView == nil && self.mainScreenUv.gMapView != nil){
                    
                    //self.mainScreenUv.addressContainerView.destViewTapped(isAutoOpenSelection: false)
                    self.mainScreenUv.setTripLocation(selectedAddress: "DEST_SKIPPED", selectedLocation: CLLocation(latitude: 0.0, longitude: 0.0))
                    self.mainScreenUv.addressContainerView.pickUpTapped(isOpenSelection: false)
                    
                }
                
            }
            else
            {
                self.mainScreenUv.sourcePickUpEtaLbl.isHidden = true
            }
        })
        
    
    }
    func getFeaturedDriverList(listOfDrivers:[NSDictionary]) -> [NSDictionary]{
        let driverList = listOfDrivers
        var featuredDriversList = [NSDictionary]()
        var otherDriversList = [NSDictionary]()
        
        for i in 0..<driverList.count{
            if driverList[i].get("eIsFeatured").uppercased() == "YES"{
                featuredDriversList.append(driverList[i])
            }else{
                otherDriversList.append(driverList[i])
            }
        }
        
        featuredDriversList.append(contentsOf: otherDriversList)
        
        return featuredDriversList
    }
    
    /* ONLINE DRIVERS CHANGES*/
    func getOnlineToOfflineDriverFilters(listOfDrivers:[NSDictionary]) -> [NSDictionary]{
        let driverList = listOfDrivers
        var onlineList = [NSDictionary]()
        var offlineDriversList = [NSDictionary]()
        
        for i in 0..<driverList.count{
            if driverList[i].get("IS_PROVIDER_ONLINE").uppercased() == "YES"{
                onlineList.append(driverList[i])
            }else{
                offlineDriversList.append(driverList[i])
            }
        }
        
        onlineList.append(contentsOf: offlineDriversList)
        
        return onlineList
    }/* ..........*/
    
    /* FAV DRIVERS CHANGES*/
    func getFavDriversWithOtherFilters(listOfDrivers:[NSDictionary]) -> [NSDictionary]{
        let driverList = listOfDrivers
        var favDriversList = [NSDictionary]()
        var otherDriversList = [NSDictionary]()
        
        for i in 0..<driverList.count{
            if driverList[i].get("eFavDriver").uppercased() == "YES"{
                favDriversList.append(driverList[i])
            }else{
                otherDriversList.append(driverList[i])
            }
        }
        
        favDriversList.append(contentsOf: otherDriversList)
        
        return favDriversList
    }/* ..........*/
    
    func filterDrivers(isCheckAgain:Bool){
        
        if(pickUpLocation == nil || mainScreenUv == nil){
            return
        }
    
        var lowestKM = 0.0
        var isFirst_lowestKM = true
        
        var currentLoadedDrivers = [NSDictionary]()
        
        var driverMarkerListTemp = [GMSMarker]()
        
        var bounds = GMSCoordinateBounds()
        bounds =  bounds.includingCoordinate(self.pickUpLocation.coordinate)
        

        for i in 0..<listOfDrivers.count{
            let driverData = listOfDrivers[i]
            var driverData1 = listOfDrivers[i] as! [String: String]
            
            
            let driverName = driverData.get("Name")
            var vCarType = driverData.get("vCarType").components(separatedBy: ",")
            let vRentalCarType = driverData.get("vRentalCarType").components(separatedBy: ",")
            let eHandiCapAccessibility = driverData.get("eHandiCapAccessibility")
            let eChildAccessibility = driverData.get("eChildSeatAvailable")//eChildAccessibility
            let eWheelChairAccessibility = driverData.get("eWheelChairAvailable")
            let eFemaleOnlyReqAccept = driverData.get("eFemaleOnlyReqAccept")
            let DriverGender = driverData.get("DriverGender")
            let eDestinationMode = driverData.get("eDestinationMode")
            
//            Utils.printLog(msgData: "HandiCap:\((self.mainScreenUv.isHandicapPrefEnabled == true && eHandiCapAccessibility.uppercased() != "YES"))")
//            Utils.printLog(msgData: "Female:\((eFemaleOnlyReqAccept.uppercased() == "YES" && self.mainScreenUv.userProfileJson.get("eGender") == "Male"))")
//            Utils.printLog(msgData: "DriverGender:\((DriverGender.uppercased() != "FEMALE" && self.mainScreenUv.isPreferFemaleDriverEnable == true))")
//            Utils.printLog(msgData: "SelectedProviderId:\((self.mainScreenUv.ufxSelectedServiceProviderId != "" && self.mainScreenUv.ufxSelectedServiceProviderId != driverData.get("driver_id")))")
//            Utils.printLog(msgData: "CashEmpty:\((self.mainScreenUv.isCashPayment == true && driverData.get("ACCEPT_CASH_TRIPS") == "No"))")
            
            //If rental is selected than check with rental car types
            if self.mainScreenUv.selectedCabCategoryType == Utils.rentalCategoryType{
                vCarType = vRentalCarType
            }
        
            
            /* POOL CONDITION ADDED. */
            if(self.selectedCabTypeId == "" || (vCarType.contains(self.selectedCabTypeId) == false && !(userProfileJson.get("SERVICE_PROVIDER_FLOW").uppercased() == "PROVIDER" && self.mainScreenUv.currentCabGeneralType.uppercased() == Utils.cabGeneralType_UberX.uppercased())) || (self.mainScreenUv.currentCabGeneralType == Utils.cabGeneralType_Ride && self.mainScreenUv.isHandicapPrefEnabled == true && eHandiCapAccessibility.uppercased() != "YES") || (self.mainScreenUv.currentCabGeneralType == Utils.cabGeneralType_Ride && self.mainScreenUv.isChildPrefEnabled == true && eChildAccessibility.uppercased() != "YES") || (self.mainScreenUv.currentCabGeneralType == Utils.cabGeneralType_Ride && self.mainScreenUv.isWheelChairPrefEnabled == true && eWheelChairAccessibility.uppercased() != "YES") || (self.mainScreenUv.currentCabGeneralType == Utils.cabGeneralType_Ride && eFemaleOnlyReqAccept.uppercased() == "YES" && self.mainScreenUv.userProfileJson.get("eGender").uppercased() != "FEMALE") || (self.mainScreenUv.currentCabGeneralType == Utils.cabGeneralType_Ride && DriverGender.uppercased() != "FEMALE" && self.mainScreenUv.isPreferFemaleDriverEnable == true) || (self.mainScreenUv.ufxSelectedServiceProviderId != "" && self.mainScreenUv.ufxSelectedServiceProviderId != driverData.get("driver_id")) || ((self.mainScreenUv.isCashPayment == true && driverData.get("ACCEPT_CASH_TRIPS") == "No" && self.mainScreenUv.currentCabGeneralType.uppercased() != Utils.cabGeneralType_UberX.uppercased()) || (self.mainScreenUv.currentCabGeneralType.uppercased() == Utils.cabGeneralType_UberX.uppercased() && driverData.get("ACCEPT_CASH_TRIPS") == "No" && self.mainScreenUv.userProfileJson.get("APP_PAYMENT_MODE").uppercased() == "CASH")) || (self.mainScreenUv.isPoolVehicleSelected == false && driverData.get("eTripStatusActive") == "Yes") || ((self.mainScreenUv.isPoolVehicleSelected == true || self.mainScreenUv.currentCabGeneralType != Utils.cabGeneralType_Ride) && eDestinationMode.uppercased() == "YES")){
                continue
            }
    
            
            let driverLocLatitude = GeneralFunctions.parseDouble(origValue: 0.0, data: driverData.get("Latitude"))
            let driverLocLongitude = GeneralFunctions.parseDouble(origValue: 0.0, data: driverData.get("Longitude"))
            
            let distance = self.pickUpLocation.distance(from: CLLocation(latitude: driverLocLatitude, longitude: driverLocLongitude)) / 1000
            
            if(isFirst_lowestKM == true){
                lowestKM = distance
                isFirst_lowestKM = false
            }else {
                if (distance < lowestKM) {
                    lowestKM = distance
                }
            }
            
            let PROVIDER_RADIUS_value = GeneralFunctions.parseDouble(origValue: -1.00, data: driverData.get("PROVIDER_RADIUS"))
            

//            if ((PROVIDER_RADIUS_value != -1.00 && distance < PROVIDER_RADIUS_value)  || (PROVIDER_RADIUS_value == -1.00 && distance < RESTRICTION_KM_NEAREST_TAXI)){
            if ((PROVIDER_RADIUS_value != -1.00 && distance < PROVIDER_RADIUS_value && mainScreenUv.currentCabGeneralType.uppercased() == Utils.cabGeneralType_UberX.uppercased())  || (distance < RESTRICTION_KM_NEAREST_TAXI  && mainScreenUv.currentCabGeneralType.uppercased() != Utils.cabGeneralType_UberX.uppercased())){

            //                distance < RESTRICTION_KM_NEAREST_TAXI
                
                driverData1["DIST_TO_PICKUP"] = "\(distance)"
                
//                currentLoadedDrivers += [driverData1 as NSDictionary]
                
                let eIconType = GeneralFunctions.getSelectedCarTypeData(selectedCarTypeId: selectedCabTypeId, dataKey: "eIconType", carTypesArr: self.mainScreenUv.cabTypesArr as NSArray)
                
                var iconId = "ic_driver_car_pin"
                if(eIconType == "Bike"){
                    iconId = "ic_bike"
                }else if(eIconType == "Cycle"){
                    iconId = "ic_cycle"
                }else if(eIconType == "Truck"){
                    iconId = "ic_truck"
                }
                driverData1["eIconType"] = "\(eIconType)"
                
                let driverMarker_temp = mainScreenUv.getDriverMarkerOnPubNubMsg(iDriverId: driverData.get("driver_id"), isRemoveFromList: true)
                if(driverMarker_temp == nil){
                    let driverMarker = self.drawMarker(location: CLLocation(latitude: driverLocLatitude, longitude: driverLocLongitude), Name: driverName, driverData: driverData)
                    
                    driverMarkerListTemp += [driverMarker]
                }else{
                    if(self.mainScreenUv.currentCabGeneralType.uppercased() == Utils.cabGeneralType_UberX.uppercased()){
                        let providerView = self.getProviderMarkerView(providerImage: UIImage(named: "ic_no_pic_user")!)
                        driverMarker_temp!.icon = UIImage(view: providerView)
                        
                        (providerView.subviews[1] as! UIImageView).sd_setImage(with: URL(string: "\(CommonUtils.driver_image_url)\(driverData.get("driver_id"))/\(driverData.get("driver_img"))"), placeholderImage: UIImage(named: "ic_no_pic_user"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                            driverMarker_temp!.icon = UIImage(view: providerView)
                        })
                        
                    }else{
                        
                        driverMarker_temp!.icon = UIImage(named: iconId)
                    }
                    driverMarker_temp!.isFlat = true
//                    driverMarker_temp!.icon = UIImage(named: iconId)
                    driverMarkerListTemp += [driverMarker_temp!]
                }
                
                bounds =  bounds.includingCoordinate(CLLocation(latitude: driverLocLatitude, longitude: driverLocLongitude).coordinate)

                 currentLoadedDrivers += [driverData1 as NSDictionary]
            }
        }
        
        //        For Filter driver
        if currentLoadedDrivers.count > 0{
            if(self.selctedFilterType == "eIsFeatured"){
                currentLoadedDrivers = self.getFeaturedDriverList(listOfDrivers: currentLoadedDrivers)
            }else if(self.selctedFilterType == "vAvgRating"){
                currentLoadedDrivers = currentLoadedDrivers.sorted(by: { $0.getFloat("average_rating") > $1.getFloat("average_rating")})
            }else if(self.selctedFilterType == "distance"){
                currentLoadedDrivers =  currentLoadedDrivers.sorted(by: { $0.getFloat("DIST_TO_PICKUP") < $1.getFloat("DIST_TO_PICKUP")})
            }else if(self.selctedFilterType == "eFavDriver"){  /* FAV DRIVERS CHANGES*/
                currentLoadedDrivers = self.getFavDriversWithOtherFilters(listOfDrivers: currentLoadedDrivers)
            }else if(self.selctedFilterType == "eAvailable"){  /* FAV DRIVERS CHANGES*/
                currentLoadedDrivers = self.getOnlineToOfflineDriverFilters(listOfDrivers: currentLoadedDrivers)
            }
           
        }
        
//        /* FAV DRIVERS CHANGES*/
//        if(userProfileJson.get("ENABLE_FAVORITE_DRIVER_MODULE").uppercased() == "YES"){
//            currentLoadedDrivers = self.getFavDriversWithOtherFilters(listOfDrivers: currentLoadedDrivers)
//        }

        self.removeDriversFromMap(isUnSubscribeAll: false)
        self.driverMarkerList.append(contentsOf: driverMarkerListTemp)
        
        if(self.mainScreenUv != nil){
            let lowestTime = lowestKM * DRIVER_ARRIVED_MIN_TIME_PER_MINUTE
            var lowestTime_int = Int(lowestTime)
            
            if(lowestTime_int < 1){
                lowestTime_int = 1
            }
            
            if(currentLoadedDrivers.count > 0){
                if(lowestKM > 1.5 && isFirstZoomlevel){
                    isFirstZoomlevel = false
                    
                    if(self.gMapView != nil){
                        let maxZoomLevel = self.gMapView.maxZoom
                        self.mainScreenUv.gMapView.setMinZoom(self.mainScreenUv.gMapView.minZoom, maxZoom: self.mainScreenUv.gMapView.maxZoom - 5)
                        
                        let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
                        
                        CATransaction.begin()
                        CATransaction.setCompletionBlock {
                            self.mainScreenUv.gMapView.setMinZoom(self.mainScreenUv.gMapView.minZoom, maxZoom: maxZoomLevel)
                        }
                        
                        self.gMapView.animate(with: update)
                        
                        CATransaction.commit()
                    }
                }
            }
            
            self.mainScreenUv.setETA(time: "\(lowestTime_int) \n\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_MIN_SMALL_TXT"))")
        }
        
        if(self.mainScreenUv != nil){
            var unSubscribeChannelList = [String]()
            var subscribeChannelList = [String]()
            var currentDriverChannelsList = mainScreenUv.getDriverLocationChannelList()
            var newDriverChannelsList = mainScreenUv.getDriverLocationChannelList(listData: currentLoadedDrivers)
            
            for i in 0..<currentDriverChannelsList.count{
                let channel_name = currentDriverChannelsList[i]
                
                if(!newDriverChannelsList.contains(channel_name)){
                    unSubscribeChannelList += [channel_name]
                }
            }
            
            for i in 0..<newDriverChannelsList.count{
                let channel_name = newDriverChannelsList[i]
                
                if(!currentDriverChannelsList.contains(channel_name)){
                    subscribeChannelList += [channel_name]
                }
            }
            
            mainScreenUv.setCurrentLoadedDriverList(currentLoadedDriverList: currentLoadedDrivers)
            
            ConfigPubNub.getInstance().subscribeToChannels(channels: subscribeChannelList)
            
            
            ConfigPubNub.getInstance().unSubscribeToChannels(channels: unSubscribeChannelList)
            
        }
        
        
        if(currentLoadedDrivers.count == 0){
            if(mainScreenUv != nil){
                mainScreenUv.notifyNoCabs()
                
                if(self.mainScreenUv.requestPickUpView != nil){
                    self.mainScreenUv.requestNowBtn.setButtonTitleColor(color: UIColor.UCAColor.AppThemeTxtColor_1)
                    self.mainScreenUv.requestNowBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "NO CARS", key: "LBL_NO_CARS"))
                }
            }
            
            if(isCheckAgain){
                self.checkAvailableCabs()
            }
            
           
        }else{
            if(mainScreenUv != nil){
                mainScreenUv.notifyCabsAvailable()
                
                if(self.mainScreenUv.requestPickUpView != nil){
                    self.mainScreenUv.requestNowBtn.setButtonEnabled(isBtnEnabled: true)
                    if(self.mainScreenUv.currentCabGeneralType == Utils.cabGeneralType_Deliver){
                        self.mainScreenUv.requestNowBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "Next", key: "LBL_BTN_NEXT_TXT"))
                    }else{
                        
                        //Pool Changes
                        if (self.mainScreenUv.isPoolVehicleSelected == true && self.mainScreenUv.eShowOnlyRental == false){
                            self.mainScreenUv.requestNowBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "Confirm Seats", key: "LBL_CONFIRM_SEATS"))
                        }else{
                            self.mainScreenUv.requestNowBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "Request Now", key: "LBL_REQUEST_NOW"))
                        }
                   
                    }
                    self.mainScreenUv.requestNowBtn.setButtonTitleColor(color: UIColor.UCAColor.AppThemeTxtColor)
                }
            }
            
           
        }
        
    }

    func onTaskRun(currInst: UpdateFreqTask) {
        checkAvailableCabs()
    }
    
    func onPauseCalled() {
    
        if (updateDriverListTask != nil) {
            updateDriverListTask.onTaskRunCalled = nil
            updateDriverListTask.stopRepeatingTask()
            updateDriverListTask = nil
        }
    }
    
    func onResumeCalled() {
        if (updateDriverListTask != nil && isTaskKilled == false) {
            updateDriverListTask.setTaskRunListener(onTaskRunCalled: self)
            updateDriverListTask.startRepeatingTask()
        }else if(updateDriverListTask == nil && isTaskKilled == false){
            initializeUpdateDriverListTask()
        }
    }
    
    func removeDriversFromMap(isUnSubscribeAll:Bool){
        if(driverMarkerList.count > 0){
            for i in 0..<driverMarkerList.count {
                driverMarkerList[i].map = nil
            }
            self.driverMarkerList.removeAll()
        }
        
        // Remove listener of channels (unsuscribe) of drivers from pubnub
        if (isUnSubscribeAll == true) {
            ConfigPubNub.getInstance().unSubscribeToChannels(channels: mainScreenUv.getDriverLocationChannelList())
        }
    }
    
    func getDriverMarkerList() -> [GMSMarker]{
        return self.driverMarkerList
    }
    func setDriverMarkerList(driverMarkerList:[GMSMarker]){
        self.driverMarkerList = driverMarkerList
    }
    
    func drawMarker(location:CLLocation, Name:String, driverData:NSDictionary) -> GMSMarker{
        if(mainScreenUv == nil || gMapView == nil){
            return GMSMarker()
        }
        let eIconType = GeneralFunctions.getSelectedCarTypeData(selectedCarTypeId: selectedCabTypeId, dataKey: "eIconType", carTypesArr: self.mainScreenUv.cabTypesArr as NSArray)
        
        var iconId = "ic_driver_car_pin"
        if(eIconType == "Bike"){
            iconId = "ic_bike"
        }else if(eIconType == "Cycle"){
            iconId = "ic_cycle"
        }else if(eIconType == "Truck"){
            iconId = "ic_truck"
        }
        
        let driverMarker = GMSMarker()
        
        driverMarker.position = location.coordinate
        driverMarker.title = "DriverId\(driverData.get("driver_id"))"
        
        if(self.mainScreenUv.currentCabGeneralType.uppercased() == Utils.cabGeneralType_UberX.uppercased()){
            let providerView = self.getProviderMarkerView(providerImage: UIImage(named: "ic_no_pic_user")!)
            driverMarker.icon = UIImage(view: providerView)
            
            (providerView.subviews[1] as! UIImageView).sd_setImage(with: URL(string: "\(CommonUtils.driver_image_url)\(driverData.get("driver_id"))/\(driverData.get("driver_img"))"), placeholderImage: UIImage(named: "ic_no_pic_user"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                driverMarker.icon = UIImage(view: providerView)
            })
            driverMarker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
            
        }else{
            
            driverMarker.icon = UIImage(named: iconId)
            driverMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        }
        
        driverMarker.isFlat = true
        driverMarker.rotation = 0
        driverMarker.map = self.gMapView
        driverMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        
        return driverMarker
    }
    
    func getProviderMarkerView(providerImage:UIImage) -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ProviderMapMarkerView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame.size = CGSize(width: 64, height: 100)
        
        GeneralFunctions.setImgTintColor(imgView: view.subviews[0] as! UIImageView, color: UIColor.UCAColor.AppThemeColor)
        
        view.subviews[1].layer.cornerRadius = view.subviews[1].frame.width / 2
        view.subviews[1].layer.masksToBounds = true
        let providerImgView = view.subviews[1] as! UIImageView
        providerImgView.image = providerImage
        
        return view
    }
}
