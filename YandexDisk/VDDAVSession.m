//
//  VDDAVSession.m
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/16/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import "VDDAVSession.h"

static NSString * const kVDDAVBaseURLString = @"https://webdav.yandex.ru";

@implementation VDDAVSession

+ (VDDAVSession *)sharedSession
{
    static VDDAVSession *_sharedSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSession = [[VDDAVSession alloc] initWithBaseURL:[NSURL URLWithString:kVDDAVBaseURLString]];
    });
    
    return _sharedSession;
}

- (id)initWithBaseURL:(NSURL *)url
{
    if (self = [super init]) {
        _baseURL = url;
    }
    
    return self;
}

@end
