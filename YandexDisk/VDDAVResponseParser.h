//
//  VDDAVListingResponseParser.h
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/13/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDDAVResponseParser : NSObject

- (id)initWithData:(NSData *)data;
- (NSArray *)parse:(NSError **)error;

@end
