//
//  ExtensionDelegate.m
//  WatchOSEventTimeline WatchKit Extension
//
//  Created by Petro Korienev on 1/10/16.
//  Copyright © 2016 Petro Korienev. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "CoreDataManager.h"
#import "AFNetworking.h"
#import <ClockKit/ClockKit.h>

@interface ExtensionDelegate ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, assign) NSUInteger currentPage;

@end

NSString * const URLPattern = @"/store/connector/7400712a-7f34-4322-8184-e9e56be6d092/_query?input=webpage/url:http%%3A%%2F%%2Fdou.ua%%2Fcalendar%%2Fpage-%lu%%2F&&_apikey=7054e2e6c2bd4c2eb90e56164c635a9076eba370601cfec63bf4576e5ea8f3362885e9eb5b6ebb6e3b9a1b44886414e0fbf3a958debe2163c048b2862198f7976ccedeaa8fe256edd8f7bee146bfa97b";

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
}

- (void)applicationDidBecomeActive {
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.import.io"]];
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.currentPage = 1;
    [self loadDataForCurrentPage];
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

- (void)loadDataForCurrentPage {
    NSString *path = [NSString stringWithFormat:URLPattern, (unsigned long)self.currentPage];
    __weak typeof(self) weakSelf = self;
    [self.sessionManager GET:path parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [[CoreDataManager sharedInstance] parseAndStorePage:weakSelf.currentPage withObjects:responseObject[@"results"]];
        for(CLKComplication *obj in [[CLKComplicationServer sharedInstance] activeComplications]) {
            [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:obj];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
}


@end
