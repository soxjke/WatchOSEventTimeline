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
    handler(CLKComplicationTimeTravelDirectionBackward | CLKComplicationTimeTravelDirectionForward);
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
    __block Event *event = self.dataSource.firstObject;
    [self.dataSource enumerateObjectsUsingBlock:^(Event * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.date timeIntervalSinceDate:[NSDate date]] < 0) {
            event = obj;
        }
        else {
            *stop = YES;
        }
    }];
    CLKComplicationTemplate *template = [self complicationTemplateForEvent:event complication:complication];
    handler([CLKComplicationTimelineEntry entryWithDate:event.date complicationTemplate:template]);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    NSArray *preparedDataSoure = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Event *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ([evaluatedObject.date timeIntervalSinceDate:date] < 0);
    }]];
    if (preparedDataSoure.count > limit) {
        preparedDataSoure = [preparedDataSoure subarrayWithRange:NSMakeRange(preparedDataSoure.count - limit, limit)];
    }
    NSMutableArray *mutableEntries = [NSMutableArray new];
    [preparedDataSoure enumerateObjectsUsingBlock:^(Event *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CLKComplicationTemplate *template = [self complicationTemplateForEvent:obj complication:complication];
        [mutableEntries addObject:[CLKComplicationTimelineEntry entryWithDate:obj.date complicationTemplate:template]];
    }];
    handler(mutableEntries);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    NSArray *preparedDataSoure = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Event *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ([evaluatedObject.date timeIntervalSinceDate:date] > 0);
    }]];
    if (preparedDataSoure.count > limit) {
        preparedDataSoure = [preparedDataSoure subarrayWithRange:NSMakeRange(preparedDataSoure.count - limit, limit)];
    }
    NSMutableArray *mutableEntries = [NSMutableArray new];
    [preparedDataSoure enumerateObjectsUsingBlock:^(Event *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CLKComplicationTemplate *template = [self complicationTemplateForEvent:obj complication:complication];
        [mutableEntries addObject:[CLKComplicationTimelineEntry entryWithDate:obj.date complicationTemplate:template]];
    }];
    handler(mutableEntries);
}

#pragma mark Update Scheduling

- (void)getNextRequestedUpdateDateWithHandler:(void(^)(NSDate * __nullable updateDate))handler {
    // Call the handler with the date when you would next like to be given the opportunity to update your complication content
    handler([NSDate dateWithTimeIntervalSinceNow:60]);
}

#pragma mark - Placeholder Templates

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    [self fetch];
    handler([self complicationTemplateForEvent:nil complication:complication]);
}

#pragma mark - helper

- (void)fetch {
    if (!self.dataSource.count) {
        self.dataSource = [[CoreDataManager sharedInstance] fetchAll];
    }
}

- (CLKComplicationTemplate *)complicationTemplateForEvent:(Event *)event complication:(CLKComplication *)complication {
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge: {
            CLKComplicationTemplateModularLargeStandardBody *template = [CLKComplicationTemplateModularLargeStandardBody new];
            template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:event.title ?: @"Event Title" shortText:event.title ?: @"event"];
            template.headerImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"question-mark-grey"]];
            template.body1TextProvider = [CLKSimpleTextProvider textProviderWithText:event.eventDescription ?: @"Here will go long long long event description" shortText:event.eventDescription ?: @"description"];
            return template;
        }
        case CLKComplicationFamilyModularSmall: {
            CLKComplicationTemplateModularSmallStackImage *template = [CLKComplicationTemplateModularSmallStackImage new];
            template.line1ImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"question-mark-grey"]];
            template.line2TextProvider = [CLKDateTextProvider textProviderWithDate:event.date ?: [NSDate date] units:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear];
            return template;
        }
        case CLKComplicationFamilyUtilitarianLarge: {
            CLKComplicationTemplateUtilitarianLargeFlat *template =
            [CLKComplicationTemplateUtilitarianLargeFlat new];
            template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"question-mark-grey"]];
            template.textProvider = [CLKDateTextProvider textProviderWithDate:event.date ?: [NSDate date] units:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear];
            return template;
        }
        case CLKComplicationFamilyUtilitarianSmall: {
            CLKComplicationTemplateUtilitarianSmallRingText *template =
            [CLKComplicationTemplateUtilitarianSmallRingText new];
            template.textProvider = [CLKDateTextProvider textProviderWithDate:event.date ?: [NSDate date] units:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear];
            return template;
        }
        case CLKComplicationFamilyCircularSmall: {
            CLKComplicationTemplateCircularSmallRingText *template =
            [CLKComplicationTemplateCircularSmallRingText new];
            template.textProvider = [CLKDateTextProvider textProviderWithDate:event.date ?: [NSDate date] units:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear];
            return template;
        }
        default:
            return nil;
    }
}

@end
