//
//  MNWeekListViewController.m
//  mipci
//
//  Created by weken on 15/3/20.
//
//

#import "MNWeekListViewController.h"
#import "MNDevicePlanRecordSetViewController.h"
#import "MNDevicePlanDefenceSetViewController.h"

#define WEEK @[\
NSLocalizedString(@"mcs_sunday",nil),\
NSLocalizedString(@"mcs_monday",nil),\
NSLocalizedString(@"mcs_tuesday",nil),\
NSLocalizedString(@"mcs_wednesday",nil),\
NSLocalizedString(@"mcs_thursday",nil),\
NSLocalizedString(@"mcs_friday",nil),\
NSLocalizedString(@"mcs_saturday",nil),\
]

#define WEEK_SAMPlE @[\
NSLocalizedString(@"mcs_sun",nil),\
NSLocalizedString(@"mcs_mon",nil),\
NSLocalizedString(@"mcs_tue",nil),\
NSLocalizedString(@"mcs_wed",nil),\
NSLocalizedString(@"mcs_thu",nil),\
NSLocalizedString(@"mcs_fri",nil),\
NSLocalizedString(@"mcs_sat",nil),\
]

#define WEEK_BYTE @[@0x1,@0x2,@0x4,@0x8,@0x10,@0x20,@0x40]

@interface MNWeekListViewController ()

@end

@implementation MNWeekListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"mcs_finish", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(finish:)];
    
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    
    
    if (_devicePlanRecordSetViewController != nil) {
        if (_devicePlanRecordSetViewController.weeks[_index - 2] == [NSNull null]) {
            _wday_byte = 0;
        }
        else
        {
            NSMutableString *tmpString = _devicePlanRecordSetViewController.weeks[_index - 2];
            _wday_byte = [tmpString intValue];
        }
    } else {
        if (_devicePlanDefenceSetViewController.weeks[_index - 1] == [NSNull null]) {
            _wday_byte = 0;
        }
        else
        {
            NSMutableString *tmpString2 = _devicePlanDefenceSetViewController.weeks[_index - 1];
            _wday_byte = [tmpString2 intValue];
        }
        
    }
//    NSLog(@"[_wday_byte]===============[%@]============\n",_devicePlanRecordSetViewController.weeks[_index - 2]);
//    NSLog(@"[_wday_byte]===============[%d]============\n",_wday_byte);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)finish:(id)sender
{
    NSString *week_value = nil;
    
    for(int j = 0 ; j < 7 ; j++)
    {
        if ([WEEK_BYTE[j] intValue] == (_wday_byte & [WEEK_BYTE[j] intValue]))
        {
            week_value = week_value?[NSString stringWithFormat:@"%@ %@", week_value, WEEK_SAMPlE[j]]:WEEK_SAMPlE[j];
        }
    }
    if (_devicePlanRecordSetViewController != nil) {
        //NSLog(@"[_wday_byte]===============[%d]============\n",_wday_byte);
        _devicePlanRecordSetViewController.weeks[_index - 2] = [NSNumber numberWithInt:_wday_byte];
        _devicePlanRecordSetViewController.currentDateLabel.text = week_value;
        //NSLog(@"[week[]]===============[%@]============\n",_devicePlanRecordSetViewController.weeks[_index - 2]);
    } else {
        _devicePlanDefenceSetViewController.weeks[_index - 1] = [NSNumber numberWithInt:_wday_byte];
        _devicePlanDefenceSetViewController.currentDateLabel.text = week_value;
    }
        
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return WEEK.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * const reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    int _wday = _wday_byte & [WEEK_BYTE[indexPath.row] intValue];
    
    if (_wday == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = WEEK[indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        _wday_byte = _wday_byte ^ [WEEK_BYTE[indexPath.row] intValue];
    }
    else if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _wday_byte = _wday_byte | [WEEK_BYTE[indexPath.row] intValue];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
