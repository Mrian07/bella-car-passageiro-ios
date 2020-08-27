//
//  RatingUV.swift
//  PassengerApp
//
//  Created by ADMIN on 01/06/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit
import SwiftExtensionData

class RatingUV: UIViewController, MyBtnClickDelegate, MyLabelClickDelegate, UIWebViewDelegate, CMSwitchViewDelegate, RatingViewDelegate {
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var totalFareHLbl: MyLabel!
    @IBOutlet weak var totalFareVLbl: MyLabel!
    @IBOutlet weak var billDateHLbl: MyLabel!
    @IBOutlet weak var billDateVLbl: MyLabel!
    @IBOutlet weak var dashedView: UIView!
//    @IBOutlet weak var billDateVlblXposition: NSLayoutConstraint!
//    @IBOutlet weak var billDateVlblWidth: NSLayoutConstraint!
    @IBOutlet weak var tripGeneralInfoLbl: MyLabel!
    @IBOutlet weak var discountHLbl: MyLabel!
    @IBOutlet weak var discountVLbl: MyLabel!
    @IBOutlet weak var sourceAddressLbl: MyLabel!
    @IBOutlet weak var destAddLbl: MyLabel!
    @IBOutlet weak var howWasLbl: MyLabel!
    @IBOutlet weak var ratingBar: RatingView!
    @IBOutlet weak var commentTxtView: KMPlaceholderTextView!
    @IBOutlet weak var submitBtn: MyButton!
    @IBOutlet weak var addressContainerView: UIView!
    @IBOutlet weak var addressContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var addressContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var rateContainerView: UIView!
    @IBOutlet weak var endLocPinImgView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addressContainerCenterViewYPosition: NSLayoutConstraint!
    @IBOutlet weak var addressContainerSeperatorView: UIView!
    @IBOutlet weak var vTypeLbl: MyLabel!
    @IBOutlet weak var detailsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var detailsArrowImgView: UIImageView!
    @IBOutlet weak var detailsLBl: MyLabel!
    @IBOutlet weak var fareDataContainerView: UIView!
    @IBOutlet weak var fareDataContainerStkView: UIStackView!
    @IBOutlet weak var fareContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var detailsClickView: UIView!
    @IBOutlet weak var walletAmtLbl: MyLabel!
    
    // Give Tip OutLets
    @IBOutlet weak var tipHImgView: UIImageView!
    @IBOutlet weak var giveTipHLbl: MyLabel!
    @IBOutlet weak var giveTipNoteLbl: MyLabel!
    @IBOutlet weak var giveTipPLbl: MyLabel!
    @IBOutlet weak var giveTipNLbl: MyLabel!
    @IBOutlet weak var enterTipTxtField: MyTextField!

    /* FAV DRIVERS CHANGES */
    @IBOutlet weak var favSwitchView: UIView!
    @IBOutlet weak var favSwitch: CMSwitchView!
    @IBOutlet weak var ratingBarXPosition: NSLayoutConstraint!
    @IBOutlet weak var favHLbl: MyLabel!
    @IBOutlet weak var favContainerView: UIView!
    @IBOutlet weak var favCloseView: UIView!
    var isFavSelected = false
    
    /* PAYMENT FLOW CHANGES */
    let webView = UIWebView()
    var activityIndicator:UIActivityIndicatorView!
    /* ................. */
    
    var currentTipMode = "OFF"
    
    let generalFunc = GeneralFunctions()
    
    var loaderView:UIView!
    
    var isPageLoad = false
    var window:UIWindow!
    
    var iTripId = ""
    
    var cntView:UIView!
    
    var PAGE_HEIGHT:CGFloat = 710
    var ENABLE_TIP_MODULE = ""
    
    var giveTipView:UIView!
    var bgTipView:UIView!
    
    var isBottomViewSet = false
    
    var tripFinishView:UIView!
    var tripFinishBGView:UIView!
    
    var isSafeAreaSet = false
    
    var fareContainerViewHeightTemp:CGFloat = 0
    var detailsViewHeightTemp:CGFloat = 0
    
    var eTripType = ""

    var backShowsForWebView = true
    var userProfileJson:NSDictionary!
    
    var ratingBarTapGesture:UITapGestureRecognizer!
    var favSwipeGesture:UISwipeGestureRecognizer!
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.configureRTLView()
        self.navigationController?.navigationBar.layer.zPosition = -1

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //        self.navigationController?.navigationBar.clipsToBounds = false
        self.navigationController?.navigationBar.layer.zPosition = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        window = Application.window!
        
        cntView = self.generalFunc.loadView(nibName: "RatingScreenDesign", uv: self, contentView: scrollView)
        cntView.backgroundColor = UIColor.clear
        self.scrollView.addSubview(cntView)
        self.scrollView.isHidden = true
        
        scrollView.bounces = false
        scrollView.backgroundColor = UIColor.clear
        
