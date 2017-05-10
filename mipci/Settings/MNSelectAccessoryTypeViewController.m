//
//  MNSelectAccessoryTypeViewController.m
//  mipci
//
//  Created by mining on 16/4/20.
//
//

#import "MNSelectAccessoryTypeViewController.h"
#import "MNAccessoryCell.h"

#define DEFAULT_LINE_COUNTS      2

@interface MNSelectAccessoryTypeViewController ()


@end

@implementation MNSelectAccessoryTypeViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - initUI
-(void)initUI
{
    self.title = NSLocalizedString(@"mcs_accessory_type", nil);
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
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UICollectionViewDatasource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    MNAccessoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"vt_magnetic"];
        cell.label.text = NSLocalizedString(@"mcs_magnetic", nil);
        cell.onlineLabel.hidden = YES;
    }else
    {
        cell.imageView.image = [UIImage imageNamed:@"vt_sos_type"];
        cell.label.text = NSLocalizedString(@"mcs_sos", nil);
        cell.onlineLabel.hidden = YES;
    }
    
    return cell;
}

#pragma mark - <UICollectionViewDelagate>
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
//        NSInteger screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
//        int lineCounts = DEFAULT_LINE_COUNTS + 1;
//        NSInteger cellWidth = (screenWidth - 6 * 2 - (lineCounts - 1) * 6) / lineCounts;
//        itemSize = CGSizeMake(cellWidth, cellWidth * 3 / 5 + 16);
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight) {
            
            float width = [UIScreen mainScreen].bounds.size.width;
            itemSize = CGSizeMake(width / 4.0, 123);
        }else
        {
            float width = [UIScreen mainScreen].bounds.size.width;
            itemSize = CGSizeMake(width / 3.0, 123);
        }
    }
    else
    {
        float width = [UIScreen mainScreen].bounds.size.width;
        itemSize = CGSizeMake(width / 3.0, 123);
    }
    
    return itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            self.type = 6;
            break;
        case 1:
            self.type = 5;
            break;
            
        default:
            break;
    }
    [self performSegueWithIdentifier:@"MNSearchAccessoryViewController" sender:nil];
}
#pragma mark - Action
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *viewController = segue.destinationViewController;
    [viewController setValue:_agent forKey:@"agent"];
    [viewController setValue:_deviceID forKey:@"deviceID"];
    
    if ([segue.identifier isEqualToString:@"MNSearchAccessoryViewController"] ) {
        
        MNSearchAccessoryViewController *searchAccessoryViewController = segue.destinationViewController;
        searchAccessoryViewController.type = self.type;
    }
}

#pragma mark - InterfaceOrientation
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView reloadData];
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
@end
