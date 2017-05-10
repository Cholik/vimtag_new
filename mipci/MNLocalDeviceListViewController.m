//
//  MNLocalDeviceListViewController.m
//  mipci
//
//  Created by mining on 15/11/13.
//
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define __ProbeRequest_type_magic 0x2bdbce08
#define __ProbeResponse_type_magic 0xfe16d431
#define mbmc_msg_tmp_size   1024
#define __CcmSession_type_magic 0x169090d4

#define DEFAULT_LINE_COUNTS       2
#define PROFILE_ID_MAX            3
#define DEFAULT_CELL_MARGIN       4
#define DEFAULT_EDGE_MARGIN       5
#define DELETE_TAG                1001
#define CHANGEPASSWORD_TAG        1002
#define ONLINE                    2001
#define ONLINE_REFRESH            2002

#import "MNLocalDeviceListViewController.h"
#import "MNLANDeviceViewCell.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNProgressHUD.h"
#import "MNToastView.h"
#import "MIPCUtils.h"
#import "UserInfo.h"
#import "MNDeviceListViewController.h"
#import "MNDevicePlayViewController.h"
#import "MNDeviceTabBarController.h"
#import "MNBoxListViewController.h"
#import "MNBoxTabBarController.h"
#import "MNSettingsDeviceViewController.h"
#import "MNMessagePageViewController.h"
#import "MNModifyPasswordViewController.h"
#import "MNLoginViewController.h"
#import "MNInfoPromptView.h"
#import "pack.h"
#import "msg_pack.h"
#import "msg_type.h"
#import "msg_mbc.h"
#import "mipc_def_manager.h"
#import "MNGuideNavigationController.h"
#import "UIImageView+refresh.h"

#pragma mark - struct ProbeRequest

typedef struct ProbeRequest
{
    struct
    {
        struct pack_ip  remote_ip;      /*  */
        int32_t         remote_port;    /*  */
    }_msysenv;                   /*  */
    struct pack_lenstr  pack_def_pointer(Types);    /*  */
    struct pack_lenstr  pack_def_pointer(Scopes);   /*  */
    struct pack_lenstr  type;                       /*  */
    struct pack_lenstr  sn;                         /*  */
}_ProbeRequest;

typedef struct ProbeResponse
{
    struct
    {
        struct pack_ip  remote_ip;      /*  */
        int32_t         remote_port;    /*  */
    }_msysenv;                       /*  */
    uint32_t                ProbeMatch_counts;              /* ProbeMatch counts */
    struct ProbeMatchType   pack_def_pointer(ProbeMatch);   /* [0-100] */
    struct pack_lenstr      sn;                             /*  */
    int32_t                 listen_port;                    /*  */
    struct pack_lenstr      type;                           /*  */
}_ProbeResponse;


@interface MNLocalDeviceListViewController () <MNLANDeviceViewCellDelegate>
{
    unsigned char _encrypt_pwd[16];
    void *mmbc_handle;
}
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (strong, nonatomic) NSIndexPath *lastIndexPath;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) mdev_devs *devices;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) int lastMessageTick;
@property (assign, nonatomic) unsigned int messageSoundID;
@property (strong, nonatomic) NSString *currentDeviceID;
@property (assign, nonatomic) CGSize transitionToSize;
@property (strong, nonatomic) NSString *currentDevicePassword;
@property (assign, nonatomic) int curProfileID;
@property (strong, nonatomic) NSMutableArray *devicesArray;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (strong, nonatomic) UILabel *downRefreshLabel;
@property (strong, nonatomic) UIActivityIndicatorView *pullUpActivityView;
@property (assign, nonatomic) BOOL isScrollerViewRelease;
@property (strong, nonatomic) NSArray *usersArray;
@property (strong, nonatomic) NSMutableArray *deviceList;
@property (strong ,nonatomic) UIImageView *refreshImageView;
@property (strong, nonatomic) NSTimer *refreshTimer;
@property (strong, nonatomic) NSMutableDictionary *playDic;

@property (strong, nonatomic) NSMutableDictionary *agentDic;

@end

@implementation MNLocalDeviceListViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

static NSString * const reuseIdentifier = @"Cell";

-(mipc_agent *)agent
{
    return self.app.localAgent;
}

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}


- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    return _configuration;
}

-(MNProgressHUD *)progressHUD
{
    if (nil == _progressHUD) {
        _progressHUD = [[MNProgressHUD alloc] initWithView:self.view];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.view insertSubview:_progressHUD aboveSubview:self.collectionView];
            [self.view addSubview:_progressHUD];
        });
        _progressHUD.color = [UIColor colorWithWhite:1.0f alpha:0.8f];
        _progressHUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f];
        _progressHUD.labelText = NSLocalizedString(@"mcs_loading", nil);
        _progressHUD.labelColor = [UIColor grayColor];
        if (self.app.is_vimtag) {
            _progressHUD.activityIndicatorColor = [UIColor colorWithRed:0 green:168.0/255 blue:185.0/255 alpha:1.0f];
        }
        else {
            _progressHUD.activityIndicatorColor = [UIColor grayColor];
        }
        
    }
    
    return  _progressHUD;
}

