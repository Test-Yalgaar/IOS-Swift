//
//  ViewController.swift
//  Yalgaar_Swift_Example
//
//  Created by Paresh Patel on 06/06/18.
//  Copyright © 2018 System Level Solutions (I) Pvt. Ltd. All rights reserved.
//

import UIKit
import YalgaarSwiftSDK

class ViewController: UIViewController, YalgaarClientDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate {

    @IBOutlet weak var txtClientKey: UITextField!
    @IBOutlet weak var txtUUID: UITextField!
    @IBOutlet weak var connectionType: UISegmentedControl!
    
    @IBOutlet weak var txtChannel: UITextField!
    @IBOutlet weak var txtMessage: UITextField!
    @IBOutlet weak var tblMessagereceived: UITableView!
    
    var objYalgaarClient : YalgaarClient?
    var arrSubscribeData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objYalgaarClient = YalgaarClient.sharedInstance
        objYalgaarClient!.delegate = self
        
        self.tblMessagereceived.dataSource = self
        self.tblMessagereceived.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)// this will do the trick
    }
    
    // Mark: control events
    @IBAction func connectTapped(_ sender: Any) {
        var errorClientIDValidation : NSError?
        
        var isSecureConnection = false
        
        switch (connectionType.selectedSegmentIndex) {
        case 0:
            isSecureConnection = false
            break;
        case 1:
            isSecureConnection = true
            break;
        default:
            break;
        }
        
        if(txtUUID.text != nil && txtUUID.text != ""){
            objYalgaarClient!.connectWithClientKey(txtClientKey.text!, isSecure: isSecureConnection, uuid: txtUUID.text!, error: &errorClientIDValidation)
        } else {
            objYalgaarClient!.connectWithClientKey(txtClientKey.text!, isSecure:isSecureConnection, error:&errorClientIDValidation)
        }
        
        if errorClientIDValidation != nil {
            self.showErrorMessage("connectionDidFailWithError: \(errorClientIDValidation!.code), \(errorClientIDValidation!.userInfo["reason"] as! String)")
        }
    }
    @IBAction func disconnectTapped(_ sender: Any) {
        objYalgaarClient!.disconnect()
    }
    @IBAction func subscribeTapped(_ sender: Any) {
        var errorSub : NSError?
        
        let arrSubChannels = txtChannel.text!.components(separatedBy: ",")
        objYalgaarClient!.subscribeWithChannels(arrSubChannels, error:&errorSub)
        
        if errorSub != nil {
            self.showErrorMessage("\(errorSub!.code), \(errorSub!.userInfo["reason"] as! String)")
        }
    }
    @IBAction func unsubscribeTapped(_ sender: Any) {
        var errorUnSub : NSError?
        
        let arrUnSubChannels = txtChannel.text!.components(separatedBy: ",")
        objYalgaarClient!.unsubscribeWithChannels(arrUnSubChannels, error:&errorUnSub)
        
        if errorUnSub != nil {
            self.showErrorMessage("\(errorUnSub!.code), \(errorUnSub!.userInfo["reason"] as! String)")
        }
    }
    @IBAction func publishTapped(_ sender: Any) {
        var errorPubData : NSError?
        
        objYalgaarClient!.publishWithChannel(txtChannel.text!, message:txtMessage.text!, error:&errorPubData)
        
        if errorPubData != nil {
            self.showErrorMessage("\(errorPubData!.code), \(errorPubData!.userInfo["reason"] as! String)")
            return;
        }
    }
    @IBAction func clearTableTapped(_ sender: Any) {
        arrSubscribeData.removeAll()
        self.tblMessagereceived.reloadData()
    }
    // EndMark: control events
    
    // Mark: custom methods
    func showErrorMessage(_ message:String) {
        let alertView = UIAlertController.init(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    func showMessage(_ message: String, WithHeader:String) {
        
        let alertView = UIAlertController.init(title: WithHeader, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    // EndMark: custom methods
   
    //Mark: UITableView delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSubscribeData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier:"cell")
        let txtData = UITextView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width - 20, height: 40))
        txtData.textAlignment = NSTextAlignment.right
        txtData.isEditable = false
        txtData.text = arrSubscribeData[(indexPath as NSIndexPath).row]
        cell.addSubview(txtData)
        return cell;
    }
    //EndMark: UITableView delegate
    
    //Mark: YalgaarClientDelegate
    func didConnected() {
        self.showMessage("Connected", WithHeader:"Info")
    }
    func connectionAlreadyEstablished(_ yalgaarClient:NSObject){
        self.showMessage("Already connected", WithHeader:"Info")
    }
    func connectionError(_ error: NSError?){
        self.showErrorMessage("\(error!.code), \(error!.userInfo["reason"] as! String)")
    }
    func publishStatus(_ status: Bool, error: NSError?){
        if status == false {
            self.showErrorMessage("\(error!.code), \(error!.userInfo["reason"] as! String)")
        }
    }
    func didSubscribed(){
    }
    func subscribeError(_ error: NSError?){
        self.showErrorMessage("\(error!.code), \(error!.userInfo["reason"] as! String)")
    }
    func unsubscribeError(_ error: NSError?) {
        self.showErrorMessage("\(error!.code), \(error!.userInfo["reason"] as! String)")
    }
    func dataReceivedForSubscription(_ data: String, channels:[String]){
        let receivedChannels = channels.joined(separator: ",")
        
        let combineChannelAndData = "Ch:\(receivedChannels) - data:\(data)"
        
        arrSubscribeData.append(combineChannelAndData)
        
        self.tblMessagereceived.reloadData()
        
        let myIndexPath = IndexPath.init(row: arrSubscribeData.count-1, section: 0)
        self.tblMessagereceived.scrollToRow(at: myIndexPath, at:UITableViewScrollPosition.bottom, animated:true)
    }
    func didUnsubscribed(){
    }
    func dataReceivedOfPresenceForAction(_ action: PresenceAction, channel:String, uuid:String, dateTime:Date){
        var pre = "Bind"
        if  action == .unbind  {
            pre = "Unbind"
        }
        
        let combineChannelAndData = "Pre = Act:\(pre) - Ch:\(channel) - UUID:\(uuid) - T:\(DateFormatter.localizedString(from: dateTime, dateStyle:DateFormatter.Style.short, timeStyle:DateFormatter.Style.short))"
        
        arrSubscribeData.append(combineChannelAndData)
        
        self.tblMessagereceived.reloadData()
        
        let myIndexPath = IndexPath.init(row: arrSubscribeData.count-1, section:0)
        self.tblMessagereceived.scrollToRow(at: myIndexPath, at:UITableViewScrollPosition.bottom, animated:true)
    }
    func dataReceivedWithUUID(_ arrUUID: [String], channel:String){
    }
    func dataReceivedWithChannels(_ arrChannels: [String], uuid:String){
    }
    func getUUIDListChannelListError(_ error: NSError?){
    }
    func messageHistoryStatus(_ status: Bool, error:NSError?){
    }
    func dataReceivedForMessageHistroy(_ data: NSArray){
    }
    func didDisconnected(){
        self.showMessage("Disconnected", WithHeader:"Info")
    }
    func channelsAddedForPushNotification(_ status: Bool) {
    }
    func channelsRemovedForPushNotification(_ status: Bool) {
    }
    func allChannelsRemovedForPushNotification(_ status: Bool) {
    }
    //EndMark: YalgaarClientDelegate
}

