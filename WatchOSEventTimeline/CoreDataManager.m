//
//  CoreDataManager.m
//  WatchOSEventTimeline
//
//  Created by Petro Korienev on 1/21/16.
//  Copyright © 2016 Petro Korienev. All rights reserved.
//

#import "CoreDataManager.h"

@interface CoreDataManager ()

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSMutableDictionary *dict;

@end

@implementation CoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(){
        instance = [CoreDataManager new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        [self managedObjectContext];
        self.dict = [NSMutableDictionary new];
    }
    return self;
}

- (NSURL *)containerDirectoryURL {
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.soxjke.WatchOSEventTimeline"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WatchOSEventTimeline" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self containerDirectoryURL] URLByAppendingPathComponent:@"WatchOSEventTimeline.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

static NSEntityDescription *eventEntityDescription = nil;

- (NSArray<Event *> *)parseAndStorePage:(NSUInteger)page withObjects:(NSArray *)objects {
    if (eventEntityDescription == nil){
        eventEntityDescription = [NSEntityDescription entityForName:NSStringFromClass([Event class]) inManagedObjectContext:[self managedObjectContext]];
    }
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:objects.count];
    for (NSDictionary *dataDict in objects) {
        NSInteger eventId = [[[dataDict[@"title_link"] stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@"http:dou.uacalendar" withString:@""] integerValue];
        Event *event = [self findById:eventId];
        if (event == nil) {
            event = [[Event alloc] initWithEntity:eventEntityDescription insertIntoManagedObjectContext:[self managedObjectContext]];
        }
        event.title = dataDict[@"title_link/_text"];
        event.imageURL = dataDict[@"logo_image/_srcset"][@"2x"];
        event.eventDescription = dataDict[@"typo_description_1"];
        event.page = @(page);
        event.eventId = @(eventId);
        event.venue = dataDict[@"whenandwhere_value"];
        event.date = [self parseDate:dataDict[@"date_value"]];
        [result addObject:event];
    }
    [self saveContext];
    return [NSArray arrayWithArray:result];
}

- (NSDate *)parseDate:(NSString *)stringDate {
    NSArray *components1 = [stringDate componentsSeparatedByString:@"—"];
    NSArray *components2 = nil;
    NSString *processedString = stringDate;
    if (components1.count != 1) {
        components2 = [components1.lastObject componentsSeparatedByString:@" "];
        processedString = [@[components1.firstObject, components2.lastObject] componentsJoinedByString:@" "];
    }
    else {
        components2 = [stringDate componentsSeparatedByString:@" "];
    }
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.calendar = [NSCalendar currentCalendar];
    components.year = 2016;
    components.day = [components1.firstObject integerValue];
    components.month = [@[@"",@"января",@"февраля",@"марта",@"апреля",@"мая",@"июня",@"июля",@"августа",@"сентября",@"октября",@"ноября",@"декабря"] indexOfObject:components2.lastObject];
    NSString *key = [[@(components.day) stringValue] stringByAppendingFormat:@"-%@", @(components.month)];
    if (self.dict[key] == nil) {
        self.dict[key] = [NSMutableArray new];
    }
    NSMutableArray *array = self.dict[key];
    NSNumber *number = array.lastObject;
    if (!number) {
        number = @(8);
    }
    number = @((number.integerValue + 1));
    [array addObject:number];
    components.hour = number.integerValue;
    return [components date];
}

- (NSArray<Event *> *)fetchAll {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Event class])];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date"
    ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    return [[self managedObjectContext] executeFetchRequest:fetchRequest error:nil];
}

- (Event *)findById:(NSInteger)eventId {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Event class])];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"eventId = %li", (long)eventId],
    fetchRequest.fetchLimit = 1;
    return [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] firstObject];
}

@end