- (NSMutableArray *)deviceList
{
    if (nil == _deviceList) {
        _deviceList = [NSMutableArray array];
    }
    return _deviceList;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        if (self.app.is_vimtag) {
            self.hidesBottomBarWhenPushed = YES;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(becomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    
    return self;
}

-(UIImageView *)refreshImageView
{
    if (_refreshImageView == nil) {
        _refreshImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_vimtagRefresh"]];
    }
    return _refreshImageView;
}

-(NSMutableDictionary *)playDic
{
    if (_playDic == nil) {
        _playDic = [NSMutableDictionary dictionary];
    }
    return _playDic;
}

- (NSMutableDictionary *)agentDic
{
    if (nil == _agentDic) {
        _agentDic = [NSMutableDictionary dictionary];
    }
    return _agentDic;
}

- (void)initUI
{
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
    self.navigationItem.title = NSLocalizedString(@"mcs_local_search", nil);

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    self.collectionView.alwaysBounceVertical = YES;
    
    [_emptyPromptView setHidden:YES];
    _firstLineLabel.text = NSLocalizedString(@"mcs_empty_local_list_first", nil);
    _firstLineLabel.textColor = self.configuration.labelTextColor;
    _thirdLineLabel.text = NSLocalizedString(@"mcs_empty_local_list_fifth", nil);
    _thirdLineLabel.textColor = [UIColor colorWithRed:153./255. green:153./255 blue:153./255. alpha:1.0];
    
    //Init Custom UILabel
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *firstString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"mcs_empty_local_list_second", nil)];
    NSMutableAttributedString *secondString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\"%@\"",NSLocalizedString(@"mcs_empty_local_list_third", nil)]];
    NSMutableAttributedString *thirdString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"mcs_empty_local_list_forth", nil)];
    [firstString addAttribute:NSForegroundColorAttributeName value:self.configuration.labelTextColor range:NSMakeRange(0,firstString.length)];
    [secondString addAttribute:NSForegroundColorAttributeName value:self.configuration.switchTintColor range:NSMakeRange(0, secondString.length)];
    [thirdString addAttribute:NSForegroundColorAttributeName value:self.configuration.labelTextColor range:NSMakeRange(0, thirdString.length)];
    [attributedString appendAttributedString:firstString];
    [attributedString appendAttributedString:secondString];
    [attributedString appendAttributedString:thirdString];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:NSMakeRange(0, attributedString.length)];
    
    _secondLineLabel.attributedText = attributedString;
    _secondLineLabel.numberOfLines = 2;
    _secondLineLabel.textAlignment = NSTextAlignmentCenter;
    
    _downRefreshLabel = [[UILabel alloc] init];
    CGRect downRefreshLabelFrame = _downRefreshLabel.frame;
    downRefreshLabelFrame = CGRectMake(0, -35, 300, 40);
    //    downRefreshLabelFrame.origin.y = -35;
    _downRefreshLabel.frame = downRefreshLabelFrame;
    CGPoint downRefreshLabelCenter = _downRefreshLabel.center;
    downRefreshLabelCenter.x = self.collectionView.center.x;
    _downRefreshLabel.center = downRefreshLabelCenter;
    
    _downRefreshLabel.font = [UIFont systemFontOfSize:16];
    _downRefreshLabel.textAlignment = NSTextAlignmentCenter;
    _downRefreshLabel.textColor = self.configuration.labelTextColor;
    _downRefreshLabel.hidden = YES;

