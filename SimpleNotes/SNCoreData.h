//
//  SNCoreData.h
//  SimpleNotes
//
//  Created by Gershy Lev on 5/10/14.
//  Copyright (c) 2014 Gershy Lev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNCoreData : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

//[[SNCoreData sharedInstance] managedObjectContext]

@end
