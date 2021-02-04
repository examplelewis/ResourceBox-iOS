//
//  RBHTTPHeader.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#ifndef RBHTTPHeader_h
#define RBHTTPHeader_h

#pragma mark - Domain
static NSString * const RBErrorDomainHTTP = @"com.gongyu.MyUniqueBox.HTTP";
static NSString * const RBErrorDomainHTTPWeiboAPI = @"com.gongyu.MyUniqueBox.HTTP.weiboApi";
static NSString * const RBErrorDomainHTTPExHentaiAPI = @"com.gongyu.MyUniqueBox.HTTP.exHentaiApi";


#pragma mark - Code
static NSInteger const RBErrorCodeAPIReturnEmptyObject = -10001;
static NSInteger const RBErrorCodeAPIReturnUselessObject = -10002;

#pragma mark - UserInfo
static NSString * const RBErrorLocalizedDescriptionAPIReturnEmptyObject = @"接口返回空数据";
static NSString * const RBErrorLocalizedDescriptionAPIReturnUselessObject = @"接口未返回可用数据";

#pragma mark - Weibo



#endif /* RBHTTPHeader_h */