//        [self.collectionView addSubview:_downRefreshLabel];
    
    //get _downRefreshLabel.text width
    NSString *downRefreshLabelText = NSLocalizedString(@"mcs_refreshing", nil);
    CGSize labelSize = CGSizeMake(100, 20);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
    {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        labelSize = [downRefreshLabelText boundingRectWithSize:CGSizeMake(0, 0)
                                                       options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                    attributes:attributes
                                                       context:nil].size;
        
        labelSize.width = ceil(labelSize.width);
    }
    if (self.app.is_vimtag) {
        [self.refreshImageView setImageViewFrame:self.collectionView with:labelSize];
    }
    else {
        //activity for refresh
        _pullUpActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _pullUpActivityView.color = self.configuration.labelTextColor;
        CGRect frame = _pullUpActivityView.frame;
        frame.origin.y =  -25;
        _pullUpActivityView.frame = frame;
        _pullUpActivityView.hidesWhenStopped = YES;
        CGPoint center =_pullUpActivityView.center;
        center.x = self.collectionView.center.x - labelSize.width / 2.0 - 15;
        _pullUpActivityView.center = center;
        //    [self.collectionView addSubview:_pullUpActivityView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.app.isLocalDevice = YES;
    [self initUI];
    [self refreshDeviceList:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isViewAppearing = YES;
    self.app.isLocalDevice = YES;
    self.agent = self.app.localAgent;
    [_emptyPromptView setHidden:(self.agent.devs.counts ? YES : NO)];
    [self destoryVideoMegine];
    [self.collectionView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _isViewAppearing = NO;
    [self.progressHUD hide:YES];
//    if(mmbc_handle)
//    {
//        mmbc_destroy(mmbc_handle);
//        mmbc_handle = NULL;
//    }
    
    [MNInfoPromptView hideAll:self.navigationController];
    [self.refreshTimer invalidate];
    
//    if (self.app.developerOption.multiScreenSwitch) {
        [self destoryVideoMegine];
//    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma markviewDidLayoutSubviews
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGPoint downRefreshLabelCenter = _downRefreshLabel.center;
    downRefreshLabelCenter.x = self.collectionView.center.x;
    _downRefreshLabel.center = downRefreshLabelCenter;
    [self.collectionView addSubview:_downRefreshLabel];
    
    //get _downRefreshLabel.text width
    NSString *downRefreshLabelText = NSLocalizedString(@"mcs_refreshing", nil);
    CGSize labelSize = CGSizeMake(100, 20);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
    {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        labelSize = [downRefreshLabelText boundingRectWithSize:CGSizeMake(0, 0)
                                                       options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                    attributes:attributes
                                                       context:nil].size;
        
        labelSize.width = ceil(labelSize.width);
    }
    if (self.app.is_vimtag) {
        [self.refreshImageView layoutFrame:self.collectionView with:labelSize];
    }
    else {
        //activity for refresh
        CGPoint center =_pullUpActivityView.center;
        center.x = self.collectionView.center.x - labelSize.width / 2.0 - 15;
        _pullUpActivityView.center = center;
        [self.collectionView addSubview:_pullUpActivityView];
    }
}

#pragma mark - Action

-(IBAction)refreshDeviceList:(id)sender
{
    _lastIndexPath = nil;
    
    if (self.app.isLocalDevice)
    {
        
        if(mmbc_handle)
        {
            mmbc_destroy(mmbc_handle);
            mmbc_handle = NULL;
        }

        NSData *usersData = [[NSUserDefaults standardUserDefaults] dataForKey:@"local_users"];
        _usersArray = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
        
        mipc_def_manager *def_manager = [mipc_def_manager shared_def_manager];
        struct mmbc_create_param    param = {0};
        param.broadcast_addr.data = "255.255.255.255";
        param.broadcast_addr.len = strlen( param.broadcast_addr.data );
        param.multicast_addr.data = "239.255.255.0";
        param.multicast_addr.len = strlen( param.multicast_addr.data );
        param.port = 3703;
        //    param.on_recv_msg = on_recv_msg;
        param.on_recv_json_msg = on_recv_json_msg;
        param.refer = (__bridge void *)(self);
        param.def_list = def_manager.new_def_list;
        param.disable_listen = 1;

        mmbc_handle = mmbc_create( &param );
        if( NULL != mmbc_handle )
        {
            struct ProbeRequest     *probe = NULL;
            char                    pbuf_data[mbmc_msg_tmp_size] = {0}; /* !!!!!!not good way. */
            struct message          *msg = (struct message*)&pbuf_data[0];
            struct mpack_buf        pbuf = {0};
            
            /* Send probe through mmbc */
            msg_set_size(msg, mbmc_msg_tmp_size);
            msg_set_version(msg, 1 == (*(short*)"\x00\x01"), msg_sizeof_header(sizeof("ProbeRequest") - 1), 0);
            msg_set_type(msg, "ProbeRequest", sizeof("ProbeRequest") - 1);
            msg_set_type_magic(msg, __ProbeRequest_type_magic);
            msg_set_from(msg, 0x1231);
            msg_set_from_handle(msg, 1);
            msg_set_to(msg, 0x20500000);/* !!!!need change  (component id)*/
            msg_set_to_handle(msg, 0);
            mpbuf_init(&pbuf, (unsigned char*)msg_get_data(msg), mbmc_msg_tmp_size - msg_sizeof_header(sizeof("ProbeRequest") - 1));
            
            probe = (struct ProbeRequest*)mpbuf_alloc(&pbuf, sizeof(struct ProbeRequest));
            
            if( probe == NULL )
            {
                NSLog(@"failed when mpbuf_alloc()");
                goto fail_label;
            }
            //        if(NULL == (probe->type.data = mpbuf_save_str(&pbuf, len_str_def_const("IPC"), NULL)))
            if(mpbuf_save_str(&pbuf, len_str_def_const(""), NULL) == NULL)
            {
                NSLog (@"failed when mpbuf_save_str()");
                goto fail_label;
            }
            
            msg_set_data_base_addr(msg, ((char*)(pbuf.index)));
            msg_save_finish(msg);
            if(mmbc_send_msg(mmbc_handle, NULL, msg))
            {
                NSLog (@"failed when mmbc_send_msg()");
                goto fail_label;
            }
            
            
        fail_label:
            if( msg )
            {
                //                mmbc_destroy(mmbc_handle);
            }
        }
    }
}

-(void)back
{
    if(mmbc_handle)
    {
        mmbc_destroy(mmbc_handle);
        mmbc_handle = NULL;
    }
    [self removeObserver];
    self.app.isLocalDevice = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)destoryVideoMegine
{
    for (int i = 0; i < self.agent.devs.counts; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        MNLANDeviceViewCell *cell = (MNLANDeviceViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell mediaEndPlay];
    }
}
#pragma mark - mmbc callback

long on_recv_json_msg( void *ref, struct len_str *msg_type, struct len_str *msg_json, struct sockaddr_in *remote_addrin )
{
    MNLocalDeviceListViewController *referSelf = (__bridge MNLocalDeviceListViewController*)ref;
    if (!referSelf.isViewAppearing) {
        return 0;
    }
    
    NSLog(@"----->%@", [NSString stringWithUTF8String:msg_type->data]);
    
    if(0 == len_str_casecmp_const(msg_type, "ProbeResponse"))
    {
        struct len_str sn = {0}, type = {0};
        m_dev *dev = [[m_dev alloc] init];
        
        NSData *msg_data = [NSData dataWithBytes:msg_json->data length:msg_json->len];
        struct json_object *data_json = MIPC_DataTransformToJson(msg_data);
        
        struct json_object *probe_json = json_get_child_by_name(data_json, NULL, len_str_def_const("ProbeMatch"));
//        json_get_child_string(data_json, "sn", &sn);
        json_get_child_string(data_json, "type", &type);
        NSLog(@"-------------------ProbeResponse----------------------------");
        
        if(probe_json
           && (probe_json->type == ejot_array)
           && probe_json->v.array.counts)
        {
            struct json_object *obj = probe_json->v.array.list;
            for (int i = 0; i < probe_json->v.array.counts; i++, obj = obj->in_parent.next)
            {
                struct len_str ip_addr = {0};
                json_get_child_string(obj, "XAddrs", &ip_addr);
                
                struct json_object *Endpoint_json = json_get_child_by_name(obj, NULL, len_str_def_const("EndpointReference"));
                json_get_child_string(Endpoint_json, "Address", &sn);
                
                dev.sn = sn.len ? [NSString stringWithUTF8String:sn.data].lowercaseString : nil;
                dev.type = type.len ? [NSString stringWithUTF8String:type.data] : nil;
                dev.ip_addr = ip_addr.len ? [NSString stringWithUTF8String:ip_addr.data] : nil;
                dev.status = @"InvalidAuth";
                if (![referSelf isContainDev:dev.sn] && dev.sn && dev.ip_addr)
                {
                    [referSelf.deviceList addObject:dev];
                    [referSelf.agent.devs add_dev:dev];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (referSelf.isScrollerViewRelease)
                        {
                            [referSelf.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
                        }
                        [referSelf destoryVideoMegine];
                        [referSelf.collectionView reloadData];
                        [referSelf.emptyPromptView setHidden:(referSelf.agent.devs.counts ? YES : NO)];
                        for (int i = 0; i < referSelf.agent.devs.counts; i ++) {
                            m_dev *dev = [referSelf.agent.devs get_dev_by_index:i];
                            if (dev.observationInfo != nil) {
                                [dev addObserver:referSelf forKeyPath:@"nick" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
                            }
                        }

                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (referSelf.isScrollerViewRelease)
                        {
                            [referSelf.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
                        }
                        [referSelf.emptyPromptView setHidden:(referSelf.agent.devs.counts ? YES : NO)];
                    });
                }
            }
        }

    }
    
    return 0;
}

#pragma mark - InterfaceOrientation
-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (!self.app.is_vimtag || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}


//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIDeviceOrientationLandscapeLeft | UIDeviceOrientationLandscapeRight | UIDeviceOrientationPortrait;
//}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//        [self updateCollectionViewFlowLayout];
    [self destoryVideoMegine];
    [self.collectionView reloadData];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    _transitionToSize = size;
    [self destoryVideoMegine];
    [self.collectionView reloadData];
}

#pragma mark - Utils
-(MNLANDeviceViewCell*)getCollectionViewCell:(NSString*)deviceID
{
    NSArray *subviews = self.collectionView.subviews;
    for (UIView *view in subviews) {
        if ([view isMemberOfClass:[MNLANDeviceViewCell class]]) {
            if ([((MNLANDeviceViewCell*)view).deviceID isEqualToString:deviceID]) {
                return (MNLANDeviceViewCell*)view;
            }
        }
    }
    
    return nil;
}

-(void)cancelNetworkRequest
{
    for (UIView *view in self.collectionView.subviews) {
        if ([view isMemberOfClass:[MNLANDeviceViewCell class]]) {
            MNLANDeviceViewCell *cell = (MNLANDeviceViewCell*)view;
            if ([cell respondsToSelector:@selector(cancelNetworkRequest)]) {
                [cell performSelector:@selector(cancelNetworkRequest)];
            }
        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSLog(@"");
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    return self.deviceList.count;
        NSLog(@"");
    return self.agent.devs.counts;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNLANDeviceViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    m_dev *dev = [self.agent.devs get_dev_by_index:indexPath.row];
    for (UserInfo *tempInfo in _usersArray) {
        if ([tempInfo.name isEqual:dev.sn]) {
            dev.status = @"Online";
            break;
        }
    }
    cell.device = dev;
    cell.status = dev.status;
    cell.deviceID = dev.sn;
    cell.nickLabel.text = dev.nick.length ? dev.nick : dev.sn;
    if (self.app.is_ebitcam || self.app.is_mipc) {
        cell.nickLabel.text = [NSString stringWithFormat:@"· %@", cell.nickLabel.text];
    }
    [cell localLoadWebImage:YES devType:dev.type deviceID:dev.sn];
//    [dev addObserver:self forKeyPath:@"nick" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [cell setNeedsLayout];
    
    cell.delegate = self;
    
    cell.playButton.selected = NO;
    cell.backgroundPlayView.hidden = YES;
    
    if ([dev.type isEqualToString:@"IPC"] && [dev.status isEqualToString:@"Online"] && [dev.status caseInsensitiveCompare:@"InvalidAuth"]) {
        cell.playButton.hidden = NO;
    } else {
        cell.playButton.hidden = YES;
    }
    
//    NSNumber *playNumber = [self.playDic objectForKey:cell.deviceID];
//    mipc_agent *agent = [self.agentDic objectForKey:cell.deviceID];
//    BOOL isPlay = [playNumber boolValue];
//    [cell resetMediaPlay:isPlay withAgent:agent];
    
//    if (!self.app.developerOption.multiScreenSwitch) {
//        cell.playButton.hidden = YES;
//        cell.backgroundPlayView.hidden = YES;
//    }
    
    return cell;
}

#pragma mark - MNLANDeviceViewCellDelagate
- (void)managerLocalAgent:(mipc_agent *)agent withDev:(m_dev *)dev;
{
    @try {
        [self.agentDic setObject:agent forKey:dev.sn];
    } @catch (NSException *exception) {
        NSLog(@"Exception:%@",exception);
    } @finally {
        
    }
}

- (void)recordVideoPlay:(m_dev *)dev with:(BOOL)isPlay;
{
    NSNumber *playNumber = [NSNumber numberWithBool:isPlay];
    [self.playDic setObject:playNumber forKey:dev.sn];
}

- (mipc_agent*)getAgentWithDev:(m_dev *)dev
{
    mipc_agent *agent = [self.agentDic objectForKey:dev.sn];
    if (agent && agent.srv.length) {
            return agent;
    }
    return nil;
}

- (void)updateCellOfflineWithDev:(m_dev *)dev
{
//    m_dev *dev = [self get_dev_by_sn:_currentDeviceID];
    dev.status = @"Offline";
    [self changeDevice:dev];
    [self.agent.devs  add_dev:dev];
    @try {
        [self.playDic removeObjectForKey:dev.sn];
    } @catch (NSException *exception) {
        NSLog(@"Exception:%@",exception);
    } @finally {
        
    }
    if (!_isViewAppearing) {
        return;
    }
    [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
}

- (void)updateCellInvalidWithDev:(m_dev *)dev
{
    dev.status = @"InvalidAuth";
    [self changeDevice:dev];
    [self.agent.devs  add_dev:dev];
    
    [self deleteUserInfoToLocal:dev.sn];
    
    if (!_isViewAppearing) {
        return;
    }
    [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_password",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
}

#pragma mark <UICollectionViewDelegate>

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
//    m_dev *dev = [_deviceList objectAtIndex:indexPath.row];
    m_dev *dev = [self.agent.devs get_dev_by_index:indexPath.row];
    _currentDeviceID = dev.sn;
    
    NSData *usersData = [[NSUserDefaults standardUserDefaults] dataForKey:@"local_users"];
    _usersArray = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
    UserInfo *userInfo = [[UserInfo alloc] init];
    for (UserInfo *tempInfo in _usersArray) {
        if ([tempInfo.name isEqual:_currentDeviceID]) {
            userInfo = tempInfo;
            if(userInfo.name && userInfo.password)
            {
//                [mipc_agent passwd_encrypt:userInfo.password encrypt_pwd:_encrypt_pwd];
                _currentDevicePassword = @"*******";
                const char *pass_md5 = [userInfo.password bytes];
                
                mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
                ctx.srv = MIPC_SrvFix(dev.ip_addr);
                ctx.user = _currentDeviceID;
                ctx.passwd = pass_md5;
                ctx.target = self;
                ctx.ref = dev;
                ctx.on_event = @selector(sign_in_done:);
                
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSString *token = [user objectForKey:@"mipci_token"];
                
                if(token && token.length)
                {
                    ctx.token = token;
                }
                
                [self.agent local_sign_in:ctx switchMmq:YES];
                [self.progressHUD show:YES];
                return;
            }
        }
    }
    
    if (NSOrderedSame == [dev.status caseInsensitiveCompare:@"InvalidAuth"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_input_password",nil)
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"mcs_cancel",nil)
                                                  otherButtonTitles:NSLocalizedString(@"mcs_apply",nil), nil];
        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        alertView.tag = CHANGEPASSWORD_TAG;
        [alertView show];
        
        UITextField *userTextField = [alertView textFieldAtIndex:0];
        userTextField.enabled = NO;
        userTextField.text = dev.sn;
        UITextField *passTextField = [alertView textFieldAtIndex:1];
        passTextField.secureTextEntry = YES;
        passTextField.placeholder = NSLocalizedString(@"mcs_input_password",nil);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        NSInteger screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        if (self.app.is_luxcam) {
            int lineCounts = DEFAULT_LINE_COUNTS + 1;
            NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
            itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
        }
        else if (self.app.is_vimtag)
        {
            int lineCounts = DEFAULT_LINE_COUNTS + 1;
            NSInteger cellWidth = (screenWidth - 6 * 2 - (lineCounts - 1) * 6) / lineCounts;
            itemSize = CGSizeMake(cellWidth, cellWidth * 3 / 5 + 16);
        }
        else if (self.app.is_ebitcam || self.app.is_mipc)
        {
            int lineCounts = DEFAULT_LINE_COUNTS + 1;
            NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * 6) / lineCounts;
            itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
        }
        else
        {
            int lineCounts = DEFAULT_LINE_COUNTS + 1;
            NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
            itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16);
        }
    }
    else
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)
        {
            //            float height = CGRectGetHeight(self.view.bounds);
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? width : height;
//                NSInteger screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        
            //              NSInteger screenWidth = [UIDevice currentDevice].systemVersion.floatValue < 8.0 ? CGRectGetWidth(self.view.bounds) : self.transitionToSize.width;
            if (self.app.is_luxcam) {
                
                int lineCounts = DEFAULT_LINE_COUNTS + 1;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
            else if (self.app.is_vimtag) {
                int lineCounts = DEFAULT_LINE_COUNTS + 1;
                CGFloat cellWidth = (screenWidth - 6 * 2 - (lineCounts - 1) * 6) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 3 / 5 + 16);
            }
            else if (self.app.is_ebitcam || self.app.is_mipc)
            {
                int lineCounts = DEFAULT_LINE_COUNTS + 1;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * 6) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
            else
            {
                int lineCounts = DEFAULT_LINE_COUNTS + 1;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16);
            }
        }
        else
        {
            //            float height = CGRectGetHeight(self.view.bounds);
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? height : width;
            //             NSInteger screenWidth = [UIDevice currentDevice].systemVersion.floatValue < 8.0 ? CGRectGetWidth(self.view.bounds) : self.transitionToSize.width;
            if (self.app.is_luxcam) {
                int lineCounts = DEFAULT_LINE_COUNTS;
                CGFloat cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
            else if (self.app.is_vimtag)
            {
                int lineCounts = DEFAULT_LINE_COUNTS;
                CGFloat cellWidth = (screenWidth - 6 * 2 - (lineCounts - 1) * 6) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 3 / 5 + 16);
            }
            else if (self.app.is_ebitcam || self.app.is_mipc)
            {
                int lineCounts = DEFAULT_LINE_COUNTS;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * 6) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
            else
            {
                int lineCounts = DEFAULT_LINE_COUNTS;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16);
            }
        }
        
    }
    return itemSize;
}

