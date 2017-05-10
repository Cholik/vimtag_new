//
//  MNAddAccessoryViewController.m
//  mipci
//
//  Created by mining on 16/6/8.
//
//

#import "MNAddAccessoryViewController.h"
#import "MNSetNickNameViewController.h"
#import "MNAddResultViewController.h"
#define TIME 90.0

@interface MNAddAccessoryViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *timeCountView;
@property (weak, nonatomic) IBOutlet UIImageView *progressViewImg;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, assign) int timeCount;
@property (weak, nonatomic) IBOutlet UIWebView *gifWebView;
@property (weak, nonatomic) IBOutlet UILabel *headLabel;
@property (strong ,nonatomic) NSData *gifData;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (assign, nonatomic) BOOL isfailOfCancle;
@property (assign,nonatomic) long rtime;;

@end

@implementation MNAddAccessoryViewController


-(void)initUI
{
    switch (self.searchAccessoryViewController.type) {
        case 5:
            self.headLabel.text = NSLocalizedString(@"mcs_add_accessory_button", nil);
            break;
        case 6:
            self.headLabel.text = NSLocalizedString(@"mcs_add_accessory_button", nil);
            break;
        default:
            break;
    }
    self.timeView.layer.cornerRadius = 10;
    self.timeView.layer.masksToBounds = YES;
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
    mcall_ctx_exdev_get *ctx = [[mcall_ctx_exdev_get alloc] init];
    ctx.sn = _deviceID;
    ctx.flag = 3;
    ctx.target = self;
    ctx.exdev_id = self.exdevID;
    ctx.on_event = @selector(exdev_get_done:);
    [_agent exdev_get:ctx];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkAddResult) userInfo:nil repeats:YES];
    self.timeCount = TIME;
    
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"gif" ofType:nil];
    NSString *headGifPath;
    switch (self.searchAccessoryViewController.type) {
        case 5:
            headGifPath = [NSString stringWithFormat:@"%@/sos_add.gif",gifPath];
            break;
        case 6:
            headGifPath = [NSString stringWithFormat:@"%@/magnetic_add.gif",gifPath];
            break;
        default:
            break;
    }
    self.gifData = [NSData dataWithContentsOfFile:headGifPath];
    self.gifWebView.userInteractionEnabled = NO;
    self.gifWebView.scalesPageToFit = YES;
    self.gifWebView.backgroundColor = [UIColor clearColor];
    self.gifWebView.opaque = 0;
    [self.gifWebView loadData:self.gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    mcall_ctx_dev_msg_listener_del *del = [[mcall_ctx_dev_msg_listener_del alloc] init];
    del.target = self.searchAccessoryViewController;
    [self.searchAccessoryViewController.agent dev_msg_listener_del:del];
    [self.timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.trailingConstraint.constant = (self.progressView.progress - 1) * self.progressView.frame.size.width + 9;
    }
}
#pragma mark - checkAddRecall
-(void)checkAddResult
{
    if (self.searchAccessoryViewController.exit) {
        _isfailOfCancle = YES;
        [self performSegueWithIdentifier:@"MNAddResultViewController" sender:nil];
    }
    if (self.progressView.progress == 0) {
        _isfailOfCancle = NO;
        [self performSegueWithIdentifier:@"MNAddResultViewController" sender:nil];
    }else {
        self.progressView.progress -= (1/TIME);
        self.timeCount -= 1;
        self.timeLabel.text = [NSString stringWithFormat:@"%ds",self.timeCount];
        self.trailingConstraint.constant = (self.progressView.progress - 1) * self.progressView.frame.size.width + 9;
//        self.timeLabel.center = self.progressViewImg.center;
    }
}

-(void)exdev_get_done:(mcall_ret_exdev_get *)ret
{
    if (ret.result == nil) {
        if (ret.exDevs.count == 1) {
            mExDev_obj *obj = ret.exDevs[0];
            if (obj.stat == 1) {
                _rtime = obj.rtime;
                [self performSegueWithIdentifier:@"MNSetNickNameViewController" sender:nil];
                [self.timer invalidate];
            }
        }
    }
    if (self.timer.isValid) {
        mcall_ctx_exdev_get *ctx = [[mcall_ctx_exdev_get alloc] init];
        ctx.sn = _deviceID;
        ctx.flag = 3;
        ctx.target = self;
        ctx.exdev_id = self.exdevID;
        ctx.on_event = @selector(exdev_get_done:);
        [_agent performSelector:@selector(exdev_get:) withObject:ctx afterDelay:3.0];
    }
}

#pragma mark - Action

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNSetNickNameViewController"]) {
        MNSetNickNameViewController *setNickNameViewController = segue.destinationViewController;
        setNickNameViewController.agent = _agent;
        setNickNameViewController.deviceID = _deviceID;
        setNickNameViewController.exdevID = _exdevID;
        setNickNameViewController.rtime = _rtime;
    }
    if ([segue.identifier isEqualToString:@"MNAddResultViewController"]) {
        MNAddResultViewController *addResultViewController = segue.destinationViewController;
        addResultViewController.isfailOfCanle = _isfailOfCancle;
    }
}
#pragma mark - Rotate

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}
@end
