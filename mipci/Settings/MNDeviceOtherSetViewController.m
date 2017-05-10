//
//  MNDeviceOtherSetViewController.m
//  mining_client
//
//  Created by mining on 14-9-12.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import "MNDeviceOtherSetViewController.h"
#import "UITableViewController+loading.h"
#import "MNToastView.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"
#import "MNInfoPromptView.h"
#import "MNSystemSettingsAlertView.h"

#define REBOOT           1001
#define DEVICERESTARTING 1002

#define SCREEN_SIZE_ADAPT       @"4:3"
#define SCREEN_SIZE_COVERED     @"16:9"

@interface MNDeviceOtherSetViewController ()
@property (assign, nonatomic) BOOL isViewAppearing;

@property (assign, nonatomic) int brightness;
@property (assign, nonatomic) int contrast;
@property (assign, nonatomic) int saturation;
@property (assign, nonatomic) int sharpness;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (weak, nonatomic)   AppDelegate *app;
@property (assign, nonatomic) long ratio;
@property (assign, nonatomic) long screenIndex;

@end

@implementation MNDeviceOtherSetViewController

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = NSLocalizedString(@"mcs_others", nil);
    }
    
    return self;
}

- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    return _configuration;
}

-(void)initUI
{
    _ratio = 0;
    
    self.navigationItem.title = NSLocalizedString(@"mcs_others", nil);
    [self.applyButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
    
    //code for color
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_applyButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_applyButton setBackgroundColor:app.button_color];
    
    self.speakerTiteLable.text = NSLocalizedString(@"mcs_speaker", nil);
    self.microphoneTiteLable.text = NSLocalizedString(@"mcs_mic", nil);
    self.overturnTiteLable.text = NSLocalizedString(@"mcs_equipment_flip", nil);
    
    self.speakerSlider.value = 0;
    self.speakerValueLable.text = @"0";
    self.microphoneSlider.value = 0;
    self.microphoneValueLable.text = @"0";
    self.overturnSwitch.on = NO;
    
    self.overturnSwitch.onTintColor = self.configuration.switchTintColor;
    self.frequencySegment.tintColor = self.configuration.switchTintColor;
    self.screenSegment.tintColor = self.configuration.switchTintColor;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.microphoneSlider.tintColor = self.configuration.switchTintColor;
        self.speakerSlider.tintColor = self.configuration.switchTintColor;
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    _isViewAppearing = YES;
    
    mcall_ctx_audio_get *audio_ctx = [[mcall_ctx_audio_get alloc] init];
    audio_ctx.sn = _deviceID;
    audio_ctx.target = self;
    audio_ctx.on_event = @selector(audio_get_done:);
    [_agent audio_get:audio_ctx];
    
    mcall_ctx_cam_get *cam_ctx = [[mcall_ctx_cam_get alloc] init];
    cam_ctx.sn = _deviceID;
    cam_ctx.on_event = @selector(cam_get_done:);
    cam_ctx.target = self;
    [_agent cam_get:cam_ctx];
    
    [self loading:YES];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MNInfoPromptView hideAll:_rootNavigationController];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - audio_get_done
//设置操作
- (void)audio_get_done:(mcall_ret_audio_get *)ret
{
    [self loading:NO];
    
    if (!_isViewAppearing)
    {
        return;
    }
    
    if(nil != ret.result)
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView failToast:nil]];
            }
        }
        return;
    }
    else
    {
        //FIXME:add alert
        _speakerSlider.value = ret.speaker_level;
        [_speakerSlider sendActionsForControlEvents:UIControlEventValueChanged];
        
        _microphoneSlider.value = ret.mic_level;
        [_microphoneSlider sendActionsForControlEvents:UIControlEventValueChanged];
        
    }
    
}

#pragma mark - cam_get_done
- (void)cam_get_done:(mcall_ret_cam_get *)ret
{
    [self loading:NO];
    
    if (!_isViewAppearing)
    {
        return;
    }
    
    if(nil != ret.result)
    {
        
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView failToast:nil]];
            }
        }
        return;
    }
    else
    {
        //FIXME:add alert
        _brightness = ret.brightness;
        _contrast = ret.contrast;
        _saturation = ret.saturation;
        _sharpness = ret.sharpness;
        self.overturnSwitch.on = ret.flip;
        [self.frequencySegment setSelectedSegmentIndex:ret.flicker_freq];
        [self.screenSegment setSelectedSegmentIndex:[ret.resolute isEqualToString:SCREEN_SIZE_ADAPT] ? 0 : 1];
        _screenIndex = self.screenSegment.selectedSegmentIndex;
        
        m_dev        *dev = [_agent.devs get_dev_by_sn:_deviceID];
        if (dev.ratio && ret.resolute.length) {
            _ratio = 1;
            [self.tableView reloadData];
        }
    }
}