#pragma mark - sign_in_done
- (void)sign_in_done:(mcall_ret_sign_in*)ret
{
    if (!_isViewAppearing || !self.app.isLocalDevice)
    {
        return;
    }
    if (nil == ret.result) {
        m_dev *dev = [self get_dev_by_sn:_currentDeviceID];
        MNLANDeviceViewCell *cell = [self getCollectionViewCell:_currentDeviceID];
        cell.status = @"Online";
        dev.status = @"Online";
        [self changeDevice:dev];
        [self.agent.devs  add_dev:dev];
        
//        if (self.currentDevicePassword.length > 0 && self.currentDevicePassword.length < 6)
//        {
//            [self.progressHUD hide:YES];
//
//            UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
//            MNModifyPasswordViewController *modifyPasswordViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNModifyPasswordViewController"];
//            MNGuideNavigationController *guideNavigationController = [[MNGuideNavigationController alloc] initWithRootViewController:modifyPasswordViewController];
//            modifyPasswordViewController.deviceID = _currentDeviceID;
//            modifyPasswordViewController.oldPassword = _currentDevicePassword;
//            modifyPasswordViewController.localDeviceIP = dev.ip_addr;
//            modifyPasswordViewController.is_notAdd = YES;
//            [self presentViewController:guideNavigationController animated:YES completion:nil];
//        }
//        else
        {
            mcall_ctx_dev_info_get *ctx = [[mcall_ctx_dev_info_get alloc] init];
            ctx.sn = _currentDeviceID;
            ctx.target = self;
            ctx.ref = _currentDeviceID;
            ctx.on_event = @selector(dev_info_get_done:);
            
            [self.agent dev_info_get:ctx];
        }
        
    }
    else if([ret.result isEqualToString:@"ret.pwd.invalid"]){
        [self.progressHUD hide:YES];
        m_dev *dev = [self get_dev_by_sn:_currentDeviceID];
        MNLANDeviceViewCell *cell = [self getCollectionViewCell:_currentDeviceID];
        cell.status = @"InvalidAuth";
        dev.status = @"InvalidAuth";
        [self changeDevice:dev];
        [self.agent.devs  add_dev:dev];
        
        [self deleteUserInfoToLocal:_currentDeviceID];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_input_password",nil)
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"mcs_cancel",nil)
                                                  otherButtonTitles:NSLocalizedString(@"mcs_apply",nil), nil];
        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        alertView.tag = CHANGEPASSWORD_TAG;
        [alertView show];
        
        UITextField *userTextField = [alertView textFieldAtIndex:0];
        userTextField.enabled = NO;
        userTextField.text = _currentDeviceID;
        UITextField *passTextField = [alertView textFieldAtIndex:1];
        passTextField.secureTextEntry = YES;
        passTextField.placeholder = NSLocalizedString(@"mcs_input_password",nil);
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_password",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else
    {
        [self.progressHUD hide:YES];
        m_dev *dev = [self get_dev_by_sn:_currentDeviceID];
        MNLANDeviceViewCell *cell = [self getCollectionViewCell:dev.sn];
        cell.status = @"Offline";
        cell.playButton.hidden = YES;
        dev.status = @"Offline";
        [self changeDevice:dev];
        [self.agent.devs  add_dev:dev];
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}

