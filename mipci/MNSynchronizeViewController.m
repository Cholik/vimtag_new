//
//  MNSynchronizeViewController.m
//  mipci
//
//  Created by mining on 16/6/13.
//
//

#import "MNSynchronizeViewController.h"
#import "AppDelegate.h"
#import "UIViewController+loading.h"

@interface MNSynchronizeViewController () <UITableViewDataSource,UITabBarDelegate>
@property (weak, nonatomic) AppDelegate *app;
@property (nonatomic,strong) NSMutableArray *synchronizeArray;
@property (nonatomic,assign) NSInteger recallIndex;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *synchronizeView;
@property (weak, nonatomic) IBOutlet UIButton *synchronizeBtn;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation MNSynchronizeViewController

static NSString * const reuseIdentifier = @"Cell";
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

-(NSMutableArray *)synchronizeArray
{
    if (_synchronizeArray == nil) {
        _synchronizeArray = [NSMutableArray array];
        [self resetSynArray];
    }
    return _synchronizeArray;
}

-(void)initUI
{
    self.label.text = NSLocalizedString(@"mcs_synchronize_detail", nil);
    self.title = NSLocalizedString(@"mcs_synchronize", nil);
    [self.synchronizeBtn setTitle:NSLocalizedString(@"mcs_synchronize", nil) forState:UIControlStateNormal];
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.synchronizeArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    m_dev *dev = [self.synchronizeArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld.%@",indexPath.row + 1 ,dev.sn];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = [UIColor colorWithRed:50.0/255 green:50.0/255 blue:50.0/255 alpha:1.0];
    
    //test
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];

    if (NSOrderedSame == [dev.status caseInsensitiveCompare:@"InvalidAuth"]) {
        NSMutableAttributedString *firstString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  ",NSLocalizedString(@"mcs_password_expired", nil)]];
        [firstString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:252.0/255 green:192.0/255 blue:86.0/255 alpha:1.0] range:NSMakeRange(0,firstString.length)];
        [attributedString appendAttributedString:firstString];
    } else if (!(NSOrderedSame == [dev.status caseInsensitiveCompare:@"online"])) {
        NSMutableAttributedString *firstString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  ",NSLocalizedString(@"mcs_device_offline", nil)]];
        [firstString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,firstString.length)];
        [attributedString appendAttributedString:firstString];
    }
    
    NSString *sceneString = [NSString string];
    if ([dev.scene isEqualToString:@"auto"]) {
        sceneString = NSLocalizedString(@"mcs_auto_switch_mode", nil);
    } else if ([dev.scene isEqualToString:@"in"]) {
        sceneString = NSLocalizedString(@"mcs_home_mode", nil);
    } else if ([dev.scene isEqualToString:@"out"]) {
        sceneString = NSLocalizedString(@"mcs_away_home_mode", nil);
    }
    
    NSMutableAttributedString *secondString= [[NSMutableAttributedString alloc] initWithString:sceneString];
    [secondString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0/255 green:166.0/255 blue:186.0/255 alpha:1.0] range:NSMakeRange(0,secondString.length)];
    [attributedString appendAttributedString:secondString];
    
    cell.detailTextLabel.attributedText = attributedString;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];


//    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0/255 green:166.0/255 blue:186.0/255 alpha:1.0];
//    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Action
- (IBAction)synchronize:(id)sender {
    self.recallIndex = 0;
    [self scene_set_done:nil];
    [self loading:YES];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Recall
-(void)scene_set_done:(mcall_ret_scene_set *)ret
{
    if (ret.result == nil) {
        
    }
    if (self.recallIndex == self.synchronizeArray.count) {
        mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc] init];
        ctx.target = self;
        ctx.on_event = @selector(devs_refresh_done:);
        [self.agent devs_refresh:ctx];
    }else {
        m_dev *dev = nil;
        for ( ; self.recallIndex < self.synchronizeArray.count; self.recallIndex++) {
            dev = self.synchronizeArray[self.recallIndex];
            if (NSOrderedSame == [dev.status caseInsensitiveCompare:@"online"]) {
                break;
            }
        }
        if (self.recallIndex >= self.synchronizeArray.count) {
            mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc] init];
            ctx.target = self;
            ctx.on_event = @selector(devs_refresh_done:);
            [self.agent devs_refresh:ctx];
            return;
        }
        
        mcall_ctx_scene_set *ctx = [[mcall_ctx_scene_set alloc] init];
        ctx.sn = dev.sn;
        ctx.select = self.selectSceneName;
        ctx.all = 0;
        ctx.timeout = 10;
        ctx.target = self;
        ctx.on_event = @selector(scene_set_done:);
        [self.agent scene_set:ctx];
        self.recallIndex ++;
    }
}

-(void)devs_refresh_done:(mcall_ret_devs_refresh*)ret
{
    [self loading:NO];
    if (ret.result == nil) {
        self.devices = ret.devs;
        [self resetSynArray];
        [self.tableView reloadData];
        [self.deviceListSetViewController checkSynchronize:self.selectSceneName inArray:_synchronizeArray];
    }
}

#pragma mark - data
-(void)resetSynArray
{
    [_synchronizeArray removeAllObjects];
    for (int i = 0; i < self.devices.counts; i ++) {
        m_dev *dev = [self.devices get_dev_by_index:i];
        if (dev.support_scene) {
            if (![dev.scene isEqualToString:self.selectSceneName]) {
                [_synchronizeArray addObject:dev];
            }
        }
    }
}

#pragma mark - Rotate
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}
@end
