//
//  VDDataSynchronizer.m
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/16/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import "VDDataSynchronizer.h"

#import <objc/runtime.h>

#import "VDAppDelegate.h"

#import "VDDAVSession.h"
#import "VDDAVRequest.h"
#import "VDDAVFile.h"

#import "VDCDFile.h"
#import "VDCDFile+DataSync.h"

const char SyncPathKey;

@interface VDDataSynchronizer () //<VDDAVListingRequestDelegate>

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@end

@implementation VDDataSynchronizer

#pragma mark - Accessors

- (NSManagedObjectContext *)managedObjectContext
{
    VDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

#pragma mark -

+ (void)syncPath:(NSString *)path
{    
    VDDAVRequest *request = [[VDDAVRequest alloc] init];
    request.path = path;
    
    request.success = ^(VDDAVRequest *request, NSArray *remoteFiles) {
        VDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        
        VDCDFile *directory = [VDCDFile fileForPath:request.path inContext:context];
        
        if (directory)
        {
            // Directory exist in local cache but have no children files.
            if ([directory.children count] == 0)
            {
                [directory addFiles:remoteFiles withPath:request.path inManagedObjectContext:context];
            }
            // Directory exist in local cache and have children files.
            else
            {
                NSArray *sortedLocalFiles = [self sortArray:[directory.children allObjects] byChildProperty:@"path"];
                NSArray *sortedRemoteFiles = [self sortArray:remoteFiles byChildProperty:@"href"];
                
                int i = 0, j = 0;
                VDCDFile *currentLocalFile;
                VDDAVFile *currentRemoteFile;
                
                while ((i < [sortedLocalFiles count]) || (j < [sortedRemoteFiles count]))
                {
                    // Iterating through list of local files is finished. Add all remaining remote files.
                    if (i == [sortedLocalFiles count]) {
                        [directory addFile:[sortedRemoteFiles objectAtIndex:j] inManagedObjectContext:context];
                        j++;
                        continue;
                    }
                    
                    // Iterating through list of remote files is finished. Remove all remaining local files.
                    if (j == [sortedRemoteFiles count]) {
                        [directory removeFile:[sortedLocalFiles objectAtIndex:i] inManagedObjectContext:context];
                        i++;
                        continue;
                    }
                    
                    currentLocalFile = [sortedLocalFiles objectAtIndex:i];
                    currentRemoteFile = [sortedRemoteFiles objectAtIndex:j];
                    
                    // Excluding the directory itself from the list of it's children.
                    if ([currentRemoteFile.href isEqualToString:request.path]) {
                        [directory updateWithFile:currentRemoteFile];
                        j++;
                        continue;
                    }
                    
                    // Compare local (cached) and remote files.
                    switch ([currentLocalFile.path compare:currentRemoteFile.href]) {
                        case NSOrderedAscending:
                            [directory removeFile:currentLocalFile inManagedObjectContext:context];
                            i++;
                            break;
                        case NSOrderedDescending:
                            [directory addFile:currentRemoteFile inManagedObjectContext:context];
                            j++;
                            break;
                        case NSOrderedSame:
                            [currentLocalFile updateWithFile:currentRemoteFile];
                            i++; j++;
                            break;
                    }                    
                }
            }
        }
        // Directory not exist in local cache.
        else
        {
            directory = [NSEntityDescription insertNewObjectForEntityForName:@"File" inManagedObjectContext:context];
            directory.isDirectory = @YES;
            [directory addFiles:remoteFiles withPath:request.path inManagedObjectContext:context];
        }
    };
    
    request.failure = ^(VDDAVRequest *request, NSError *error) {
        if ([error.domain isEqualToString:AuthErrorDomain] && error.code == 911) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter login and password"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
            
            objc_setAssociatedObject(alertView, &SyncPathKey, request.path, OBJC_ASSOCIATION_COPY_NONATOMIC);
            
            [alertView show];
        }
    };
    
    [request send];
}

#pragma mark - Alert view delegate

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    VDDAVSession *session = [VDDAVSession sharedSession];
    
    NSString *login = [[alertView textFieldAtIndex:0] text];
    if (login && ![login isEqualToString:@""]) {
        session.username = login;
    }
    
    NSString *password = [[alertView textFieldAtIndex:1] text];
    if (password && ![password isEqualToString:@""]) {
        session.password = password;
    }
    
    NSString *path = objc_getAssociatedObject(alertView, &SyncPathKey);
    [self syncPath:path];
}

#pragma mark - Utils

+ (NSArray *)sortArray:(NSArray *)array byChildProperty:(NSString *)property
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:property ascending:YES];
    return [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

@end