#pragma mark - dev_info_get_done
- (void)dev_info_get_done:(mcall_ret_dev_info_get *)ret
{
    
    if (!_isViewAppearing || !self.app.isLocalDevice)
    {
        return;
    }
    
    if (nil == ret.result)
    {

        MNLANDeviceViewCell *cell = [self getCollectionViewCell:(NSString *)ret.ref];
        m_dev *dev = [self get_dev_by_sn:(NSString *)ret.ref];
        if ([ret.type  isEqualToString: @"BOX"]) {
            if (self.app.is_vimtag) {
                cell.backgroundImageView.image = [UIImage imageNamed:@"vt_box_placeholder.png"];
            } else {
                cell.backgroundImageView.image = [UIImage imageNamed:@"box_placeholder.png"];
            }
            cell.status = @"Online";
            dev.type = @"BOX";
            
            [cell localLoadWebImage:NO devType:ret.type deviceID:ret.sn];
            
        }
        else if([ret.type  isEqualToString: @"IPC"]) {
            cell.status = @"Online";
            
            [cell localLoadWebImage:NO devType:ret.type deviceID:ret.sn];
//            cell.playButton.hidden = NO;
//            cell.backgroundPlayView.hidden = !cell.playButton.selected;
//            m_dev *dev = [self.agent.devs get_dev_by_sn:(NSString *)ret.ref];
            dev.type = @"IPC";
        }
        dev.status = @"Online";
        dev.nick = ret.nick;
        dev.spv = ret.spv;
        dev.img_ver = ret.img_ver;
        dev.wifi_status = ret.wifi_status;
        dev.p0 = ret.p0;
        dev.support_scene = ret.support_scene;
        dev.add_accessory = ret.add_accessory;
        dev.timeZone = ret.timezone;
        dev.ratio = ret.ratio;
        dev.del_ipc = ret.del_ipc;
        [self changeDevice:dev];
        [self.agent.devs  add_dev:dev];
        
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(0.1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           [weakSelf.progressHUD hide:YES];
                           if (dev && dev.sn && self.app.isLocalDevice) {
                               if (NSOrderedSame == [dev.type caseInsensitiveCompare:@"IPC"])
                               {
                                   if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
                                       [self performSegueWithIdentifier:@"MNDevicePlayViewController" sender:dev.sn];
                                   }
                                   else
                                   {
                                       [self performSegueWithIdentifier:@"MNDeviceTabBarController" sender:[NSNumber numberWithInt:0]];
                                   }
                               }
                               else
                               {
                                   //coding for segment records
                                   if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
                                       [self performSegueWithIdentifier:@"MNBoxListViewController" sender:dev.sn];
                                   } else {
                                       [self performSegueWithIdentifier:@"MNBoxTabBarController" sender:[NSNumber numberWithInt:0]];
                                   }
                                   
                               }
                           }
                           
                       });
       
        
    }
}

