//
//  MNStartScreenViewController.m
//  mipci
//
//  Created by mining on 16/1/21.
//
//

#import "MNStartScreenViewController.h"
#import "MNCycleScrollView.h"
#import "MNLoginViewController.h"

@interface  MNStartScreenViewController ()

@property(strong, nonatomic) MNCycleScrollView *mainScorllView;

@end

@implementation MNStartScreenViewController


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.mainScorllView) {
        [self.mainScorllView stopAnimationDuration];
    }
}

- (void)initUI
{
    self.navigationController.navigationBarHidden = YES;
    NSMutableArray *viewsArray = [@[] mutableCopy];
    NSArray *imageArray = @[@"startImage1.png",@"startImage2.png",@"startImage3.png",@"startImage4.png",@"startImage5.png"];
    NSArray *iconArray = @[@"Icon01.png",@"Icon02.png",@"Icon03.png",@"Icon04.png",@"Icon05.png"];
    
    for (int i = 0; i < 5; ++i) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0 - 90, self.view.frame.size.width / 2.0 - 90, 180,180)];
        
        imageView.image = [UIImage imageNamed:(NSString *)[imageArray objectAtIndex:i]];
        iconImageView.image = [UIImage imageNamed:(NSString *)[iconArray objectAtIndex:i]];
        [imageView addSubview:iconImageView];
        
        [viewsArray addObject:imageView];
    }
    
    self.mainScorllView = [[MNCycleScrollView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height)
                                                 animationDuration:2];
    self.mainScorllView.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1];
    
    self.mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return viewsArray[pageIndex];
    };
    self.mainScorllView.totalPagesCount = ^NSInteger(void){
        return 5;
    };
    self.mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"tip :%ld",(long)pageIndex);
    };
    [self.view addSubview:self.mainScorllView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2.0 - 120, self.view.frame.size.width + (self.view.frame.size.height  - self.view.frame.size.width) / 2.0 - 12 , 240, 44)];
//    [button setImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:NSLocalizedString(@"mcs_sign_in",nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_login"] forState:UIControlStateNormal];
    [self.view addSubview:button];
    
}
- (void)login{
    [self performSegueWithIdentifier:@"MNDeviceListViewController" sender:nil];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
