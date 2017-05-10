//
//  MNQRCodeViewController.m
//  mipci
//
//  Created by weken on 15/4/22.
//
//

#import "MNQRCodeViewController.h"
#import "MIPCUtils.h"
#import "MNLoginViewController.h"
#import "MNAddDeviceViewController.h"
#import "MNConfiguration.h"
#import "AppDelegate.h"


@interface MNQRCodeViewController ()
@property (strong, nonatomic) ZBarReaderView *readerView;

@property (strong, nonatomic) AVCaptureDevice * captureDevice;

@property (strong, nonatomic) AVCaptureDeviceInput * captureDeviceInput;

@property (strong, nonatomic) AVCaptureMetadataOutput * captureMetadataOutput;

@property (strong, nonatomic) AVCaptureSession * captureSession;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;

@property (strong, nonatomic) UIImageView * lineImageView;

@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *deviceID;
@property (weak, nonatomic) AppDelegate *app;
@property (assign, nonatomic) BOOL is_scan;
@property (assign, nonatomic) BOOL is_scanSucess;
@property (assign, nonatomic) BOOL is_wifiConfig;

@end

@implementation MNQRCodeViewController

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (void)initUI
{
    self.titleLabel.text = NSLocalizedString(@"mcs_qrcode_scan", nil);
    self.cameraOverlayView.remindContent = NSLocalizedString(@"mcs_qrcode_scan_hint", nil);
    self.navigationItem.title = NSLocalizedString(@"mcs_qrcode_scan", nil);
    [self.imputIDBtn setTitle:NSLocalizedString(@"mcs_manual_input_prompt", nil) forState:UIControlStateNormal];
    [self.imputIDBtn setTitleColor:self.app.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    [self.promaptView setHidden:YES];
    self.promaptLabel.text = NSLocalizedString(@"mcs_qrscan_prompt", nil);

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        if (self.app.is_luxcam)
        {
            [self.navImage setImage:[UIImage imageNamed:@"nav_bg.png"]];
            [_imputIDBtn setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        }
        else if (self.app.is_vimtag)
        {
            [self.navImage setImage:[UIImage imageNamed:@"vt_navigation.png"]];
            [self.imputIDBtn setBackgroundImage:[UIImage imageNamed:@"vt_btn_login.png"] forState:UIControlStateNormal];
        }
        else if (self.app.is_ebitcam)
        {
            [self.navImage setImage:[UIImage imageNamed:@"eb_navbar_bg.png"]];
            [self.imputIDBtn setBackgroundImage:[UIImage imageNamed:@"eb_login_btn.png"] forState:UIControlStateNormal];
        }
        else if (self.app.is_mipc)
        {
            [self.navImage setImage:[UIImage imageNamed:@"mi_navbar_bg.png"]];
            [self.imputIDBtn setBackgroundImage:[UIImage imageNamed:@"mi_login_btn.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.navImage setImage:[UIImage imageNamed:@"navbar_bg.png"]];
            [self.imputIDBtn setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
        }
    }
    if (self.loginViewController) {
        _imputIDBtn.hidden = YES;
    }
    if (self.app.is_sereneViewer) {
        UIButton *helpButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 50, 50, 50)];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"help.png"] forState:UIControlStateNormal];
        [helpButton addTarget:self action:@selector(jumpHelp) forControlEvents:UIControlEventTouchUpInside];
        helpButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self.view addSubview:helpButton];
    }
}

- (BOOL)checkOpenCameraOrNot
{
    if (self.app.is_vimtag) {
        if(([[[UIDevice currentDevice] systemVersion] floatValue] < 7.f)
           || [self checkCamera])
        {
            return YES;
        } else {
            [self selectpromaptImage];
            NSString *mediaType = AVMediaTypeVideo;
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
            if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                
                NSLog(@"Limited camera access");
                return NO;
            }
        }
    } else {
        NSError *error = nil;
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error];
        if (error) {
            return NO;
        }
        
        return YES;
    }
    
    return YES;
}

- (BOOL)checkCamera
{
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error];
    if(nil == videoInput)
    {
        if(error.code == -11852)
        {
            if(([[[UIDevice currentDevice] systemVersion] floatValue] < 7.f)
               )
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
        return NO;
    }
    return YES;
}

