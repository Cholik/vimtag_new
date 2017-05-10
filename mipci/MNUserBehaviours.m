//
//  MNUserBehaviours.m
//  mipci
//
//  Created by mining on 16/5/30.
//
//

#import "MNUserBehaviours.h"

@implementation PlayToken

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.p0_token = [aDecoder decodeIntegerForKey: @"p0_token"];
        self.p1_token = [aDecoder decodeIntegerForKey: @"p1_token"];
        self.p2_token = [aDecoder decodeIntegerForKey: @"p2_token"];
        self.p3_token = [aDecoder decodeIntegerForKey: @"p3_token"];
    }
    return self;
    
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeInteger: _p0_token forKey:@"p0_token"];
    [aCoder encodeInteger: _p1_token forKey:@"p1_token"];
    [aCoder encodeInteger: _p2_token forKey:@"p2_token"];
    [aCoder encodeInteger: _p3_token forKey:@"p3_token"];
    
}

@end

@implementation MNUserBehaviours

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{

    self = [super init];
    if (self) {
        self.start_time = [aDecoder decodeIntegerForKey:@"start_time"];
        self.last_time = [aDecoder decodeIntegerForKey: @"last_time"];
        self.login_succ_times = [aDecoder decodeIntegerForKey: @"login_succ_times"];
        self.login_fail_times = [aDecoder decodeIntegerForKey: @"login_fail_times"];
        self.devs_refresh_succ_times = [aDecoder decodeIntegerForKey: @"devs_refresh_succ_times"];
        self.devs_refresh_fail_times = [aDecoder decodeIntegerForKey: @"devs_refresh_fail_times"];
        self.dev_play_succ_times = [aDecoder decodeIntegerForKey: @"dev_play_succ_times"];
        self.dev_play_fail_times = [aDecoder decodeIntegerForKey: @"dev_play_fail_times"];
        self.playToken = [aDecoder decodeObjectForKey:@"playToken"];
        self.dev_snaps_fail_times = [aDecoder decodeIntegerForKey: @"dev_snaps_fail_times"];
        self.dev_snaps_succ_times = [aDecoder decodeIntegerForKey: @"dev_snaps_succ_times"];
        self.dev_replay_succ_times = [aDecoder decodeIntegerForKey: @"dev_replay_succ_times"];
        self.dev_replay_fail_tiems = [aDecoder decodeIntegerForKey: @"dev_replay_fail_tiems"];
        self.dev_add_succ_times = [aDecoder decodeIntegerForKey: @"dev_add_succ_times"];
        self.dev_add_fail_times = [aDecoder decodeIntegerForKey: @"dev_add_fail_times"];
        self.dev_add_wfc_succ_times = [aDecoder decodeIntegerForKey: @"dev_add_wfc_succ_times"];
        self.dev_add_wfc_fail_times = [aDecoder decodeIntegerForKey: @"dev_add_wfc_fail_times"];
        self.last_feedback_time = [aDecoder decodeIntegerForKey:@"last_feedback_time"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_start_time forKey:@"start_time"];
    [aCoder encodeInteger:_last_time forKey:@"last_time"];
    [aCoder encodeInteger:_login_succ_times forKey:@"login_succ_times"];
    [aCoder encodeInteger:_login_fail_times forKey:@"login_fail_times"];
    [aCoder encodeInteger:_devs_refresh_succ_times forKey:@"devs_refresh_succ_times"];
    [aCoder encodeInteger:_devs_refresh_fail_times forKey:@"devs_refresh_fail_times"];
    [aCoder encodeInteger:_dev_play_succ_times forKey:@"dev_play_succ_times"];
    [aCoder encodeInteger:_dev_play_fail_times forKey:@"dev_play_fail_times"];
    [aCoder encodeObject:_playToken forKey:@"playToken"];
    [aCoder encodeInteger:_dev_snaps_succ_times forKey:@"dev_snaps_succ_times"];
    [aCoder encodeInteger:_dev_snaps_fail_times forKey:@"dev_snaps_fail_times"];
    [aCoder encodeInteger:_dev_replay_succ_times forKey:@"dev_replay_succ_times"];
    [aCoder encodeInteger:_dev_replay_fail_tiems forKey:@"dev_replay_fail_tiems"];
    [aCoder encodeInteger:_dev_add_succ_times forKey:@"dev_add_succ_times"];
    [aCoder encodeInteger:_dev_add_fail_times forKey:@"dev_add_fail_times"];
    [aCoder encodeInteger:_dev_add_wfc_succ_times forKey:@"dev_add_wfc_succ_times"];
    [aCoder encodeInteger:_dev_add_wfc_fail_times forKey:@"dev_add_wfc_fail_times"];
    [aCoder encodeInteger:_last_feedback_time forKey:@"last_feedback_time"];
}

@end
