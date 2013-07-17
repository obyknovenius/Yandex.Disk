//
//  VDDAVListingRequest.h
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/11/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const HTTPErrorDomain;
extern NSString * const AuthErrorDomain;

@class VDDAVRequest;

typedef void (^VDDAVRequestSuccessBlock)(VDDAVRequest *request, NSArray *files);
typedef void (^VDDAVRequestFailureBlock)(VDDAVRequest *request, NSError *error);

@interface VDDAVRequest : NSObject

@property (nonatomic, copy) NSString *path;

@property (nonatomic, copy) VDDAVRequestSuccessBlock success;
@property (nonatomic, copy) VDDAVRequestFailureBlock failure;

- (id)initWithPath:(NSString *)path;
- (void)send;

@end
