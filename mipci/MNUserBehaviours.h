//
//  MNUserBehaviours.h
//  mipci
//
//  Created by mining on 16/5/30.
//
//

#import <Foundation/Foundation.h>

@interface PlayToken : NSObject<NSCoding>

//he Profile Token element indicates the media profile to use how many times
//720 X 1080
@property(assign,nonatomic)NSInteger p0_token;
//640 X 360
@property(assign,nonatomic)NSInteger p1_token;
//320 X 180
@property(assign,nonatomic)NSInteger p2_token;
//160 X 90 or 160 X 96
@property(assign,nonatomic)NSInteger p3_token;

@end


@interface MNUserBehaviours : NSObject<NSCoding>

/*
 Get first using time
 Get last using time
 Login success times
 Login fail times
 Get device list success
 Get device list fail
 Device Play success times
 Device play fail times
 The Profile Token element indicates the media profile to use how many times
 Device snapshot success times
 Device snapshot fail times
 Device replay success times
 Device replay fail times
 Device add ipc success times
 Device add ipc fail times
 Device add ipc with wifi connected success times
 Device add ipc with wifi connected fail times
 */

@property(assign,nonatomic)long long start_time;
@property(assign,nonatomic)long long last_time;

@property(assign,nonatomic)NSInteger login_succ_times;
@property(assign,nonatomic)NSInteger login_fail_times;

@property(assign,nonatomic)NSInteger devs_refresh_succ_times;
@property(assign,nonatomic)NSInteger devs_refresh_fail_times;

@property(assign,nonatomic)NSInteger dev_play_succ_times;
@property(assign,nonatomic)NSInteger dev_play_fail_times;

@property(strong,nonatomic)PlayToken *playToken;

@property(assign,nonatomic)NSInteger dev_snaps_succ_times;
@property(assign,nonatomic)NSInteger dev_snaps_fail_times;

@property(assign,nonatomic)NSInteger dev_replay_succ_times;
@property(assign,nonatomic)NSInteger dev_replay_fail_tiems;

@property(assign,nonatomic)NSInteger dev_add_succ_times;
@property(assign,nonatomic)NSInteger dev_add_fail_times;

@property(assign,nonatomic)NSInteger dev_add_wfc_succ_times;
@property(assign,nonatomic)NSInteger dev_add_wfc_fail_times;

@property(assign,nonatomic)long long last_feedback_time;



@end
