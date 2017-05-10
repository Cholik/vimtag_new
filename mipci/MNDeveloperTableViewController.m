//
//  MNDeveloperTableViewController.m
//  test
//
//  Created by mining on 16/5/25.
//  Copyright © 2016年 LiuCheng. All rights reserved.
//

#import "MNDeveloperTableViewController.h"
#import "MNDeveloperOption.h"
#import "MNShareVideoWindow.h"
#import "AppDelegate.h"
#import "MNInfoPromptView.h"

#import "MIPCUtils.h"
#import "msg_http.h"
#import "http_param.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

#define GET_ADDR_INFOS  1001
#define GET_IF_ADDR     1002

typedef NS_ENUM(NSInteger, MNTableViewCellType) {
    MNCellTextField,
    MNCellTextSwitch
};

@interface MNTableViewCell : UITableViewCell

@property (assign, nonatomic) MNTableViewCellType type;
@property (strong, nonatomic) UITextField *cellTextField;
@property (strong, nonatomic) UISwitch *cellSwitch;

- (instancetype)initWithType:(MNTableViewCellType)cellType;

@end

@implementation MNTableViewCell

- (instancetype)initWithType:(MNTableViewCellType)cellType
{
    self = [super init];
    
    if (self) {
        _type = cellType;
        
        if (MNCellTextField == cellType) {
            _cellTextField = [[UITextField alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 130, 3, 125, 34)];
            _cellTextField.background = [UIImage imageNamed:@"vt_btn_outline"];
            _cellTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            _cellTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            
            [self.contentView addSubview:_cellTextField];
        } else {
            _cellSwitch = [[UISwitch alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 60, 5, 0, 0)];
            [self.contentView addSubview:_cellSwitch];
        }
    }
    
    return self;
}

@end


@interface MNDeveloperTableViewController ()<UITextFieldDelegate>
{
    struct mhttp_module *module_handle;
}

@property (strong, nonatomic) NSMutableArray *relatedArray;
@property (strong, nonatomic) NSArray        *optionArray;
@property (weak, nonatomic) AppDelegate *app;
@property (weak, nonatomic) MNDeveloperOption *developerOption;
@property (strong, nonatomic) MNShareVideoWindow *shareVideoWindow;

@property (strong, nonatomic) MNTableViewCell *playAgreement;
@property (strong, nonatomic) MNTableViewCell *portalServer;
@property (strong, nonatomic) MNTableViewCell *signalServer;
@property (strong, nonatomic) MNTableViewCell *sceneSwitch;
@property (strong, nonatomic) MNTableViewCell *ipcSwitch;
@property (strong, nonatomic) MNTableViewCell *QRSwitch;
@property (strong, nonatomic) MNTableViewCell *soundsSwitch;
@property (strong, nonatomic) MNTableViewCell *normalSwitch;
@property (strong, nonatomic) MNTableViewCell *webSwitch;
@property (strong, nonatomic) MNTableViewCell *webMobileOriginSwitch;
@property (strong, nonatomic) MNTableViewCell *nativeSwitch;
@property (strong, nonatomic) MNTableViewCell *printLogSwitch;
@property (strong, nonatomic) MNTableViewCell *soundFreqhigh;
@property (strong, nonatomic) MNTableViewCell *soundFreqlow;
@property (strong, nonatomic) MNTableViewCell *transMode;
@property (strong, nonatomic) MNTableViewCell *wifiSpeed;
@property (strong, nonatomic) MNTableViewCell *magicLoopSegs;
@property (strong, nonatomic) MNTableViewCell *startMagicCounts;
@property (strong, nonatomic) MNTableViewCell *homeUrl;
@property (strong, nonatomic) MNTableViewCell *multiScreenSwitch;
@property (strong, nonatomic) MNTableViewCell *saveLogSwitch;
@property (strong, nonatomic) MNTableViewCell *automationSwitch;

