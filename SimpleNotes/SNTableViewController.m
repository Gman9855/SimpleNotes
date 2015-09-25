//
//  SNTableViewController.m
//  SimpleNotes
//
//  Created by Gershy Lev on 3/31/14.
//  Copyright (c) 2014 Gershy Lev. All rights reserved.
//

#import "SNTableViewController.h"
#import "SNContentViewController.h"
#import "SNTableViewCell.h"
#import "Note.h"

static NSString * const identifier = @"Cell";

@interface SNTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *lastDeletedIndexPath;

@property (nonatomic, strong) UILabel *noNotesLabel;
@property (nonatomic, strong) UIColor *sepColor;

@end

@implementation SNTableViewController

- (BOOL)hasObjects;
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (void)setupFetchedResultsController;
{
    NSManagedObjectContext *context = [SNCoreData sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    fetchRequest.entity = entity;

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifiedDate"
                                                                   ascending:NO];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    controller.delegate = self;
    self.fetchedResultsController = controller;
}

- (void)addContentVCNoteDeletedObserver;
{
    __weak __typeof__(self) this = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:SNContentViewControllerDidDeleteNoteNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
                                                      if (this == this.navigationController.topViewController) {
                                                          return;
                                                      }
                                                      
                                                      Note *changedNoteObject = notification.object;
                                                      NSIndexPath *indexPath = nil;
                                                      if (!changedNoteObject && [this hasObjects]) {
                                                          indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                                      } else if (changedNoteObject) {
                                                          indexPath = [this.fetchedResultsController indexPathForObject:changedNoteObject];
                                                          indexPath = [this nextIndexPathAfterDeletionOfIndexPath:indexPath];
                                                          
                                                          [changedNoteObject.managedObjectContext deleteObject:changedNoteObject];
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [this.fetchedResultsController.managedObjectContext save:nil];
                                                          });
                                                      }
                                                      
                                                      [this.navigationController popToViewController:this animated:NO];
                                                      
                                                      SNContentViewController *cvc = [this.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
                                                      cvc.note = indexPath ? [this.fetchedResultsController objectAtIndexPath:indexPath] : nil;
                                                      [this.navigationController pushViewController:cvc animated:YES];
                                                  }];
}

- (void)updateNoNotesLabelVisibility;
{
    BOOL hasObjects = [self hasObjects];
    self.tableView.separatorStyle = hasObjects ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    self.noNotesLabel.alpha = !hasObjects;
    if (hasObjects) {
        [self setSeparatorsHidden:NO];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupFetchedResultsController];
    [self addContentVCNoteDeletedObserver];
    
    self.noNotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(121, 175, 100, 25)];
    self.noNotesLabel.text = @"No Notes";
    self.noNotesLabel.textColor = [UIColor grayColor];
    self.noNotesLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:self.noNotesLabel];
    self.noNotesLabel.alpha = 0.0;

    self.sepColor = self.tableView.separatorColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.fetchedResultsController performFetch:nil];
    [self updateNoNotesLabelVisibility];
}

- (NSIndexPath *)nextIndexPathAfterDeletionOfIndexPath:(NSIndexPath *)indexPathThatWasDeleted;
{
    NSUInteger count = self.fetchedResultsController.fetchedObjects.count;
    
    if (count == 0) {
        return nil;
    }
    
    NSUInteger nextRow = NSNotFound;
    if (indexPathThatWasDeleted.row < count - 1) {
        nextRow = indexPathThatWasDeleted.row + 1;
    } else if (count > 1 && indexPathThatWasDeleted.row == count - 1) {
        nextRow = count - 2;
    }
    
    if (nextRow != NSNotFound) {
        return [NSIndexPath indexPathForRow:nextRow inSection:0];
    }
    
    return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller;
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
{
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeDelete) {
        if ([self.tableView numberOfRowsInSection:indexPath.section] == 1) {
            [UIView animateWithDuration:1 delay:0.35 options:0 animations:^{
                [self updateNoNotesLabelVisibility];
            } completion:nil];
        }
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeMove) {
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
    } else if (type == NSFetchedResultsChangeUpdate) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.title.text = note.body;
    cell.date.text = [self formatForNoteDate:note.modifiedDate];
    return cell;
}

- (NSString *)formatForNoteDate:(NSDate *)noteDate;
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *yesterday = [[NSDate date] dateByAddingTimeInterval: -86400.0];
    NSDateComponents *noteComponents = [cal components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:noteDate];
    NSDateComponents *todayComponents = [cal components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    NSDateComponents *yesterdayComponents = [cal components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:yesterday];
    
    NSString *formattedDate = nil;
    if ([noteComponents isEqual:yesterdayComponents]) {
        formattedDate = @"Yesterday";
    } else {
        formattedDate = [NSDateFormatter localizedStringFromDate:noteDate
                                                       dateStyle:[noteComponents isEqual:todayComponents] ? NSDateFormatterNoStyle : NSDateFormatterShortStyle
                                                       timeStyle:[noteComponents isEqual:todayComponents] ? NSDateFormatterShortStyle : NSDateFormatterNoStyle];
    }
    
    return formattedDate;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)setSeparatorsHidden:(BOOL)b {
    self.tableView.separatorColor = [self.tableView.separatorColor colorWithAlphaComponent:!b];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [note.managedObjectContext deleteObject:note];
        [note.managedObjectContext save:nil];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    SNContentViewController *contentController = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if (indexPath) {
        contentController.note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
}

@end
