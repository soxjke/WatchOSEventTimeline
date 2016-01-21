//
//  EventTableViewCell.m
//  WatchOSEventTimeline
//
//  Created by Petro Korienev on 1/21/16.
//  Copyright © 2016 Petro Korienev. All rights reserved.
//

#import "EventTableViewCell.h"

@interface EventTableViewCell ()

@end

@implementation EventTableViewCell

- (void)awakeFromNib {
    self.logoImageView.image = [UIImage imageNamed:@"question-mark-grey"];    
}

- (void)prepareForReuse {
    self.logoImageView.image = [UIImage imageNamed:@"question-mark-grey"];
}

@end
