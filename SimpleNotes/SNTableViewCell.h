//
//  SNTableViewCell.h
//  SimpleNotes
//
//  Created by Gershy Lev on 4/4/14.
//  Copyright (c) 2014 Gershy Lev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end
