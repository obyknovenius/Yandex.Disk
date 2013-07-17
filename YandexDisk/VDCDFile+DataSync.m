//
//  VDFile+DataSync.m
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/16/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import "VDCDFile+DataSync.h"

@implementation VDCDFile (DataSync)

+ (VDCDFile *)fileForPath:(NSString *)path inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"File" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"path == %@", path];
    [fetchRequest setPredicate:predicate];
    
    NSArray *result = [context executeFetchRequest:fetchRequest error:nil];
    
    if ([result count] > 0)
        return (VDCDFile *)[result objectAtIndex:0];
    
    return nil;
}

- (void)addFiles:(NSArray *)remoteFiles withPath:(NSString *)path inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSAssert([self.isDirectory boolValue], @"Must be directory");
    
    for (VDDAVFile *remoteFile in remoteFiles) {
        if ([remoteFile.href isEqualToString:path]) {
            [self updateWithFile:remoteFile];
        } else {
            [self addFile:remoteFile inManagedObjectContext:context];
        }
    }
}

- (void)addFile:(VDDAVFile *)remoteFile inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSAssert([self.isDirectory boolValue], @"Must be directory");
        
    VDCDFile *localFile = [NSEntityDescription insertNewObjectForEntityForName:@"File" inManagedObjectContext:context];
    
    localFile.path = remoteFile.href;
    localFile.name = remoteFile.displayName;
    localFile.isDirectory = [NSNumber numberWithBool:remoteFile.collection];
    localFile.creationDate = remoteFile.creationDate;
    localFile.modificationDate = remoteFile.modificationDate;
    localFile.size = [NSNumber numberWithLongLong:remoteFile.contentLength];
    
    [self addChildrenObject:localFile];
    
    [self saveContext:context];
}

- (void)removeFile:(VDCDFile *)localFile inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSAssert([self.isDirectory boolValue], @"Must be directory");
        
    [self removeChildrenObject:localFile];
    [context deleteObject:localFile];
    
    [self saveContext:context];
}

- (void)updateWithFile:(VDDAVFile *)remoteFile
{
    if (![self.path isEqualToString:remoteFile.href]) {
        self.path = remoteFile.href;
    }
    
    if (![self.name isEqualToString:remoteFile.displayName]) {
        self.name = remoteFile.displayName;
    }
    
    if ([self.isDirectory boolValue] != remoteFile.collection) {
        self.isDirectory = [NSNumber numberWithBool:remoteFile.collection];
    }
    
    if (![self.creationDate isEqualToDate:remoteFile.creationDate]) {
        self.creationDate = remoteFile.creationDate;
    }
    
    if (![self.modificationDate isEqualToDate:remoteFile.modificationDate]) {
        self.modificationDate = remoteFile.modificationDate;
    }
    
    if (self.size.longLongValue != remoteFile.contentLength) {
        self.size = [NSNumber numberWithLongLong:remoteFile.contentLength];
    }
    
    [self saveContext:self.managedObjectContext];
}

- (void)saveContext:(NSManagedObjectContext *)context;
{
    NSError *error = nil;
    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
