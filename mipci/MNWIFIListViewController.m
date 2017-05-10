//
//  MNWIFIListViewController.m
//  mipci
//
//  Created by weken on 15/3/16.
//
//

#import "MNWIFIListViewController.h"
#import "mipc_agent.h"
#import "MNModifyWIFIViewController.h"
#import "MNProgressHUD.h"
#import "AppDelegate.h"

@interface MNWIFIListViewController ()
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) NSMutableArray *wifiList;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (assign, nonatomic) BOOL isRefreshing;
@property (strong, nonatomic) NSIndexPath *lastIndexPath;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (weak, nonatomic) AppDelegate *app;


@end

@implementation MNWIFIListViewController

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

-(mipc_agent *)agent
{
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return app.isLocalDevice?app.localAgent:app.cloudAgent;
}

-(MNProgressHUD *)progressHUD
{
    if (nil == _progressHUD) {
        _progressHUD = [[MNProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_progressHUD];
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

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isViewAppearing = YES;
    _isRefreshing = NO;
    [self refresh:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)refresh:(id)sender
{
    if (!_isRefreshing)
    {
        mcall_ctx_net_get *ctx = [[mcall_ctx_net_get alloc] init] ;
        ctx.sn = _deviceID;
        ctx.target = self;
        ctx.force_scan = 1;
        ctx.on_event = @selector(net_get_done:);
        
        _isRefreshing = YES;
        [self.progressHUD show:YES];
        [self.agent net_get:ctx];
    }
}

- (void)net_get_done:(mcall_ret_net_get*)ret
{
    _isRefreshing = NO;
    [self.progressHUD hide:YES];
    if (!_isViewAppearing) {
        return;
    }
    if (nil == ret.result) {
        net_obj *obj = ret.networks[1];
        _wifiList = obj.wifi_list;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _wifiList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (_lastIndexPath.row == indexPath.row && _lastIndexPath) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
//    cell.accessoryType = (_lastIndexPath.row == indexPath.row)?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;

    wifi_obj *obj = [_wifiList objectAtIndex:indexPath.row];
    cell.textLabel.text = obj.ssid;
    
    if (obj.quality <= 25) {
        cell.imageView.image = [UIImage imageNamed:@"wifi-1.png"];
    }
    else if (obj.quality <= 50)
    {
        cell.imageView.image = [UIImage imageNamed:@"wifi-2.png"];
    }
    else if (obj.quality <= 75)
    {
        cell.imageView.image = [UIImage imageNamed:@"wifi-3.png"];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"wifi-4.png"];
    }
    
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
    
    
    wifi_obj *obj = [_wifiList objectAtIndex:indexPath.row];
    _modifyWIFIViewController.WIFINameTextField.text = obj.ssid;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