@property (strong, nonatomic) MNTableViewCell *environmentSwitch;
@property (strong, nonatomic) MNTableViewCell *printfVaule;
@property (strong, nonatomic) MNTableViewCell *printfLevel;

@property (strong, nonatomic) MNTableViewCell *getaddrinfoSwitch;
@property (strong, nonatomic) MNTableViewCell *getifaddrSwitch;
@property (strong, nonatomic) MNTableViewCell *getaddrinfo_ip;
@property (strong, nonatomic) MNTableViewCell *getaddrinfo_port;
@property (strong, nonatomic) MNTableViewCell *getaddrinfo_ai_flag;
@property (strong, nonatomic) MNTableViewCell *getaddrinfo_ai_family;
@property (strong, nonatomic) MNTableViewCell *getaddrinfo_ai_sock;
@property (strong, nonatomic) MNTableViewCell *getaddrinfo_ai_proto;

@property (strong, nonatomic) NSTimer *mhttp_timer;
@property (strong, nonatomic) NSString *http_conf_path;
@property (strong, nonatomic) NSString *ipAddress;
@property (strong, nonatomic) NSThread *mhttp_wait_thread;
@property (strong ,nonatomic) NSString *url;

@property (strong, nonatomic) UIView *shareListView;
@property (strong, nonatomic) NSString *shareFileName;

@property (strong, nonatomic) UIView *infoView;
@property (strong, nonatomic) UITextView *infoTextView;

@end

@implementation MNDeveloperTableViewController

- (MNDeveloperOption *)developerOption
{
    if (!_developerOption) {
        _developerOption = [MNDeveloperOption shared_developerOption];
    }
    return _developerOption;
}

- (NSArray *)optionArray
{
    //------ Modify flag ------
    if (!_optionArray) {
        _optionArray = @[@"print log", @"save log", @"automation", @"entra server address", @"singal server address", @"play protocol", @"environment switch", @"printf vaule", @"printf level", @"getaddrinfoSwitch", @"getaddrinfo_ip", @"getaddrinfo_port", @"getaddrinfo_ai_flag", @"getaddrinfo_ai_family", @"getaddrinfo_ai_sock", @"getaddrinfo_ai_proto", @"getifaddrSwitch", @"WiFi normal config", @"WiFi QR config", @"WiFi sound config", @"sound freqhigh", @"sound freqlow", @"trans mode", @"wifi speed", @"magic loop segs", @"start magic counts", @"open scene", @"open exdevice", @"web mode", @"web mobile origin", @"native mode", @"home url", @"multi screen", @"Clear option cache"];
    }
    return _optionArray;
}

-(NSThread *)mhttp_wait_thread
{
    if (nil == _mhttp_wait_thread) {
        _mhttp_wait_thread = [[NSThread alloc] initWithTarget:self selector:@selector(run_mhttp_wait) object:nil];
    }
    
    return _mhttp_wait_thread;
}

