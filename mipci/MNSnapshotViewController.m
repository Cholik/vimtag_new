//
//  SnapshotViewController.m
//  mipci
//
//  Created by mining on 13-11-25.
//
//

#import "MNSnapshotViewController.h"
#import "UIImageView+MNNetworking.h"
#import "MNCache.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNInfoPromptView.h"
#import "MNToastView.h"

@implementation MNPhotoScrollView
@synthesize photo        = _photo;
@synthesize photoView    = _photoView;
@synthesize indicatorView = _indicatorView;


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.decelerationRate = 0;
        self.delegate = self;
        self.bounces = YES;
        self.bouncesZoom = YES;
        self.contentMode = UIViewContentModeRedraw;
        [self setMinimumZoomScale:1.0];
        [self setMaximumZoomScale:4.0];
        self.contentSize = CGSizeMake(frame.size.width, frame.size.height);
        
        _photo = [[UIImageView alloc] init];
        _photo.layer.borderWidth = 0.5;
        _photo.layer.borderColor = [UIColor grayColor].CGColor;
        _photo.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_photo];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.frame = CGRectMake(CGRectGetWidth(_photo.frame)*.5f-20.f, CGRectGetHeight(_photo.frame)/2-20.f, 40.f, 40.f);
        _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin   |
        UIViewAutoresizingFlexibleBottomMargin;
        _indicatorView.hidesWhenStopped = YES;
        [_photo addSubview:_indicatorView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.zoomScale == 1.f)
    {
        CGFloat width = CGRectGetWidth(self.frame),
        height = width/16.f*9.f;
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
            self.contentOffset = CGPointMake(0, 0);
        _photo.frame = CGRectMake(0, (CGRectGetHeight(self.frame)-height)*.5f, width, height);
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _photo;
}

- (void)reSetPhotoFrameWhenRotate
{
    if (self.zoomScale > 1.f)
    {
        CGFloat width = CGRectGetWidth(self.frame),
        height = width/16.f*9.f;
        _photo.frame = CGRectMake(0, (CGRectGetHeight(self.frame)-height)*.5f, width, height);
        _isZoomed = NO;
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _photo.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                scrollView.contentSize.height * 0.5 + offsetY);
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if( self.zoomScale == self.minimumZoomScale )
    {
        _isZoomed = NO;
    }
	else
    {
        _isZoomed = YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:_photoView];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1)
    {
        [_photoView performSelector:@selector(singleTapView) withObject:nil afterDelay:.3f];
    }
    
   	if (touch.tapCount == 2 && !_indicatorView.isAnimating)
    {
   		if( _isZoomed )
   		{
   			_isZoomed = NO;
   			[self setZoomScale:self.minimumZoomScale animated:YES];
   		}
   		else
        {
   			_isZoomed = YES;
            
   			// define a rect to zoom to.
   			CGPoint touchCenter = [touch locationInView:self];
   			CGSize zoomRectSize = CGSizeMake(self.frame.size.width / self.maximumZoomScale, self.frame.size.height / self.maximumZoomScale );
   			CGRect zoomRect = CGRectMake( touchCenter.x - zoomRectSize.width * .5, touchCenter.y - zoomRectSize.height * .5, zoomRectSize.width, zoomRectSize.height );
            
   			// correct too far left
   			if( zoomRect.origin.x < 0 )
   				zoomRect = CGRectMake(0, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
            
   			// correct too far up
   			if( zoomRect.origin.y < 0 )
   				zoomRect = CGRectMake(zoomRect.origin.x, 0, zoomRect.size.width, zoomRect.size.height );
            
   			// correct too far right
   			if( zoomRect.origin.x + zoomRect.size.width > self.frame.size.width )
   				zoomRect = CGRectMake(self.frame.size.width - zoomRect.size.width, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
            
   			// correct too far down
   			if( zoomRect.origin.y + zoomRect.size.height > self.frame.size.height )
   				zoomRect = CGRectMake( zoomRect.origin.x, self.frame.size.height - zoomRect.size.height, zoomRect.size.width, zoomRect.size.height );
            
   			// zoom to it.
   			[self zoomToRect:zoomRect animated:YES];
   		}
   	}
}
@end



//---------------------------------------------------------------------------------------------------------------
@interface MNSnapshotViewController ()
{
    BOOL                       is7,active,isBigImg,isHidden;
}

@property (assign, nonatomic) BOOL isViewAppearing;
@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNSnapshotViewController

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return  _app;
}

