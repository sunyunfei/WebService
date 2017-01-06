//
//  ViewController.swift
//  WebServiceRequest_Swift
//
//  Created by 孙云飞 on 2017/1/6.
//  Copyright © 2017年 孙云飞. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        webServiceConnect(nameSpace: "http://WebXml.com.cn/", urlStr: "http://www.webxml.com.cn/WebServices/WeatherWebService.asmx", method: "getSupportCity")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    
    /*
     nameSpace:命名空间
     urlStr:请求接口
     method:方法体
     */
    func webServiceConnect( nameSpace:String, urlStr:String, method:String){
        
        //soap的配置
        let soapMsg:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"+"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"+"<soap:Body>\n"+"<"+method+" xmlns=\""+nameSpace+"\">\n"+"<byProvinceName>"+"北京"+"</byProvinceName>\n"+"</"+method+">\n"+"</soap:Body>\n"+"</soap:Envelope>\n"
        
        let soapMsg2:NSString = soapMsg as NSString
        //接口的转换为url
        let url:URL = URL.init(string:urlStr)!
        //计算出soap所有的长度，配置头使用
        let msgLength:NSString = NSString.init(format: "%i", soapMsg2.length)
        //创建request请求，把请求需要的参数配置
        var request:URLRequest = NSMutableURLRequest.init() as URLRequest
        //请求的参数配置，不用修改
        request.timeoutInterval = 10
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.url = url
        request.httpMethod = "POST"
        //请求头的配置
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(msgLength as String, forHTTPHeaderField: "Content-Length")
        request.httpBody = soapMsg.data(using: String.Encoding.utf8)
        //soapAction的配置
        let soapActionStr:String = nameSpace + method
        request.addValue(soapActionStr, forHTTPHeaderField: "SOAPAction")
        
        //开始网络session请求的单例创建
        let session:URLSession = URLSession.shared
        //开始请求
        let task:URLSessionDataTask = session.dataTask(with: request as URLRequest , completionHandler: {( data, respond, error) -> Void in
            
            if (error != nil){
                
                print("error is coming")
            }else{
                //结果输出
                let result:NSString = NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue)!
                print("result=\(result),\n adress=\(request.url)")
            }
        })
        
        //提交请求
        task.resume()
    }
}