#pragma mark - alertView Delegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CHANGEPASSWORD_TAG)
    {
        if (buttonIndex != alertView.cancelButtonIndex) {
            UITextField *userTextField = [alertView textFieldAtIndex:0];
            UITextField *pwdTextField = [alertView textFieldAtIndex:1];
            
            _currentDeviceID = userTextField.text;
            _currentDevicePassword = pwdTextField.text;
            
            if(pwdTextField.text.length)
            {
                if(pwdTextField.text && pwdTextField.text.length)
                {
                    [mipc_agent passwd_encrypt:pwdTextField.text encrypt_pwd:_encrypt_pwd];
                    
                }
                
                m_dev *dev = [self.agent.devs get_dev_by_sn:userTextField.text];
                
                UserInfo *userInfo = [[UserInfo alloc] init];
                userInfo.name = dev.sn;
                //                userInfo.password = pwdTextField.text;
                
                char *pass_md5 = _encrypt_pwd;
                NSData *data = [NSData dataWithBytes:pass_md5   length:16];
                userInfo.password = data;
                [self saveUserInfoToLocal:userInfo];
                
                
                mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
                ctx.srv = MIPC_SrvFix(dev.ip_addr);
                ctx.user = dev.sn;
                ctx.passwd = _encrypt_pwd;
                ctx.target = self;
                ctx.ref = userInfo;
                ctx.on_event = @selector(sign_in_done:);
                
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSString *token = [user objectForKey:@"mipci_token"];
                
                if(token && token.length)
                {
                    ctx.token = token;
                }
                
                [self.agent local_sign_in:ctx switchMmq:YES];
                [self.progressHUD show:YES];
            }
        }
        else if (buttonIndex == alertView.cancelButtonIndex)
        {
        }
    }
}