- (void)selectpromaptImage
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [allLanguages objectAtIndex:0];
    NSLog(@"Current language:%@", preferredLang);
    
    if ([preferredLang rangeOfString:@"en"].length) {
        _promaptImage.image = [UIImage imageNamed:@"cut_p"];
    }
    else if ([preferredLang rangeOfString:@"zh-Hans"].length) {
        _promaptImage.image = [UIImage imageNamed:@"cut_q"];
    }
    else if ([preferredLang rangeOfString:@"zh-Hant"].length) {
        _promaptImage.image = [UIImage imageNamed:@"cut_g"];
    }
    else if ([preferredLang rangeOfString:@"ja"].length) {
        _promaptImage.image = [UIImage imageNamed:@"cut_o"];
    }
    else if ([preferredLang rangeOfString:@"ko"].length) {
        _promaptImage.image = [UIImage imageNamed:@"cut_n"];
    }
    else if ([preferredLang rangeOfString:@"de"].length) {
        _promaptImage.image = [UIImage imageNamed:@"cut_i"];
    }
    else if ([preferredLang rangeOfString:@"fr"].length) {
        _promaptImage.image = [UIImage imageNamed:@"cut_f"];
    }
    else if ([preferredLang rangeOfString:@"es"].length) {
        _promaptImage.image = [UIImage imageNamed:@"cut_e"];
    }
    else if ([preferredLang rangeOfString:@"pt"].length) {
        _promaptImage.image = [UIImage imageNamed:@"cut_h"];
    }
    else if ([preferredLang rangeOfString:@"it"].length) {
        _promaptImage.image = [UIImage imageNamed:@"cut_d"];
    }
    else if ([preferredLang rangeOfString:@"ar"].length) {
        _promaptImage.image = [UIImage imageNamed:@"cut_c"];
    }
    else if ([preferredLang rangeOfString:@"ru"].length) {
        _promaptImage.image = [UIImage imageNamed:@"cut_a"];
    }
    else if ([preferredLang rangeOfString:@"hu"].length) {
        _promaptImage.image = [UIImage imageNamed:@"cut_b"];
    }
    else {
        _promaptImage.image = [UIImage imageNamed:@"cut_p"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
    self.scanMaskSize = CGSizeMake(240, 200);
    _cameraOverlayView.scanMaskSize = _scanMaskSize;
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _is_wifiConfig = 0;

    if ([self checkOpenCameraOrNot]) {
        [self setupCamera];
        [self.cameraOverlayView startAnimate];
    } else {
        self.cameraOverlayView.hidden = YES;
        if (!self.app.is_vimtag) {
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString *appName = [infoDict objectForKey:@"CFBundleDisplayName"];
            NSString *title = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"mcs_please_allow", nil), appName, NSLocalizedString(@"mcs_access_camera", nil)];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:[NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"mcs_ios_privacy_setting_for_camera_prompt", nil),appName, NSLocalizedString(@"mcs_execute_change", nil)]
                                                           delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil)
                                                  otherButtonTitles: nil];
            [alert show];
            
        } else {
            [self.promaptView setHidden:NO];
        }
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.cameraOverlayView stopAnimate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _captureVideoPreviewLayer.frame = self.view.frame;
}

#pragma mark - Rotate
-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //    return UIInterfaceOrientationMaskPortrait;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([[_captureVideoPreviewLayer connection] isVideoOrientationSupported])
        {
            [[_captureVideoPreviewLayer connection] setVideoOrientation:(AVCaptureVideoOrientation)[UIApplication sharedApplication].statusBarOrientation];
        }
        return UIInterfaceOrientationMaskAllButUpsideDown;
        
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [UIApplication sharedApplication].statusBarOrientation;
    }
    else
    {
        return UIInterfaceOrientationPortrait;
    }
    
}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    if (_loginViewController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)manual:(id)sender
{
    if (_loginViewController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [self performSegueWithIdentifier:@"MNAddDeviceViewController" sender:nil];
    }
}

