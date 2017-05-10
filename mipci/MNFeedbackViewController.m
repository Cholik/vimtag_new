//
//  MNFeedbackViewController.m
//  mipci
//
//  Created by mining on 15/11/11.
//
//

#define SUCCESS 1001
#define FAILED  1002

#import "MNFeedbackViewController.h"
#import "AppDelegate.h"
#import "MNAppSettingsViewController.h"
#import "mipc_agent.h"
#import "mipc_data_object.h"
#import "MNImagePickerController.h"
#import <AVFoundation/AVFoundation.h>

@interface MNFeedbackViewController ()<UIAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak,nonatomic) AppDelegate *app;
@property (strong,nonatomic) mipc_agent *agent;
@property (strong,nonatomic) NSString *callback;
@property (strong,nonatomic) UIImage  *feedback_img;
@property (strong,nonatomic) NSString *jsParam;

@end

@implementation MNFeedbackViewController

-(AppDelegate *)app
{
    if (!_app) {
        _app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    }
    return _app;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

#pragma mark - View lifecycle
- (void)initUI
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backToDeviceList)];
    
    self.navigationItem.title = NSLocalizedString(@"mcs_feedback", nil);
    
    _feedbackWebview = [[UIWebView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _feedbackWebview.delegate = self;
    [self.view addSubview:_feedbackWebview];

}
-(void)backToDeviceList
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    self.agent = self.app.agent;
    
    
    //load web view
    
    /*
     NSString *unzipFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"unzipFilePath"];
     NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/add_device_html/add_device_choose_device_type.html", unzipFilePath]];
     */
    
//    NSString *urlStr = [[NSBundle mainBundle]pathForResource:@"add_device_html/user_feedback" ofType:@"html"];
//    NSURL *url =[[NSURL alloc] initWithString:urlStr];
    
//    NSURL *url = [NSURL fileURLWithPath:@"/Users/tanjiancong/project/src/apps/app/ipc/www/add_device_html/user_feedback.html"];
//    NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
//    [_feedbackWebview loadRequest:request];
   
    
    NSString *unzipFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"unzipFilePath"];
    NSString *filePath = [NSString stringWithFormat:@"%@/add_device_html/user_feedback.html", unzipFilePath];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        NSURL *url = [NSURL URLWithString:filePath];
        NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
        [_feedbackWebview loadRequest:request];

    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.app.is_vimtag) {
        MNAppSettingsViewController *appSetVC = self.navigationController.viewControllers.firstObject;
        appSetVC.navigationController.navigationBarHidden = NO;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


#pragma mark-uiwebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *jsRequestStr = [request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([jsRequestStr hasPrefix:@"iosapp:"]) {
        [self dealWithJsRequest:jsRequestStr];
        return NO;
    }
    return YES;
}

-(NSMutableDictionary *)parseWithJSRequestString:(NSString *)jsRequestStr
{
    
    NSMutableArray *paramArr = (NSMutableArray *)[jsRequestStr componentsSeparatedByString:@"&"];
    [paramArr removeObjectAtIndex:0];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc]init];
    for (NSString *param in paramArr) {
        NSArray *arr = [param componentsSeparatedByString:@"="];
        [requestDict setObject:arr[1] forKey:arr[0]];
    }
    return requestDict;
}

-(void)dealWithJsRequest:(NSString *)requestString
{
    NSDictionary *requestDict = [self parseWithJSRequestString:requestString];
    NSString *req_type = requestDict[@"func"];
    _callback = requestDict[@"callback"];
    if ([req_type isEqualToString:@"get_browser_language"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *allLanguages = [defaults objectForKey:@"AppleLanguages"];
        NSString *preferredLang = [allLanguages objectAtIndex:0];
        [self callJSWithFun:_callback parma:preferredLang];
    }
    else if([req_type isEqualToString:@"feedback_img_get"]){
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"mcs_Photograph", nil),NSLocalizedString(@"mcs_Album", nil), nil];
        [actionSheet showInView:self.view];
        
//        MNImagePickerController *imgPicker = [[MNImagePickerController alloc]init];
//        imgPicker.maxCount = 1;
//        [imgPicker setDidFinishSelectImages:^(NSArray *imags) {
//            
//            _feedback_img = imags[0];
//            NSString *imgPath = [self saveFeedbackImg:_feedback_img];
//            NSString *imgStr = [self transformImagToBase64:_feedback_img];
//            if(!imgStr){
//                imgStr = @"";
//            }
//            [self performSelector:@selector(callJSWithParam:) withObject:[NSString stringWithFormat:@"{imgPath:\'%@\',imgStr:\'%@\'}",imgPath,imgStr]];
//            
//        }];
//        
//        [self presentViewController:imgPicker animated:YES completion:nil];
        
    }else if([req_type isEqualToString:@"submit_result"]){
        NSString *result = requestDict[@"result"];
        [self showSubmitResultAlrt:result];
    }  else  if ([req_type isEqualToString:@"get_native_param"]) {
        if (!self.jsParam) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray *allLanguages = [defaults objectForKey:@"AppleLanguages"];
            NSString *preferredLang = [allLanguages objectAtIndex:0];
            
//            NSDictionary *infodict = [[NSBundle mainBundle]infoDictionary];
//            NSString *preferredLang = infodict[@"CFBundleDevelopmentRegion"];
            
            //china 61.147.109.92:10080    other coutry 96.46.4.26:10080
            
            NSString *srv_url = [[NSUserDefaults standardUserDefaults] stringForKey:@"u_ticket"];
            NSString *feedback_srv = (srv_url.length) ? srv_url : (self.app.is_vimtag ? @"http://ticket.vimtag.com/ctck" : @"http://ticket.mipcm.com/ctck");
            
           // feedback_srv = @"http://96.46.4.26:10080/ctck";
            
            [self callJSWithFun:[requestDict objectForKey:@"callback"] parma:preferredLang];
            self.jsParam =
            [NSString stringWithFormat:@"{loadweb:\'%@\', srv:\'%@\',share_key:\'%@\',sid:\'%lld\', language:\'%@\',feedback_srv:\'%@\'}", [requestDict objectForKey:@"loadweb"], self.agent.srv, self.agent.shareKey, self.agent.sid, preferredLang,feedback_srv];
        }
        NSString *nativeParam = [self.jsParam stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
       // NSLog(@"%@",nativeParam);
        [self callJSWithFun:[requestDict objectForKey:@"callback"] parma:nativeParam];
        
    }
}

