//
//  MNLANIPCViewController.m
//  mipci
//
//  Created by mining on 15/10/12.
//
//

#define __ProbeRequest_type_magic 0x2bdbce08
#define __ProbeResponse_type_magic 0xfe16d431
#define mbmc_msg_tmp_size   1024
#define __CcmSession_type_magic 0x169090d4
#define CHANGEPASSWORD_TAG        1002

#import "MNLANIPCViewController.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNProgressHUD.h"
#import "MNToastView.h"
#import "MIPCUtils.h"
#import "MNDeviceListViewController.h"
#import "MNDevicePlayViewController.h"
#import "MNDeviceTabBarController.h"
#import "MNBoxListViewController.h"
#import "MNBoxTabBarController.h"
#import "pack.h"
#import "msg_pack.h"
#import "msg_type.h"
#import "msg_mbc.h"
#import "mipc_def_manager.h"

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


//static dispatch_group_t receive_message_group() {
//    static dispatch_group_t mn_receive_message_group;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        mn_receive_message_group = dispatch_group_create();
//    });
//
//    return mn_receive_message_group;
//}
//
//static dispatch_queue_t receive_message_queue() {
//    static dispatch_queue_t mn_receive_message_queue;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        mn_receive_message_queue = dispatch_queue_create("com.mining.message.operation.queue", DISPATCH_QUEUE_CONCURRENT );
//    });
//
//    return mn_receive_message_queue;
//}


@interface MNLANIPCViewController ()
{
    unsigned char _encrypt_pwd[16];
    void *mmbc_handle;
    //    NSMutableArray *deviceList;
}
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (assign, nonatomic) BOOL isRefreshing;
@property (strong, nonatomic) NSIndexPath *lastIndexPath;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (strong, nonatomic) NSString *password;

@end

@implementation MNLANIPCViewController