#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title = @"Developer Option";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(clickBack)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    
    //------ Modify flag ------
    _playAgreement = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _portalServer = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _signalServer = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _soundFreqhigh = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _soundFreqlow = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _transMode = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _wifiSpeed = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _magicLoopSegs = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _startMagicCounts = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _homeUrl = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _environmentSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _printfVaule = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _printfLevel = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    
    _sceneSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _ipcSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _QRSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _soundsSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _normalSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _webSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _webMobileOriginSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _nativeSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _printLogSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _multiScreenSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _saveLogSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _automationSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    
    _getaddrinfoSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _getifaddrSwitch = [[MNTableViewCell alloc] initWithType:MNCellTextSwitch];
    _getaddrinfoSwitch.tag = GET_ADDR_INFOS;
    _getifaddrSwitch.tag = GET_IF_ADDR;
    _getaddrinfo_ip = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _getaddrinfo_port = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _getaddrinfo_ai_flag = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _getaddrinfo_ai_family = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _getaddrinfo_ai_sock = [[MNTableViewCell alloc] initWithType:MNCellTextField];
    _getaddrinfo_ai_proto = [[MNTableViewCell alloc] initWithType:MNCellTextField];

    [self initDeveloerpOption];
    
    //------ Modify flag ------
    self.relatedArray = [NSMutableArray arrayWithArray:@[_printLogSwitch, _saveLogSwitch, _automationSwitch, _portalServer, _signalServer, _playAgreement, _environmentSwitch, _printfVaule, _printfLevel, _getaddrinfoSwitch, _getaddrinfo_ip, _getaddrinfo_port, _getaddrinfo_ai_flag, _getaddrinfo_ai_family, _getaddrinfo_ai_sock, _getaddrinfo_ai_proto, _getifaddrSwitch, _normalSwitch, _QRSwitch, _soundsSwitch, _soundFreqhigh, _soundFreqlow, _transMode, _wifiSpeed, _magicLoopSegs, _startMagicCounts, _sceneSwitch, _ipcSwitch, _webSwitch, _webMobileOriginSwitch, _nativeSwitch, _homeUrl, _multiScreenSwitch]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self destroyHandle];
}

#pragma mark - Action
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

- (void)initDeveloerpOption
{
    //------ Modify flag ------
    _portalServer.cellTextField.text = self.developerOption.portalServer;
    _signalServer.cellTextField.text = self.developerOption.signalServer;
    _playAgreement.cellTextField.text = self.developerOption.playAgreement;
    _soundFreqhigh.cellTextField.text = [NSString stringWithFormat:@"%ld", self.developerOption.freqhigh];
    _soundFreqlow.cellTextField.text = [NSString stringWithFormat:@"%ld", self.developerOption.freqlow];
    _transMode.cellTextField.text = [NSString stringWithFormat:@"%ld", self.developerOption.trans_mode];
    _wifiSpeed.cellTextField.text = [NSString stringWithFormat:@"%ld", self.developerOption.wifiSpeed];
    _magicLoopSegs.cellTextField.text = [NSString stringWithFormat:@"%ld", self.developerOption.magic_loop_segs];
    _startMagicCounts.cellTextField.text = [NSString stringWithFormat:@"%ld", self.developerOption.start_magic_counts];
    _homeUrl.cellTextField.text = self.developerOption.homeUrl;
    _environmentSwitch.cellSwitch.on = self.developerOption.environmentSwitch;
    _printfVaule.cellTextField.text = self.developerOption.printfVaule;
    _printfLevel.cellTextField.text = [NSString stringWithFormat:@"%ld", self.developerOption.printfLevel];
    
    _printLogSwitch.cellSwitch.on = self.developerOption.printLogSwitch;
    _normalSwitch.cellSwitch.on = self.developerOption.normalSwitch;
    _QRSwitch.cellSwitch.on = self.developerOption.QRSwitch;
    _soundsSwitch.cellSwitch.on = self.developerOption.soundsSwitch;
    _sceneSwitch.cellSwitch.on = self.developerOption.sceneSwitch;
    _ipcSwitch.cellSwitch.on = self.developerOption.ipcSwitch;
    _webSwitch.cellSwitch.on = self.developerOption.webSwitch;
    _webMobileOriginSwitch.cellSwitch.on = self.developerOption.webMobileOriginSwitch;
    _nativeSwitch.cellSwitch.on = self.developerOption.nativeSwitch;
    _multiScreenSwitch.cellSwitch.on = self.developerOption.multiScreenSwitch;
    _saveLogSwitch.cellSwitch.on = self.developerOption.saveLogSwitch;
    _automationSwitch.cellSwitch.on =  self.developerOption.automationSwitch;
    
    _getaddrinfoSwitch.cellSwitch.on =  self.developerOption.getaddrinfoSwitch;
    _getifaddrSwitch.cellSwitch.on =  self.developerOption.getifaddrSwitch;
    _getaddrinfo_ip.cellTextField.text = self.developerOption.getaddrinfo_ip;
    _getaddrinfo_port.cellTextField.text = self.developerOption.getaddrinfo_port;

    _getaddrinfo_ai_flag.cellTextField.text = [NSString stringWithFormat:@"%ld", self.developerOption.getaddrinfo_ai_flag];
    _getaddrinfo_ai_family.cellTextField.text = [NSString stringWithFormat:@"%ld", self.developerOption.getaddrinfo_ai_family];
    _getaddrinfo_ai_sock.cellTextField.text = [NSString stringWithFormat:@"%ld", self.developerOption.getaddrinfo_ai_sock];
    _getaddrinfo_ai_proto.cellTextField.text = [NSString stringWithFormat:@"%ld", self.developerOption.getaddrinfo_ai_proto];
}