        if(PAGE_HEIGHT < self.contentView.frame.height){
            PAGE_HEIGHT = self.contentView.frame.height
        }
        
        /* PAYMENT FLOW CHANGES */
        self.webView.isHidden = true
        /* ........... */
        
        
        userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        setData()
        
        GeneralFunctions.removeValue(key: "isDriverAssigned")
    }
    
    override func viewDidLayoutSubviews() {
        
        if(isSafeAreaSet == false){
            
            if(cntView != nil){
                scrollView.frame.size.height = scrollView.frame.size.height + GeneralFunctions.getSafeAreaInsets().bottom
            }
            
            isSafeAreaSet = true
        }
    }
    
    override func closeCurrentScreen() {
        /* PAYMENT FLOW CHANGES */
        if(GeneralFunctions.getPaymentMethod(userProfileJson: self.userProfileJson) != "1" && self.webView.isHidden == false){
            
            self.closeWebView()
            
            return
        }/* ........... */
        
        let window = Application.window
        
        let getUserData = GetUserData(uv: self, window: window!)
        getUserData.getdata()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isPageLoad == false){
            
            
            cntView.frame.size = CGSize(width: cntView.frame.width, height: PAGE_HEIGHT)
            
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: PAGE_HEIGHT)
            
            if(iTripId != ""){
                self.addBackBarBtn()
            }else{
                backShowsForWebView = true
                self.navigationItem.leftBarButtonItems = []
            }
            
            /* FAV DRIVERS CHANGES */
            if(userProfileJson.get("ENABLE_FAVORITE_DRIVER_MODULE").uppercased() == "YES"){
                
                self.ratingBar.delegate = self
                self.favHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SAVE_AS_FAV_DRIVER")
                favSwitch.dotColor = UIColor(hex: 0xFF0000)
                favSwitch.isUserInteractionEnabled = true
                favSwitch.color = UIColor(hex: 0xADD8E6)
                favSwitch.tintColor = UIColor(hex: 0xADD8E6)
                favSwitch.delegate = self
                
                self.favCloseView.setOnClickListener { (instance) in
                    self.performSwipeAction()
                }
                
                let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
                swipeRight.direction = UISwipeGestureRecognizer.Direction.right
                self.favContainerView.addGestureRecognizer(swipeRight)
                
                let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
                swipeDown.direction = UISwipeGestureRecognizer.Direction.left
                self.favContainerView.addGestureRecognizer(swipeDown)
                
            }/* ............... */
            
            getTripData()
            
            isPageLoad = true
           
        }
        UIApplication.shared.isStatusBarHidden = false
    }
    
    
    
    func setData(){
    
        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RATING")
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RATING")
        
        addressContainerView.layer.shadowOpacity = 0.5
        addressContainerView.layer.shadowOffset = CGSize(width: 0, height: 6)
        addressContainerView.layer.shadowColor = UIColor(hex: 0xe6e6e6).cgColor
        
        rateContainerView.layer.shadowOpacity = 0.5
        rateContainerView.layer.shadowOffset = CGSize(width: 0, height: 6)
        rateContainerView.layer.shadowColor = UIColor(hex: 0xe6e6e6).cgColor
        
        tripGeneralInfoLbl.layer.shadowOpacity = 0.5
        tripGeneralInfoLbl.layer.shadowOffset = CGSize(width: 0, height: 6)
        tripGeneralInfoLbl.layer.shadowColor = UIColor(hex: 0xe6e6e6).cgColor
        
        self.submitBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_SUBMIT_TXT"))
        
        self.totalFareHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_Total_Fare_TXT").uppercased()
        
        self.discountHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DIS_APPLIED").uppercased()
        
        
        self.detailsLBl.text = self.generalFunc.getLanguageLabel(origValue: "Fare details", key: "LBL_FARE_DETAILS")
        self.commentTxtView.placeholder = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_WRITE_COMMENT_HINT_TXT")
        
        self.submitBtn.clickDelegate = self
        
        detailsArrowImgView.transform = CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180))
        
        GeneralFunctions.setImgTintColor(imgView: detailsArrowImgView, color: UIColor(hex: 0x333333))
        
        let detailsViewTapGue = UITapGestureRecognizer()
        detailsViewTapGue.addTarget(self, action: #selector(self.detailsViewTapped))
        
        detailsClickView.isUserInteractionEnabled = true
        detailsClickView.addGestureRecognizer(detailsViewTapGue)
        
        Utils.createRoundedView(view: detailsView, borderColor: UIColor.clear, borderWidth: 0, cornerRadius: 10)
        Utils.createRoundedView(view: tripGeneralInfoLbl, borderColor: UIColor.clear, borderWidth: 0, cornerRadius: 10)
        Utils.createRoundedView(view: addressContainerView, borderColor: UIColor.clear, borderWidth: 0, cornerRadius: 10)
        Utils.createRoundedView(view: rateContainerView, borderColor: UIColor.clear, borderWidth: 0, cornerRadius: 10)

        GeneralFunctions.setImgTintColor(imgView: self.endLocPinImgView, color: UIColor(hex: 0xFF0000))
        
        self.headerView.backgroundColor = UIColor.UCAColor.AppThemeColor
        
        
    }
    
    @objc func detailsViewTapped(){
        if(self.detailsViewHeight.constant > 60){
            
            UIView.animate( withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.detailsArrowImgView.transform = CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180))
                    self.fareContainerViewHeight.constant = 0
                    self.detailsViewHeight.constant = 55
                    self.cntView.layoutIfNeeded()
                    self.view.layoutIfNeeded()
                    self.PAGE_HEIGHT = self.PAGE_HEIGHT - self.fareContainerViewHeightTemp
                    
                    self.cntView.frame.size = CGSize(width: self.cntView.frame.width, height: self.PAGE_HEIGHT)
                    
                    self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.PAGE_HEIGHT)
            })
            
        }else{
            
            UIView.animate( withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.detailsArrowImgView.transform = CGAffineTransform(rotationAngle: -90 * CGFloat(CGFloat.pi/180))
                
                    self.fareContainerViewHeight.constant = self.fareContainerViewHeightTemp
                    self.detailsViewHeight.constant = self.detailsViewHeightTemp
                    self.cntView.layoutIfNeeded()
                    self.view.layoutIfNeeded()
                
                    self.PAGE_HEIGHT = self.PAGE_HEIGHT + self.fareContainerViewHeightTemp
                
                    self.cntView.frame.size = CGSize(width: self.cntView.frame.width, height: self.PAGE_HEIGHT)
                
                    self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.PAGE_HEIGHT)
            })
            
        }
    }
    
    func myBtnTapped(sender: MyButton) {
        if(sender == self.submitBtn){
            
            if(self.ratingBar.rating > 0.0){
                
                //            submitRating()
                if(self.ENABLE_TIP_MODULE == "Yes"){
                    self.loadTipView()
                }else{
                    submitRating(fAmount: "", isCollectTip: "No")
                }
                
            }else{
                Utils.showSnakeBar(msg: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ERROR_RATING_DIALOG_TXT"), uv: self)
            }
            
        }
    }
    
    
    
    func getTripData(){
        scrollView.isHidden = true
        loaderView =  self.generalFunc.addMDloader(contentView: self.view)
        loaderView.backgroundColor = UIColor.clear
        
        let parameters = ["type":"displayFare","iMemberId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType, "iTripId": iTripId]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: false)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: true)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    self.eTripType = dataDict.get("eType")
                    
                    /* FAV DRIVERS CHANGES */
                    if(dataDict.get("eFavDriver").uppercased() == "YES" && self.userProfileJson.get("ENABLE_FAVORITE_DRIVER_MODULE").uppercased() == "YES"){
                        self.favSwitch.configSwitchState(true, animated: false)
                        self.isFavSelected = true
                    }/* ........... */
                    
                    self.howWasLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("eType").uppercased() == Utils.cabGeneralType_Deliver.uppercased() || self.eTripType == "Multi-Delivery"
                        ? "LBL_HOW_WAS_YOUR_DELIVERY" : (dataDict.get("eType").uppercased() == Utils.cabGeneralType_UberX.uppercased() ? "LBL_HOW_WAS_YOUR_BOOKING" : "LBL_HOW_WAS_RIDE")).uppercased()
                    
                    self.billDateHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("eType").uppercased() == Utils.cabGeneralType_Deliver.uppercased() || self.eTripType == "Multi-Delivery" ? "LBL_DELIVERY_DATE_TXT" : (dataDict.get("eType").uppercased() == Utils.cabGeneralType_UberX.uppercased() ? "LBL_BOOK_DATE_TXT" : "LBL_TRIP_DATE_TXT")).uppercased()
                    
                    self.totalFareVLbl.text = Configurations.convertNumToAppLocal(numStr: dataDict.getObj(Utils.message_str).get("FareSubTotal"))
                    self.billDateVLbl.text = Utils.convertDateFormateInAppLocal(date: Utils.convertDateGregorianToAppLocale(date: dataDict.getObj(Utils.message_str).get("tStartDate"), dateFormate: "yyyy-MM-dd HH:mm:ss"), toDateFormate: Utils.dateFormateWithTime)
                    
                    if(dataDict.get("eWalletAmtAdjusted").uppercased() == "YES"){
                        self.totalFareVLbl.font = UIFont(name: Fonts().light, size: 45)!
                        self.walletAmtLbl.text = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_WALLET_AMT_ADJUSTED")): \(dataDict.get("fWalletAmountAdjusted"))"
                        self.walletAmtLbl.isHidden = false
                    }
                    
                    let fDiscount = dataDict.getObj(Utils.message_str).get("fDiscount")
                    let CurrencySymbol = dataDict.getObj(Utils.message_str).get("CurrencySymbol")
                    _ = dataDict.getObj(Utils.message_str).get("vTripPaymentMode")
                    
                    let eCancelled = dataDict.getObj(Utils.message_str).get("eCancelled")
                    let vCancelReason = dataDict.getObj(Utils.message_str).get("vCancelReason")
//                    self.vehicleTypeLbl.text = dataDict.getObj(Utils.message_str).get("carTypeName")
                    
                    if (fDiscount != "" && fDiscount != "0" && fDiscount != "0.00") {
                        self.discountVLbl.text = CurrencySymbol + Configurations.convertNumToAppLocal(numStr: fDiscount)
                    }else{
                        self.discountVLbl.text = "--"
                    }
                    
                    
                    self.vTypeLbl.text = dataDict.getObj(Utils.message_str).get("vServiceDetailTitle")
                    
                    self.vTypeLbl.fitText()
                    
                    let vTypeNameHeight = self.vTypeLbl.text!.height(withConstrainedWidth: Application.screenSize.width - 20, font: UIFont(name: Fonts().light, size: 18)!)

                    self.PAGE_HEIGHT = self.PAGE_HEIGHT + vTypeNameHeight
                    
                    self.ENABLE_TIP_MODULE = dataDict.getObj(Utils.message_str).get("ENABLE_TIP_MODULE")
                    
                    let tSaddress = dataDict.getObj(Utils.message_str).get("tSaddress").trim()
                    let tDAddress = dataDict.getObj(Utils.message_str).get("tDaddress").trim()
                    
                    self.sourceAddressLbl.text = tSaddress
                    self.destAddLbl.text = tDAddress
                    self.sourceAddressLbl.fitText()
                    self.destAddLbl.fitText()
                    
                    let sourceAddHeight = tSaddress.height(withConstrainedWidth: Application.screenSize.width - 101, font: UIFont(name: Fonts().semibold, size: 18)!)
                    
                    let destAddHeight = tDAddress.height(withConstrainedWidth: Application.screenSize.width - 101, font: UIFont(name: Fonts().semibold, size: 18)!)
                    
                    let Yoffset = (sourceAddHeight - destAddHeight) / 2
                    
                    self.addressContainerCenterViewYPosition.constant = Yoffset
                    
                    self.addressContainerViewHeight.constant = 40 + sourceAddHeight + destAddHeight
                    
                    self.iTripId = dataDict.getObj(Utils.message_str).get("iTripId")
                    
                    if(tDAddress.trim() == ""){
                        self.destAddLbl.text = ""
                        self.destAddLbl.fitText()
                        self.dashedView.isHidden = true
                        self.endLocPinImgView.isHidden = true
                        self.addressContainerViewHeight.constant = sourceAddHeight + 20
                        self.addressContainerSeperatorView.isHidden = true
                        self.addressContainerCenterViewYPosition.constant = (self.addressContainerViewHeight.constant / 2)
                    }
                    
                    if(eCancelled == "Yes"){
                        
                        self.tripGeneralInfoLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("eType").uppercased() == Utils.cabGeneralType_Deliver.uppercased() || self.eTripType == "Multi-Delivery" ? "LBL_PREFIX_DELIVERY_CANCEL_DRIVER" : ( dataDict.get("eType").uppercased() == Utils.cabGeneralType_UberX.uppercased() ? "LBL_PREFIX_JOB_CANCEL_PROVIDER" : "LBL_PREFIX_TRIP_CANCEL_DRIVER")) + " \(vCancelReason)"
                        self.tripGeneralInfoLbl.isHidden = false
                        self.tripGeneralInfoLbl.fitText()
                    }else{
                        self.tripGeneralInfoLbl.isHidden = true
                        self.addressContainerViewTopMargin.constant = self.addressContainerViewTopMargin.constant - 55
                        self.PAGE_HEIGHT = self.PAGE_HEIGHT - 40
                    }
                    
                    
                    self.addFareDetails(dataDict: dataDict)
                    
