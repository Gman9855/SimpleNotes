//
//  NSManagedObjectContext+SNAdditions.h
//  SimpleNotes
//
//  Created by Gershy Lev on 5/10/14.
//  Copyright (c) 2014 Gershy Lev. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (SNAdditions)

- (BOOL)saveRecursively:(NSError **)error;

@end
