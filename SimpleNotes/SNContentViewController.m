//
//  SNContentViewController.m
//  SimpleNotes
//
//  Created by Gershy Lev on 3/31/14.
//  Copyright (c) 2014 Gershy Lev. All rights reserved.
//

#import "SNContentViewController.h"
#import "SNTableViewController.h"

NSString *const SNContentViewControllerDidDeleteNoteNotification = @"SNContentViewControllerDidDeleteNoteNotification";

@interface SNContentViewController () <UITextViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashToolbarIcon;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (nonatomic, strong) NSManagedObjectContext *childContext;
@property (nonatomic, strong) NSString *cachedBody;

@end

@implementation SNContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.note) {
        NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] init];
        childContext.parentContext = [SNCoreData sharedInstance].managedObjectContext;
        
        self.note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:childContext];
        self.childContext = childContext;
    }
    
    self.cachedBody = self.note.body;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.dateLabel.text = [NSDateFormatter localizedStringFromDate:self.note.modifiedDate
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    if (self.note.body.length > 0) {
        [self.textView resignFirstResponder];
        self.textView.text = self.note.body;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.note.body.length) {
        [self.textView becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    
    if (![self.cachedBody isEqualToString:self.note.body]) {
        self.note.modifiedDate = [NSDate date];
    }
    
    if (self.note.body.length) {
        [self.note.managedObjectContext saveRecursively:nil];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (!self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                            style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(doneButtonTapped:)];
    }
}

- (void)textViewDidChange:(UITextView *)textView;
{
    self.note.body = textView.text;
}

- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender;
{
    self.navigationItem.rightBarButtonItem = nil;
    [self.textView resignFirstResponder];
    
    self.note.body = self.textView.text;
    
    if (!self.note.body.length) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)composeButtonTapped:(UIBarButtonItem *)sender {
    UIViewController *controller = self.navigationController.viewControllers[0];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [controller performSegueWithIdentifier:@"pushContentViewController" sender:self];
}

- (IBAction)trashButtonTapped:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Note"
                                                    otherButtonTitles:nil];
    [actionSheet showFromToolbar:self.toolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        Note *note = nil;
        if (self.note.managedObjectContext == self.childContext) {
            [self.note.managedObjectContext deleteObject:self.note];
            [self.note.managedObjectContext saveRecursively:nil];
        } else {
            note = self.note;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SNContentViewControllerDidDeleteNoteNotification object:note];
        });
    }
}

- (IBAction)actionButtonTapped:(UIBarButtonItem *)sender {
    
}

@end