//                    self.tripGeneralInfoLbl.fitText()
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                        
                        self.dashedView.addDashedLine(color: UIColor(hex: 0xADADAD), lineWidth: 2)
                        
                        self.setPageHeight()
                    })
                    
                    self.loaderView.isHidden = true
                    self.scrollView.isHidden = false
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
            
        })
    }
    
    
    func setPageHeight(){
        let pageHeight_tmp = Application.screenSize.height - 64
        let btnFrameY = self.submitBtn.frame.maxY + 25
        self.PAGE_HEIGHT = pageHeight_tmp > btnFrameY ? pageHeight_tmp : btnFrameY
        
        self.cntView.frame.size = CGSize(width: self.cntView.frame.width, height: self.PAGE_HEIGHT)
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.PAGE_HEIGHT)
        
    }
    
    func addFareDetails(dataDict:NSDictionary){
        
        let FareDetailsNewArr = dataDict.getObj(Utils.message_str).getArrObj("FareDetailsNewArr")
        
        var totalSeperatorViews = 0
        let seperatorViewHeight = 1
        
        for i in 0..<FareDetailsNewArr.count {
            
            let dict_temp = FareDetailsNewArr[i] as! NSDictionary
            
            for (key, value) in dict_temp {
                
                let totalSubViewCounts = self.fareDataContainerView.subviews.count
                
                if((key as! String) == "eDisplaySeperator"){
                    
                    let viewWidth = Application.screenSize.width - 20
                    
                    let viewCus = UIView(frame: CGRect(x: 10, y: CGFloat((totalSubViewCounts - totalSeperatorViews) * 40 + (totalSeperatorViews * seperatorViewHeight)), width: viewWidth - 20, height: 1))
                    
                    viewCus.backgroundColor = UIColor(hex: 0xdedede)
                    
//                    self.fareDataContainerStkView.addArrangedSubview(viewCus)
                    self.fareDataContainerView.addSubview(viewCus)
                    
                    totalSeperatorViews = totalSeperatorViews + 1
                }else{
                    let viewWidth = Application.screenSize.width - 20
                    
//                    let viewCus = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: 40))
                     let viewCus = UIView(frame: CGRect(x: 0, y:  CGFloat((totalSubViewCounts - totalSeperatorViews) * 40 + (totalSeperatorViews * seperatorViewHeight)), width: viewWidth, height: 40))
                    
                    let titleStr = Configurations.convertNumToAppLocal(numStr: key as! String)
                    let valueStr = Configurations.convertNumToAppLocal(numStr: value as! String)
                    
                    let font = UIFont(name: Fonts().light, size: 16)!
                    var widthOfTitle = titleStr.width(withConstrainedHeight: 40, font: font) + 15
                    var widthOfvalue = valueStr.width(withConstrainedHeight: 40, font: font) + 15
                    
                    if(widthOfTitle > ((viewWidth * 20) / 100) && widthOfvalue > ((viewWidth * 80) / 100)){
                        widthOfvalue = ((viewWidth * 80) / 100)
                        widthOfTitle = ((viewWidth * 20) / 100)
                    }else if(widthOfTitle < ((viewWidth * 20) / 100) && widthOfvalue > ((viewWidth * 80) / 100) && (viewWidth - widthOfTitle - widthOfvalue) < 0){
                        widthOfvalue = viewWidth - widthOfTitle
                    }
                    
                    let widthOfParentView = viewWidth - widthOfvalue
                    
                    var lblTitle = MyLabel(frame: CGRect(x: 0, y: 0, width: widthOfParentView - 5, height: 40))
                    var lblValue = MyLabel(frame: CGRect(x: widthOfParentView, y: 0, width: widthOfvalue, height: 40))
                    
                    if(Configurations.isRTLMode()){
                        lblTitle = MyLabel(frame: CGRect(x: widthOfvalue + 5, y: 0, width: widthOfParentView, height: 40))
                        lblValue = MyLabel(frame: CGRect(x: 0, y: 0, width: widthOfvalue, height: 40))
                        
                        lblTitle.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 15)
                        lblValue.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 15, paddingRight: 0)
                    }else{
                        lblTitle.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 15, paddingRight: 0)
                        lblValue.setPadding(paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 15)
                    }
                    
                    lblTitle.textColor = UIColor(hex: 0x272727)
                    lblValue.textColor = UIColor(hex: 0x272727)
                    
                    lblTitle.font = font
                    lblValue.font = font
                    
                    lblTitle.numberOfLines = 2
                    lblValue.numberOfLines = 2
                    
                    lblTitle.minimumScaleFactor = 0.5
                    lblValue.minimumScaleFactor = 0.5
                    
                    lblTitle.text = titleStr
                    lblValue.text = valueStr
                    
                    viewCus.addSubview(lblTitle)
                    viewCus.addSubview(lblValue)
                    
//                    self.fareDataContainerStkView.addArrangedSubview(viewCus)
                    self.fareDataContainerView.addSubview(viewCus)
                    
                    if(Configurations.isRTLMode()){
                        lblValue.textAlignment = .left
                    }else{
                        lblValue.textAlignment = .right
                    }
                }
            }
        }
        
        self.fareDataContainerStkView.layoutIfNeeded()
        
