//
//  VDDataSynchronizer.h
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/16/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDDataSynchronizer : NSObject

+ (void)syncPath:(NSString *)path;

@end
