//
//  WebServiceManager.swift
//  WebServiceRequest_Swift
//
//  Created by 孙云飞 on 2017/1/6.
//  Copyright © 2017年 孙云飞. All rights reserved.
//

import UIKit
//代理
protocol WebServiceManagerDelegate {
    
    func transmitDataToVC(dataStr:String)//data总数据传递过来
    func transmitBodyToVC(bodyStr:String)//body中的数据传递过来
}
class WebServiceManager: NSObject,XMLParserDelegate {

    var delegate:WebServiceManagerDelegate?
    /*
     nameSpace:命名空间
     urlStr:请求接口
     method:方法体
     */
    func webServiceConnect( nameSpace:String, urlStr:String, method:String,paramDic:Dictionary<String,AnyObject>){
        
        //soap的配置
        let soapMsgFront:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"+"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"+"<soap:Body>\n"+"<"+method+" xmlns=\""+nameSpace+"\">\n"
        
        var paraStr:String="";
        for (key,value) in paramDic {
            
            print("key=\(key),value=\(value)")
            let para:String = "<"+key+">"+(value as! String)+"</"+key+">\n"
            paraStr = paraStr + para
        }
        
        let soapMsgLast:String = "</"+method+">\n"+"</soap:Body>\n"+"</soap:Envelope>\n"
        //组合起来
        let soapMsg = soapMsgFront+paraStr+soapMsgLast
        
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
                
                //回到主线程
                DispatchQueue.main.async {
                    
                    if (self.delegate != nil){
                        
                        self.delegate?.transmitDataToVC(dataStr:result as String)
                    }
                }
                
                
                //解析xml
                let xmlParser:XMLParser = XMLParser.init(data: result.data(using: String.Encoding.utf8.rawValue)!)
                xmlParser.delegate = self
                xmlParser.parse()
            }
        })
        
        //提交请求
        task.resume()
    }
    
    
    //xml解析
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if (delegate != nil) {
            
            delegate?.transmitBodyToVC(bodyStr: string)
        }
    }
}
