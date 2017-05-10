//
//  MNSnapshotViewCell.m
//  mipci
//
//  Created by weken on 15/5/19.
//
//

#import "MNSnapshotViewCell.h"
#import "mipc_agent.h"
#import "AppDelegate.h"

@interface MNSnapshotViewCell()
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) NSString *token;

@end

@implementation MNSnapshotViewCell

-(mipc_agent *)agent
{
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return app.isLocalDevice?app.localAgent:app.cloudAgent;
}

#pragma mark - prepareForReuse
-(void)prepareForReuse
{
    [super prepareForReuse];
    
    _snapshotImageView.image = nil;
    _timeLabel.text = nil;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //iniUI
    _snapshotImageView.layer.borderWidth = 0.5;
    _snapshotImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //initParameter
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_start_time / 1000];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [currentCalendar components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    NSInteger hour = [weekdayComponents hour];
    NSInteger min = [weekdayComponents minute];
    NSInteger sec = [weekdayComponents second];

    _timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)sec];
    
    self.token = [NSString stringWithFormat:@"%@_p3_%ld_%ld", _deviceID, _cluster_id, _seg_id];
    
    mcall_ctx_pic_get *ctx = [[mcall_ctx_pic_get alloc] init];
    ctx.sn = _boxID;
    ctx.target = self;
    ctx.token = _token;
    ctx.type = mdev_pic_seg_album;
    ctx.flag = 1;
    ctx.on_event = @selector(pic_get_done:);
    
//    [self.agent pic_get:ctx];
}

#pragma mark - pic_get_done
- (void)pic_get_done:(mcall_ret_pic_get*)ret
{
    //the normal operation is that cancel the thread of downloading the picture
    //FIXME:need to be changed
    if (nil != ret.img && _token == ret.token)
    {
        _snapshotImageView.image = ret.img;
    }
}


@end
