//
//  ComplicationController.m
//  WatchOSEventTimeline WatchKit Extension
//
//  Created by Petro Korienev on 1/10/16.
//  Copyright © 2016 Petro Korienev. All rights reserved.
//

#import "ComplicationController.h"
#import "CoreDataManager.h"

@interface ComplicationController ()

@property (nonatomic, strong) NSArray<Event *> *dataSource;

@end

@implementation ComplicationController

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    [self fetch];
    handler(CLKComplicationTimeTravelDirectionForward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    [self fetch];
    handler(self.dataSource.firstObject.date);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    [self fetch];
    handler(self.dataSource.lastObject.date);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    // Call the handler with the current timeline entry
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries prior to the given date
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries after to the given date
    handler(nil);
}

#pragma mark Update Scheduling

- (void)getNextRequestedUpdateDateWithHandler:(void(^)(NSDate * __nullable updateDate))handler {
    // Call the handler with the date when you would next like to be given the opportunity to update your complication content
    handler([NSDate dateWithTimeIntervalSinceNow:60]);
}

#pragma mark - Placeholder Templates

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    [self fetch];
    // This method will be called once per supported complication, and the results will be cached
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge: {
            CLKComplicationTemplateModularLargeStandardBody *template = [CLKComplicationTemplateModularLargeStandardBody new];
            template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"Event Title" shortText:@"event"];
            template.headerImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"question-mark-grey"]];
            template.body1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Here will go long long long event description" shortText:@"description"];
            handler(template);
            break;
        }
        case CLKComplicationFamilyModularSmall: {
            CLKComplicationTemplateModularSmallStackImage *template = [CLKComplicationTemplateModularSmallStackImage new];
            template.line1ImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"question-mark-grey"]];
            template.line2TextProvider = [CLKDateTextProvider textProviderWithDate:[NSDate date] units:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear];
            handler(template);
            break;
        }
        case CLKComplicationFamilyUtilitarianLarge: {
            CLKComplicationTemplateUtilitarianLargeFlat *template =
            [CLKComplicationTemplateUtilitarianLargeFlat new];
            template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"question-mark-grey"]];
            template.textProvider = [CLKDateTextProvider textProviderWithDate:[NSDate date] units:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear];
            handler(template);
            break;
        }
        case CLKComplicationFamilyUtilitarianSmall: {
            CLKComplicationTemplateUtilitarianSmallRingText *template =
            [CLKComplicationTemplateUtilitarianSmallRingText new];
            template.textProvider = [CLKDateTextProvider textProviderWithDate:[NSDate date] units:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear];
            handler(template);
            break;
        }
        case CLKComplicationFamilyCircularSmall: {
            CLKComplicationTemplateCircularSmallRingText *template =
            [CLKComplicationTemplateCircularSmallRingText new];
            template.textProvider = [CLKDateTextProvider textProviderWithDate:[NSDate date] units:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear];
            handler(template);
            break;
        }
        default:
            handler(nil);
            break;
    }
}

#pragma mark - helper

- (void)fetch {
    if (!self.dataSource.count) {
        self.dataSource = [[CoreDataManager sharedInstance] fetchAll];
    }
}

@end
