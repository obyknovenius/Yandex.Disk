//
//  VDDAVListtingResponseItem.h
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/13/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDDAVFile : NSObject

@property (nonatomic, copy) NSString *href;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, assign) long long contentLength;
@property (nonatomic, strong) NSDate *modificationDate;
@property (nonatomic, assign, getter = isCollection) BOOL collection;

@end
