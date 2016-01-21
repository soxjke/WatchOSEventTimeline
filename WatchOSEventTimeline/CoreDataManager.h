//
//  CoreDataManager.h
//  WatchOSEventTimeline
//
//  Created by Petro Korienev on 1/21/16.
//  Copyright © 2016 Petro Korienev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Event.h"

@interface CoreDataManager : NSObject

+ (instancetype)sharedInstance;
- (NSArray<Event *> *)parseAndStorePage:(NSUInteger)page withObjects:(NSArray *)objects;
- (NSArray<Event *> *)fetchAll;

@end
