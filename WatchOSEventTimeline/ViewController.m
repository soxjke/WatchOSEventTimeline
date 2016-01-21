//
//  ViewController.m
//  WatchOSEventTimeline
//
//  Created by Petro Korienev on 1/10/16.
//  Copyright © 2016 Petro Korienev. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "CoreDataManager.h"
#import "EventTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SAMHUDView.h"
#import "AppDelegate.h"
#import "MMWormhole.h"

NSString * const URLPattern = @"/store/connector/7400712a-7f34-4322-8184-e9e56be6d092/_query?input=webpage/url:http%%3A%%2F%%2Fdou.ua%%2Fcalendar%%2Fpage-%lu%%2F&&_apikey=7054e2e6c2bd4c2eb90e56164c635a9076eba370601cfec63bf4576e5ea8f3362885e9eb5b6ebb6e3b9a1b44886414e0fbf3a958debe2163c048b2862198f7976ccedeaa8fe256edd8f7bee146bfa97b";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSArray *dataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) SAMHUDView *hud;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) MMWormhole *wormhole;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.import.io"]];
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.currentPage = 1;
    [self loadDataForCurrentPage];
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.soxjke.WatchOSEventTimeline"
                         optionalDirectory:@"wormhole"];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)loadDataForCurrentPage {
    NSString *path = [NSString stringWithFormat:URLPattern, (unsigned long)self.currentPage];
    __weak typeof(self) weakSelf = self;
    self.hud = [[SAMHUDView alloc] initWithTitle:@"Loading" loading:YES];    
    [self.hud show];
    [self.sessionManager GET:path parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        weakSelf.dataSource = [[CoreDataManager sharedInstance] parseAndStorePage:weakSelf.currentPage withObjects:responseObject[@"results"]];
        [self.appDelegate.session sendMessage:responseObject replyHandler:nil errorHandler:^(NSError * _Nonnull error) {
            NSLog(@"%@", error);
        }];
        [self.wormhole passMessageObject:responseObject
                              identifier:@"group.com.soxjke.WatchOSEventTimeline"];
        [weakSelf updateNoLoad:YES];
        [weakSelf.hud completeAndDismissWithTitle:@"Success"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.hud failAndDismissWithTitle:@"Failed"];
    }];
}

- (IBAction)previousButtonTapped:(id)sender {
    self.currentPage--;
    [self updateNoLoad:NO];
}

- (IBAction)nextButtonTapped:(id)sender {
    self.currentPage++;
    [self updateNoLoad:NO];
}

- (void)updateNoLoad:(BOOL)noLoad {
    if (self.currentPage == 1) {
        self.previousButton.enabled = NO;
    }
    else {
        self.previousButton.enabled = YES;
        if (self.dataSource.count < 20) {
            self.nextButton.enabled = NO;
        }
        else {
            self.nextButton.enabled = YES;
        }
    }
    if (!noLoad) {
        [self loadDataForCurrentPage];
    }
    [self.tableView reloadData];
    self.titleLabel.text = [NSString stringWithFormat:@"Page %lu", self.currentPage];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [NSDateFormatter new];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateFormat = @"dd/MM/YYY";
    }
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EventTableViewCell class]) forIndexPath:indexPath];
    Event *event = [self.dataSource objectAtIndex:[indexPath row]];
    cell.eventTitleLabel.text = event.title;
    cell.eventVenueLabel.text = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:event.date], event.venue];
    [cell.logoImageView setImageWithURL:[NSURL URLWithString:event.imageURL]
                       placeholderImage:[UIImage imageNamed:@"question-mark-grey"]];
    return cell;
}

@end
