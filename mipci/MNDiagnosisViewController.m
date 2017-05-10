//
//  MNDiagnosisViewController.m
//  mipci
//
//  Created by mining on 16/7/28.
//
//

#import "MNDiagnosisViewController.h"
#import "MNDiagnosisingViewController.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"
#import "MNProgressHUD.h"
#import "MNInfoPromptView.h"

@interface MNDiagnosisViewController () <UITextFieldDelegate>
{
    long                                _isSelfOrginFrameActive;
    CGRect                              _selfOrginFrame;
}
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) MNConfiguration *configration;
@property( strong, nonatomic) MNProgressHUD *progressHUD;

@property (strong, nonatomic) NSArray *buttonArray;
@property (strong, nonatomic) NSString *diagnosisProblem;

@end

@implementation MNDiagnosisViewController

- (MNProgressHUD *)progressHUD
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

- (MNConfiguration *)configration
{
    if (!_configration) {
        _configration = [MNConfiguration shared_configuration];
    }
    return _configration;
}

- (AppDelegate *)app
{
    if (!_app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

- (mipc_agent *)agent
{
    return self.app.cloudAgent;
}

#pragma mark - Life Cycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.hidesBottomBarWhenPushed = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_fault_diagnosis", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"item_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];

    _problemView.layer.borderWidth = 1;
    _problemView.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.8].CGColor;
    _problemView.layer.cornerRadius = 6.0f;
    _unablePlayView.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.8].CGColor;
    _unablePlayView.layer.borderWidth = 1;
    _diagnosisButton.layer.cornerRadius = 4.0f;
    
    _diagnosisTitleLabel.text = NSLocalizedString(@"mcs_sever_diagnosis", nil);
    _selectProblemLabel.text = NSLocalizedString(@"mcs_select_problem", nil);
    _unableLoginLabel.text = NSLocalizedString(@"mcs_connot_lonin", nil);
    _unablePlayLabel.text = NSLocalizedString(@"mcs_connot_play", nil);
    _otherLabel.text = NSLocalizedString(@"mcs_others", nil);
    _otherProblemTitle.text = NSLocalizedString(@"mcs_add_problems", nil);
    _otherProblemText.placeholder = NSLocalizedString(@"mcs_encounterer_problems", nil);
    [_diagnosisButton setTitle:NSLocalizedString(@"mcs_diagnostic_network", nil) forState:UIControlStateNormal];
    _diagnosisLabel.text = NSLocalizedString(@"mcs_network_diagnostic_prompt", nil);
    
    [_unableLoginButton setImage:[UIImage imageNamed:@"vt_check"] forState:UIControlStateSelected];
    [_unableLoginButton setImage:[UIImage imageNamed:@"vt_uncheck"] forState:UIControlStateNormal];
    [_unableLoginButton addTarget:self action:@selector(changeSelectStatus:) forControlEvents:UIControlEventTouchUpInside];
    _unableLoginButton.selected = NO;
    
    [_unablePlayButton setImage:[UIImage imageNamed:@"vt_check"] forState:UIControlStateSelected];
    [_unablePlayButton setImage:[UIImage imageNamed:@"vt_uncheck"] forState:UIControlStateNormal];
    [_unablePlayButton addTarget:self action:@selector(changeSelectStatus:) forControlEvents:UIControlEventTouchUpInside];
    _unablePlayButton.selected = NO;
    
    [_otherButton setImage:[UIImage imageNamed:@"vt_check"] forState:UIControlStateSelected];
    [_otherButton setImage:[UIImage imageNamed:@"vt_uncheck"] forState:UIControlStateNormal];
    [_otherButton addTarget:self action:@selector(changeSelectStatus:) forControlEvents:UIControlEventTouchUpInside];
    _otherButton.selected = NO;
    
    _otherProblemView.hidden = YES;
    _otherProblemText.delegate = self;
    _otherProblemText.returnKeyType = UIReturnKeyDone;
    
    [_diagnosisButton addTarget:self action:@selector(diagnosising) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    
    _buttonArray = @[_unableLoginButton,_unablePlayButton,_otherButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MNInfoPromptView hideAll:self.navigationController];
}