-(void)dealloc
{
    [self.scrollView.photo cancelImageRequestOperation];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    _scrollView = [[MNPhotoScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _scrollView.photoView = self;
    
    [self.view addSubview:_scrollView];
    
    isHidden = YES;
    active = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareSnapshot)];
    
    is7 = ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.f)?YES:NO;

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isViewAppearing = YES;
    
//    UIImage *placeholderImage;
  
    if(_snapshotImage)
    {
        _scrollView.photo.image = _snapshotImage;
        
        if (_token) {
            NSString *imagePath = [self localMessageSnapshotPathByMsgSn:_boxID withMsgImgToken:_token];
            UIImage *image = nil;
            if(imagePath)
            {
                image = [UIImage imageWithContentsOfFile:imagePath];
            }

            if (image) {
                __strong __typeof(self)strongSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    strongSelf.scrollView.photo.image = image;
                });
            }
            else
            {
                mcall_ctx_pic_get *ctx = [[mcall_ctx_pic_get alloc] init];
                ctx.sn = _boxID;
                ctx.token = _token;
                ctx.type = mdev_pic_seg_album;
                ctx.flag = 1;
                
                UIImage *placeholderImage;
                placeholderImage = _snapshotImage;
                
                NSURL *downloadImageURL = [NSURL URLWithString:[self.agent pic_url_create:ctx]];
                __block typeof(self) weakSelf = self;
                [self.scrollView.photo setImageWithURLRequest:[NSURLRequest requestWithURL:downloadImageURL]            placeholderImage:placeholderImage token:_token deviceID:_snapshotID flag:1                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image, NSString *deviceID, NSString *token) {
                    
                    if (token == self.token && image) {
                        __strong typeof (self) strongSelf = weakSelf;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            strongSelf.scrollView.photo.image = image;
                            [strongSelf.scrollView.photo setAlpha:0.5];
                            [UIView animateWithDuration:0.3 animations:^{
                                [strongSelf.scrollView.photo setAlpha:1.0];
                            }];
                        });
                        NSString *imagePath = [weakSelf localMessageSnapshotPathByMsgSn:ctx.sn  withMsgImgToken:ctx.token];
                        if (image && imagePath) {
                            [[[MNCache class] mn_sharedCache] setObject:image forKey:imagePath];
                        }
                        [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath atomically:YES];
                    }
                    
                }
                                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                          NSLog(@"err[%@]", [error localizedDescription]);
                                                      }];
            }
        }
    }
    else
    {
        if (self.app.is_vimtag)
        {
            _scrollView.photo.image = [UIImage imageNamed:@"vt_cellBg.png"];
            
        }
        else if (self.app.is_ebitcam)
        {
            _scrollView.photo.image = [UIImage imageNamed:@"eb_cellBg.png"];
        }
        else if (self.app.is_mipc)
        {
            _scrollView.photo.image = [UIImage imageNamed:@"mi_cellBg.png"];
        }
        else
        {
            _scrollView.photo.image = [UIImage imageNamed:self.app.is_luxcam ? @"placeholder.png" : @"camera_placeholder.png"];
        }
    }
    if (_msg) {
     
        NSString *imagePath = [self localMessageSnapshotPathByMsgSn:_msg.sn withMsgImgToken:_msg.img_token];
        UIImage *image = [[[MNCache class] mn_sharedCache] objectForKey:imagePath];
        if(!image)
        {
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
        
        if (image) {
            __strong __typeof(self)strongSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.scrollView.photo.image = image;
            });
        }
        else
        {
            isBigImg = YES;
            
            [_scrollView.indicatorView startAnimating];
            
            mcall_ctx_pic_get *ctx = [[mcall_ctx_pic_get alloc] init];
            ctx.sn = _msg.sn;
            ctx.type = mdev_pic_album;
            ctx.token = _msg.img_token;
//            ctx.target = self;
//            ctx.on_event = @selector(pic_get_done:);
         
            NSURL *downloadImageURL = [NSURL URLWithString:[self.agent pic_url_create:ctx]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadImageURL];
            [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            
            m_dev *dev = [self.agent.devs get_dev_by_sn:ctx.sn];
            __block typeof(self) weakSelf = self;
            [_scrollView.photo setImageWithURLRequest:request placeholderImage:nil token:ctx.token deviceID:ctx.sn flag:dev.spv success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image, NSString *deviceID, NSString *token) {
                
                __strong typeof (self) strongSelf = weakSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    strongSelf.scrollView.photo.image = image;
                    [strongSelf.scrollView.indicatorView stopAnimating];
                    });
                NSString *imagePath = [weakSelf localMessageSnapshotPathByMsgSn:ctx.sn  withMsgImgToken:ctx.token];
                if (image && imagePath) {
                    [[[MNCache class] mn_sharedCache] setObject:image forKey:imagePath];
                }
                [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath atomically:YES];
                
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                NSLog(@"err[%@]", [error localizedDescription]);
            }];