#pragma mark - cam_set_done
- (void)cam_set_done:(mcall_ret_cam_set *)ret
{
    [self loading:NO];
    if (!_isViewAppearing)
    {
        return;
    }
    
    if (nil == ret.result)
    {
//        [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
    }
    else
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.permission.denied"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_permission_denied",nil)]];
            }
        }
        else
        {
            //            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_failed_to_set_the", nil)]];
        }
    }
}

#pragma mark - audio_set_done
- (void)audio_set_done:(mcall_ret_audio_set *)ret
{
    [self loading:NO];
    if(!_isViewAppearing)
    {
        return;
    }
    
    if (nil == ret.result)
    {
        if (_ratio && (_screenSegment.selectedSegmentIndex != _screenIndex)) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt" , nil)
                                                                message:NSLocalizedString(@"mcs_sdcard_reset", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                                      otherButtonTitles:NSLocalizedString(@"mcs_ok", nil) , nil];
            alertView.tag = REBOOT;
            [alertView show];
        } else {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
            }
        }
    }
    else
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.permission.denied"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_permission_denied",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_failed_to_set_the", nil)]];
            }
        }
    }
}

- (void)reboot_done:(mcall_ret_reboot *)ret
{
    [self loading:NO];
    if (!_isViewAppearing) {
        return;
    }
    
    if(nil == ret.result)
    {
        NSString *buttonTitle;
        if (self.app.is_jump && (self.app.isLoginByID || (self.app.serialNumber && self.app.serialNumber.length)))
        {
            buttonTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"mcs_will_back", nil), self.app.fromTarget];
        }
        else
        {
            buttonTitle = NSLocalizedString(@"mcs_i_know", nil);
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_restarting" , nil)
                                                            message:NSLocalizedString(@"mcs_visit_again_later", nil)
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:buttonTitle , nil];
        alertView.tag = DEVICERESTARTING;
        [alertView show];
    }
    else
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.permission.denied"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_permission_denied",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_restart_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_restart_failed", nil)]];
            }
        }
    }
}

#pragma mark - AlertView delegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        switch ([alertView tag])
        {
            case REBOOT:
            {
                mcall_ctx_reboot *ctx = [[mcall_ctx_reboot alloc] init];
                ctx.sn = _deviceID;
                ctx.on_event = @selector(reboot_done:);
                ctx.target = self;
                [_agent reboot:ctx];
                [self loading:YES];
                break;
            }
            case DEVICERESTARTING:
            {
                if (self.app.is_jump && (self.app.isLoginByID || (self.app.serialNumber && self.app.serialNumber.length)))
                {
                    NSString *url = [self.app.fromTarget stringByAppendingString:@"://ret.dev.offline"];
                    if (url) {
                        self.app.is_jump = NO;
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    }
                    
                }
                else
                {
                    NSNotification *notification = [NSNotification notificationWithName:@"DeviceRestartNotification" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotification:notification];
                    
                }
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Action
- (IBAction)speakerValueChange:(id)sender
{
    self.speakerValueLable.text = [NSString stringWithFormat:@"%d", (int)((UISlider*)sender).value];
}
- (IBAction)microphoneValueChange:(id)sender
{
    self.microphoneValueLable.text = [NSString stringWithFormat:@"%d", (int)((UISlider*)sender).value];
}

- (IBAction)apply:(id)sender
{

    mcall_ctx_cam_set *cam_ctx = [[mcall_ctx_cam_set alloc] init];
    cam_ctx.sn = _deviceID;
    cam_ctx.brightness = _brightness?_brightness:50;
    cam_ctx.contrast = _contrast?_contrast:65;
    cam_ctx.saturation = _saturation?_saturation:75;
    cam_ctx.sharpness = _sharpness?_sharpness:20;
    cam_ctx.flip = _overturnSwitch.on;
    cam_ctx.flicker_freq = (int)_frequencySegment.selectedSegmentIndex;
    if (_ratio) {
        cam_ctx.resolute = _screenSegment.selectedSegmentIndex == 0 ? SCREEN_SIZE_ADAPT : SCREEN_SIZE_COVERED;
    }
    cam_ctx.on_event = @selector(cam_set_done:);
    cam_ctx.target = self;
    [_agent cam_set:cam_ctx];
    
    
    mcall_ctx_audio_set *audio_ctx = [[mcall_ctx_audio_set alloc] init];
    audio_ctx.sn = _deviceID;
    audio_ctx.on_event = @selector(audio_set_done:);
    audio_ctx.target = self;
    audio_ctx.speaker_level = [_speakerValueLable.text intValue];
    audio_ctx.mic_level = [_microphoneValueLable.text intValue];
    [_agent audio_set:audio_ctx];
    
    [self loading:YES];
}

#pragma mark - Table view delegate
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"", nil);
    }
    else if (section == 1)
    {
        return NSLocalizedString(@"mcs_power_frequency", nil);
    }
    else if (section == 2)
    {
        if (_ratio) {
            return NSLocalizedString(@"mcs_screen_size", nil);
        } else {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _ratio ? 4 : 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 3 : 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (_ratio) {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        if (indexPath.section >= 2) {
            NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
            cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
        } else {
            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }
    }
    
    return cell;
}

@end