-(mipc_agent *)agent
{
    if (nil == _agent) {
        _agent = [mipc_agent shared_mipc_agent];
    }
    
    return _agent;
}

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = [UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (NSMutableArray *)deviceList
{
    @synchronized(self){
        if (nil == _deviceList) {
            _deviceList = [NSMutableArray array];
        }
        return _deviceList;
    }
}

-(MNProgressHUD *)progressHUD
{
    if (nil == _progressHUD) {
        _progressHUD = [[MNProgressHUD alloc] initWithView:self.view];
        //        [self.view addSubview:_progressHUD];
        [self.view insertSubview:_progressHUD belowSubview:self.navigationController.navigationBar];
        _progressHUD.color = [UIColor colorWithWhite:1.0f alpha:0.8f];
        _progressHUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f];
        _progressHUD.labelText = NSLocalizedString(@"mcs_loading", nil);
        _progressHUD.labelColor = [UIColor grayColor];
        _progressHUD.activityIndicatorColor = [UIColor grayColor];
        
    }
    
    return  _progressHUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isRefreshing = NO;
    
    [self refreshDeviceList:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isViewAppearing = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _isViewAppearing = NO;
    if(mmbc_handle)
    {
        mmbc_destroy(mmbc_handle);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
-(IBAction)refreshDeviceList:(id)sender
{
    _lastIndexPath = nil;
    
    if (!_isRefreshing)
    {
        if(mmbc_handle)
        {
            mmbc_destroy(mmbc_handle);
        }
        if (_deviceList) {
            [_deviceList removeAllObjects];
            [self.agent.devs reset];
            [self.tableView reloadData];
        }
        
        _isRefreshing = YES;
        [self.progressHUD show:YES];
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
            msg_set_to(msg, 0x20500000);/* !!!!need change */
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


#pragma mark - mmbc callback

long on_recv_json_msg( void *ref, struct len_str *msg_type, struct len_str *msg_json, struct sockaddr_in *remote_addrin )
{
    MNLANIPCViewController *referSelf = (__bridge MNLANIPCViewController*)ref;
    referSelf.isRefreshing = NO;
    [referSelf.progressHUD hide:YES];
    if (!referSelf.isViewAppearing) {
        return 0;
    }
    
    NSLog(@"----->%@", [NSString stringWithUTF8String:msg_type->data]);
    
    if(0 == len_str_casecmp_const(msg_type, "ProbeResponse"))
    {
        
        NSData *msg_data = [NSData dataWithBytes:msg_json->data length:msg_json->len];
        struct json_object *data_json = MIPC_DataTransformToJson(msg_data);
        
        struct json_object *probe_json = json_get_child_by_name(data_json, NULL, len_str_def_const("ProbeMatch"));
        
        NSLog(@"-------------------ProbeResponse----------------------------");
        
        m_dev *dev = [[m_dev alloc] init];
        
        if(probe_json
           && (probe_json->type == ejot_array)
           && probe_json->v.array.counts)
        {
            struct json_object *obj = probe_json->v.array.list;
            for (int i = 0; i < probe_json->v.array.counts; i++, obj = obj->in_parent.next)
            {
                struct len_str sn = {0}, ip_addr = {0};
                json_get_child_string(obj, "XAddrs", &ip_addr);
                
                struct json_object *Endpoint_json = json_get_child_by_name(obj, NULL, len_str_def_const("EndpointReference"));
                json_get_child_string(Endpoint_json, "Address", &sn);
                
                
                dev.sn = sn.len ? [NSString stringWithUTF8String:sn.data] : nil;
                dev.ip_addr = ip_addr.len ? [NSString stringWithUTF8String:ip_addr.data] : nil;
                dev.status = @"Online";
                [referSelf.deviceList addObject:dev];
                
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [referSelf.tableView reloadData];
        });
    }
    
    return 0;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    m_dev *obj = [_deviceList objectAtIndex:indexPath.row];
    cell.textLabel.text = obj.sn;
    
    return cell;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nil == _lastIndexPath)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        _lastIndexPath = indexPath;
    }
    else if (_lastIndexPath.row != indexPath.row)
    {
        UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:_lastIndexPath];
        lastCell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        _lastIndexPath = indexPath;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    m_dev *obj = [_deviceList objectAtIndex:indexPath.row];
    
    //    devicecontroller.deviceid = obj.sn;
    _selectedDeviceID = obj.sn;
    _selectedDeviceIP = obj.ip_addr;
    [mipc_agent passwd_encrypt:@"admin" encrypt_pwd:_encrypt_pwd];
    
    NSString  *sServer = obj.ip_addr, *sUser = _selectedDeviceID;
    struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
    
    if(conf)
    {
        conf_new        = *conf;
    }
    
    conf_new.server.data = (char*)(sServer?sServer.UTF8String:NULL);
    conf_new.server.len = (uint32_t)(sServer?sServer.length:0);
    conf_new.user.data = (char*)(sUser?sUser.UTF8String:NULL);
    conf_new.user.len = (uint32_t)(sUser?sUser.length:0);
    if (conf) {
        memcpy(_encrypt_pwd, conf->password_md5.data, sizeof(_encrypt_pwd));
    }
    
    conf_new.password_md5.data = (char*)_encrypt_pwd;
    conf_new.password_md5.len = 16;
    
    MIPC_ConfigSave(&conf_new);
    
    mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
    ctx.srv = MIPC_SrvFix(sServer);
    ctx.user = sUser;
    ctx.passwd = _encrypt_pwd;
    ctx.target = self;
    ctx.on_event = @selector(sign_in_done:);
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *token = [user objectForKey:@"mipci_token"];
    
    if(token && token.length)
    {
        ctx.token = token;
    }
    
    [self.agent sign_in:ctx block:nil];
    [self.progressHUD show:YES];
    
}

#pragma mark - sign_in_done
- (void)sign_in_done:(mcall_ret_sign_in*)ret
{
    if (nil == ret.result) {
        mcall_ctx_dev_info_get *ctx = [[mcall_ctx_dev_info_get alloc] init];
        ctx.sn = _selectedDeviceID;
        ctx.target = self;
        ctx.on_event = @selector(dev_info_get_done:);
        
        [self.agent dev_info_get:ctx];
        
        
    }
    else if([ret.result isEqualToString:@"ret.pwd.invalid"]){
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
        userTextField.text = _selectedDeviceID;
        UITextField *passTextField = [alertView textFieldAtIndex:1];
        passTextField.secureTextEntry = YES;
        passTextField.placeholder = NSLocalizedString(@"mcs_input_password",nil);
    }
}

#pragma mark - dev_info_get_done
- (void)dev_info_get_done:(mcall_ret_dev_info_get *)ret
{
    self.isRefreshing = NO;
    [self.progressHUD hide:YES];
    if (!_isViewAppearing)
    {
        return;
    }
    
    if (nil == ret.result)
    {
        
        if ([ret.type  isEqualToString: @"BOX"]) {
            for (m_dev *dev in _deviceList) {
                if ([dev.sn isEqualToString:_selectedDeviceID]) {
                    dev.type = @"BOX";
                    [self.agent.devs  add_dev:dev];
                }
            }
            
            if (self.app.is_luxcam || self.app.is_vimtag) {
                [self performSegueWithIdentifier:@"MNBoxListViewController" sender:nil];
            } else {
                [self performSegueWithIdentifier:@"MNBoxTabBarController" sender:nil];
            }
        }
        else {
            for (m_dev *dev in _deviceList) {
                if ([dev.sn isEqualToString:_selectedDeviceID]) {
                    dev.type = @"IPC";
                    [self.agent.devs  add_dev:dev];
                }
            }
            if (self.app.is_luxcam || self.app.is_vimtag) {
                [self performSegueWithIdentifier:@"MNDevicePlayViewController" sender:nil];
            }else{
                [self performSegueWithIdentifier:@"MNDeviceTabBarController" sender:[NSNumber numberWithInt:0]];
            }
        }
        
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
            
            _selectedDeviceID = userTextField.text;
            //            _devicePasswordTextField = pwdTextField;
            if(pwdTextField.text.length)
            {
                if([pwdTextField.text isEqualToString:@"amdin"]){
                    pwdTextField.text = @"admin";
                }
                
                if(pwdTextField.text && pwdTextField.text.length)
                {
                    [mipc_agent passwd_encrypt:pwdTextField.text encrypt_pwd:_encrypt_pwd];
                    
                }
                struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
                
                if(conf)
                {
                    conf_new        = *conf;
                }
                conf_new.password_md5.data = (char*)_encrypt_pwd;
                conf_new.password_md5.len = 16;
                
                MIPC_ConfigSave(&conf_new);
                
                mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
                ctx.user = userTextField.text;
                ctx.passwd = _encrypt_pwd;
                ctx.target = self;
                ctx.on_event = @selector(sign_in_done:);
                
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSString *token = [user objectForKey:@"mipci_token"];
                
                if(token && token.length)
                {
                    ctx.token = token;
                }
                
                [self.agent sign_in:ctx block:nil];
                
                [self.progressHUD show:YES];
                self.isRefreshing = YES;
            }
        }
        else if (buttonIndex == alertView.cancelButtonIndex)
        {
            self.isRefreshing = NO;
            [self.progressHUD hide:YES];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MNDeviceTabBarController"])
    {
        MNDeviceTabBarController *deviceTabBarController = segue.destinationViewController;
        deviceTabBarController.deviceID = _selectedDeviceID;
        //        deviceTabBarController.deviceListViewController = self;
        deviceTabBarController.selectedIndex = [sender integerValue];
    }
    else if ([segue.identifier isEqualToString:@"MNDevicePlayViewController"])
    {
        MNDevicePlayViewController *devicePlayViewController = segue.destinationViewController;
        devicePlayViewController.deviceID = _selectedDeviceID;
    }
    else if ([segue.identifier isEqualToString:@"MNBoxListViewController"])
    {
        MNBoxListViewController *boxListViewController = segue.destinationViewController;
        boxListViewController.boxID = _selectedDeviceID;
    }
    else if ([segue.identifier isEqualToString:@"MNBoxTabBarController"])
    {
        MNBoxTabBarController *boxTabBarController = segue.destinationViewController;
        boxTabBarController.boxID = _selectedDeviceID;
    }
}


@end