//
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    if (self.app.is_InfoPrompt) {
        [MNInfoPromptView hideAll:self.navigationController];
    }
}

#pragma mark - pic_get_done
- (void)pic_get_done:(mcall_ret_pic_get *)ret
{
    [_scrollView.indicatorView stopAnimating];
    
    if (!_isViewAppearing)
    {
        return;
    }
    
    if(ret && nil == ret.result && ret.img)
    {
        _scrollView.photo.image = ret.img;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
                          stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",_msg.sn]];
        if ([fileManager fileExistsAtPath:path] || [self createDirectoryByPath:path])
        {
            NSString *imagePath = [path
                                   stringByAppendingPathComponent:[NSString  stringWithFormat:@"%@.jpg",_msg.img_token]];
            [UIImageJPEGRepresentation(ret.img, 1.0) writeToFile:imagePath atomically:YES];
        }
    }

}

#pragma mark -
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)singleTapView
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    if(!isHidden)
    {
        //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        if(is7)
        {
            [UIView beginAnimations:@"1" context:NULL];
            [UIView setAnimationDuration:0.35];
            self.navigationController.navigationBar.alpha=1.f;
            [UIView commitAnimations];
        }
        else
        {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    }
    else
    {
        if(is7)
        {
            // [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [UIView beginAnimations:@"1" context:NULL];
            [UIView setAnimationDuration:0.35];
            self.navigationController.navigationBar.alpha=0.f;
            [UIView commitAnimations];
        }
        else
        {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
    }
    isHidden = !isHidden;
    [_scrollView sizeToFit];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)shareSnapshot
{
    if(self.scrollView.photo.image)
    {
        NSDate* now = [NSDate date];
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit;
        NSDateComponents *dd = [cal components:unitFlags fromDate:now];
        int y = (int)[dd year];
        int m = (int)[dd month];
        int d = (int)[dd day];
        
        int hour = (int)[dd hour];
        int min = (int)[dd minute];
        int sec = (int)[dd second];
        
        NSString *time = [NSString stringWithFormat:@"%02d-%02d-%02d %02d:%02d:%02d",y,m,d,hour,min,sec];
        if (nil == [UIActivityViewController class])
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"mcs_save", nil),@"E-mail", nil];
            [sheet showInView:self.tabBarController.view];
        }
        else
        {
            UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.snapshotID,time,_scrollView.photo.image] applicationActivities:nil];
            activityController.completionHandler = ^(NSString *activityType, BOOL completed){
                if (completed) {
                    if (self.app.is_InfoPrompt) {
                        
                        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_saved_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
                    }
                    else{
                        [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_saved_successfully", nil)]];
                    }
                }
            };
            if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.f)
                activityController.excludedActivityTypes = @[UIActivityTypeMessage];
            
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                //                UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
                UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
                //                popoverController.popoverContentSize = CGSizeMake(320, 480);
                //                [popoverController setPopoverContentSize:CGSizeMake(320, 480) animated:YES];
                
                float width = CGRectGetWidth(self.view.bounds);
                [popoverController presentPopoverFromRect:CGRectMake(width - 60, -150 , 200, 200) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
                
            }
            else
            {
                [self presentViewController:activityController  animated:YES completion:nil];
            }
        }

    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            UIImageWriteToSavedPhotosAlbum(self.scrollView.photo.image, self, @selector(savePhotoDone:didFinishSavingWithError:contextInfo:),nil);
            break;
        case 1:
            if([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                picker.mailComposeDelegate = self;
                [picker setSubject:@"Snapshot"];
                NSData *imgData = UIImageJPEGRepresentation(self.scrollView.photo.image, 0);
                [picker addAttachmentData:imgData mimeType:@"jpg" fileName:@"photo.jpg"];
                [picker setMessageBody:_snapshotID isHTML:NO];
//                [self presentModalViewController:picker animated:YES];
                [self presentViewController:picker animated:YES completion:nil];
            }
            break;
        default:
            break;
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            //FIXME:NSLocalizedString(@"mcs_fail", nil)
            break;
        default:
            break;
    }
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)savePhotoDone:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        NSString  *msg, *title;
        if (-3310 == (int)error.code)
        {
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString *appName = [infoDict objectForKey:@"CFBundleDisplayName"];
            title = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"mcs_please_allow", nil), appName, NSLocalizedString(@"mcs_access_album", nil)];
