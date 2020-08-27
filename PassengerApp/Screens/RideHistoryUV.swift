//
//  RideHistroyUV.swift
//  PassengerApp
//
//  Created by ADMIN on 13/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class RideHistoryUV: UIViewController, UITableViewDataSource, UITableViewDelegate, MyBtnClickDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let generalFunc = GeneralFunctions()
    
    var navItem:UINavigationItem!
    
    var HISTORY_TYPE:String = "PAST"
    
    var loaderView:UIView!
    
    var dataArrList = [NSDictionary]()
    var nextPage_str = 1
    var isLoadingMore:Bool = false
    var isNextPageAvail:Bool = false
    
    var APP_TYPE:String = ""
    
    var cntView:UIView!
    
    var extraHeightContainer = [CGFloat]()
    var userProfileJson:NSDictionary!
    
    var isFirstCallFinished:Bool = false
    
    var isDataLoaded:Bool = false
    
    var msgLbl:MyLabel!
    
    var isDirectPush:Bool = false
    var isSafeAreaSet:Bool = false
    
    var iCabBookingId:String = ""
    var dateStr:String = ""
    
    var isOpenFromMainScreen = false
    
    var isDataFetchBlocked = false
    
    var appTypeFilterArr:NSArray!
    var vFilterParam = ""
    var currentWebTask:ExeServerUrl!
    var isFromUFXCheckOut = false
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.configureRTLView()
        
        if(!isDirectPush){
            pageTabBarItem.titleColor = UIColor(hex: 0x141414)
        }
        
        
        if(/*HISTORY_TYPE != "PAST" &&*/ loaderView != nil && self.isFirstCallFinished == true){
            if(isDataFetchBlocked == false){
                
                self.dataArrList.removeAll()
                self.extraHeightContainer.removeAll()
                self.isLoadingMore = false
                self.nextPage_str = 1
                self.isNextPageAvail = false
                
                if(self.tableView != nil){
                    self.removeFooterView()
                    self.tableView.reloadData()
                }
                
                if(self.msgLbl != nil){
                    self.msgLbl.isHidden = true
                }
                
                self.getDtata(isLoadingMore: false)
            }else{
                isDataFetchBlocked = false
            }
           
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(!isDirectPush){
            pageTabBarItem.titleColor = UIColor(hex: 0x737373)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cntView = self.generalFunc.loadView(nibName: "RideHistoryScreenDesign", uv: self, contentView: contentView)
        
        self.contentView.addSubview(cntView)
        
        self.tableView.delegate = self
        self.tableView.bounces = false
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "RideHistoryUFXListTVCell", bundle: nil), forCellReuseIdentifier: "RideHistoryUFXListTVCell")
        self.tableView.register(UINib(nibName: "RideHistoryListTVCell", bundle: nil), forCellReuseIdentifier: "RideHistoryTVCell")
        
        self.tableView.contentInset = UIEdgeInsets.init(top: 6, left: 0, bottom: GeneralFunctions.getSafeAreaInsets().bottom + 6, right: 0)

        userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        APP_TYPE = userProfileJson.get("APP_TYPE")
        
        if(isDirectPush){
            self.addBackBarBtn()
            
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
        }
        
    }
    
    override func closeCurrentScreen() {
        Utils.printLog(msgData: "CloseCalled")
        if(isOpenFromMainScreen || isFromUFXCheckOut == true){
            
            GeneralFunctions.saveValue(key: "FROMCHECKOUT", value: true as AnyObject)
            self.performSegue(withIdentifier: "unwindToUFXHomeScreen", sender: self)
        }else{
            super.closeCurrentScreen()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isDataLoaded == false){
            
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
//                self.cntView.frame = self.view.frame
//                self.cntView.frame.size = CGSize(width: Application.screenSize.width, height: self.view.frame.height)
//                self.cntView.setNeedsLayout()
//
//
//            })

            self.extraHeightContainer.removeAll()
            self.dataArrList.removeAll()
            self.tableView.reloadData()
            self.getDtata(isLoadingMore: self.isLoadingMore)
            
            isDataLoaded = true
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        
        if(isSafeAreaSet == false){
            
            if(cntView != nil){
                self.cntView.frame = self.view.frame
                cntView.frame.size.height = cntView.frame.size.height + GeneralFunctions.getSafeAreaInsets().bottom
            }
            
            isSafeAreaSet = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDtata(isLoadingMore:Bool){
        if(loaderView == nil){
            loaderView =  self.generalFunc.addMDloader(contentView: self.view)
            loaderView.backgroundColor = UIColor.clear
        }else if(loaderView != nil && isLoadingMore == false){
            loaderView.isHidden = false
        }
        
        if(currentWebTask != nil){
            currentWebTask.cancel()
        }

        let parameters = ["type": HISTORY_TYPE == "PAST" ? "getRideHistory" : "checkBookings", "UserType": Utils.appUserType, "iUserId": GeneralFunctions.getMemberd(), "page": self.nextPage_str.description, "vFilterParam": self.vFilterParam]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: false)
        currentWebTask = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(self.navItem != nil){
                    let appTypeFilterArr = dataDict.getArrObj("AppTypeFilterArr")
                    if(appTypeFilterArr.count > 0){
                        self.appTypeFilterArr = appTypeFilterArr
                        let rightButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_filter_list_history")!, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.filterDataTapped))
                        self.navItem.rightBarButtonItem = rightButton
                    }else{
                        self.navItem.rightBarButtonItem = nil
                    }
                }
                
                if(dataDict.get("Action") == "1"){
                    
                    let dataArr = dataDict.getArrObj(Utils.message_str)
                    
                    if(self.isFirstCallFinished == false){
                        self.isFirstCallFinished = true
                    }
                    
                    for i in 0 ..< dataArr.count{
                        let dataTemp = dataArr[i] as! NSDictionary
                        
                        self.dataArrList.append(dataTemp)
                        
                        if(self.HISTORY_TYPE != "PAST"){

                            /**
                             Calculating address height. As source location address is always available, default height of source address label (20) is minus.
                             88 is minus from screen width due to left and right margins from screen. To check label's width, kindly look into design file.
                            */
                            let sourceAddHeight = dataTemp.get("vSourceAddresss").height(withConstrainedWidth: Application.screenSize.width - 88, font: UIFont(name: Fonts().light, size: 16)!) - 19.5
                            
                            var destAddHeight = dataTemp.get("tDestAddress").height(withConstrainedWidth: Application.screenSize.width - 88, font: UIFont(name: Fonts().light, size: 16)!) - 19.5

                            /**
                             If destination address is not available then set destination address height to ZERO.
                            */
                            if((dataTemp.get("tDaddress") == "" && dataTemp.get("tDestAddress") == "") || dataTemp.get("eType") == "Multi-Delivery"){
                                destAddHeight = 0
                            }
                            
                            let vTypeNameTxt = dataTemp.get("vVehicleCategory") != "" ? "\(dataTemp.get("vVehicleCategory")) - \(dataTemp.get("vVehicleType"))" : "\(dataTemp.get("vVehicleType"))"
                            
                            /**
                             Calculate height of vehicle type value. 50 is the default left and right margins from screen.
                             */
                            var vTypeNameHeight = vTypeNameTxt.trim().height(withConstrainedWidth: Application.screenSize.width - 50, font: UIFont(name: Fonts().light, size: 16)!) - 19.5

                            if(vTypeNameHeight < 0){
                                vTypeNameHeight = 0 // setting default value
                            }

                            self.extraHeightContainer.append(sourceAddHeight + destAddHeight + vTypeNameHeight)
                            
                        }else{
                            var packageNameHeight : CGFloat = 0
                            let topPaddingForPackageName : CGFloat = 2
                            
                            if(dataTemp.get("vPackageName") != ""){
                                packageNameHeight = dataTemp.get("vPackageName").height(withConstrainedWidth: Application.screenSize.width - 50, font: UIFont(name: Fonts().light, size: 14)!) + topPaddingForPackageName
                            }
                            
                            let sourceAddHeight = dataTemp.get("tSaddress").height(withConstrainedWidth: Application.screenSize.width - 88, font: UIFont(name: Fonts().light, size: 16)!) - 19.5
                            var destAddHeight = dataTemp.get("tDaddress").height(withConstrainedWidth: Application.screenSize.width - 88, font: UIFont(name: Fonts().light, size: 16)!) - 19.5
                            
                            if((dataTemp.get("tDaddress") == "" && dataTemp.get("tDestAddress") == "") || dataTemp.get("eType") == "Multi-Delivery"){
                                destAddHeight = 0
                            }
                            
                            var vTypeNameTxt  = ""
                            
                            if(dataTemp.get("vPackageName") != ""){
                                vTypeNameTxt = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RENTAL_CATEGORY_TXT")) - "
                            }
                            
                            vTypeNameTxt = "\(vTypeNameTxt)\(dataTemp.get("vVehicleCategory") != "" ? "\(dataTemp.get("vVehicleCategory")) - \(dataTemp.get("vVehicleType"))" : "\(dataTemp.get("vVehicleType"))")"
                            
                            var vTypeNameHeight = vTypeNameTxt.trim().height(withConstrainedWidth: Application.screenSize.width - 50, font: UIFont(name: Fonts().light, size: 16)!) - 19.5
                            
                            if(vTypeNameHeight < 0){
                                vTypeNameHeight = 0 // setting default value
                            }
                            
                            self.extraHeightContainer.append(sourceAddHeight + destAddHeight + vTypeNameHeight + packageNameHeight)
                        }
                        
                    }
                    let NextPage = dataDict.get("NextPage")
                    
                    if(NextPage != "" && NextPage != "0"){
                        self.isNextPageAvail = true
                        self.nextPage_str = Int(NextPage)!
                        
                        self.addFooterView()
                    }else{
                        self.isNextPageAvail = false
                        self.nextPage_str = 0
                        
                        self.removeFooterView()
                    }
                    
                    self.tableView.reloadData()
                    
                    
                    
                }else{
                    if(isLoadingMore == false){
                        if(self.msgLbl != nil){
                            self.msgLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message"))
                            self.msgLbl.isHidden = false
                        }else{
                            self.msgLbl = GeneralFunctions.addMsgLbl(contentView: self.view, msg: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                        }
                        
                    }else{
                        self.isNextPageAvail = false
                        self.nextPage_str = 0
                        
                        self.removeFooterView()
                    }
                    
                }
            }else{
                if(isLoadingMore == false){
                    self.generalFunc.setError(uv: self)
                }
            }

            self.isLoadingMore = false
            self.loaderView.isHidden = true
        })
    }
    
    @objc func filterDataTapped(){
        if(appTypeFilterArr == nil){
            return
        }
        
        var filterDataTitleList = [String]()
        
        for i in 0..<appTypeFilterArr.count{
            let data_tmp = appTypeFilterArr[i] as! NSDictionary
            filterDataTitleList.append(data_tmp.get("vTitle"))
        }
        
        let openListView = OpenListView(uv: self, containerView: self.view)
        openListView.show(listObjects: filterDataTitleList, title: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SELECT_TYPE"), currentInst: openListView, handler: { (selectedItemId) in
            self.vFilterParam = (self.appTypeFilterArr[selectedItemId] as! NSDictionary).get("vFilterParam")
            
            self.dataArrList.removeAll()
            self.extraHeightContainer.removeAll()
            self.isLoadingMore = false
            self.nextPage_str = 1
            self.isNextPageAvail = false
            
            if(self.tableView != nil){
                self.removeFooterView()
                self.tableView.reloadData()
            }
            
            if(self.msgLbl != nil){
                self.msgLbl.isHidden = true
            }
            
            self.getDtata(isLoadingMore: false)
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.dataArrList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.dataArrList[indexPath.item]
        var vBookingNo:String = ""
        
        if((item.get("tDaddress") == "" && item.get("tDestAddress") == "") || item.get("eType") == "Multi-Delivery"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "RideHistoryUFXListTVCell", for: indexPath) as! RideHistoryUFXListTVCell
            
            cell.statusView.isHidden = false
  
            
            if(self.HISTORY_TYPE == "PAST"){
                cell.rideDateLbl.text = Utils.convertDateFormateInAppLocal(date: Utils.convertDateGregorianToAppLocale(date: item.get("tTripRequestDateOrig"), dateFormate: "yyyy-MM-dd HH:mm:ss"), toDateFormate: Utils.dateFormateWithTime)
                cell.pickUpLocVLbl.text = item.get("tSaddress")
                vBookingNo = Configurations.convertNumToAppLocal(numStr: item.get("vRideNo"))
                
                cell.btnContainerView.isHidden = true
                
            }else{
                cell.btnContainerView.isHidden = false
                cell.rideDateLbl.text = Utils.convertDateFormateInAppLocal(date: Utils.convertDateGregorianToAppLocale(date: item.get("dBooking_dateOrig"), dateFormate: "yyyy-MM-dd HH:mm:ss"), toDateFormate: Utils.dateFormateWithTime)
                cell.pickUpLocVLbl.text = item.get("vSourceAddresss")
                vBookingNo = Configurations.convertNumToAppLocal(numStr: item.get("vBookingNo"))
            }
            
            let vTypeNameTxt = item.get("vServiceTitle")
            
            cell.vTypeNameLbl.text = vTypeNameTxt.trim()
            cell.vTypeNameLbl.textColor = UIColor.UCAColor.AppThemeColor_1
            cell.vTypeNameLbl.textAlignment = .center
            
            cell.rentalPackageNameLbl.text = item.get("vPackageName")
            cell.rentalPackageNameLbl.textColor = UIColor.UCAColor.AppThemeColor_1
            cell.rentalPackageNameLbl.textAlignment = .center
            
            if(item.get("vPackageName") == ""){
                cell.rentalPackageNameLbl.text = ""
                cell.rentalPackageNameLbl.isHidden = true
            }else{
                cell.rentalPackageNameLbl.isHidden = false
            }
            
            cell.pickUpLocVLbl.fitText()
            
            let statusH_str = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_Status")): "
            
            if(item.get("eCancelled") == "Yes"){
                cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCELED_TXT")
            }else{
                if(item.get("iActive") == "Canceled"){
                    cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCELED_TXT")
                }else if(item.get("iActive") == "Finished"){
                    cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FINISHED_TXT")
                }else {
                    if(item.get("iActive") == ""){
                        if(item.get("eStatus") == "Pending"){
                            cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PENDING")
                        }else if(item.get("eStatus") == "Cancel"){
//                            cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCELED_TXT")
                            if(item.get("eCancelBy") == "Admin"){
                                cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCELLED_BY_ADMIN")
                            }else if(item.get("eCancelBy") == "Driver"){
                                cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key:  item.get("eType") == Utils.cabGeneralType_Ride ? "LBL_CANCELLED_BY_DRIVER" : (item.get("eType") == Utils.cabGeneralType_UberX ? "LBL_CANCELLED_BY_PROVIDER" : "LBL_CANCELLED_BY_CARRIER"))
                            }else{
                                cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCELED_TXT")
                            }
                        }else if(item.get("eStatus") == "Assign"){
                            cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ASSIGNED")
                        }else if(item.get("eStatus") == "Accepted"){
                            cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ACCEPTED")
                        }else if(item.get("eStatus") == "Declined"){
                            cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DECLINED")
                        }else if(item.get("eStatus") == "Failed"){
                            cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FAILED_TXT")
                        }else{
                            cell.statusVLbl.text = item.get("eStatus")
                        }
                    }else{
                        cell.statusVLbl.text = item.get("iActive") == "" ? item.get("eStatus") : item.get("iActive")
                    }
                }
            }
            
            cell.statusVLbl.textAlignment = .center
            cell.statusVLbl.text =  "\(statusH_str)\(cell.statusVLbl.text!)"
            cell.statusVLbl.halfTextColorChange(fullText: cell.statusVLbl.text!, changeText: statusH_str, withColor: UIColor.UCAColor.AppThemeColor)
            
            cell.bookingNoLbl.text = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BOOKING"))# \(vBookingNo)"
            
            cell.pickUpLocHLbl.text = self.generalFunc.getLanguageLabel(origValue: item.get("eType") == Utils.cabGeneralType_UberX ? "Job Location" : (item.get("eType") == Utils.cabGeneralType_Deliver || item.get("eType") == "Multi-Delivery" ? "Sender's location" : "Pick up location"), key: item.get("eType") == Utils.cabGeneralType_UberX ? "LBL_JOB_LOCATION_TXT" : (item.get("eType") == Utils.cabGeneralType_Deliver || item.get("eType") == "Multi-Delivery" ? "LBL_SENDER_LOCATION" : "LBL_PICK_UP_LOCATION"))
            
            //        cell.rideTypeLbl.text = item.get("eType")
            //        cell.rideTypeLbl.text = item.get("eType") == Utils.cabGeneralType_Deliver ? self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DELIVERY") : self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BOOKING")
            
            cell.rideTypeLbl.text = item.get("eType") == Utils.cabGeneralType_Deliver || item.get("eType") == "Multi-Delivery" ? self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DELIVERY") : (item.get("eType") == Utils.cabGeneralType_Ride ? self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RIDE") : self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BOOKING"))
            
            if(item.get("eType") == Utils.cabGeneralType_UberX){
                cell.rideTypeLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SERVICES")
            }
            
            if(self.APP_TYPE.uppercased() == "RIDE-DELIVERY" || self.APP_TYPE.uppercased() == "RIDE-DELIVERY-UBERX"){
                cell.rideDateLbl.isHidden = false
            }else{
                cell.rideTypeLbl.text = cell.rideDateLbl.text
                cell.rideDateLbl.isHidden = true
            }
            
            cell.reScheduleBookingBtn.btnType = "RE_BOOKING"
            cell.reScheduleBookingBtn.tag = indexPath.item
            cell.reScheduleBookingBtn.clickDelegate = self
            cell.reScheduleBookingBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: item.get("eType") == Utils.cabGeneralType_UberX ? "Re Booking" : "Re Schedule", key: item.get("eType") == Utils.cabGeneralType_UberX ? "LBL_REBOOKING" : "LBL_RESCHEDULE"))
            
            cell.cancelBookingBtn.tag = indexPath.item
            cell.cancelBookingBtn.clickDelegate = self
            
            if(item.get("eStatus") == "Declined" || item.get("eStatus") == "Cancel"){
                
                if(item.get("eType") != Utils.cabGeneralType_UberX && item.get("eAutoAssign").uppercased() == "NO"){
                    cell.reScheduleBookingBtn.isHidden = true
                }else{
                    cell.reScheduleBookingBtn.isHidden = false
                }
                
                cell.cancelBookingBtn.btnType = "VIEW_CANCEL_REASON"
                cell.cancelBookingBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_VIEW_REASON"))
            }else{
                if(item.get("eType") == Utils.cabGeneralType_UberX || item.get("eAutoAssign").uppercased() == "NO"){
                    cell.reScheduleBookingBtn.isHidden = true
                }else{
                    cell.reScheduleBookingBtn.isHidden = false
                }
                cell.cancelBookingBtn.btnType = "CANCEL_BOOKING"
                cell.cancelBookingBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_BOOKING"))
            }
            
            if(userProfileJson.get("SERVICE_PROVIDER_FLOW").uppercased() == "PROVIDER" && item.get("moreServices").uppercased() == "YES"){
                cell.viewServicesListBtn.clickDelegate = self
                cell.viewServicesListBtn.tag = indexPath.row
                cell.viewServicesListBtn.btnType = "MORE_SERVICES"
                cell.viewServicesListBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_VIEW_REQUESTED_SERVICES"))
                cell.viewServicesListBtn.isHidden = false
            }else{
                cell.viewServicesListBtn.clickDelegate = nil
                cell.viewServicesListBtn.isHidden = true
            }
            
            cell.dataView.layer.shadowOpacity = 0.5
            cell.dataView.layer.shadowOffset = CGSize(width: 0, height: 3)
            cell.dataView.layer.shadowColor = UIColor(hex: 0xe6e6e6).cgColor
            
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.clear
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RideHistoryTVCell", for: indexPath) as! RideHistoryTVCell
            

            if(self.HISTORY_TYPE == "PAST"){
                cell.btnContainerView.isHidden = true
                cell.rideDateLbl.text = Utils.convertDateFormateInAppLocal(date: Utils.convertDateGregorianToAppLocale(date: item.get("tTripRequestDateOrig"), dateFormate: "yyyy-MM-dd HH:mm:ss"), toDateFormate: Utils.dateFormateWithTime)
                cell.pickUpLocVLbl.text = item.get("tSaddress")
                cell.destVLbl.text = item.get("tDaddress") == "" ? "----" : item.get("tDaddress")
                vBookingNo = Configurations.convertNumToAppLocal(numStr: item.get("vRideNo"))
                
                cell.btnContainerView.isHidden = true
                
            }else{
                cell.btnContainerView.isHidden = false
                cell.rideDateLbl.text = Utils.convertDateFormateInAppLocal(date: Utils.convertDateGregorianToAppLocale(date: item.get("dBooking_dateOrig"), dateFormate: "yyyy-MM-dd HH:mm:ss"), toDateFormate: Utils.dateFormateWithTime)
                cell.pickUpLocVLbl.text = item.get("vSourceAddresss")
                cell.destVLbl.text = item.get("tDestAddress") == "" ? "----" : item.get("tDestAddress")
                vBookingNo = Configurations.convertNumToAppLocal(numStr: item.get("vBookingNo"))
            }
            
            let vTypeNameTxt = item.get("vServiceTitle")
            
            cell.vehicleTypeLbl.text = vTypeNameTxt
            cell.vehicleTypeLbl.textColor = UIColor.UCAColor.AppThemeColor_1
            cell.vehicleTypeLbl.textAlignment = .center
            
            cell.destVLbl.fitText()
            cell.pickUpLocVLbl.fitText()
            
            cell.rentalPackageNameLbl.text = item.get("vPackageName")
            cell.rentalPackageNameLbl.textColor = UIColor.UCAColor.AppThemeColor_1
            cell.rentalPackageNameLbl.textAlignment = .center
            
            if(item.get("vPackageName") == ""){
                cell.rentalPackageNameLbl.text = ""
                cell.rentalPackageNameLbl.isHidden = true
            }else{
                cell.rentalPackageNameLbl.isHidden = false
            }
            
            let statusH_str = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_Status")): "
            
            if(item.get("eCancelled") == "Yes"){
                if(item.get("eCancelBy") == "Admin"){
                    cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCELLED_BY_ADMIN")
                }else if(item.get("eCancelBy") == "Driver"){
                    cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key:  item.get("eType") == Utils.cabGeneralType_Ride ? "LBL_CANCELLED_BY_DRIVER" : (item.get("eType") == Utils.cabGeneralType_UberX ? "LBL_CANCELLED_BY_PROVIDER" : "LBL_CANCELLED_BY_CARRIER"))
                }else{
                    cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCELED_TXT")
                }
            }else{
                if(item.get("iActive") == "Canceled"){
                    cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCELED_TXT")
                }else if(item.get("iActive") == "Finished"){
                    cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FINISHED_TXT")
                }else {
                    if(item.get("iActive") == ""){
                        if(item.get("eStatus") == "Pending"){
                            cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PENDING")
                        }else if(item.get("eStatus") == "Cancel"){
                            if(item.get("eCancelBy") == "Admin"){
                                cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCELLED_BY_ADMIN")
                            }else if(item.get("eCancelBy") == "Driver"){
                                cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key:  item.get("eType") == Utils.cabGeneralType_Ride ? "LBL_CANCELLED_BY_DRIVER" : (item.get("eType") == Utils.cabGeneralType_UberX ? "LBL_CANCELLED_BY_PROVIDER" : "LBL_CANCELLED_BY_CARRIER"))
                            }else{
                                cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCELED_TXT")
                            }
                        }else if(item.get("eStatus") == "Assign"){
                            cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ASSIGNED")
                        }else if(item.get("eStatus") == "Accepted"){
                            cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ACCEPTED")
                        }else if(item.get("eStatus") == "Declined"){
                            cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DECLINED")
                        }else if(item.get("eStatus") == "Failed"){
                            cell.statusVLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FAILED_TXT")
                        }else{
                            cell.statusVLbl.text = item.get("eStatus")
                        }
                    }else{
                        cell.statusVLbl.text = item.get("iActive") == "" ? item.get("eStatus") : item.get("iActive")
                    }
                }
            }
            
            cell.statusVLbl.textAlignment = .center
            cell.statusVLbl.text =  "\(statusH_str)\(cell.statusVLbl.text!)"
            cell.statusVLbl.halfTextColorChange(fullText: cell.statusVLbl.text!, changeText: statusH_str, withColor: UIColor.UCAColor.AppThemeColor)
            
            cell.reScheduleBookingBtn.tag = indexPath.item
            cell.reScheduleBookingBtn.clickDelegate = self
            
            cell.reScheduleBookingBtn.btnType = "RE_BOOKING"
            cell.reScheduleBookingBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: item.get("eType") == Utils.cabGeneralType_UberX ? "Re Booking" : "Re Schedule", key: item.get("eType") == Utils.cabGeneralType_UberX ? "LBL_REBOOKING" : "LBL_RESCHEDULE"))
            
            cell.cancelBookingBtn.tag = indexPath.item
            cell.cancelBookingBtn.clickDelegate = self
            
            if(item.get("eStatus") == "Declined" || item.get("eStatus") == "Cancel"){
                if(item.get("eType") != Utils.cabGeneralType_UberX && item.get("eAutoAssign").uppercased() == "NO"){
                    cell.reScheduleBookingBtn.isHidden = true
                }else{
                    cell.reScheduleBookingBtn.isHidden = false
                }
                
                cell.cancelBookingBtn.btnType = "VIEW_CANCEL_REASON"
                cell.cancelBookingBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_VIEW_REASON"))
            }else{
                if(item.get("eType") == Utils.cabGeneralType_UberX || item.get("eAutoAssign").uppercased() == "NO"){
                    cell.reScheduleBookingBtn.isHidden = true
                }else{
                    cell.reScheduleBookingBtn.isHidden = false
                }
                
                cell.cancelBookingBtn.btnType = "CANCEL_BOOKING"
                cell.cancelBookingBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_BOOKING"))
            }
            
            cell.bookingNoLbl.text = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BOOKING"))# \(vBookingNo)"
            