#pragma mark - ScrollView delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -20 && !_isScrollerViewRelease ) {
        _downRefreshLabel.hidden = NO;
        _downRefreshLabel.text = NSLocalizedString(@"mcs_down_refresh", nil);
        self.refreshImageView.hidden = YES;
    }
    if (scrollView.contentOffset.y  < -50 && !_isScrollerViewRelease){
        _downRefreshLabel.hidden = NO;
        _downRefreshLabel.text = NSLocalizedString(@"mcs_release_refresh", nil);
        self.refreshImageView.hidden = YES;
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -50) {
        _downRefreshLabel.text = NSLocalizedString(@"mcs_refreshing", nil);
        if (self.app.is_vimtag) {
            [self.refreshTimer invalidate];
            self.refreshImageView.hidden = NO;
            self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self.refreshImageView selector:@selector(start) userInfo:nil repeats:YES];
        }
        else {
            [_pullUpActivityView startAnimating];
        }
        _isScrollerViewRelease = YES;
        [scrollView setContentOffset:CGPointMake(0, -40) animated:YES];
        [self performSelector:@selector(refreshDeviceList:) withObject:nil afterDelay:1.0f];
        [self destoryVideoMegine];
        [self.collectionView reloadData];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == 0) {
        _isScrollerViewRelease = NO;
        if (self.app.is_vimtag) {
            [self.refreshTimer invalidate];
        }
        else {
            [_pullUpActivityView stopAnimating];
        }
    }
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    m_dev *dev = [self.agent.devs get_dev_by_sn:_currentDeviceID];
    long counts = dev.msg_id_max - dev.read_id;
    MNLANDeviceViewCell *currentCell = [self getCollectionViewCell:_currentDeviceID];
    currentCell.alarmCounts = counts <= 0 ? 0 : counts;
    currentCell.nickLabel.text = dev.nick.length ? dev.nick : dev.sn;
    [currentCell setNeedsDisplay];
}