//            title = NSLocalizedString(@"mcs_please_allow_access_album",nil);
            msg = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"mcs_ios_privacy_setting_for_photo_prompt",nil), appName, NSLocalizedString(@"mcs_execute_change",nil)] ;
        }
        else if (-3301 == (int)error.code)
        {
            title = NSLocalizedString(@"mcs_save_failed",nil);
            msg = NSLocalizedString(@"mcs_busy_when_write",nil);
        }
        else
        {
            title = NSLocalizedString(@"mcs_save_failed",nil);
            msg = [NSString stringWithFormat:@"%@",error];
        }
        [self pictureFailedAlertView:title msg:msg];
        
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_save_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else{
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_save_failed", nil)]];
        }
    }
    else
    {
        if (self.app.is_InfoPrompt) {
            
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_saved_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
        }
        else{
            [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_saved_successfully", nil)]];
        }

        
        //FIXME:[self.view addSubview:[xToastView successToast:NSLocalizedString(@"mcs_saved_successfully",nil)]];
    }
}

- (void)pictureFailedAlertView:(NSString*)title msg:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_i_know",nil) otherButtonTitles:nil];
    [alert show];
}

//---------------------------------------------snapshot-----------------------------

- (UIImage*)findLocalImg:(NSString*)token
{
    NSString *imagePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
                           stringByAppendingPathComponent:[NSString  stringWithFormat:@"%@/%@.jpg", _msg.sn, token]];
    return [UIImage imageWithContentsOfFile:imagePath];
}

- (BOOL)createDirectoryByPath:(NSString *)file
{
    return [[NSFileManager defaultManager] createDirectoryAtPath:file withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_scrollView reSetPhotoFrameWhenRotate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
}

#pragma mark -Local messageSnapshot
- (NSString *)localMessageSnapshotPathByMsgSn:(NSString *)msg_sn withMsgImgToken:(NSString *)msg_imgtoken
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *messageSnapshotPath = [[path stringByAppendingPathComponent:@"photos/messageSnapshot"] stringByAppendingPathComponent:msg_sn];
    NSString *imagePath = [messageSnapshotPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", msg_imgtoken]];

    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager]
         createDirectoryAtPath:messageSnapshotPath withIntermediateDirectories:YES attributes:nil
                                   error:&error];
        if (error) {
            NSLog(@"errer:%@", [error localizedDescription]);
        }
        return nil;
    }
    
    return imagePath;
}
@end
