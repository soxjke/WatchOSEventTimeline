//
//  Event+CoreDataProperties.m
//  WatchOSEventTimeline
//
//  Created by Petro Korienev on 1/21/16.
//  Copyright © 2016 Petro Korienev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Event+CoreDataProperties.h"

@implementation Event (CoreDataProperties)

@dynamic eventId;
@dynamic page;
@dynamic title;
@dynamic imageURL;
@dynamic date;
@dynamic venue;
@dynamic eventDescription;

@end