//            cell.pickUpLocHLbl.text = self.generalFunc.getLanguageLabel(origValue: "Pick up location", key: "LBL_PICK_UP_LOCATION")
            
            cell.pickUpLocHLbl.text = self.generalFunc.getLanguageLabel(origValue: item.get("eType") == Utils.cabGeneralType_UberX ? "Job Location" : (item.get("eType") == Utils.cabGeneralType_Deliver ? "Sender's location" : "Pick up location"), key: item.get("eType") == Utils.cabGeneralType_UberX ? "LBL_JOB_LOCATION_TXT" : (item.get("eType") == Utils.cabGeneralType_Deliver || item.get("eType") == "Multi-Delivery" ? "LBL_SENDER_LOCATION" : "LBL_PICK_UP_LOCATION"))
            
            
            cell.destHLbl.text = self.generalFunc.getLanguageLabel(origValue: item.get("eType") == Utils.cabGeneralType_Deliver || item.get("eType") == "Multi-Delivery" ? "Receiver's location" : "Destination location", key: item.get("eType") == Utils.cabGeneralType_Deliver || item.get("eType") == "Multi-Delivery" ? "LBL_RECEIVER_LOCATION" : "LBL_DEST_LOCATION")
            
//            cell.destHLbl.text = self.generalFunc.getLanguageLabel(origValue: "Destination location", key: "LBL_DEST_LOCATION")
            
            cell.rideTypeLbl.text = item.get("eType") == Utils.cabGeneralType_Deliver || item.get("eType") == "Multi-Delivery" ? self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DELIVERY") : (item.get("eType") == Utils.cabGeneralType_Ride ? self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RIDE") : self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BOOKING"))
            
            if(item.get("eType") == Utils.cabGeneralType_UberX){
                cell.rideTypeLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SERVICES")
            }
            
            if(self.APP_TYPE.uppercased() == "RIDE-DELIVERY" || self.APP_TYPE.uppercased() == "RIDE-DELIVERY-UBERX"){
                cell.rideDateLbl.isHidden = false
            }else{
                cell.rideTypeLbl.text = cell.rideDateLbl.text
                cell.rideDateLbl.isHidden = true
            }
            
            cell.dataView.layer.shadowOpacity = 0.5
            cell.dataView.layer.shadowOffset = CGSize(width: 0, height: 3)
            cell.dataView.layer.shadowColor = UIColor(hex: 0xe6e6e6).cgColor
            
            cell.dashedView.backgroundColor = UIColor.clear
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                cell.dashedView.addDashedLine(color: UIColor(hex: 0xADADAD), lineWidth: 2)
            })
            
            GeneralFunctions.setImgTintColor(imgView: cell.locPinImgView, color: UIColor(hex: 0xd73030))
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = UIColor.clear
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(self.HISTORY_TYPE == "PAST"){
            
            let item = dataArrList[indexPath.item]
           
            if item.get("eType") == "Multi-Delivery"
            {
            }else{
                let rideDetailUV = GeneralFunctions.instantiateViewController(pageName: "RideDetailUV") as! RideDetailUV
                rideDetailUV.tripDetailDict = self.dataArrList[indexPath.item]
                isDataFetchBlocked = true 
                self.pushToNavController(uv: rideDetailUV)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        //Rental package name related height is managed in extraHeightContainer arr
        if(indexPath.item < self.extraHeightContainer.count){
            let item = dataArrList[indexPath.item]
            
            if((item.get("tDaddress") == "" && item.get("tDestAddress") == "") || item.get("eType") == "Multi-Delivery") {
                if(userProfileJson.get("SERVICE_PROVIDER_FLOW").uppercased() == "PROVIDER" && item.get("moreServices").uppercased() == "YES"){
                   return self.extraHeightContainer[indexPath.item] + (self.HISTORY_TYPE == "PAST" ? 225 : 280 + 55)
                }else{
                    return self.extraHeightContainer[indexPath.item] + (self.HISTORY_TYPE == "PAST" ? 225 : 280)
                }
                
            }else{
                return self.extraHeightContainer[indexPath.item] + (self.HISTORY_TYPE == "PAST" ? 298 : 350)
            }
        }
        
        return (self.HISTORY_TYPE == "PAST" ? 298 : 350)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y;
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if (maximumOffset - currentOffset <= 15) {
            if(isNextPageAvail==true && isLoadingMore==false){
                
                isLoadingMore=true
                
                getDtata(isLoadingMore: isLoadingMore)
            }
        }
    }
    
    func addFooterView(){
        let loaderView =  self.generalFunc.addMDloader(contentView: self.tableView, isAddToParent: false)
        loaderView.backgroundColor = UIColor.clear
        loaderView.frame = CGRect(x:0, y:0, width: Application.screenSize.width, height: 80)
        self.tableView.tableFooterView  = loaderView
        self.tableView.tableFooterView?.isHidden = false
    }
    
    func removeFooterView(){
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView?.isHidden = true
    }
    
    func myBtnTapped(sender: MyButton) {
        
        if(sender.btnType == "RE_BOOKING"){
            
            let item = self.dataArrList[sender.tag]

            if(item.get("eType") == Utils.cabGeneralType_UberX){
                
                var customDataDict = [String:String]()
                
                customDataDict["iVehicleCategoryId"] = item.get("SelectedCategoryId")
                customDataDict["vCategory"] = item.get("SelectedCategory")
                customDataDict["ePriceType"] = item.get("SelectedPriceType")
                customDataDict["vVehicleType"] = item.get("SelectedVehicle")
                customDataDict["eFareType"] = item.get("SelectedFareType")
                customDataDict["fFixedFare"] = "\(item.get("SelectedCurrencySymbol"))\(item.get("SelectedPrice"))"
                customDataDict["fPricePerHour"] = "\(item.get("SelectedCurrencySymbol"))\(item.get("SelectedPrice"))"
                customDataDict["fPricePerKM"] = "\(item.get("SelectedCurrencySymbol"))\(item.get("SelectedPricePerKM"))"
                customDataDict["fPricePerMin"] = "\(item.get("SelectedCurrencySymbol"))\(item.get("SelectedPricePerMin"))"
                customDataDict["iBaseFare"] = "\(item.get("SelectedCurrencySymbol"))\(item.get("SelectedBaseFare"))"
                customDataDict["fCommision"] = "\(item.get("SelectedCurrencySymbol"))\(item.get("SelectedCommision"))"
                customDataDict["iMinFare"] = "\(item.get("SelectedCurrencySymbol"))\(item.get("SelectedMinFare"))"
                customDataDict["iPersonSize"] = "\(item.get("SelectedCurrencySymbol"))\(item.get("SelectedPersonSize"))"
                customDataDict["vVehicleTypeImage"] = item.get("SelectedVehicleTypeImage")
                customDataDict["eType"] = item.get("SelectedeType")
                customDataDict["eIconType"] = item.get("SelectedeIconType")
                customDataDict["eAllowQty"] = item.get("SelectedAllowQty")
                customDataDict["iMaxQty"] = item.get("SelectediMaxQty")
                customDataDict["iVehicleTypeId"] = item.get("iVehicleTypeId")
                customDataDict["fFixedFare_value"] = item.get("SelectedPrice")
                customDataDict["fPricePerHour_value"] = item.get("SelectedPrice")
                customDataDict["ALLOW_SERVICE_PROVIDER_AMOUNT"] = item.get("ALLOW_SERVICE_PROVIDER_AMOUNT")
                customDataDict["vCategoryTitle"] = item.get("SelectedCategoryTitle")
                customDataDict["vCategoryDesc"] = item.get("SelectedCategoryDesc")
                customDataDict["vSymbol"] = item.get("SelectedCurrencySymbol")
                
                let ufxServiceItemDict = customDataDict as NSDictionary

            }else{
                
                let minDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
                let maxDate = Calendar.current.date(byAdding: .month, value: Utils.MAX_DATE_SELECTION_MONTH_FROM_CURRENT, to: Date())
                
                DatePickerDialog().show(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BOOKING_DATE"), doneButtonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SELECT_TXT"), cancelButtonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_TXT"), minimumDate: minDate, maximumDate: maxDate, datePickerMode: .dateAndTime) {
                    (date) -> Void in
                    
                    if(date != nil){
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_GB")
                        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
                        let dateString = dateFormatter.string(from: date!)
                        
                        self.changeBookingDate(iCabBookingId: item.get("iCabBookingId"), dateStr: dateString, eConfirmByUser: "No")
                    }
                }
            }
        }else if(sender.btnType == "MORE_SERVICES"){

        }else if(sender.btnType == "CANCEL_BOOKING"){
            cancelBooking(position: sender.tag)
        }else if(sender.btnType == "VIEW_CANCEL_REASON"){
            
            let item = self.dataArrList[sender.tag]

            self.generalFunc.setError(uv: self, title: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BOOKING_CANCEL_REASON"), content: item.get("vCancelReason"))
        }
        
    }
    
    func cancelBooking(position:Int){
        let openCancelBooking = OpenCancelBooking(uv: self)
        openCancelBooking.cancelTrip(eTripType: self.dataArrList[position].get("eStatus"), iTripId: "", iCabBookingId: self.dataArrList[position].get("iCabBookingId")) { (iCancelReasonId, reason) in
            self.continueCancelBooking(iCabBookingId: self.dataArrList[position].get("iCabBookingId"), reason: reason, iCancelReasonId: iCancelReasonId)
        }
    }
    
    func changeBookingDate(iCabBookingId: String, dateStr:String, eConfirmByUser:String){
        let parameters = ["type":"UpdateBookingDateRideDelivery", "iUserId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType, "iCabBookingId": iCabBookingId, "scheduleDate": dateStr, "eConfirmByUser": eConfirmByUser]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    self.isLoadingMore = false
                    self.dataArrList.removeAll()
                    self.tableView.reloadData()
                    self.nextPage_str = 1
                    
                    if(self.msgLbl != nil){
                        self.msgLbl.isHidden = true
                    }
                    
                    self.getDtata(isLoadingMore: false)
                    
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)))
                    
                }else{
                    if(dataDict.get("SurgePrice") != ""){
                        self.iCabBookingId = iCabBookingId
                        self.dateStr = dateStr
                        self.openSurgeConfirmDialog(dataDict: dataDict)
                        return
                    }
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    }
    
    /**
     This function is used to show surge charge view on screen.
     - parameters:
     - dataDict: server response.
     */
    func openSurgeConfirmDialog(dataDict:NSDictionary){
        var superView:UIView!
        
        if(self.parent != nil && self.parent!.navigationController != nil){
            superView = self.parent!.navigationController!.view!
        }else{
            if(self.pageTabBarController != nil){
                superView = self.pageTabBarController!.view
            }else{
                superView = self.view
            }
        }
        
        let openSurgeChargeView = OpenSurgePriceView(uv: self, containerView: superView)
        openSurgeChargeView.show(userProfileJson: self.userProfileJson, currentFare: dataDict.get("total_fare"), dataDict: dataDict) { (isSurgeAccept, isSurgeLater) in
            if(isSurgeAccept){
                self.changeBookingDate(iCabBookingId: self.iCabBookingId, dateStr: self.dateStr, eConfirmByUser: "Yes")
            }else if(isSurgeLater){
                
            }
        }
    }
    
    func continueCancelBooking(iCabBookingId: String, reason:String, iCancelReasonId: String){
        let parameters = ["type":"cancelBooking", "iUserId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType, "iCabBookingId": iCabBookingId, "Reason": reason, "iCancelReasonId": iCancelReasonId]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    
                    self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                        
                        self.isLoadingMore = false
                        self.dataArrList.removeAll()
                        self.tableView.reloadData()
                        self.nextPage_str = 1
                        self.getDtata(isLoadingMore: false)
                    })
                    
                    
                }else{
                    if(dataDict.get(Utils.message_str) == "DO_RESTART"){
                        let window = Application.window
                        
                        let getUserData = GetUserData(uv: self, window: window!)
                        getUserData.getdata()
                        
                        return
                    }
                    
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    }

    @IBAction func unwindToRideHistoryScreen(_ segue:UIStoryboardSegue) {
        
        if(segue.source.isKind(of: RideDetailUV.self)){
            if(self.HISTORY_TYPE == "PAST"){
                let iTripId = (segue.source as! RideDetailUV).tripDetailDict.get("iTripId")
                var dataList = [NSDictionary]()
                dataList.append(contentsOf: dataArrList)
                
                self.dataArrList.removeAll()
                
                for i in 0..<dataList.count{
                    
                    let item = dataList[i]
                    let tripId = item.get("iTripId")
                    
                    if(iTripId == tripId){
                        item.setValue("Yes", forKey: "is_rating")
                    }
                    
                    self.dataArrList.append(item)
                }
                
                self.tableView.reloadData()
            }
           
        }else if(segue.source.isKind(of: MainScreenUV.self)){
            // Called when booking is successfully finished
            let mainScreenUv = segue.source as! MainScreenUV
            
            if(mainScreenUv.ufxCabBookingId != ""){
                self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "Your selected booking has been updated.", key: "LBL_BOOKING_UPDATED"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                    
                    self.isLoadingMore = false
                    self.dataArrList.removeAll()
                    self.tableView.reloadData()
                    self.nextPage_str = 1
                    
                    if(self.msgLbl != nil){
                        self.msgLbl.isHidden = true
                    }
                    
                    self.getDtata(isLoadingMore: false)
                })
            }
        }
    }
}
