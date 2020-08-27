//
//  SelectPaymentProfileUV.swift
//  PassengerApp
//
//  Created by Admin on 08/10/18.
//  Copyright © 2018 V3Cube. All rights reserved.
//

import UIKit
import SwiftExtensionData

class SelectPaymentProfileUV: UIViewController, MyBtnClickDelegate, BEMCheckBoxDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doneBtn: MyButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var selectProfileView: UIView!
    @IBOutlet weak var selectProfileArrowImgView: UIImageView!
    @IBOutlet weak var profileLbl: MyLabel!
    @IBOutlet weak var profileIconImgView: UIImageView!
    @IBOutlet weak var hLbl: MyLabel!
    @IBOutlet weak var reasonsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var reasonLbl: MyLabel!
    @IBOutlet weak var reasonHLbl: MyLabel!
    @IBOutlet weak var reasonArrowImgView: UIImageView!
    @IBOutlet weak var reasonParentView: UIView!
    @IBOutlet weak var reaosnSelectView: UIView!
    @IBOutlet weak var writeReasonHLbl: MyLabel!
    @IBOutlet weak var writeReasonTxtView: UITextView!
    @IBOutlet weak var writeReasonView: UIView!
    @IBOutlet weak var writeReasonViewHeight: NSLayoutConstraint!

    @IBOutlet weak var paymentOptionView: UIView!
    @IBOutlet weak var paymentOptionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var paymentHLbl: MyLabel!
    @IBOutlet weak var useWalletChkBox: BEMCheckBox!
    @IBOutlet weak var useWalletLbl: MyLabel!
    @IBOutlet weak var addWalletBalLbl: MyLabel!
    
    @IBOutlet weak var useWalletView: UIView!
    @IBOutlet weak var cashPayModeView: UIView!
    @IBOutlet weak var cardPayModeView: UIView!
    @IBOutlet weak var cashPayLbl: MyLabel!
    @IBOutlet weak var cardPayLbl: MyLabel!
    @IBOutlet weak var cashPayImgView: UIImageView!
    @IBOutlet weak var cardPayImgView: UIImageView!
    
    var isSafeAreaSet = false
    var iphoneXBottomView:UIView!
    
    var isCashPayment = true
    var isCardValidated = false
    var isPayByOrganization = false
    
    let generalFunc = GeneralFunctions()
    
    var cntView:UIView!
    
    var PAGE_HEIGHT:CGFloat = 505
    

    var organizationDataArr = [NSDictionary]()
    
    var isPersonalProfileSelected = true
    
    var selectedProfileId = ""
    var selectedReasonId = ""
    
    var userProfileJson:NSDictionary!
    
    var selectedProfileDataDict:NSDictionary!
    
    var isAutoContinue_payBox = false
    
    var isOtherReasonSelected = false
    
    // variables for retrival process
    var retrival_eWalletDebitAllow = false
    var retrival_isCashPayment = false
    var retrival_isCardValidated = false
    var retrival_iUserProfileId = ""
    var retrival_iOrganizationId = ""
    var retrival_isPayByOrganization = false
    var retrival_vProfileEmail = ""
    var retrival_vProfileName = ""
    var retrival_ePaymentBy = ""
    var retrival_iTripReasonId = ""
    var retrival_reasonTitleOfId = ""
    var retrival_vReasonTitle = ""
    var retrival_selectedProfileDataDict:NSDictionary!
    
    override func viewWillAppear(_ animated: Bool) {
        self.configureRTLView()
       
        self.userProfileJson =  (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        if(self.useWalletLbl != nil){
            self.useWalletLbl.text = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_USE_WALLET_BALANCE"))\n(\(Configurations.convertNumToAppLocal(numStr: userProfileJson.get("user_available_balance"))))"
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        if(isSafeAreaSet == false){
            
            if(Configurations.isIponeXDevice()){
                
                if(iphoneXBottomView == nil){
                    iphoneXBottomView = UIView()
                    self.view.addSubview(iphoneXBottomView)
                }
                
                iphoneXBottomView.backgroundColor = UIColor.UCAColor.AppThemeColor_1
                iphoneXBottomView.frame = CGRect(x: 0, y: self.view.frame.maxY - GeneralFunctions.getSafeAreaInsets().bottom, width: Application.screenSize.width, height: GeneralFunctions.getSafeAreaInsets().bottom)
            }
            
            isSafeAreaSet = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addBackBarBtn()
        
        cntView = self.generalFunc.loadView(nibName: "SelectPaymentProfileScreenDesign", uv: self, contentView: scrollView)
        
        self.scrollView.addSubview(cntView)

        self.scrollView.bounces = false
        
        self.userProfileJson =  (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        
        self.cntView.frame.size = CGSize(width: self.scrollView.frame.width, height: PAGE_HEIGHT)
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: PAGE_HEIGHT)
        
        selectProfileArrowImgView.transform = CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180))
        GeneralFunctions.setImgTintColor(imgView: selectProfileArrowImgView, color: UIColor(hex: 0x272727))
        
        reasonArrowImgView.transform = CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180))
        GeneralFunctions.setImgTintColor(imgView: reasonArrowImgView, color: UIColor(hex: 0x272727))
        
        doneBtn.clickDelegate = self
        
        selectProfileView.layer.shadowOpacity = 0.5
        selectProfileView.layer.shadowOffset = CGSize(width: 0, height: 3)
        selectProfileView.layer.shadowColor = UIColor(hex: 0xe6e6e6).cgColor
        
        reaosnSelectView.layer.shadowOpacity = 0.5
        reaosnSelectView.layer.shadowOffset = CGSize(width: 0, height: 3)
        reaosnSelectView.layer.shadowColor = UIColor(hex: 0xe6e6e6).cgColor
        
        selectProfileView.setOnClickListener { (instance) in
            self.findOrganizationList()
        }
        
        reaosnSelectView.setOnClickListener { (instance) in
            self.openReasonList()
        }
        
        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.cntView.frame.size = CGSize(width: self.scrollView.frame.width, height: PAGE_HEIGHT)
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: PAGE_HEIGHT)
    }
    
   
    
    func setRetrivalData(){
        if(self.retrival_iUserProfileId != "" && self.retrival_selectedProfileDataDict != nil){
            isPersonalProfileSelected = false
            profileLbl.text = self.retrival_vProfileName
            self.selectedProfileId = self.retrival_iUserProfileId
            
            self.selectedProfileDataDict = self.retrival_selectedProfileDataDict
            
            self.reasonParentView.isHidden = false
            self.reasonsViewHeight.constant = 85
            
            self.profileIconImgView.showActivityIndicator(.gray)
            self.profileIconImgView.sd_setImage(with: URL(string: self.retrival_selectedProfileDataDict.get("vImage")), placeholderImage: UIImage(named:"ic_no_icon"), options: SDWebImageOptions(rawValue: 0), completed: nil)
        }
        
        if(self.retrival_iTripReasonId != ""){
            self.selectedReasonId = self.retrival_iTripReasonId
            self.writeReasonView.isHidden = true
            self.writeReasonViewHeight.constant = 0
            
            self.isOtherReasonSelected = false
        }else if(self.retrival_vReasonTitle != ""){
            self.selectedReasonId = ""
            writeReasonTxtView.text = self.retrival_vReasonTitle
            self.isOtherReasonSelected = true
        }
        
        if(self.retrival_reasonTitleOfId != ""){
            self.reasonLbl.text = self.retrival_reasonTitleOfId
        }
        
        self.isPayByOrganization = self.retrival_isPayByOrganization
        
        if(self.isPayByOrganization == true){
            self.configPaymentOptionView(true)
        }else{
            self.configPaymentOptionView(false)
        }
        
        if(self.retrival_eWalletDebitAllow == true){
            self.useWalletChkBox.on = true
        }else{
            self.useWalletChkBox.on = false
        }
        
        if(self.retrival_isCashPayment == true){
            self.cashViewTapped()
        }else{
            self.selectCard()
            self.isCardValidated = self.retrival_isCardValidated
        }
    }
    
    func setData(){
        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PROFILE_PAYMENT")
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PROFILE_PAYMENT")
        self.reasonHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_REASON")
        self.hLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SELECT_PROFILE")
        self.writeReasonHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_WRITE_REASON_BELOW")
        doneBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_DONE"))
        self.paymentHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SELECT_PAY_MODE")
        
        self.useWalletLbl.text = "\(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_USE_WALLET_BALANCE"))\n(\(Configurations.convertNumToAppLocal(numStr: userProfileJson.get("user_available_balance"))))"
        self.cashPayLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CASH_PAYMENT_TXT")
        self.cardPayLbl.text = self.generalFunc.getLanguageLabel(origValue: "Pay online", key: "LBL_PAY_ONLINE_TXT")
        
        self.addWalletBalLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ACTION_ADD").uppercased()
        
        self.useWalletChkBox.setUpBoxType()
        
        if(self.userProfileJson.get("APP_PAYMENT_MODE") == "Card"){
            isCashPayment = false
            self.cashPayModeView.isHidden = true
            
            cardPayImgView.image = UIImage(named: "ic_select_true")
            cashPayImgView.image = UIImage(named: "ic_select_false")
            
            GeneralFunctions.setImgTintColor(imgView: cashPayImgView, color: UIColor(hex: 0xd3d3d3))
            GeneralFunctions.setImgTintColor(imgView: cardPayImgView, color: UIColor.UCAColor.AppThemeColor_1)
            
        }else if(self.userProfileJson.get("APP_PAYMENT_MODE") == "Cash"){
            isCashPayment = true
            self.cardPayModeView.isHidden = true
            
            cashPayImgView.image = UIImage(named: "ic_select_true")
            cardPayImgView.image = UIImage(named: "ic_select_false")
            
            GeneralFunctions.setImgTintColor(imgView: cardPayImgView, color: UIColor(hex: 0xd3d3d3))
            GeneralFunctions.setImgTintColor(imgView: cashPayImgView, color: UIColor.UCAColor.AppThemeColor_1)
            self.addWalletBalLbl.isHidden = true
        }else{
            isCashPayment = true
            
            GeneralFunctions.setImgTintColor(imgView: cardPayImgView, color: UIColor(hex: 0xd3d3d3))
            GeneralFunctions.setImgTintColor(imgView: cashPayImgView, color: UIColor.UCAColor.AppThemeColor_1)
        }
        
        let APPSTORE_MODE_IOS = GeneralFunctions.getValue(key: Utils.APPSTORE_MODE_IOS_KEY)
        
        if(userProfileJson.get("WALLET_ENABLE").uppercased() == "YES" && (APPSTORE_MODE_IOS != nil && (APPSTORE_MODE_IOS as! String).uppercased() != "REVIEW")){
            self.useWalletView.isHidden = false
        }else{
            self.useWalletView.isHidden = true
        }
        
        self.addWalletBalLbl.setClickHandler { (instance) in
             let manageWalletUV = GeneralFunctions.instantiateViewController(pageName: "ManageWalletUV") as! ManageWalletUV
            self.pushToNavController(uv: manageWalletUV)
        }
        
        self.cashPayModeView.setOnClickListener { (instance) in
            self.cashViewTapped()
        }
        
        self.cardPayModeView.setOnClickListener { (instance) in
            self.cardViewTapped()
        }
        
        self.setRetrivalData()
        
        if(isPersonalProfileSelected){
            setPersonalProfileSelection()
        }
        
        /* PAYMENT FLOW CHANGES */
        if(GeneralFunctions.getPaymentMethod(userProfileJson:self.userProfileJson) == "1"){
            self.cardPayLbl.text = self.generalFunc.getLanguageLabel(origValue: "Pay online", key: "LBL_PAY_ONLINE_TXT")
        }else if(GeneralFunctions.getPaymentMethod(userProfileJson:self.userProfileJson) == "2"){
            self.useWalletView.isHidden = true
            let walletBal = Configurations.convertNumToAppLocal(numStr: GeneralFunctions.getValue(key: "user_available_balance") as! String)
            
            self.cardPayLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PAY_BY_WALLET_TXT") + " (\(walletBal))"
        }/*.........*/
    }
    
    func setPersonalProfileSelection(){
        self.selectedProfileDataDict = nil
        profileIconImgView.image = UIImage(named: "ic_personal")
        profileLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PERSONAL")
        isPersonalProfileSelected = true
        selectedProfileId = ""
       // GeneralFunctions.setImgTintColor(imgView: profileIconImgView, color: UIColor.UCAColor.AppThemeColor)
        
        self.reasonParentView.isHidden = true
        self.reasonsViewHeight.constant = 0
        
        self.writeReasonView.isHidden = true
        self.writeReasonViewHeight.constant = 0
        
        isCardValidated = false
        self.isPayByOrganization = false
    }
    
    func resetReason(){
        self.reasonLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SELECT_REASON")
        selectedReasonId = ""
        
        self.writeReasonTxtView.text = ""
        
        var reasonNameList = [String]()
        
        reasonNameList = self.selectedProfileDataDict.getArrObj("tripreasons").compactMap({ (reason) -> String in
            return (reason as! NSDictionary).get("vReasonTitle")
        })
        
        reasonNameList.append(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_OTHER_TXT"))
        
        if(reasonNameList.count == 1){
            self.reasonLbl.text = reasonNameList[0]
            self.selectedReasonId = ""
            self.writeReasonView.isHidden = false
            self.writeReasonViewHeight.constant = 140
            self.isOtherReasonSelected = true
        }else{
            self.writeReasonView.isHidden = true
            self.writeReasonViewHeight.constant = 0
            self.isOtherReasonSelected = false
            self.closeKeyboard()
        }
        
    }
    
    func openReasonList(){
        if(self.selectedProfileId == ""){
            return
        }
        
        var reasonNameList = [String]()
        
        let arr_reasons = self.selectedProfileDataDict.getArrObj("tripreasons")
        
        for i in 0..<arr_reasons.count{
            let tmp_dataDict = arr_reasons[i] as! NSDictionary
            reasonNameList.append(tmp_dataDict.get("vReasonTitle"))
        }
        
        reasonNameList.append(self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_OTHER_TXT"))
        
        let openListView = OpenListView(uv: self, containerView: self.view)
        openListView.show(listObjects: reasonNameList, title: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SELECT_TXT"), currentInst: openListView, handler: { (selectedItemId) in
            
            self.reasonLbl.text = reasonNameList[selectedItemId]
            
            if(selectedItemId == (reasonNameList.count - 1)){
                self.selectedReasonId = ""
                self.writeReasonView.isHidden = false
                self.writeReasonViewHeight.constant = 140
                self.isOtherReasonSelected = true
            }else{
                self.selectedReasonId = (arr_reasons[selectedItemId] as! NSDictionary).get("iTripReasonId")
                self.writeReasonView.isHidden = true
                self.writeReasonViewHeight.constant = 0
                self.isOtherReasonSelected = false
                
                self.closeKeyboard()
            }
            
        })
    }
    
    func findOrganizationList(){
        if(organizationDataArr.count == 0){
            let parameters = ["type":"DisplayUserOrganizationProfile", "UserType": Utils.appUserType, "iUserId": GeneralFunctions.getMemberd()]
            
            let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
            exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
                
                if(response != ""){
                    let dataDict = response.getJsonDataDict()
                    
                    if(dataDict.get("Action") == "1"){
                        
                        let dataArr = dataDict.getArrObj(Utils.message_str)
                        self.organizationDataArr.removeAll()
                        
                        self.addPersonalProfile()
                        
                        for i in 0 ..< dataArr.count{
                            let dataTemp = dataArr[i] as! NSDictionary
                            self.organizationDataArr.append(dataTemp)
                        }
                        
                        self.openOrganizationList()
                    }else{
                        self.addPersonalProfile()
                        self.openOrganizationList()
                        //                    self.generalFunc.setError(uv: self, isCloseScreen: true)
                        //                        self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message") == "" ? "LBL_TRY_AGAIN_TXT" : dataDict.get("message")), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "OK", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btn_id) in
                        ////                            self.closeCurrentScreen()
                        //                        })
                    }
                }else{
                    self.generalFunc.setError(uv: self, isCloseScreen: true)
                }
            })
        }else{
            self.openOrganizationList()
        }
    }
    
    func addPersonalProfile(){
        let personalProfileDataDict = NSMutableDictionary()
        personalProfileDataDict["vImage"] = "ic_personal"
        personalProfileDataDict["vProfileName"] = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PERSONAL")
        personalProfileDataDict["ePaymentBy"] = ""
        
        self.organizationDataArr.append(personalProfileDataDict)
    }
    
    func configPaymentOptionView(_ isHide:Bool){
        if(isHide){
            self.paymentOptionViewHeight.constant = 0
            self.paymentOptionView.isHidden = true
        }else{
            self.paymentOptionView.isHidden = false
            self.paymentOptionViewHeight.constant = 175
        }
    }
    
    func openOrganizationList(){
        var orgNameList = [String]()
        
        for i in 0..<organizationDataArr.count{
            let tmp_dataDict = organizationDataArr[i]
            
            orgNameList.append(tmp_dataDict.get("vProfileName"))
        }
        
        let openListView = OpenListView(uv: self, containerView: self.view)
        openListView.show(listObjects: orgNameList, title: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SELECT_TXT"), currentInst: openListView, handler: { (selectedItemId) in
            
            if(selectedItemId == 0){
                self.setPersonalProfileSelection()
                self.configPaymentOptionView(false)
            }else{
                self.isPersonalProfileSelected = false
                let item = self.organizationDataArr[selectedItemId]
                
                
                self.selectedProfileDataDict = item
                
                self.selectedProfileId = item.get("iUserProfileId")
                self.profileIconImgView.showActivityIndicator(.gray)
                self.profileLbl.text = item.get("vProfileName")
                self.profileIconImgView.sd_setImage(with: URL(string: item.get("vImage")), placeholderImage: UIImage(named:"ic_no_icon"), options: SDWebImageOptions(rawValue: 0), completed: nil)
                
                self.reasonParentView.isHidden = false
                self.reasonsViewHeight.constant = 85
                
                self.resetReason()
                
                if(item.get("ePaymentBy").uppercased() == "ORGANIZATION"){
                    self.isPayByOrganization = true
                    self.configPaymentOptionView(true)
                }else{
                    self.isPayByOrganization = false
                    self.configPaymentOptionView(false)
                }
            }
            
        })
    }
    
    func cashViewTapped(){
        self.isCashPayment = true
        cashPayImgView.image = UIImage(named: "ic_select_true")
        cardPayImgView.image = UIImage(named: "ic_select_false")
        
        GeneralFunctions.setImgTintColor(imgView: cardPayImgView, color: UIColor(hex: 0xd3d3d3))
        GeneralFunctions.setImgTintColor(imgView: cashPayImgView, color: UIColor.UCAColor.AppThemeColor_1)
    }
    
    func cardViewTapped(){
        /* PAYMENT FLOW CHANGES */
        if(GeneralFunctions.getPaymentMethod(userProfileJson:self.userProfileJson) == "1"){
            if(GeneralFunctions.isUserCardExist(userProfileJson: self.userProfileJson)){
                showPaymentBox()
            }else{
                let paymentUV = GeneralFunctions.instantiateViewController(pageName: "PaymentUV") as! PaymentUV
                paymentUV.isFromUFXPayMode = false
                self.pushToNavController(uv: paymentUV)
            }
        }else if(GeneralFunctions.getPaymentMethod(userProfileJson:self.userProfileJson) == "2"){
            self.selectCard()
        }/*.........*/
    }
    
    func showPaymentBox(){
        let openConfirmCardView = OpenConfirmCardView(uv: self, containerView: self.navigationController != nil ? self.navigationController!.view : self.view)
        openConfirmCardView.show(checkCardMode: "") { (isCheckCardSuccess, dataDict) in
            self.selectCard()
            
            if(self.isAutoContinue_payBox == true){
                self.doneBtn.btnTapped()
            }
        }
    }
    
    func selectCard(){
        self.isCardValidated = true
        self.isCashPayment = false
        
        self.cashPayImgView.image = UIImage(named: "ic_select_false")
        self.cardPayImgView.image = UIImage(named: "ic_select_true")
        
        GeneralFunctions.setImgTintColor(imgView: cashPayImgView, color: UIColor(hex: 0xd3d3d3))
        GeneralFunctions.setImgTintColor(imgView: cardPayImgView, color: UIColor.UCAColor.AppThemeColor_1)
    }
    
    func myBtnTapped(sender: MyButton) {
        if(sender == self.doneBtn){
            
            if(self.selectedProfileId != "" && (self.selectedReasonId == "" && self.isOtherReasonSelected == false)){
                Utils.showSnakeBar(msg: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RESTRICT_SEL_REASON"), uv: self)
                return
            }
            
            if(self.selectedProfileId != "" && (self.isOtherReasonSelected == true  && writeReasonTxtView.text! == "")){
                Utils.showSnakeBar(msg: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RESTRICT_ADD_REASON"), uv: self)
                return
            }
            
            if(isCashPayment == false && isCardValidated == false && isPayByOrganization == false){
                isAutoContinue_payBox = true
                self.cardViewTapped()
                return
            }
            
            
            self.performSegue(withIdentifier: "unwindToMainScreen", sender: self)
        }
    }
}
