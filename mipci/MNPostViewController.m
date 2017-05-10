//
//  MNPostViewController.m
//  mipci
//
//  Created by mining on 15/11/26.
//
//

#import "MNPostViewController.h"

@interface MNPostViewController ()

@end

@implementation MNPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title =  NSLocalizedString(@"mcs_push", nil);
    //get seriver url
    NSURL *url=[NSURL URLWithString:@"https://www.baidu.com/"];
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:url];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    //add
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