//        self.fareContainerViewHeightTemp = CGFloat(40 * FareDetailsNewArr.count)
        self.fareContainerViewHeightTemp = CGFloat((self.fareDataContainerView.subviews.count - totalSeperatorViews) * 40 + (totalSeperatorViews * seperatorViewHeight))

        self.detailsViewHeightTemp = self.detailsViewHeight.constant +  self.fareContainerViewHeightTemp
        
//        self.detailsViewHeight.constant = self.detailsViewHeight.constant +  self.fareContainerViewHeight.constant
        
//        self.PAGE_HEIGHT = self.PAGE_HEIGHT + self.detailsViewHeight.constant
        
//        self.cntView.frame.size = CGSize(width: self.contentView.frame.width, height: self.PAGE_HEIGHT)
//        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.PAGE_HEIGHT)

        
    }
    
    
    
    func submitRating(fAmount:String, isCollectTip:String){
        
        if(bgTipView != nil){
            bgTipView.removeFromSuperview()
        }
        
        if(giveTipView != nil){
            giveTipView.removeFromSuperview()
        }
        
        let parameters = ["type":"submitRating","iMemberId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType, "tripID": iTripId, "rating": "\(self.ratingBar.rating)", "message": "\(commentTxtView.text!)", "fAmount": fAmount, "isCollectTip": isCollectTip, "eFavDriver": self.isFavSelected == true ? "Yes" : "No"]  /* FAV DRIVERS CHANGES */
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: true)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    
                    self.loadTripFinishView()
                    
                }else{
                    if(dataDict.get(Utils.message_str) == "LBL_REQUIRED_MINIMUM_AMOUT"){
                        
                        self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)) + " " + dataDict.get("minValue"))
                        
                    }else{
                        self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                    }
                    
                    self.currentTipMode = "OFF"

                }
                
            }else{
                self.generalFunc.setError(uv: self)
                self.currentTipMode = "OFF"

            }
        })
    }
    

    func loadTripFinishView(){
        let tripFinishView = self.generalFunc.loadView(nibName: "TripFinishView", uv: self, isWithOutSize: true)
        
        self.tripFinishView = tripFinishView
        
        let width = Application.screenSize.width  > 380 ? 370 : Application.screenSize.width - 50
        
        tripFinishView.frame.size = CGSize(width: width, height: 270)
        
        tripFinishView.center = CGPoint(x: Application.screenSize.width / 2, y: Application.screenSize.height / 2)
        
//        tripFinishView.center = CGPoint(x: self.contentView.bounds.midX, y: self.contentView.bounds.midY)
        
        let bgView = UIView()
//        bgView.frame = self.contentView.frame
        self.tripFinishBGView = bgView
        
        bgView.frame = CGRect(x:0, y:0, width:Application.screenSize.width, height: Application.screenSize.height)
        
        bgView.center = CGPoint(x: Application.screenSize.width / 2, y: Application.screenSize.height / 2)
        
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.4
        bgView.isUserInteractionEnabled = true
        
        tripFinishView.layer.shadowOpacity = 0.5
        tripFinishView.layer.shadowOffset = CGSize(width: 0, height: 3)
        tripFinishView.layer.shadowColor = UIColor.black.cgColor
        
//        self.view.addSubview(bgView)
//        self.view.addSubview(tripFinishView)

        
        _ = Application.window
        
        if(self.navigationController != nil){
//            currentWindow?.addSubview(bgView)
//            currentWindow?.addSubview(tripFinishView)
            
            self.navigationController?.view.addSubview(bgView)
            self.navigationController?.view.addSubview(tripFinishView)
            
        }else{
            self.view.addSubview(bgView)
            self.view.addSubview(tripFinishView)
        }
        
        bgView.alpha = 0
        tripFinishView.alpha = 0
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                bgView.alpha = 0.4
                tripFinishView.alpha = 1
                
        }
        )
        
        Utils.createRoundedView(view: tripFinishView, borderColor: UIColor.clear, borderWidth: 0, cornerRadius: 10)
        
        GeneralFunctions.setImgTintColor(imgView: (tripFinishView.subviews[0] as! UIImageView), color: UIColor.UCAColor.AppThemeColor)
        
        (tripFinishView.subviews[1] as! MyLabel).text = self.generalFunc.getLanguageLabel(origValue: "", key: self.eTripType.uppercased() == Utils.cabGeneralType_UberX.uppercased() ? "LBL_JOB_SUCCESS_FINISHED" : (self.eTripType.uppercased() == Utils.cabGeneralType_Deliver.uppercased() || self.eTripType == "Multi-Delivery" ? "LBL_DELIVERY_SUCCESS_FINISHED" : "LBL_SUCCESS_FINISHED"))
        
        (tripFinishView.subviews[2] as! MyLabel).text = self.generalFunc.getLanguageLabel(origValue: "", key: self.eTripType.uppercased() == Utils.cabGeneralType_Deliver.uppercased() || self.eTripType == "Multi-Delivery" ? "LBL_DELIVERY_FINISHED_TXT" : (self.eTripType.uppercased() == Utils.cabGeneralType_UberX.uppercased() ? "LBL_BOOKING_FINISHED_TXT" : "LBL_TRIP_FINISHED_TXT"))
        (tripFinishView.subviews[2] as! MyLabel).fitText()
        
        (tripFinishView.subviews[4] as! MyLabel).text = self.generalFunc.getLanguageLabel(origValue: "OK THANKS", key: "LBL_OK_THANKS").uppercased()
        
        
        let okTapGue = UITapGestureRecognizer()
        
        okTapGue.addTarget(self, action: #selector(self.tripFinishOkTapped))
        
        (tripFinishView.subviews[4] as! MyLabel).isUserInteractionEnabled = true
        
        (tripFinishView.subviews[4] as! MyLabel).addGestureRecognizer(okTapGue)
    }
    
    func loadTipView(){
        giveTipView = self.generalFunc.loadView(nibName: "GiveTipView", uv: self, isWithOutSize: true)
        
        let width = Application.screenSize.width  > 380 ? 370 : Application.screenSize.width - 50
        
        giveTipView.frame.size = CGSize(width: width, height: 300)
        
        
        giveTipView.center = CGPoint(x: Application.screenSize.width / 2, y: Application.screenSize.height / 2)
        
        bgTipView = UIView()
        bgTipView.frame = CGRect(x: 0, y: 0, width: Application.screenSize.width, height: Application.screenSize.height)
        
        bgTipView.backgroundColor = UIColor.black
        bgTipView.alpha = 0.4
        bgTipView.isUserInteractionEnabled = true
        
        giveTipView.layer.shadowOpacity = 0.5
        giveTipView.layer.shadowOffset = CGSize(width: 0, height: 3)
        giveTipView.layer.shadowColor = UIColor.black.cgColor
        
//        self.view.addSubview(bgTipView)
//        self.view.addSubview(giveTipView)

        if(self.navigationController != nil){
            //            currentWindow?.addSubview(bgView)
            //            currentWindow?.addSubview(tripFinishView)
            
            self.navigationController?.view.addSubview(bgTipView)
            self.navigationController?.view.addSubview(giveTipView)
            
        }else{
            self.view.addSubview(bgTipView)
            self.view.addSubview(giveTipView)
        }
        
        Utils.createRoundedView(view: giveTipView, borderColor: UIColor.clear, borderWidth: 0, cornerRadius: 10)
        
        GeneralFunctions.setImgTintColor(imgView: tipHImgView, color: UIColor.UCAColor.AppThemeColor)
        
        self.giveTipPLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_GIVE_TIP_TXT")
        self.giveTipNLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_NO_THANKS")
        self.giveTipNoteLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TIP_TXT")
        self.giveTipHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TIP_TITLE_TXT")
        self.giveTipNoteLbl.fitText()
        
        self.enterTipTxtField.isHidden = true
        self.enterTipTxtField.getTextField()!.keyboardType = .decimalPad
        
        self.giveTipNLbl.setClickDelegate(clickDelegate: self)
        self.giveTipPLbl.setClickDelegate(clickDelegate: self)
        
        
        self.enterTipTxtField.getTextField()!.keyboardType = .numberPad
        
    }
    
    func myLableTapped(sender: MyLabel) {
        if(sender == self.giveTipPLbl){
            
            if(currentTipMode == "ON"){
                let tipEntered = Utils.checkText(textField: self.enterTipTxtField.getTextField()!) ? true : Utils.setErrorFields(textField: self.enterTipTxtField.getTextField()!, error: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FEILD_REQUIRD_ERROR_TXT"))
                
                if(tipEntered){
                    
                    /* PAYMENT FLOW CHANGES */
                    
                    if(GeneralFunctions.getPaymentMethod(userProfileJson: userProfileJson) == "1"){
                        submitRating(fAmount: "\(Utils.getText(textField: self.enterTipTxtField.getTextField()!))", isCollectTip: "Yes")
                    }else{
                        
                        let amount_str = Utils.getText(textField: self.enterTipTxtField.getTextField()!)
                        let date = Date()
                        let nowDate:String = Utils.convertDateToFormate(date: date, formate: "yyyy-MM-dd HH:mm:ss")
                        let urlStr = "\(CommonUtils.PAYMENTLINK)amount=\(amount_str)&iUserId=\(GeneralFunctions.getMemberd())&UserType=\(Utils.appUserType)&vUserDeviceCountry=\(GeneralFunctions.getValue(key: Utils.DEFAULT_COUNTRY_KEY)!)&ccode=\(userProfileJson.get("vCurrencyPassenger"))&UniqueCode=\(nowDate)&eForTip=Yes&iTripId=\(iTripId)"
                        
                        self.addBackBarBtn()
                        self.giveTipView.isHidden = true
                        self.bgTipView.isHidden = true
                        self.webView.isHidden = false
                        self.webView.frame = self.view.bounds
                        self.webView.backgroundColor = UIColor.white
                        webView.delegate = self
                        self.contentView.addSubview(webView)
                        
                        self.activityIndicator = UIActivityIndicatorView.init(frame: CGRect(x:(self.webView.frame.width / 2) - 10, y:(self.webView.frame.height / 2) - 10, width: 20, height:20))
                        activityIndicator.style = .gray
                        activityIndicator.hidesWhenStopped = true
                        
                        self.contentView.addSubview(activityIndicator)
                        
                        let urlString = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        let url = URL.init(string: urlString!)
                        webView.loadRequest(URLRequest(url: url!))
                        
                        
                        
                    }/* .............. */
                    
                }
            }else{
                
                self.enterTipTxtField.isHidden = false
                self.giveTipNoteLbl.isHidden = true
                
                self.giveTipPLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT")
                self.giveTipNLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SKIP_TXT")
                self.giveTipHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TIP_AMOUNT_ENTER_TITLE")
                
                currentTipMode = "ON"
            }
            
        }else if(sender == self.giveTipNLbl){
            submitRating(fAmount: "", isCollectTip: "No")
        }
    }

    
    @objc func tripFinishOkTapped(){
        if(tripFinishBGView != nil){
            tripFinishBGView.removeFromSuperview()
        }
        
        if(tripFinishView != nil){
            tripFinishView.removeFromSuperview()
        }
        
        GeneralFunctions.saveValue(key: Utils.MULTI_DELIVERY_DETAIL_STORED, value: false as AnyObject)
        self.closeCurrentScreen()
//        if(self.navigationItem.leftBarButtonItem != nil){
//            self.closeCurrentScreen()
//        }else{
//            let getUserData = GetUserData(uv: self, window: self.window!)
//            getUserData.getdata()
//        }
    }
    
    /* FAV DRIVERS CHANGES */
    func ratingView(_ ratingView: RatingView, didChangeRating newRating: Float) {
       
        if(userProfileJson.get("ENABLE_FAVORITE_DRIVER_MODULE").uppercased() == "YES"){
            
            self.perform(#selector(performSwipeAction), with: self, afterDelay: 0.5)
        }
    }
    
    @objc func performSwipeAction(){
       
        if(ratingBarXPosition.constant == 0){
            
            ratingBarTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(performSwipeAction))
            self.ratingBar.isUserInteractionEnabled = true
            self.ratingBar.addGestureRecognizer(ratingBarTapGesture)
            
            view.layoutIfNeeded()
            
            let xConstant = self.ratingBar.frame.origin.x + ((self.ratingBar.frame.width / 2) + (self.ratingBar.frame.width / 2) - 35)
            if(Configurations.isRTLMode()){
                ratingBarXPosition.constant = xConstant
            }else{
                ratingBarXPosition.constant = 0 - xConstant
            }
            
            self.ratingBar.editable = false
            self.favSwitchView.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                
            })
            
        }else{
            
            self.ratingBar.removeGestureRecognizer(ratingBarTapGesture)
            view.layoutIfNeeded()
            
            ratingBarXPosition.constant = 0
            self.ratingBar.editable = true
            self.favSwitchView.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                
            })
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                if(Configurations.isRTLMode()){
                    if(ratingBarXPosition.constant == 0){
                        self.performSwipeAction()
                    }
                }else{
                    if(ratingBarXPosition.constant != 0){
                        self.performSwipeAction()
                    }
                }
                
                break
            case UISwipeGestureRecognizer.Direction.left:
                if(Configurations.isRTLMode()){
                    if(ratingBarXPosition.constant != 0){
                        self.performSwipeAction()
                    }
                }else{
                    if(ratingBarXPosition.constant == 0){
                        self.performSwipeAction()
                    }
                }
               
                break
            default:
                break
            }
        }
    }
    
    func switchValueChanged(_ sender: Any!, andNewValue value: Bool) {
        if (value == true) {
            self.isFavSelected = true
            self.favSwitch.dotColor = UIColor(hex: 0x009900)
        } else {
            self.isFavSelected = false
            self.favSwitch.dotColor = UIColor(hex: 0xFF0000)
        }
    }/* ........... */
    
    /* PAYMENT FLOW CHANGES */
    func closeWebView(){
        
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.scrollView.scrollToTop()
        self.webView.isHidden = true
        self.webView.delegate = nil
        self.webView.removeFromSuperview()
        if(activityIndicator != nil){
            activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
        
        if(self.giveTipView != nil){
            self.giveTipView.isHidden = false
            self.bgTipView.isHidden = false
        }
        
        
        if(backShowsForWebView == true){
            self.navigationItem.leftBarButtonItems = []
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        if(activityIndicator != nil){
            self.activityIndicator.startAnimating()
        }
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if(activityIndicator != nil){
            self.activityIndicator.stopAnimating()
        }
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        let url : URL? = request.url
        
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        
        let urlString : String = url!.absoluteString
        
        if (urlString.contains(find: "sucess=1")){
            
            submitRating(fAmount: "", isCollectTip: "No")
            self.closeWebView()
            
        }else if (urlString.contains(find: "sucess=0")){
            
            self.closeWebView()
            self.generalFunc.setError(uv: self)
            
        }
        
        return true
        
    }/* ............... */
}
