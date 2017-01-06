//
//  ViewController.swift
//  WebServiceRequest_Swift
//
//  Created by 孙云飞 on 2017/1/6.
//  Copyright © 2017年 孙云飞. All rights reserved.
//

import UIKit

class ViewController: UIViewController,WebServiceManagerDelegate {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        textView.isEditable = false//不允许编辑
        
        /****************************需要改变的部分*******************************************/
        //参数
        let dic:Dictionary<String,AnyObject> = ["byProvinceName":"上海" as AnyObject]
        
        //请求类
        let manager:WebServiceManager = WebServiceManager()
        //请求代理
        manager.delegate = self
        
        //请求方法
        manager.webServiceConnect(nameSpace: "http://WebXml.com.cn/", urlStr: "http://www.webxml.com.cn/WebServices/WeatherWebService.asmx", method: "getSupportCity",paramDic: dic)
        
        /********************************************************************************/
    }


    func transmitDataToVC(dataStr:String){
    
        textView.text = dataStr
    }
    
    func transmitBodyToVC(bodyStr:String){
    
    
        print("代理传递过来的body数据:\(bodyStr)")
    }
}

