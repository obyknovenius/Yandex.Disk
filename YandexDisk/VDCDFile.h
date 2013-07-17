//
//  VDFile.h
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/16/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VDCDFile;

@interface VDCDFile : NSManagedObject

@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *size;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSDate *modificationDate;
@property (nonatomic, retain) NSNumber *isDirectory;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) VDCDFile *parent;
@end

@interface VDCDFile (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(VDCDFile *)value;
- (void)removeChildrenObject:(VDCDFile *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end