- (void)setupCamera
{
    _is_scanSucess = NO;

#if !TARGET_IPHONE_SIMULATOR
    CGRect cropRect = CGRectMake(self.view.center.x - _scanMaskSize.width / 2,
                                 self.view.center.y - _scanMaskSize.height / 2,
                                 _scanMaskSize.width,
                                 _scanMaskSize.height);

    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        self.readerView = [ZBarReaderView new];
        _readerView.frame = self.view.bounds;
        _readerView.torchMode = 0;
        _readerView.tracksSymbols = NO;
        _readerView.readerDelegate = self;
        _readerView.allowsPinchZoom = NO;
        
        float factor,scale;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            factor = 0.60;
        }
        else
        {
            factor = 0.45;
        }
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        scale = CGRectGetWidth(screenRect) / CGRectGetHeight(screenRect) * factor;
        _readerView.scanCrop = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? CGRectMake(0, 0, 1, 1) : CGRectMake((1 - scale) / 2, (1 - scale) / 2,  scale, scale);
        
//        [self.view insertSubview:_readerView atIndex:0];
        [self.view insertSubview:_readerView belowSubview:_cameraOverlayView];
        [_readerView start];
        
    }
    else
    {
        // Device
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // Input
        _captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:nil];
        // Output
        _captureMetadataOutput = [[AVCaptureMetadataOutput alloc]init];
        [_captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [_captureMetadataOutput setRectOfInterest:[self transformCropRect:cropRect]];
        
        // Session
        _captureSession = [[AVCaptureSession alloc]init];
        [_captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
        
        if ([_captureSession canAddInput:_captureDeviceInput])
        {
            
            [_captureSession addInput:_captureDeviceInput];
        }
        
        if ([_captureSession canAddOutput:_captureMetadataOutput])
        {
            
            [_captureSession addOutput:_captureMetadataOutput];
        }
        
        //
//        _captureMetadataOutput.metadataObjectTypes = [NSArray arrayWithObject:AVMetadataObjectTypeQRCode];
        if ([_captureMetadataOutput.availableMetadataObjectTypes containsObject:
             AVMetadataObjectTypeQRCode])
        {
            _captureMetadataOutput.metadataObjectTypes = [NSArray arrayWithObject:AVMetadataObjectTypeQRCode];
            CGRect bounds = self.view.bounds;
            
            // Preview
            _captureVideoPreviewLayer =[AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
            _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            _captureVideoPreviewLayer.frame = CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
            //        [self.view.layer insertSublayer:_captureVideoPreviewLayer atIndex:0];
            [self.view.layer insertSublayer:_captureVideoPreviewLayer below:_cameraOverlayView.layer];
            
            // Start
            [_captureSession startRunning];
            
        } else {
            self.readerView = [ZBarReaderView new];
            _readerView.frame = self.view.bounds;
            _readerView.torchMode = 0;
            _readerView.tracksSymbols = NO;
            _readerView.readerDelegate = self;
            _readerView.allowsPinchZoom = NO;
            
            float factor,scale;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                factor = 0.60;
            }
            else
            {
                factor = 0.45;
            }
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            scale = CGRectGetWidth(screenRect) / CGRectGetHeight(screenRect) * factor;
            _readerView.scanCrop = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? CGRectMake(0, 0, 1, 1) : CGRectMake((1 - scale) / 2, (1 - scale) / 2,  scale, scale);
            
            //        [self.view insertSubview:_readerView atIndex:0];
            [self.view insertSubview:_readerView belowSubview:_cameraOverlayView];
            [_readerView start];
        }
    }
    
#endif
}

- (void)jumpHelp
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://pyleaudio.helpshift.com/a/serene-life/?s=setup-instructions-and-troubleshooting&f=qsg---setting-up-your-camera-with-the-mobile-app"]];
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    if (!_is_scanSucess) {
        if ([metadataObjects count] >0)
        {
            AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
            NSString *strValue = metadataObject.stringValue;
            
            [self sendQRCode:strValue];
            _is_scanSucess = YES;
        }
        
        [_captureSession stopRunning];
    }
}

