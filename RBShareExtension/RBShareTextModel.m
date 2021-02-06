//
//  RBShareTextModel.m
//  RBShareExtension
//
//  Created by 龚宇 on 21/02/06.
//

#import "RBShareTextModel.h"

@implementation RBShareTextModel

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        _userName = @"[未找到用户名]";
        _text = text;
        _dateString = [[NSDate date] stringWithFormat:RBTimeFormatyMdHmsSCompact];
        
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@[\\S]+:" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *results = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        if (results.count > 0) {
            NSString *realText = text; // 可能有转发微博的情况，realText就是不包含转发的文字
            NSTextCheckingResult *lastResult = (NSTextCheckingResult *)results.lastObject;
            if (lastResult.range.location != 0) {
                realText = [text substringFromIndex:lastResult.range.location];
            }
            
            _userName = [text substringWithRange:lastResult.range];
            if (_userName.length > 2) {
                _userName = [_userName substringWithRange:NSMakeRange(1, _userName.length - 2)];
            }
            _text = [realText substringFromIndex:_userName.length + 2];
            if ([_text hasPrefix:@" "]) {
                _text = [_text substringFromIndex:1];
            }
            if ([_text hasSuffix:@" "]) {
                _text = [_text substringToIndex:_text.length - 1];
            }
        }
    }
    
    return self;
}

@end
