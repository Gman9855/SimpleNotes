//
//  NSManagedObjectContext+SNAdditions.m
//  SimpleNotes
//
//  Created by Gershy Lev on 5/10/14.
//  Copyright (c) 2014 Gershy Lev. All rights reserved.
//

#import "NSManagedObjectContext+SNAdditions.h"

@implementation NSManagedObjectContext (SNAdditions)

- (BOOL)saveRecursively:(NSError **)error;
{
    if (self.parentContext) {
        if ([self save:error]) {
            return [self.parentContext saveRecursively:error];
        } else {
            return NO;
        }
    }

    return [self save:error];
}

@end
