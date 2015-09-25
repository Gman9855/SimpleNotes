//
//  Note.m
//  SimpleNotes
//
//  Created by Gershy Lev on 5/10/14.
//  Copyright (c) 2014 Gershy Lev. All rights reserved.
//

#import "Note.h"


@implementation Note

@dynamic body;
@dynamic modifiedDate;

- (void)awakeFromInsert;
{
    [super awakeFromInsert];
    
    self.modifiedDate = [NSDate date];
}

@end
