//
//  ViewController.m
//  WebServiceRequest_OC
//
//  Created by 孙云飞 on 2017/1/6.
//  Copyright © 2017年 孙云飞. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSXMLParserDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self webServiceConnectionNameSpace:@"http://WebXml.com.cn/" withUrlStr:@"http://www.webxml.com.cn/WebServices/WeatherWebService.asmx" withMethod:@"getSupportCity"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)webServiceConnectionNameSpace:(NSString *)nameSpace withUrlStr:(NSString *)urlStr withMethod:(NSString *)method{
    
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                         
                         "<soap:Body>\n"
                         
                         "<%@ xmlns=\"%@\">\n"
                         
                         "<byProvinceName>%@</byProvinceName>\n"
                         
                         "</%@>\n"
                         
                         "</soap:Body>\n"
                         
                         "</soap:Envelope>\n",method,nameSpace,@"北京",method];
    NSLog(@"%@", soapMsg);
    // 创建URL
    NSURL *url = [NSURL URLWithString: urlStr];
    //计算出soap所有的长度，配置头使用
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    //创建request请求，把请求需要的参数配置
    NSMutableURLRequest  *request=[[NSMutableURLRequest alloc]init];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    //请求的参数配置，不用修改
    [request setTimeoutInterval: 10 ];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setURL: url ] ;
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //soapAction的配置
    [request setValue:[NSString stringWithFormat:@"%@%@",nameSpace,method] forHTTPHeaderField:@"SOAPAction"];
    
    [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 将SOAP消息加到请求中
    [request setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 创建连接
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"失败%@", error.localizedDescription);
        }else{
            
            NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
            
            NSLog(@"结果：%@\n请求地址：%@", result, response.URL);
            
            //系统自带的
            NSXMLParser *par = [[NSXMLParser alloc] initWithData:[result dataUsingEncoding:NSUTF8StringEncoding]];
            [par setDelegate:self];//设置NSXMLParser对象的解析方法代理
            [par parse];//调用代理解析NSXMLParser对象，看解析是否成功
        }
    }];
    
    [task resume];
}


//获取节点间内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    NSLog(@"%@", string);
}

@end
