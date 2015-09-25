//
//  SNContentViewController.h
//  SimpleNotes
//
//  Created by Gershy Lev on 3/31/14.
//  Copyright (c) 2014 Gershy Lev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

extern NSString *const SNContentViewControllerDidDeleteNoteNotification;

@interface SNContentViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) Note *note;

@end
