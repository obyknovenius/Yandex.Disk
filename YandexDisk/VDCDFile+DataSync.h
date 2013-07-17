//
//  VDFile+DataSync.h
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/16/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import "VDCDFile.h"
#import "VDDAVFile.h"

@interface VDCDFile (DataSync)

+ (VDCDFile *)fileForPath:(NSString *)path inContext:(NSManagedObjectContext *)context;

- (void)addFiles:(NSArray *)remoteFiles withPath:(NSString *)path inManagedObjectContext:(NSManagedObjectContext *)context;
- (void)addFile:(VDDAVFile *)remoteFile inManagedObjectContext:(NSManagedObjectContext *)context;
- (void)removeFile:(VDCDFile *)localFile inManagedObjectContext:(NSManagedObjectContext *)context;
- (void)updateWithFile:(VDDAVFile *)item;

@end