- (CGRect)transformCropRect:(CGRect)cropRect
{
    CGSize size = self.view.bounds.size;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920.0/1080.0;  //Using the 1080p image output
    

    if (p1 < p2) {
        CGFloat fixHeight = self.view.bounds.size.width * 1920.0 / 1080.0;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        return CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                          cropRect.origin.x/size.width,
                          cropRect.size.height/fixHeight,
                          cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = self.view.bounds.size.height * 1080.0 / 1920.0;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        return CGRectMake(cropRect.origin.y/size.height,
                          (cropRect.origin.x + fixPadding)/fixWidth,
                          cropRect.size.height/size.height,
                          cropRect.size.width/fixWidth);
    }
}

- (void)sendQRCode:(NSString *)strValue
{
   
    struct len_str  sID = {0}, sPassword = {0}, sPasswordMD5 = {0}, sWifi = {0},
    sResult = {strValue.length, (char*)[strValue UTF8String]};
    
    if((0 == MIPC_ParseLineParams(&sResult, &sID, &sPassword, &sPasswordMD5, &sWifi))
       && sID.len)
    {
        if (_loginViewController) {
            _loginViewController.txtUser.text = [[NSString stringWithFormat:@"%*.*s", 0, (int)sID.len, sID.data] lowercaseString];
            _loginViewController.txtPassword.text = [NSString stringWithFormat:@"%*.*s", 0, (int)sPassword.len, sPassword.data];
            NSString *wifi = [NSString stringWithFormat:@"%*.*s", 0,(int)sWifi.len, sWifi.data];
            _is_wifiConfig = 0;
            if (![wifi isEqualToString:@"(null)"])
            {
                _is_wifiConfig = 1;
            }
            _loginViewController.is_wifiConfig = _is_wifiConfig;
//            unsigned char    encrypt_pwd[16] = {0};
//            
//            [mipc_agent passwd_encrypt:_loginViewController.txtPassword.text encrypt_pwd:encrypt_pwd];
//            struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
//            
//            if(conf)
//            {
//                conf_new        = *conf;
//            }
//            conf_new.password_md5.data = (char*)encrypt_pwd;
//            conf_new.password_md5.len = 16;
//            MIPC_ConfigSave(&conf_new);
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else if (_storageDeviceViewController){
             _storageDeviceViewController.deviceIDTextField.text = [[NSString stringWithFormat:@"%*.*s", 0, (int)sID.len, sID.data] lowercaseString];
            _storageDeviceViewController.passwordTextField.text = [NSString stringWithFormat:@"%*.*s", 0, (int)sPassword.len, sPassword.data];
            _storageDeviceViewController.isViewAppearing = YES;
             [self dismissViewControllerAnimated:YES completion:nil];
        } else{
            _deviceID = [[NSString stringWithFormat:@"%*.*s", 0, (int)sID.len, sID.data] lowercaseString];
            _password = [NSString stringWithFormat:@"%*.*s", 0, (int)sPassword.len, sPassword.data];
            NSString *wifi = [NSString stringWithFormat:@"%*.*s", 0,(int)sWifi.len, sWifi.data];
            _is_wifiConfig = 0;
            if (![wifi isEqualToString:@"(null)"])
            {
                _is_wifiConfig = 1;
            }
            if (self.app.is_luxcam && _addDeviceViewController) {
                _addDeviceViewController.nameTextField.text = _deviceID;
                _addDeviceViewController.passwordTextField.text = _password;
                [[self navigationController] popViewControllerAnimated:YES];
            }
            else
            {
                self.is_scan = YES;
                [self performSegueWithIdentifier:@"MNAddDeviceViewController" sender:nil];
            }
        }
    }

}

#pragma mark -

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image{
    const zbar_symbol_t *symbol = zbar_symbol_set_first_symbol(symbols.zbarSymbolSet);
    NSString *strValue = [NSString stringWithUTF8String: zbar_symbol_get_data(symbol)];
    
    [self sendQRCode:strValue];
    
    [self.readerView stop];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNAddDeviceViewController"]) {
        MNAddDeviceViewController *addDeviceViewController = segue.destinationViewController;
        addDeviceViewController.deviceID = _deviceID;
        addDeviceViewController.devicePassword = _password;
        addDeviceViewController.is_scan = _is_scan;
        addDeviceViewController.is_wifiConfig = _is_wifiConfig;
    }
}


@end
