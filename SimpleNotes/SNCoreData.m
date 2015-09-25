//
//  SNCoreData.m
//  SimpleNotes
//
//  Created by Gershy Lev on 5/10/14.
//  Copyright (c) 2014 Gershy Lev. All rights reserved.
//

@import CoreData;

#import "SNCoreData.h"

@interface SNCoreData ()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;

@end

@implementation SNCoreData

+ (instancetype)sharedInstance;
{
    static SNCoreData *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (NSManagedObjectContext *)newManagedObjectContext;
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SimpleNotes" withExtension:@"momd"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *persistentStoreURL = [[fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil] URLByAppendingPathComponent:@"SimpleNotes.sqlite"];
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:persistentStoreURL
                                    options:nil
                                      error:nil];
    context.persistentStoreCoordinator = coordinator;
    return context;
}

- (NSManagedObjectContext *)managedObjectContext;
{
    if (!_managedObjectContext) {
        _managedObjectContext = [self newManagedObjectContext];
    }
    
    return _managedObjectContext;
}

@end