#pragma mark -actionsheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:nil];
            if (![self checkOpenCameraOrNot])
            {
                NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
                NSString *appName = [infoDict objectForKey:@"CFBundleDisplayName"];
                NSString *title = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"mcs_please_allow", nil), appName, NSLocalizedString(@"mcs_access_camera", nil)];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:[NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"mcs_ios_privacy_setting_for_camera_prompt", nil),appName, NSLocalizedString(@"mcs_execute_change", nil)]
                                                               delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil)
                                                      otherButtonTitles: nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"mcs_camera_unavailable", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_ok", nil) otherButtonTitles: nil];
            [alert show];
        }
    }
    else if(buttonIndex == 1){
        
        MNImagePickerController *imgPicker = [[MNImagePickerController alloc]init];
        imgPicker.maxCount = 1;
        [imgPicker setDidFinishSelectImages:^(NSArray *imags) {

            _feedback_img = imags[0];
            NSString *imgPath = [self saveFeedbackImg:_feedback_img];
            NSString *imgStr = [self transformImagToBase64:_feedback_img];
            if(!imgStr){
                imgStr = @"";
            }
            [self performSelector:@selector(callJSWithParam:) withObject:[NSString stringWithFormat:@"{imgPath:\'%@\',imgStr:\'%@\'}",imgPath,imgStr]];

        }];
        
        [self presentViewController:imgPicker animated:YES completion:nil];

    }
}

#pragma mark -imagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    UIImage *image = info[UIImagePickerControllerOriginalImage];
    _feedback_img = image;
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    NSString *imgPath = [self saveFeedbackImg:_feedback_img];
    NSString *imgStr = [self transformImagToBase64:_feedback_img];
    if(!imgStr){
        imgStr = @"";
    }
    [self performSelector:@selector(callJSWithParam:) withObject:[NSString stringWithFormat:@"{imgPath:\'%@\',imgStr:\'%@\'}",imgPath,imgStr]];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -transform-img to base64
-(NSString *)transformImagToBase64:(UIImage *)img
{
#define base64_mime_start_string    "data:application/octet-stream;base64,"
    NSData *imageData = UIImageJPEGRepresentation(img, 0.001);
    
    NSString *base64ImageString = [NSString string];
    /* encode */
    unsigned long source_size = imageData.length;
    unsigned char *source_buf = (unsigned char*)[imageData bytes];
    unsigned long buf_size = source_size * 4 / 3 + sizeof(base64_mime_start_string);  //4KB, need more memory
    unsigned char *base64_buf = (unsigned char*)malloc(buf_size);
    long base64_len = 0;
    
    if (0 < source_size) {
        
        memcpy(base64_buf, base64_mime_start_string, sizeof(base64_mime_start_string) - 1);
        base64_len = base64_encode(source_buf,
                                   source_size,
                                   &base64_buf[sizeof(base64_mime_start_string) - 1],
                                   buf_size - (sizeof(base64_mime_start_string) - 1) );
        if(0 < base64_len)
        {
            base64ImageString = [NSString stringWithUTF8String:(char*)base64_buf];
            
        }
    }
    
    
    return base64ImageString;
}

-(void)callJSWithParam:(NSString *)param
{
   // NSLog(@"%@(\"%@\")",_callback,param);
    [_feedbackWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.index.%@(\"%@\");", _callback,param]];
}

-(void)callJSWithFun:(NSString *)call parma:(NSString *)param
{
   // NSLog(@"%@(\"%@\")",_callback,param);
    [_feedbackWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.index.%@(\"%@\");",call,param]];
    
}

-(void)showSubmitResultAlrt:(NSString *)resultString
{
    
    if ([resultString isEqualToString:@"success"]) {
        UIAlertView *alrt = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"mcs_feedback_submit_success", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_ok", nil) otherButtonTitles: nil];
        alrt.tag = SUCCESS;
        [alrt show];
        
        
    }else{
        
        UIAlertView *alrt = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"mcs_feedback_submit_fail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_ok", nil) otherButtonTitles: nil];
        alrt.tag = FAILED;
        [alrt show];
        
    }
    
}


#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex && alertView.tag == SUCCESS) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)shouldAutorotate
{
    
    return NO;
}



#pragma mark-save feedback_img
-(NSString *)saveFeedbackImg:(UIImage *)image
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask , YES) firstObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"feedback.png"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *err = nil;
        [fileManager removeItemAtPath:filePath error:&err];
        if (err) {
            NSLog(@"fail remove!");
        }else{
            
            NSLog(@"remove success!");
        }
    }
    
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    return filePath;
}

#pragma mark - Check Camera
- (BOOL)checkOpenCameraOrNot
{
    NSError *error = nil;
    [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error];
    if (error) {
        return NO;
    }
    
    return YES;
}

@end