- (void)clickBack
{
    //------ Modify flag ------
    self.developerOption.playAgreement = self.playAgreement.cellTextField.text;
    self.developerOption.portalServer = self.portalServer.cellTextField.text;
    self.developerOption.signalServer = self.signalServer.cellTextField.text;
    self.developerOption.freqhigh      = self.soundFreqhigh.cellTextField.text.longLongValue;
    self.developerOption.freqlow      = self.soundFreqlow.cellTextField.text.longLongValue;
    self.developerOption.trans_mode    = self.transMode.cellTextField.text.longLongValue;
    self.developerOption.wifiSpeed      = self.wifiSpeed.cellTextField.text.longLongValue;
    self.developerOption.magic_loop_segs = self.magicLoopSegs.cellTextField.text.longLongValue;
    self.developerOption.start_magic_counts = self.startMagicCounts.cellTextField.text.longLongValue;
    self.developerOption.environmentSwitch = self.environmentSwitch.cellSwitch.on;
    self.developerOption.printfVaule = self.printfVaule.cellTextField.text;
    self.developerOption.printfLevel = self.printfLevel.cellTextField.text.longLongValue;
    
    self.developerOption.sceneSwitch = self.sceneSwitch.cellSwitch.on;
    self.developerOption.ipcSwitch = self.ipcSwitch.cellSwitch.on;
    self.developerOption.QRSwitch = self.QRSwitch.cellSwitch.on;
    self.developerOption.soundsSwitch = self.soundsSwitch.cellSwitch.on;
    self.developerOption.normalSwitch = self.normalSwitch.cellSwitch.on;
    self.developerOption.webSwitch = self.webSwitch.cellSwitch.on;
    self.developerOption.webMobileOriginSwitch = self.webMobileOriginSwitch.cellSwitch.on;
    self.developerOption.nativeSwitch = self.nativeSwitch.cellSwitch.on;
    self.developerOption.homeUrl = self.homeUrl.cellTextField.text;
    self.developerOption.multiScreenSwitch = self.multiScreenSwitch.cellSwitch.on;
    
    self.developerOption.printLogSwitch = self.printLogSwitch.cellSwitch.on;
    self.developerOption.saveLogSwitch = self.saveLogSwitch.cellSwitch.on;
    self.developerOption.automationSwitch = self.automationSwitch.cellSwitch.on;
    
    self.developerOption.getaddrinfoSwitch = self.getaddrinfoSwitch.cellSwitch.on;
    self.developerOption.getifaddrSwitch = self.getifaddrSwitch.cellSwitch.on;
    self.developerOption.getaddrinfo_ip = self.getaddrinfo_ip.cellTextField.text;
    self.developerOption.getaddrinfo_port = self.getaddrinfo_port.cellTextField.text;
    self.developerOption.getaddrinfo_ai_flag    = self.getaddrinfo_ai_flag.cellTextField.text.longLongValue;
    self.developerOption.getaddrinfo_ai_family    = self.getaddrinfo_ai_family.cellTextField.text.longLongValue;
    self.developerOption.getaddrinfo_ai_sock    = self.getaddrinfo_ai_sock.cellTextField.text.longLongValue;
    self.developerOption.getaddrinfo_ai_proto    = self.getaddrinfo_ai_proto.cellTextField.text.longLongValue;
    
    [self.developerOption saveDeveloperOption];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeInfoView
{
    _infoView.hidden = YES;
}

- (void)share
{
    NSString *networkRequestDerectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"NetworkRequest"];
    BOOL isDirectory;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:networkRequestDerectory isDirectory:&isDirectory];
    if (!isFileExist || !isDirectory)
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"No network request file", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        return;
    }
    
    NSArray *logInfos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:networkRequestDerectory error:nil];
    
    if (_shareListView) {
        _shareListView.hidden = NO;
    } else {
        _shareListView = [[UIView alloc] initWithFrame:self.view.frame];
        _shareListView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_shareListView];
        int index = 0;
        for (NSString *logInfo in logInfos)
        {
            if ([logInfo rangeOfString:@".txt"].length)
            {
                index ++;
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 40*(index-1), CGRectGetWidth(_shareListView.frame), 30)];
                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [button setTitle:logInfo forState:UIControlStateNormal];
                [button addTarget:self action:@selector(shareLog:) forControlEvents:UIControlEventTouchUpInside];
                [_shareListView addSubview:button];
            }
        }
    }
}

