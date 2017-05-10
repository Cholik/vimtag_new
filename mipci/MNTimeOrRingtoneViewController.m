//
//  MNBufferTimeViewController.m
//  mipci
//
//  Created by weken on 15/3/10.
//
//
#define ringPathList @[@"msg0.mp3",@"msg1.mp3",@"msg2.mp3",@"msg3.mp3",@"msg4.mp3",@"msg5.mp3",@"msg6.mp3"]

#import "MNTimeOrRingtoneViewController.h"
#import "MIPCUtils.h"
#import <AudioToolbox/AudioToolbox.h>

@interface MNTimeOrRingtoneViewController ()
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSIndexPath *lastIndexPath;
@property (assign, nonatomic) SystemSoundID ring_id;
@end

@implementation MNTimeOrRingtoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_isRingtone) {
        _dataArray = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6"];
    }
    else
    {
        _dataArray =  @[NSLocalizedString(@"mcs_default", nil),@"5s",@"10s",@"15s", @"20s", @"25s", @"30s"];
    }
  
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_ring_id) {
        AudioServicesDisposeSystemSoundID(_ring_id);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = _dataArray[indexPath.row];
    
    struct mipci_conf *conf = MIPC_ConfigLoad();
    int data = 0;
    if (_isRingtone && conf && conf->ring) {
        data = conf->ring;
    }
    else if (conf && conf->buf)
    {
        data = conf->buf / 5000;
    }
    
    if (data == [_dataArray[indexPath.row] integerValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _lastIndexPath = indexPath;
    }
    
    return cell;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nil == _lastIndexPath) {
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
    
    
    struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
    if(conf)
    {
        conf_new        = *conf;
    }
    
    if (_isRingtone) {
        
        if (_ring_id) {
            AudioServicesDisposeSystemSoundID(_ring_id);
        }
        
        int index = [[_dataArray objectAtIndex:indexPath.row] intValue];
        conf_new.ring = index;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:ringPathList[index] ofType:@""];
        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &_ring_id);
        AudioServicesPlaySystemSound(_ring_id);
    }
    else
    {
        conf_new.buf = [[_dataArray objectAtIndex:indexPath.row] intValue] * 5000;
    }
    
    MIPC_ConfigSave(&conf_new);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
