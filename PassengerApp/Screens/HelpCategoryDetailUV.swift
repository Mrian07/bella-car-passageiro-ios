//
//  HelpCategoryDetailUV.swift
//  PassengerApp
//
//  Created by iphone3 on 08/03/18.
//  Copyright © 2018 V3Cube. All rights reserved.
//

import UIKit

class HelpCategoryDetailUV: UIViewController , MyBtnClickDelegate , UITextViewDelegate {

    @IBOutlet weak var heightSelectedCategoryVw: NSLayoutConstraint!
    @IBOutlet weak var vwForm: UIView!
    @IBOutlet weak var reasonToContactLbl: MyLabel!
    @IBOutlet weak var categoryNameLbl: MyLabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var categoryDetailLbl: MyLabel!
    @IBOutlet weak var descriptionTxtLbl: MyLabel!
    @IBOutlet weak var selectedCategoryLbl: MyLabel!
    @IBOutlet weak var selectedCategoryVw: UIView!
    @IBOutlet weak var queryLbl: MyLabel!
    @IBOutlet weak var queryTxtVw: KMPlaceholderTextView!
    @IBOutlet weak var btnSubmit: MyButton!
    @IBOutlet weak var lblRequired: MyLabel!
    @IBOutlet weak var dropDownArrowImgView: UIImageView!
    
    var allSubCategoriesNameArr = [String]()
    var allSubCategoriesArr = [NSDictionary]()
    
    var selectedSubCategoryDict : NSDictionary = [:]
    
    var iHelpDetailId : String = ""
    var iTripId : String = ""
    var selectCategoryTapGue : UITapGestureRecognizer!
    
    let generalFunc = GeneralFunctions()
    var cntView:UIView!
    var loaderView:UIView!
    
    var isPageLoaded = false
    
    var PAGE_HEIGHT:CGFloat = 450
    var eSystem = ""
    
