//
//  RBConstHeader.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#ifndef RBConstHeader_h
#define RBConstHeader_h

typedef NS_OPTIONS(NSUInteger, RBFileOpertaionBehavior) {
    RBFileOpertaionBehaviorNone            = 0,
    RBFileOpertaionBehaviorShowSuccessLog  = 1 << 0,
    RBFileOpertaionBehaviorShowNoneLog     = 1 << 1,
    RBFileOpertaionBehaviorExportNoneLog     = 1 << 2,
};

// Time Format
static NSString * const RBTimeFormatCompactyMd = @"yyyyMMdd";
static NSString * const RBTimeFormatyMdHms = @"yyyy-MM-dd HH:mm:ss";
static NSString * const RBTimeFormatyMdHmsS = @"yyyy-MM-dd HH:mm:ss.SSS";
static NSString * const RBTimeFormatEMdHmsZy = @"EEE MMM dd HH:mm:ss Z yyyy";

static NSString * const RBTimeFormatyMdHmsCompact = @"yyyyMMddHHmmss";
static NSString * const RBTimeFormatyMdHmsSCompact = @"yyyyMMddHHmmssSSS";

// Notification Key
static NSString * const RBShareImageNeedShowImageFilesNotification = @"com.gongyu.ResourceBox.shareImageNeedShowImageFilesNotification";

// Warning
static NSString * const RBWarningNoneContentFoundInInputTextView = @"没有获得任何输入内容，请检查输入框";

#endif /* RBConstHeader_h */