#pragma mark - Action
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changeSelectStatus:(UIButton *)button
{
    for (UIButton *buttonObj in _buttonArray) {
        if (buttonObj != button) {
            buttonObj.selected = NO;
        } else {
            buttonObj.selected = !buttonObj.selected;
        }
    }
    
    _otherProblemView.hidden = !_otherButton.selected;
    
    if (!_otherButton.isSelected) {
        [_otherProblemText resignFirstResponder];
    }
}

- (void)diagnosising
{
    long selectFlag = 0;
    NSUInteger index = 0;
    for (UIButton *buttonObj in _buttonArray) {
        if (buttonObj.selected) {
            index = [_buttonArray indexOfObject:buttonObj];
            selectFlag = 1;
            break;
        }
    }
    
    if (selectFlag)
    {
        if (index == _buttonArray.count - 1 && !(_otherProblemText.text.length))
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_encounterer_problems", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];

            return;
        }
        [self performSegueWithIdentifier:@"MNDiagnosisingViewController" sender:nil];
    }
    else
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_diagnosis_type_select_prompt", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNDiagnosisingViewController"]) {
        MNDiagnosisingViewController *diagnosisingViewController = segue.destinationViewController;
        NSUInteger index = 0;
        for (UIButton *buttonObj in _buttonArray) {
            if (buttonObj.selected == YES) {
                index = [_buttonArray indexOfObject:buttonObj];
                self.diagnosisProblem = (index == 0 ?_unableLoginLabel.text : (index ==1 ? _unablePlayLabel.text : _otherProblemText.text));
                
                break;
            }
        }
        diagnosisingViewController.typeIndex = index;
        diagnosisingViewController.diagnosisProblem = self.diagnosisProblem;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_otherProblemText resignFirstResponder];
    return YES;
}

#pragma mark - Keyboard
-(void)keyboardWillShow:(NSNotification *)notification
{
    if (self.view.frame.size.height > 600) {
        return;
    }
    
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardBounds;
    [keyboardBoundsValue getValue:&keyboardBounds];
    
    CGRect  newFrame, selfFrame = self.view.frame;
    if([notification.name isEqualToString:@"UIKeyboardWillHideNotification"])
    {
        newFrame = _selfOrginFrame;
        _isSelfOrginFrameActive = 0;
    }
    else
    {
        UIView  *checkView = _otherProblemText;
        
        CGRect  appRect = [[UIScreen mainScreen] applicationFrame];
        int app_width = appRect.size.width,
        app_height = appRect.size.height,
        offsetx = checkView.frame.origin.x + checkView.frame.size.width,
        offsety = checkView.frame.origin.y + checkView.frame.size.height;
        
        checkView = checkView.superview;
        while(checkView && (checkView != self.view))
        {
            offsety += checkView.frame.origin.y;
            offsetx += checkView.frame.origin.x;
            checkView = checkView.superview;
        }
        
        
        if(0 == _isSelfOrginFrameActive)
        {
            _selfOrginFrame = selfFrame;
            _isSelfOrginFrameActive = 1;
        }
        newFrame = selfFrame;
        
        
        switch(self.interfaceOrientation)
        {
            case UIInterfaceOrientationLandscapeLeft:
            {
                newFrame.origin.x = (app_width - offsety) - keyboardBounds.size.width - 10;
                break;
            }
            case UIInterfaceOrientationLandscapeRight:
            {
                newFrame.origin.x = keyboardBounds.size.width - (app_width - offsety) + 30;
                break;
            }
            default /* case UIInterfaceOrientationPortrait */:
            {
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                    newFrame.origin.y = (app_height - offsety) - keyboardBounds.size.height + 15;
                break;
            }
        }
    }
    
    //  NSLog(@"offset is %f %f", newFrame.origin.x, newFrame.origin.y);
    [UIView beginAnimations:@"anim" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    //Handle the mobile event, and set the final state of the view to reach
    
    self.view.frame = newFrame;
    
    [UIView commitAnimations];
}

#pragma mark - Rotate
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

@end