    var iUniqueId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        cntView = self.generalFunc.loadView(nibName: "HelpCategoryDetailScreenDesign", uv: self, contentView: scrollView)
        cntView.backgroundColor = UIColor.clear
        cntView.frame.size.height = self.PAGE_HEIGHT
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.PAGE_HEIGHT)
        scrollView.bounces = false
        scrollView.backgroundColor = UIColor(hex: 0xF2F2F4)
        self.scrollView.addSubview(cntView)
        
        self.lblRequired.isHidden = true
        self.vwForm.isHidden = true
        
        self.iHelpDetailId = self.selectedSubCategoryDict.get("iHelpDetailId")
        
        
        addLoader()
        
        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_HELP_TXT")
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_HELP_TXT")
        
        self.addBackBarBtn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isPageLoaded == false){
            cntView.frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.size.width, height: self.PAGE_HEIGHT)
            self.setData(selectedSubCategoryDict.get("vTitle"), selectedSubCategoryDict.get("tAnswer").trim(), selectedSubCategoryDict.get("eShowFrom"))
            isPageLoaded = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.configureRTLView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.lblRequired.isHidden = true
        return true
    }
    
    func addLoader(){
        if(loaderView == nil){
            loaderView =  self.generalFunc.addMDloader(contentView: self.view)
            loaderView.backgroundColor = UIColor.clear
        }
        loaderView.isHidden = false
        self.scrollView.isHidden = true
    }
    
    func closeLoader(){
        if(self.loaderView != nil){
            self.loaderView.isHidden = true
        }
        self.scrollView.isHidden = false
    }
    
    func getAllSubCategories(){
        allSubCategoriesNameArr.removeAll()
        allSubCategoriesArr.removeAll()
        
        addLoader()
        
        var iOrderId = ""
        var iTripId = ""
        if(eSystem.uppercased() == "DELIVERALL"){
            iOrderId = self.iTripId
            iTripId = ""
        }else{
            iTripId = self.iTripId
            iOrderId = ""
        }
        
        let parameters = ["type":"getHelpDetail", "appType": Utils.appUserType, "iMemberId": GeneralFunctions.getMemberd(), "eSystem": eSystem, "iOrderId": iOrderId, "iTripId": iTripId, "iUniqueId": iUniqueId]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: false)
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    
                    let dataArr = dataDict.getArrObj(Utils.message_str)
                    
                    for i in 0 ..< dataArr.count{
                        let dataTemp = dataArr[i] as! NSDictionary
                        self.allSubCategoriesNameArr += [dataTemp.get("vTitle")]
                        self.allSubCategoriesArr += [dataTemp]
                    }
                    
                    self.closeLoader()
                }else{
                    self.generalFunc.setAlertMessage(uv: nil, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "Ok", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", viewTag: Utils.SESSION_OUT_VIEW_TAG, coverViewTag: Utils.SESSION_OUT_COVER_VIEW_TAG, completionHandler: { (btnClickedIndex) in
                            self.closeCurrentScreen()
                    })
                }
            }else{
                self.generalFunc.setError(uv: self)
            }
            if(self.loaderView != nil){
                self.loaderView.isHidden = true
            }
        })
    }
    
    func setData(_ vTitle:String, _ tAnswer:String, _ eShowFrom:String){
        
        categoryNameLbl.text = vTitle
        categoryNameLbl.fitText()
        
        let categoryNameHeight = categoryNameLbl.text!.height(withConstrainedWidth: Application.screenSize.width - 32, font: UIFont(name: Fonts().semibold, size: 18)!)
    
        let content = tAnswer.replace("\n", withString: "<br>")
        categoryDetailLbl.setHTMLFromString(text: content)
        
        let categoryDetailsHeight = tAnswer.getHTMLString(fontName: Fonts().light, fontSize: "14", textColor: "#676767", text: tAnswer).height(withConstrainedWidth: Application.screenSize.width - 32)
        categoryDetailLbl.fitText()
        
        descriptionTxtLbl.text = self.generalFunc.getLanguageLabel(origValue: "Please contact support below for further assistance", key: "LBL_CONTACT_SUPPORT_ASSISTANCE_TXT")
        descriptionTxtLbl.fitText()
        
        let descriptionTxtHeight = descriptionTxtLbl.text!.height(withConstrainedWidth: Application.screenSize.width - 32, font: UIFont(name: Fonts().light, size: 18)!)
        
        selectedCategoryLbl.text = vTitle
        
        queryLbl.text = self.generalFunc.getLanguageLabel(origValue: "Additional Comments", key: "LBL_ADDITIONAL_COMMENTS")
        queryTxtVw.placeholder = self.generalFunc.getLanguageLabel(origValue: "Write your query here.", key: "LBL_CONTACT_US_WRITE_EMAIL_TXT")
        queryTxtVw.layer.borderColor = UIColor.lightGray.cgColor
        queryTxtVw.layer.borderWidth = 0.5
        queryTxtVw.layer.cornerRadius = 1
        queryTxtVw.delegate = self
        
        reasonToContactLbl.text = self.generalFunc.getLanguageLabel(origValue: "Reason to contact", key: "LBL_RES_TO_CONTACT")
        
        GeneralFunctions.setImgTintColor(imgView: dropDownArrowImgView, color: UIColor(hex: 0x272727))
        
        self.btnSubmit.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_SUBMIT_TXT"))
        self.btnSubmit.clickDelegate = self
        
        if(eShowFrom.uppercased() == "YES"){
            self.vwForm.isHidden = false
            self.PAGE_HEIGHT = categoryNameHeight + categoryDetailsHeight + descriptionTxtHeight + 383
            self.getAllSubCategories()
        }else{
            self.vwForm.isHidden = true
            self.PAGE_HEIGHT = categoryNameHeight + categoryDetailsHeight + 10
            self.closeLoader()
        }
        
        self.contentView.frame.size = CGSize(width: self.contentView.frame.width, height: self.PAGE_HEIGHT)
        self.cntView.frame.size = CGSize(width: self.contentView.frame.width, height: self.PAGE_HEIGHT)
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.PAGE_HEIGHT)
   
        let selectCategoryTapGue = UITapGestureRecognizer()
        selectCategoryTapGue.addTarget(self, action: #selector(self.selectCategoryTapped))
        self.selectedCategoryVw.addGestureRecognizer(selectCategoryTapGue)
        
    }
    
    func myBtnTapped(sender: MyButton) {
        
        if(queryTxtVw.text!.trim() != ""){
            
            loaderView = self.generalFunc.addMDloader(contentView: self.contentView)
            loaderView.backgroundColor = UIColor.clear
            
            let parameters = ["type":"submitTripHelpDetail", "appType": Utils.appUserType, "iMemberId": GeneralFunctions.getMemberd() , "iHelpDetailId": self.iHelpDetailId, "vComment": queryTxtVw.text! , "TripId" : iTripId, "eSystem":eSystem]
            
            let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: false)
            exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
                
                if(response != ""){
                    let dataDict = response.getJsonDataDict()
                    
                    if(dataDict.get("Action") == "1"){
                        self.queryTxtVw.text = ""
                        self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_COMMENT_ADDED_TXT"))
                        
                    }else{
                        _ = GeneralFunctions.addMsgLbl(contentView: self.view, msg: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)))
                    }
                }else{
                    self.generalFunc.setError(uv: self)
                }
                self.loaderView.isHidden = true
            })
        }else{
            self.lblRequired.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FEILD_REQUIRD_ERROR_TXT").uppercased()
            self.lblRequired.isHidden = false
        }
    }
    
    @objc func selectCategoryTapped(){
        let openListView = OpenListView(uv: self, containerView: self.view)
        openListView.show(listObjects: allSubCategoriesNameArr, title: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SELECT_TXT"), currentInst: openListView, handler: { (selectedItemId) in
            self.iHelpDetailId = self.allSubCategoriesArr[selectedItemId].get("iHelpDetailId")
            self.selectedCategoryLbl.text = self.allSubCategoriesNameArr[selectedItemId]
            
            self.setData(self.allSubCategoriesArr[selectedItemId].get("vTitle"), self.allSubCategoriesArr[selectedItemId].get("tAnswer").trim(), self.allSubCategoriesArr[selectedItemId].get("eShowFrom"))
            
        })
    }
}