#pragma mark - remove Observer
- (void)removeObserver
{
    for (int i = 0; i < self.agent.devs.counts; i ++) {
        m_dev *dev = [self.agent.devs get_dev_by_index:i];
        if (dev.observationInfo) {
            [dev removeObserver:self forKeyPath:@"nick"];
        }
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNDeviceTabBarController"])
    {
        MNDeviceTabBarController *deviceTabBarController = segue.destinationViewController;
        deviceTabBarController.deviceID = _currentDeviceID;
//        deviceTabBarController.deviceListViewController = self;
        deviceTabBarController.selectedIndex = [sender integerValue];
    }
    else if ([segue.identifier isEqualToString:@"MNDevicePlayViewController"])
    {
        MNDevicePlayViewController *devicePlayViewController = segue.destinationViewController;
        devicePlayViewController.deviceID = sender;
    }
    else if ([segue.identifier isEqualToString:@"MNBoxListViewController"])
    {
        MNBoxListViewController *boxListViewController = segue.destinationViewController;
        boxListViewController.boxID = sender;
    }
    else if ([segue.identifier isEqualToString:@"MNBoxTabBarController"])
    {
        MNBoxTabBarController *boxTabBarController = segue.destinationViewController;
        boxTabBarController.boxID = _currentDeviceID;
        boxTabBarController.selectedIndex = [sender integerValue];
    }
    else if ([segue.identifier isEqualToString:@"MNSettingsDeviceViewController"])
    {
        MNSettingsDeviceViewController *settingsDeviceViewController = segue.destinationViewController;
        settingsDeviceViewController.deviceID = _currentDeviceID;
//        settingsDeviceViewController.deviceListViewController = self;
    }
    else if ([segue.identifier isEqualToString:@"MNMessagePageViewController"])
    {
        MNMessagePageViewController *messagePageViewController = segue.destinationViewController;
        messagePageViewController.deviceID = _currentDeviceID;
    }
    else if ([segue.identifier isEqualToString:@"MNQRCodeViewController"])
    {
//        MNQRCodeViewController *qrCodeViewController = segue.destinationViewController;
    }
    else if ([segue.identifier isEqualToString:@"MNModifyPasswordViewController"])
    {
        MNModifyPasswordViewController *modifyPasswordviewController = segue.destinationViewController;
        modifyPasswordviewController.deviceID = _currentDeviceID;
        modifyPasswordviewController.oldPassword = _currentDevicePassword;
        modifyPasswordviewController.is_notAdd = YES;
    }
}

#pragma mark - Utils
- (void)saveUserInfoToLocal:(UserInfo *)userInfo
{
    NSData *usersData = [[NSUserDefaults standardUserDefaults] dataForKey:@"local_users"];
    
    NSMutableArray *usersArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:usersData]];
    
    if (userInfo.name && userInfo.password)
    {
        if (![usersArray containsObject:userInfo])
        {
            [usersArray insertObject:userInfo atIndex:0];
        }
        else
        {
            for (int i =0; i<usersArray.count; i++) {
                UserInfo *tempInfo = [usersArray objectAtIndex:i];
//                if ([tempInfo.name isEqualToString:userInfo.name] && ![[NSString stringWithUTF8String:tempInfo.password] isEqualToString:[NSString stringWithUTF8String:userInfo.password]])
                if ([tempInfo.name isEqualToString:userInfo.name])
                {
                    [usersArray replaceObjectAtIndex:i withObject:userInfo];
                }
            }
        }
        NSData *usersData = [NSKeyedArchiver archivedDataWithRootObject:usersArray];
        
        [[NSUserDefaults standardUserDefaults] setObject:usersData forKey:@"local_users"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)deleteUserInfoToLocal:(NSString *)deviceID
{
    NSData *usersData = [[NSUserDefaults standardUserDefaults] dataForKey:@"local_users"];
    
    NSMutableArray *usersArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:usersData]];
    
    if (deviceID.length)
    {
        int index = 0;
        for (index = 0; index<usersArray.count; index++) {
            UserInfo *tempInfo = [usersArray objectAtIndex:index];
            if ([tempInfo.name isEqualToString:deviceID])
            {
                [usersArray removeObjectAtIndex:index];
                break;
            }
        }
        NSData *usersData = [NSKeyedArchiver archivedDataWithRootObject:usersArray];
        
        [[NSUserDefaults standardUserDefaults] setObject:usersData forKey:@"local_users"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)isContainDev:(NSString *)name
{
    for (m_dev *dev in _deviceList) {
        if ([dev.sn isEqualToString:name]) {
            return YES;
        }
    }
    return NO;
}

- (m_dev *)get_dev_by_sn:(NSString *)sn
{
    for (m_dev *dev in _deviceList) {
        if ([dev.sn isEqualToString:sn]) {
            return dev;
        }
    }
    return nil;
}

- (void)changeDevice:(m_dev *)dev
{
    for (int i =0; i < _deviceList.count; i++) {
        m_dev *tempDev = (m_dev *)[_deviceList objectAtIndex:i];
        if ([tempDev.sn isEqualToString:dev.sn]) {
            [_deviceList replaceObjectAtIndex:i withObject:dev];
        }
    }
}

#pragma mark - Notification
- (void)resignActiveNotification:(NSNotification *)notification
{
    [self destoryVideoMegine];
}

- (void)becomeActiveNotification:(NSNotification *)notification
{
    [self.collectionView reloadData];
}
@end
