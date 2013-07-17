//
//  VDDAVSession.h
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/16/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDDAVSession : NSObject

@property (nonatomic, readonly) NSURL *baseURL;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

+ (VDDAVSession *)sharedSession;

@end
