//
//  Event+CoreDataProperties.h
//  WatchOSEventTimeline
//
//  Created by Petro Korienev on 1/21/16.
//  Copyright © 2016 Petro Korienev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface Event (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *eventId;
@property (nullable, nonatomic, retain) NSNumber *page;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *venue;
@property (nullable, nonatomic, retain) NSString *eventDescription;

@end

NS_ASSUME_NONNULL_END