- (void)shareLog:(id)sender
{
    UIButton *button = (UIButton *)sender;
    //    NSLog(@"%@", button.titleLabel.text);
    _shareFileName = button.titleLabel.text;
    _shareListView.hidden = YES;
    
    BOOL successFlag = [self pendingLocalServer];
    if (successFlag) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        if (_shareVideoWindow) {
            _shareVideoWindow.hidden = NO;
        } else {
            _shareVideoWindow = [[MNShareVideoWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            
            __weak typeof(self) weakSelf = self;
            [_shareVideoWindow closeWindowWithBlock:^{
                [weakSelf.mhttp_wait_thread cancel];
                [UIApplication sharedApplication].idleTimerDisabled = NO;
            }];
        }
    } else {
        NSLog(@"share fail");
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"Share fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.optionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // NSArray *dataArray = [self.relatedArray objectAtIndex:section];
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if (indexPath.section < self.relatedArray.count) {
        cell = self.relatedArray[indexPath.section];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:20.0];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    cell.textLabel.text = self.optionArray[indexPath.section];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (indexPath.section == self.optionArray.count - 1) {
        [self.developerOption clearDeveloperOption];
        
        [self initDeveloerpOption];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *tmp_log = MIPC_GetFileFullPath(@"NetworkRequest");
        BOOL isDirectory;
        BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:tmp_log isDirectory:&isDirectory];
        if (isFileExist || isDirectory)
        {
            NSError *logError = nil;
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@",tmp_log] error:&logError];
            if (logError) {
                NSLog(@"download_url:timeout:%@", [logError localizedDescription]);
            }
        }
        
        [self.tableView reloadData];
    }
    
    if (cell.tag == GET_ADDR_INFOS) {
        if (_getaddrinfoSwitch.cellSwitch.on) {
            NSString *ipString = [NSString stringWithFormat:@"%@", _getaddrinfo_ip.cellTextField.text];
            NSString *portString = [NSString stringWithFormat:@"%@", _getaddrinfo_port.cellTextField.text];
            long ai_flag= self.getaddrinfo_ai_flag.cellTextField.text.longLongValue;
            long ai_famil= self.getaddrinfo_ai_family.cellTextField.text.longLongValue;
            long ai_sock= self.getaddrinfo_ai_sock.cellTextField.text.longLongValue;
            long ai_proto= self.getaddrinfo_ai_proto.cellTextField.text.longLongValue;
            
            char *info = netx_get_addrinfo((ipString.length ? ((char*)ipString.UTF8String) : NULL), (portString.length ? ((char*)portString.UTF8String) : NULL), (int)ai_flag, (int)ai_famil, (int)ai_sock, (int)ai_proto);
            
            if (_infoView) {
                _infoView.hidden = NO;
                _infoTextView.text = [NSString stringWithUTF8String:info];
            } else {
                _infoView = [[UIView alloc] initWithFrame:self.view.frame];
                _infoView.backgroundColor = [UIColor whiteColor];
                [self.view addSubview:_infoView];
                UIButton *closebutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_infoView.frame),40)];
                [closebutton setTitle:@"Close" forState:UIControlStateNormal];
                [closebutton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [closebutton addTarget:self action:@selector(closeInfoView) forControlEvents:UIControlEventTouchUpInside];
                [_infoView addSubview:closebutton];
                _infoTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 50, CGRectGetWidth(_infoView.frame), CGRectGetHeight(_infoView.frame)-100)];
                _infoTextView.textColor = [UIColor blackColor];
                _infoTextView.textAlignment = NSTextAlignmentLeft;
                _infoTextView.font = [UIFont systemFontOfSize:15.0];
                _infoTextView.text = [NSString stringWithUTF8String:info];
                [_infoView addSubview:_infoTextView];
            }
        }
    }
    else if (cell.tag == GET_IF_ADDR)
    {
        if (_getifaddrSwitch.cellSwitch.on) {
            char *addr = netx_get_ifaddr();
            if (_infoView) {
                _infoView.hidden = NO;
                _infoTextView.text = [NSString stringWithUTF8String:addr];
            } else {
                _infoView = [[UIView alloc] initWithFrame:self.view.frame];
                _infoView.backgroundColor = [UIColor whiteColor];
                [self.view addSubview:_infoView];
                UIButton *closebutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_infoView.frame),40)];
                [closebutton setTitle:@"Close" forState:UIControlStateNormal];
                [closebutton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [closebutton addTarget:self action:@selector(closeInfoView) forControlEvents:UIControlEventTouchUpInside];
                [_infoView addSubview:closebutton];
                _infoTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 50, CGRectGetWidth(_infoView.frame), CGRectGetHeight(_infoView.frame)-100)];
                _infoTextView.textColor = [UIColor blackColor];
                _infoTextView.textAlignment = NSTextAlignmentLeft;
                _infoTextView.font = [UIFont systemFontOfSize:15.0];
                _infoTextView.text = [NSString stringWithUTF8String:addr];
                [_infoView addSubview:_infoTextView];
            }
            
        }
    }
    
    [self.tableView endEditing:YES];
}

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

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Pending Local Server
- (BOOL)pendingLocalServer
{
    if ([self createHttpConfXMLFile])
    {
        [self getIPAddress];
        if ([self createIndexHtmlFile]) {
            
            [self destroyHandle];

            struct mhttp_create_param param = {0};
            param.conf_file = (char*)_http_conf_path.UTF8String;           //http conf file
            param.mqlst = (__bridge struct mmq_list *)(self);   //Any object address
            param.fwd_req = fwd_reqLogin;                            //Empty function
            param.fwd_cancel = fwd_cancelLogin;                      //Empty function
            param.get_def = get_defLogin;                            //Empty function
            param.refer = (__bridge struct component *)(self);  //Any object address
            param.log_enable = 0;
            
            module_handle = mhttp_create(&param);
            
            if (_mhttp_wait_thread) {
                self.mhttp_wait_thread = nil;
            }
            if (module_handle) {
                [self.mhttp_wait_thread start];
            }
            
            return YES;
        }
    }
    return NO;
}

