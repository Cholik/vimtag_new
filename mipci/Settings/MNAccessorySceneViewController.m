//
//  MNAccessorySceneViewController.m
//  mipci
//
//  Created by PC-lizebin on 16/8/6.
//
//

#import "MNAccessorySceneViewController.h"
#import "MNDeviceScheduleViewController.h"
#import "UIViewController+loading.h"
#import "MNDeviceAccessoryViewController.h"
#import "MNAccessoryVideoViewController.h"
#import "MNInfoPromptView.h"

#define AWAY   1002
#define ACTIVE 1003
#define AUTO   1004
#define DEFAULTCOLOR [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0]
#define SELECTCOLOR [UIColor colorWithRed:0/255.0 green:166/255.0 blue:186/255.0 alpha:1.0]


@interface MNAccessorySceneViewController ()

@property (copy,nonatomic) NSString *sceneName;

@end

@implementation MNAccessorySceneViewController

#pragma mark - initUI
-(void)initUI
{
    self.title = NSLocalizedString(@"mcs_scenes", nil);
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = [UIScreen mainScreen].bounds.size.height;
    if (width < height) {
        self.height.constant = (height - 64.0 - 24.0) /3;
        self.containViewHeight.constant = height - 64.0 - 24.0;
        self.containViewWidth.constant = width - 20.0;
        self.scrollView.contentInset = UIEdgeInsetsMake(-64.0, 0, -50, 0);
    }else {
        self.height.constant = (width - 64.0 - 24.0) /3;
        self.containViewHeight.constant = width - 64.0 - 24.0;
        self.containViewWidth.constant = width - 20.0;
        self.scrollView.contentInset = UIEdgeInsetsMake(-44.0, 0, -50, 0);
    }
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    _activeLabel.text = NSLocalizedString(@"mcs_home_mode", nil);
    _activePromptLabel.text = NSLocalizedString(@"mcs_home_mode_prompt", nil);
    _awayLabel.text = NSLocalizedString(@"mcs_away_home_mode", nil);
    _awayPromptLabel.text = NSLocalizedString(@"mcs_away_home_mode_prompt", nil);
    _autoLabel.text = NSLocalizedString(@"mcs_auto_mode", nil);
    
    _activeButton.tag = ACTIVE;
    _awayButton.tag = AWAY;
    
    if (_selectScene.length) {
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = backItem;
        
        if ([_selectScene isEqualToString:@"auto"])
        {
            _autoSwitch.on = YES;
            [self sceneStyleChange:AUTO];
        }
        else if ([_selectScene isEqualToString:@"in"])
        {
            _autoSwitch.on = NO;
            [self sceneStyleChange:ACTIVE];
        }
        else
        {
            _autoSwitch.on = NO;
            [self sceneStyleChange:AWAY];
        }
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStylePlain target:self action:@selector(cancle)];
            self.navigationItem.leftBarButtonItem = item;
        }
        
        _autoSwitch.on = NO;
        _autoLabel.highlighted = _autoSwitch.on;
        _calenderButton.selected = _autoSwitch.on;
        _calenderButton.enabled = _autoSwitch.on;
        _activeButton.enabled = !_autoSwitch.on;
        _awayButton.enabled = !_autoSwitch.on;
        _activeButton.selected = YES;
        _awayButton.selected = NO;
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    if (_selectScene.length == 0) {
        mcall_ctx_scene_get *ctx = [[mcall_ctx_scene_get alloc] init];
        ctx.sn = _deviceID;
        ctx.target = self;
        ctx.on_event = @selector(scene_get_done:);
        [_agent scene_get:ctx];
        [self loading:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MNInfoPromptView hideAll:_rootNavigationController ? _rootNavigationController : self.navigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)setTheScene:(id)sender {
    UIButton *btn = sender;
    _autoSwitch.on = NO;
    [self sceneStyleChange:btn.tag];
    [self setSceneAPI];
}

- (IBAction)autoScene:(id)sender
{
    [self sceneStyleChange:_autoSwitch.on ? AUTO : AWAY];
    [self setSceneAPI];
}

- (IBAction)calender:(id)sender {
    [self performSegueWithIdentifier:@"MNDeviceScheduleViewController" sender:nil];
}

-(void)cancle
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sceneStyleChange:(NSInteger)tag
{
    _autoLabel.highlighted = _autoSwitch.on;
    _calenderButton.selected = _autoSwitch.on;
    _calenderButton.enabled = _autoSwitch.on;
    _activeButton.enabled = !_autoSwitch.on;
    _awayButton.enabled = !_autoSwitch.on;
    _activeButton.selected = (tag == ACTIVE) ? YES : NO;
    _awayButton.selected = (tag == AWAY) ? YES : NO;
    
    if (tag == AUTO) {
        _selectScene = @"auto";
        _sceneName = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"mcs_scenes", nil),NSLocalizedString(@"mcs_auto_mode", nil)];
    } else if (tag == ACTIVE) {
        _selectScene = @"in";
        _sceneName = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"mcs_scenes", nil),NSLocalizedString(@"mcs_home_mode", nil)];
    } else {
        _selectScene = @"out";
        _sceneName = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"mcs_scenes", nil),NSLocalizedString(@"mcs_away_home_mode", nil)];
    }
}

#pragma mark - Call & Recall
-(void)setSceneAPI
{
    mcall_ctx_scene_set *ctx = [[mcall_ctx_scene_set alloc] init];
    ctx.sn = _deviceID;
    ctx.select = _selectScene;
    ctx.all = 0;
    ctx.target = self;
    ctx.timeout = 10;
    ctx.on_event = @selector(scene_set_done:);
    [self.agent scene_set:ctx];
    [self loading:YES];
}

- (void)scene_set_done:(mcall_ret_scene_set *)ret
{
    [self loading:NO];
    if (ret.result == nil) {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
        if (self.deviceAccessoryViewController) {
            self.deviceAccessoryViewController.selectScene = _selectScene;
            self.deviceAccessoryViewController.sceneLabel.text = _sceneName;
        }
        if (self.accessoryVideoViewController) {
            self.accessoryVideoViewController.selectScene = _selectScene;
            self.accessoryVideoViewController.sceneLabel.text = _sceneName;
        }
    }else {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
    }
}

- (void)scene_get_done:(mcall_ret_scene_get *)ret
{
    [self loading:NO];
    if (ret.result == nil) {
        if ([ret.select isEqualToString:@"auto"])
        {
            _autoSwitch.on = YES;
            [self sceneStyleChange:AUTO];
        }
        else if ([ret.select isEqualToString:@"in"])
        {
            _autoSwitch.on = NO;
            [self sceneStyleChange:ACTIVE];

        }
        else
        {
            _autoSwitch.on = NO;
            [self sceneStyleChange:AWAY];
        }
    } else {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
    }
}

#pragma mark - PrepareForSegue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MNDeviceScheduleViewController *deviceScheduleViewController = segue.destinationViewController;
    deviceScheduleViewController.agent = self.agent;
    deviceScheduleViewController.deviceID = self.deviceID;
}

#pragma mark - InterfaceOrientation
-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
//        return UIInterfaceOrientationMaskPortrait;
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    float width = [UIScreen mainScreen].bounds.size.width;
    self.containViewWidth.constant = width - 20.0;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.scrollView.contentOffset = CGPointMake(0, 0);
}
@end
