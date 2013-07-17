//
//  VDFilesViewController.m
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/13/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import "VDFilesViewController.h"
#import "VDFileCell.h"

#import "VDAppDelegate.h"
#import "VDDataSynchronizer.h"
#import "VDCDFile.h"

@interface VDFilesViewController () <NSFetchedResultsControllerDelegate>

@end

@implementation VDFilesViewController

- (NSManagedObjectContext *)managedObjectContext
{
    VDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"File" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    if (self.path) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent.path == %@", self.path];
        [fetchRequest setPredicate:predicate];
    }
    
    NSSortDescriptor *sortDirectory = [[NSSortDescriptor alloc]
                                       initWithKey:@"isDirectory" ascending:NO];
    NSSortDescriptor *sortAlphabetical = [[NSSortDescriptor alloc]
                                          initWithKey:@"name" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDirectory, sortAlphabetical, nil]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:context sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *reloadBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                  target:self
                                                  action:@selector(reload)];
    
    self.navigationItem.rightBarButtonItem = reloadBarButtonItem;
    
	[[self fetchedResultsController] performFetch:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reload];
}

- (void)viewWillUnload:(BOOL)animated
{
    self.fetchedResultsController = nil;
}

#pragma mark - Actions

- (void)reload
{
    [VDDataSynchronizer syncPath:self.path];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *fileCellIdentifier = @"FileCell";
    
    VDFileCell *fileCell = [tableView dequeueReusableCellWithIdentifier:fileCellIdentifier];
    [self configureCell:fileCell atIndexPath:indexPath];
    return fileCell;
}

- (void)configureCell:(VDFileCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    VDCDFile *file = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = file.name;

    if (![file.isDirectory boolValue]) {
        cell.userInteractionEnabled = NO;
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        
        cell.creationDateLabel.hidden = cell.creationDateCaptionLabel.hidden = NO;
        cell.creationDateLabel.text = [dateFormatter stringFromDate:file.creationDate];
        
        cell.modificationDateLabel.hidden = cell.modificationDateCaptionLabel.hidden = NO;
        cell.modificationDateLabel.text = [dateFormatter stringFromDate:file.modificationDate];
        
        if ([file.size longLongValue] > 10 * 1024) {
            cell.sizeLabel.hidden = cell.sizeCaptionLabel.hidden = NO;
            cell.sizeLabel.text = unitStringFromBytes([file.size doubleValue]);
        }
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VDCDFile *file = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([file.isDirectory boolValue]) {
        return 44.0f;
    } else {
        if ([file.size longLongValue] > 10 * 1024) {
            return 90.0f;
        } else {
            return 74.0f;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VDCDFile *selectedDirectory = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    VDFilesViewController *nextFilesViewController = [storyboard instantiateViewControllerWithIdentifier:@"FilesViewController"];
    nextFilesViewController.title = selectedDirectory.name;
    
    nextFilesViewController.path = selectedDirectory.path;
    
    [self.navigationController pushViewController:nextFilesViewController animated:YES];
}

#pragma mark - Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(VDFileCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Utils

NSString* unitStringFromBytes(double bytes){
    
    static const char units[] = { '\0', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y' };
    static int maxUnits = sizeof units - 1;
    
    int multiplier = 1024;
    int exponent = 0;
    
    while (bytes >= multiplier && exponent < maxUnits) {
        bytes /= multiplier;
        exponent++;
    }
    
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];

    // Beware of reusing this format string. -[NSString stringWithFormat] ignores \0, *printf does not.
    return [NSString stringWithFormat:@"%@ %cB", [formatter stringFromNumber: [NSNumber numberWithDouble: bytes]], units[exponent]];
}

@end