-(void)run_mhttp_wait
{
    NSLog(@"Start Share");
    while (!_mhttp_wait_thread.isCancelled) {
        
        if (module_handle) {
            long waitValue = mhttp_wait(module_handle, 10);
            
            if (0 == waitValue) {
                //                NSLog(@"succeed");
            } else {
                NSLog(@"error : %ld",waitValue);
            }
        }
        
    }
    NSLog(@"End Share");
}

long fwd_reqLogin( struct component* comp, struct message *msg, struct in_addr *ip, long port, long handle, void *refer, long *new_handle )
{
    return 1;
}

long fwd_cancelLogin( struct component* comp, long handle )
{
    return 1;
}

struct pack_def* get_defLogin( void *refer, struct len_str *type, unsigned long magic )
{
    return NULL;
}

- (void)destroyHandle
{
    if(module_handle)
    {
        mhttp_destroy(module_handle);
        module_handle = NULL;
    }
}

- (BOOL)createHttpConfXMLFile
{
    
    //create http conf xml file
    NSString *saveDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *saveFileName=@"http_conf.xml";
    NSString *filepath=[saveDirectory stringByAppendingPathComponent:saveFileName];
    
    NSMutableString *xmlString = [[NSMutableString alloc]initWithString:@"<http_conf>"];
    [xmlString appendString:@"<addr>"];
    [xmlString appendString:@"<ip>0.0.0.0</ip>"];
    [xmlString appendString:@"<port>7080</port>"];
    [xmlString appendString:@"</addr>"];
    [xmlString appendString:@"<vhosts>"];
    [xmlString appendString:@"<mapping>"];
    [xmlString appendString:@"<vpath>/</vpath>"];
    [xmlString appendString:[NSString stringWithFormat:@"<local_path>%@</local_path>",[self getFilePath]]];
    [xmlString appendString:@"<cid></cid>"];
    [xmlString appendString:@"<msg_type></msg_type>"];
    [xmlString appendString:@"</mapping>"];
    [xmlString appendString:@"</vhosts>"];
    [xmlString appendString:@"</http_conf>"];
    
    //save html to local
    if ([xmlString  writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        _http_conf_path = filepath;
        return YES;
    }
    
    return NO;
}

- (BOOL)createIndexHtmlFile
{
    NSString *saveDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"NetworkRequest"]];
    BOOL isDirectory;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:saveDirectory isDirectory:&isDirectory];
    if (isDirectory && isFileExist)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *mobileCssFilePath = [saveDirectory stringByAppendingPathComponent:@"mobile.css"];
        NSString *pcCssFilePath = [saveDirectory stringByAppendingPathComponent:@"pc.css"];
        NSString *btnImageFilePath = [saveDirectory stringByAppendingPathComponent:@"button_ico.png"];
        NSString *downloadImageFilePath = [saveDirectory stringByAppendingPathComponent:@"download.png"];
        
        if(![fileManager fileExistsAtPath:mobileCssFilePath])
        {
            NSString *mobileCssPath = [[NSBundle mainBundle] pathForResource:self.app.is_vimtag ? @"vimtag_mobile" : @"mobile" ofType:@"css"];
            if (![fileManager copyItemAtPath:mobileCssPath toPath:[saveDirectory stringByAppendingPathComponent:@"mobile.css"] error:nil])
            {
                return NO;
            }
        }
        
        if(![fileManager fileExistsAtPath:pcCssFilePath])
        {
            NSString *pcCssPath = [[NSBundle mainBundle] pathForResource:self.app.is_vimtag ? @"vimtag_pc" : @"pc" ofType:@"css"];
            if (![fileManager copyItemAtPath:pcCssPath toPath:[saveDirectory stringByAppendingPathComponent:@"pc.css"] error:nil])
            {
                return NO;
            }
        }
        
        [UIImagePNGRepresentation([UIImage imageNamed:@"button_ico.png"]) writeToFile:btnImageFilePath atomically:YES];
        [UIImagePNGRepresentation([UIImage imageNamed:self.app.is_vimtag ? @"vimtag_download.png" : @"download.png"]) writeToFile:downloadImageFilePath atomically:YES];
        
        //Write html file
        NSString *filepath = [saveDirectory stringByAppendingPathComponent:@"index.htm"];
        NSLog(@"%@",filepath);
        NSMutableString *htmlstring=[[NSMutableString alloc]initWithString:@"<!doctype html><html lang=\"en\"><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=2.0\" /><title>download</title>"];
        [htmlstring appendFormat:@"<link id=\"mobile_css\" rel=\"stylesheet\" href=\"mobile.css\"><link id=\"pc_css\" rel=\"stylesheet\" href=\"pc.css\">"];
        [htmlstring appendString:@"	<script type=\"text/javascript\" >var data={"];
        
        [htmlstring appendString:[NSString stringWithFormat:@"\"info_id\":\"ID：%@\",",nil]];
        [htmlstring appendString:[NSString stringWithFormat:@"\"info_size\":\"%@：%.1lfkb\",",NSLocalizedString(@"mcs_video_size",nil),[self fileSizeAtPath]]];
        [htmlstring appendString:[NSString stringWithFormat:@"\"info_time\":\"%@: %@\",",NSLocalizedString(@"mcs_video_duration", nil),nil]];
        [htmlstring appendString:[NSString stringWithFormat:@"\"info_date\":\"%@：%@\",",NSLocalizedString(@"mcs_time", nil),nil]];
        [htmlstring appendString:[NSString stringWithFormat:@"\"download_text\":\"%@\",",NSLocalizedString(@"mcs_download", nil)]];
        [htmlstring appendString:[NSString stringWithFormat:@"\"download_url\":\"http://%@:7080/%@\",", _ipAddress, _shareFileName]];
        [htmlstring appendString:[NSString stringWithFormat:@"\"download_name\":\"%@\"", _shareFileName]];
        
        [htmlstring appendString:@" };"];
        [htmlstring appendString:@"function start(){var m_userAgent = navigator.userAgent;document.getElementById(\"main\").innerHTML=\"<div id='download_img'>\"+\"	<img src='download.png'>\"+\"</div>\"+\"<div id='download_info'>\"+\"	<div id='info_id'>\"+data[\"info_id\"]+\"</div>\"+\"	<div id='info_size'>\"+data[\"info_size\"]+\"</div>\"+\"	<div id='info_time'>\"+data[\"info_time\"]+\"</div>\"+\"	<div id='info_date'>\"+data[\"info_date\"]+\"</div>\"+\"</div>\"+\"<div id='download_button'>\"+\"    <img id='buttom_ico' src='button_ico.png'>\"+\"    <span id='download_text'>\"+data[\"download_text\"]+\"</span>\"+\"  </div>\"+\"<a id='download_a' href='\"+data[\"download_url\"]+\"' download='\"+data[\"download_name\"]+\"' style='visibility: hidden;'></a>\";"];
        [htmlstring appendString:@"if (m_userAgent.indexOf('iPhone') > -1 || m_userAgent.indexOf('iPad') > -1 || m_userAgent.indexOf('Android') > -1){document.getElementsByTagName('head')[0].removeChild(document.getElementById(\"pc_css\"));}else{document.getElementsByTagName('head')[0].removeChild(document.getElementById(\"mobile_css\"));}document.getElementById(\"download_button\").onclick = function(){document.getElementById(\"download_a\").click();}}"];
        [htmlstring appendString:@"</script></head><body onload=\"start()\"><div id=\"main\"></div></body></html>"];
        
        //save html to local
        if ([htmlstring  writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Get IP Address
- (void)getIPAddress
{
    _ipAddress = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    _ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    NSLog(@"Device IP : %@", _ipAddress);
    
    // Free memory
    freeifaddrs(interfaces);
}

#pragma mark - Get File Size
- (float)fileSizeAtPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"NetworkRequest/%@", _shareFileName]];
    
    NSLog(@"%@",filePath);
    if ([fileManager fileExistsAtPath:filePath])
    {
        return ([[fileManager attributesOfItemAtPath:filePath error:nil] fileSize]/1024);
    }
    return 0;
}

#pragma mark - Get File Path
- (NSString *)getFilePath
{
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"NetworkRequest"]];
    
    NSLog(@"%@",filePath);
    return filePath;
}

@end
