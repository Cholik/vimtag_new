//
//  MNDeviceScheduleViewController.m
//  mipci
//
//  Created by mining on 16/4/15.
//
//

#define DEFAULT_CELL_MARGIN         1
#define WEEK_DAY_COUNT              7
#define ONE_DAY_NUMBER              24
#define DEFAULTLINEWIDTH            0.5

#define ACTIVECOLOR                 [UIColor colorWithRed:255/255.0 green:128/255.0 blue:132/255.0 alpha:1.0]
#define AWAYCOLOR                   [UIColor colorWithRed:92/255.0 green:200/255.0 blue:154/255.0 alpha:1.0]
#define LINECOLOR                   [UIColor grayColor]
#define SCHEDULECOLOR               [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]
#define CELL_SELECT_COLOR           [UIColor colorWithRed:200./255. green:200./255. blue:200./255. alpha:0.5]
#define SCHEDULE_PROMPT_WIDTH           120
#define SCHEDULE_PROMPT_HEIGHT          66

#define SCHEDULE_ACTIVE                 2001
#define SCHEDULE_AWAY                   2002


#import "MNDeviceScheduleViewController.h"
#import "MNScheduleViewCell.h"
#import "MNInfoPromptView.h"
#import "MNScheduleTipsView.h"

@interface MNSchedulePromptView : UIView

@property (strong, nonatomic) UIImageView *backgroundImage;
@property (strong, nonatomic) UILabel *weekLabel;
@property (strong, nonatomic) UILabel *timeLabel;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)setScheduleWeek:(NSString*)week Time:(NSString*)time;

@end

@implementation MNSchedulePromptView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    
    return self;
}

- (void)initUI
{
    self.backgroundColor = [UIColor clearColor];
    _backgroundImage = [[UIImageView alloc] initWithFrame:self.frame];
    _backgroundImage.image = [UIImage imageNamed:@"vt_schedule_background.png"];
    
    _weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 10, SCHEDULE_PROMPT_WIDTH - 13, 30)];
    _weekLabel.textColor = [UIColor colorWithRed:100./255. green:100./255. blue:100./255. alpha:1.0];
    _weekLabel.font = [UIFont systemFontOfSize:12.0];
    _weekLabel.textAlignment = NSTextAlignmentLeft;
    _weekLabel.numberOfLines = 0;
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 37, SCHEDULE_PROMPT_WIDTH - 13, 20)];
    _timeLabel.textColor = [UIColor colorWithRed:100./255. green:100./255. blue:100./255. alpha:1.0];
    _timeLabel.font = [UIFont systemFontOfSize:11.0];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel.numberOfLines = 0;
    
    [self addSubview:_backgroundImage];
    [self addSubview:_weekLabel];
    [self addSubview:_timeLabel];
}

- (void)setScheduleWeek:(NSString*)week Time:(NSString*)time
{
    if (week.length) {
        _weekLabel.text = week;
    }
    if (time.length) {
        _timeLabel.text = time;
    }
}

@end

@implementation schedule_obj

@end

@interface MNDeviceScheduleViewController () 

@property (nonatomic,strong) mcall_ret_schedule_get *ret;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationViewConstraint;

@property (strong, nonatomic) NSArray *weekArray;

@property (strong, nonatomic) MNScheduleSceneSetView *scheduleSceneSetView;
@property (strong, nonatomic) MNSchedulePromptView *schedulePromptView;
@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) CGPoint endPoint;
@property (assign, nonatomic) int startPointY;
@property (assign, nonatomic) int currentPointY;
@property (assign, nonatomic) int startPointX;
@property (assign, nonatomic) int currentPointX;

@property (assign, nonatomic) BOOL is_showView;

@end

@implementation MNDeviceScheduleViewController

static NSString * const reuseIdentifier = @"Cell";

-(AppDelegate *)app
{
    if (_app == nil) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

-(NSMutableArray *)scheduleArray
{
    if (_scheduleArray == nil) {
        
        _scheduleArray = [NSMutableArray array];
        for (int i = 0; i < WEEK_DAY_COUNT*ONE_DAY_NUMBER; i++)
        {
            schedule_obj *obj = [[schedule_obj alloc] init];
            UIColor *defaultColor = [self getDefaultColor:i];
            obj.backgroundColor = defaultColor;
            [_scheduleArray addObject:obj];
        }
    }
    return _scheduleArray;
}

#pragma mark - Life Cycle
-(void)dealloc
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIDeviceOrientationDidChangeNotification
                                                      object:nil];
    }
}

-(void)initUI
{
    _transitionToSize = self.view.bounds.size;
    _is_showView = NO;
    
    self.titleLabel.text = NSLocalizedString(@"mcs_Sense_schedule", nil);
    [_clearButton setTitle:NSLocalizedString(@"mcs_reset", nil) forState:UIControlStateNormal];
    [_confirmButton setTitle:NSLocalizedString(@"mcs_save", nil) forState:UIControlStateNormal];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationController.navigationBarHidden = YES;
        self.navigationViewConstraint.constant = 64.0;
    }
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self.collectionView addGestureRecognizer:panGesture];
    panGesture.delegate = self;
    
    _schedulePromptView = [[MNSchedulePromptView alloc] initWithFrame:CGRectMake(0, 0, SCHEDULE_PROMPT_WIDTH, SCHEDULE_PROMPT_HEIGHT)];
    _schedulePromptView.hidden = YES;
    [self.collectionView addSubview:_schedulePromptView];
    
    _weekArray = [NSArray arrayWithObjects:NSLocalizedString(@"mcs_sun", nil) ,
                          NSLocalizedString(@"mcs_mon", nil),
                          NSLocalizedString(@"mcs_tue", nil),
                          NSLocalizedString(@"mcs_wed", nil),
                          NSLocalizedString(@"mcs_thu", nil),
                          NSLocalizedString(@"mcs_fri", nil),
                          NSLocalizedString(@"mcs_sat", nil),nil];
    
    _startPointX = -1;
    _startPointY = -1;
    _currentPointX = -1;
    _currentPointY = -1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loading:YES];
    _is_showView = YES;
    [self drawLineLayerForSchedule];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    if (self.app.is_firstScheduleLauch) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everScheduleLaunched"];
        self.app.is_firstScheduleLauch = NO;
        [self createTipsView];
    }
    
    mcall_ctx_schedule_get *ctx = [[mcall_ctx_schedule_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(schedule_get_done:);
    [_agent schedule_get:ctx];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _is_showView = NO;
    [MNInfoPromptView hideAll:_rootNavigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)refresh:(id)sender
{
    for (int i = 0 ; i < self.scheduleArray.count; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        MNScheduleViewCell *cell = (MNScheduleViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

        cell.numberLabel.backgroundColor = AWAYCOLOR;
        cell.numberLabel.textColor = [UIColor whiteColor];
        ((schedule_obj *)[_scheduleArray objectAtIndex:indexPath.row]).backgroundColor = cell.numberLabel.backgroundColor;
        
        int num = indexPath.row%ONE_DAY_NUMBER;
        if (num == 0)
        {
            [cell setLabelLayer:LAYER_STYLE_SEMICIRCLE_LEFT];
        }
        else if (num == 23)
        {
            [cell setLabelLayer:LAYER_STYLE_SEMICIRCLE_RIGHT];
        }
        else
        {
            [cell setLabelLayer:LAYER_STYLE_SQUARE];
        }
    }
}

- (IBAction)confirm:(id)sender
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0 ; i < self.scheduleArray.count; i ++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        MNScheduleViewCell *cell = (MNScheduleViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        if ([cell.numberLabel.backgroundColor isEqual:ACTIVECOLOR])
        {
            NSNumber *number = [NSNumber numberWithInt:1];
            [array addObject:number];
        }
        else
        {
            NSNumber *number = [NSNumber numberWithInt:0];
            [array addObject:number];
        }
    }
    
    mcall_ctx_schedule_set *ctx = [[mcall_ctx_schedule_set alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.array = array;
//    ctx.enable = 1;
    ctx.degree = 3600;
//    ctx.bit = 2;
    ctx.on_event = @selector(schedule_set_done:);
    [_agent schedule_set:ctx];
    [self loading:YES];
}

- (IBAction)tips:(id)sender
{
    [self createTipsView];
}

-(void)createTipsView
{
    MNScheduleTipsView *scheduleTipsView = [[[NSBundle mainBundle] loadNibNamed:@"MNScheduleTipsView" owner:self options:nil] lastObject];
    scheduleTipsView.frame = [UIScreen mainScreen].bounds;
    [self.app.window addSubview:scheduleTipsView];
}

#pragma mark - draw layer
-(void)drawLineLayerForSchedule
{
    float pointX = self.collectionView.frame.origin.x;
    float pointY = self.collectionView.frame.origin.y;
    float width = CGRectGetWidth(self.collectionView.frame);
    float height = CGRectGetHeight(self.collectionView.frame);
    
    for (int i = 0 ; i < WEEK_DAY_COUNT; i++)
    {
        //init week label
        UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, pointY + i*height/WEEK_DAY_COUNT, pointX, height/WEEK_DAY_COUNT)];
        weekLabel.text = _weekArray[i];
        weekLabel.backgroundColor = [self getDefaultColor:i *24];
        weekLabel.textColor = SCHEDULECOLOR;
        weekLabel.font = [UIFont systemFontOfSize:14];
        weekLabel.textAlignment = NSTextAlignmentCenter;
        [_mainView addSubview:weekLabel];
    }
    
    //draw Y
    for (int i = 0 ; i < ONE_DAY_NUMBER; i++)
    {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(pointX + i*width/ONE_DAY_NUMBER, 0, width/ONE_DAY_NUMBER, pointY)];
        timeLabel.text = [NSString stringWithFormat:@"%d",(i+1)];
        timeLabel.backgroundColor = [UIColor colorWithRed:235/255.0 green:241/255.0 blue:243/255.0 alpha:1.0];
        timeLabel.textColor = SCHEDULECOLOR;
        timeLabel.font = [UIFont systemFontOfSize:11];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        [_mainView addSubview:timeLabel];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pointX, pointY)];
    [self.mainView addSubview:view];
    view.backgroundColor = [UIColor colorWithRed:216/255.0 green:237/255.0 blue:244/255.0 alpha:1.0];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pointX-10,  pointY/2)];
    timeLabel.text = NSLocalizedString(@"mcs_time", nil);
    timeLabel.textColor = SCHEDULECOLOR;
    timeLabel.font = [UIFont systemFontOfSize:14];
    timeLabel.textAlignment = NSTextAlignmentRight;
    [_mainView addSubview:timeLabel];
    
    UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, pointY/2, pointX-10,  pointY/2)];
    weekLabel.text = NSLocalizedString(@"mcs_week", nil);
    weekLabel.textColor = SCHEDULECOLOR;
    weekLabel.font = [UIFont systemFontOfSize:14];
    weekLabel.textAlignment = NSTextAlignmentLeft;
    [_mainView addSubview:weekLabel];
}

- (void)panGesture:(UIPanGestureRecognizer *)gestureRecongnizer
{
    CGPoint currentPoint = [gestureRecongnizer locationInView:self.collectionView];
    _schedulePromptView.hidden = NO;
    
    if (gestureRecongnizer.state == UIGestureRecognizerStateBegan)
    {
        _startPoint = currentPoint;
    }
    else if (gestureRecongnizer.state == UIGestureRecognizerStateChanged)
    {
        CGRect constantRect = CGRectMake(_startPoint.x, _startPoint.y, currentPoint.x - _startPoint.x, currentPoint.y - _startPoint.y);
        
        for (int i = 0 ; i < self.scheduleArray.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            UIColor *defaultColor = [self getDefaultColor:indexPath.row];

            MNScheduleViewCell *cell = (MNScheduleViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            if (CGRectIntersectsRect(cell.frame, constantRect))
            {
                cell.numberLabel.backgroundColor = CELL_SELECT_COLOR;
                cell.numberLabel.textColor = [UIColor whiteColor];
            }
            else
            {
                cell.numberLabel.backgroundColor = ((schedule_obj *)[_scheduleArray objectAtIndex:indexPath.row]).backgroundColor;
                cell.numberLabel.textColor = ([cell.numberLabel.backgroundColor isEqual: defaultColor]) ? [UIColor lightGrayColor] : [UIColor whiteColor];
            }
        }
        
        CGFloat startY = (_startPoint.y/(CGRectGetHeight(self.collectionView.frame)))*WEEK_DAY_COUNT;
        CGFloat currentY = (currentPoint.y/(CGRectGetHeight(self.collectionView.frame)))*WEEK_DAY_COUNT;
        int i = startY < currentY ? (int)startY : (int)currentY;
        int count = startY < currentY ? (int)currentY : (int)startY;
        
        CGFloat startX = (_startPoint.x/(CGRectGetWidth(self.collectionView.frame)))*ONE_DAY_NUMBER;
        CGFloat currentX = (currentPoint.x/(CGRectGetWidth(self.collectionView.frame)))*ONE_DAY_NUMBER;
        int j = startX < currentX ? (int)startX : (int)currentX;
        int count_X = startX < currentX ? (int)currentX : (int)startX;
        
        if (i >=0 && (count < WEEK_DAY_COUNT)) {

            if (i != _startPointY || count != _currentPointY) {
                _startPointY = i;
                _currentPointY = count;
                NSString *weekString = [NSString string];
                for (; i <= count; i++) {
                    if (weekString.length) {
                        weekString = [weekString stringByAppendingString:@" "];
                    }
                    weekString = [weekString stringByAppendingString:_weekArray[i]];
                }
                
                [_schedulePromptView setScheduleWeek:weekString Time:nil];
                
                CGFloat pointY = (count+1)*(CGRectGetHeight(self.collectionView.frame))/WEEK_DAY_COUNT;
                if (pointY < 0) {
                    pointY = 0;
                } else if (pointY > CGRectGetHeight(self.collectionView.frame) - SCHEDULE_PROMPT_HEIGHT) {
                    pointY = CGRectGetHeight(self.collectionView.frame) - SCHEDULE_PROMPT_HEIGHT;
                }
                _schedulePromptView.frame = CGRectMake(_schedulePromptView.frame.origin.x, pointY, SCHEDULE_PROMPT_WIDTH, SCHEDULE_PROMPT_HEIGHT);

            }
        }
        
        if (j >=0 && (count_X < ONE_DAY_NUMBER)) {
            if (j != _startPointX || count_X != _currentPointX) {
                _startPointX = j;
                _currentPointX = count_X;
                
                NSString *timeString = [NSString stringWithFormat:@"%@:%d:00-%d:00", NSLocalizedString(@"mcs_time", nil), j, count_X+1];

                [_schedulePromptView setScheduleWeek:nil Time:timeString];
                
                CGFloat pointX = j*(CGRectGetWidth(self.collectionView.frame))/ONE_DAY_NUMBER;
                if (pointX < 0) {
                    pointX = 0;
                } else if (pointX > CGRectGetWidth(self.collectionView.frame) - SCHEDULE_PROMPT_WIDTH) {
                    pointX = CGRectGetWidth(self.collectionView.frame) - SCHEDULE_PROMPT_WIDTH;
                }
                _schedulePromptView.frame = CGRectMake(pointX, _schedulePromptView.frame.origin.y, SCHEDULE_PROMPT_WIDTH, SCHEDULE_PROMPT_HEIGHT);

            }
        }
    }
    else if (gestureRecongnizer.state == UIGestureRecognizerStateEnded)
    {
        _endPoint = currentPoint;
        _schedulePromptView.hidden = YES;
        
        if (_scheduleSceneSetView) {
            _scheduleSceneSetView.hidden = NO;
        } else {
            _scheduleSceneSetView = [[[NSBundle mainBundle] loadNibNamed:@"MNScheduleSceneSetView" owner:self options:nil] lastObject];
            _scheduleSceneSetView.frame = [UIScreen mainScreen].bounds;
            _scheduleSceneSetView.delegate = self;
            [self.app.window addSubview:_scheduleSceneSetView];
        }
        
        _startPointX = -1;
        _startPointY = -1;
        _currentPointX = -1;
        _currentPointY = -1;
    }
    else
    {
        //dismiss all
        _schedulePromptView.hidden = YES;
        
        _startPointX = -1;
        _startPointY = -1;
        _currentPointX = -1;
        _currentPointY = -1;
    }
}

-(UIColor *)getDefaultColor:(NSInteger)index
{
    if ((index / 24 % 2) == 0) {
        return [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    }else
    {
        return  [UIColor colorWithRed:235/255.0 green:241/255.0 blue:243/255.0 alpha:1.0];
    }
}

#pragma mark - Network Callback
- (void)schedule_get_done:(mcall_ret_schedule_get *)ret
{
    [self loading:NO];

    if (ret.result == nil) {
        _ret = ret;
        
        for (int i = 0; i < self.scheduleArray.count; i++)
        {
            schedule_obj *obj = self.scheduleArray[i];
            
            NSNumber *number = _ret.array[i];
            int hourValue = [number intValue];
            
            switch (hourValue)
            {
                case 0:
                    obj.backgroundColor = AWAYCOLOR;
                    break;
                case 1:
                    obj.backgroundColor = ACTIVECOLOR;
                    break;
                default:
                    obj.backgroundColor = AWAYCOLOR;
                    break;
            }
        }
        
//        [self.collectionView reloadData];
        [self finishSceneSetView:NO schedule:0];
    }
    else
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}

- (void)schedule_set_done:(mcall_ret_schedule_set *)ret
{
    [self loading:NO];
    if (ret.result == nil) {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
    }
    else {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _is_showView ? WEEK_DAY_COUNT*ONE_DAY_NUMBER : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNScheduleViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    UIColor *defaultColor = [self getDefaultColor:indexPath.row];
    
    if (indexPath.row >= 0 && indexPath.row < WEEK_DAY_COUNT*ONE_DAY_NUMBER)
    {
        cell.numberLabel.text = [NSString stringWithFormat:@"%ld",(indexPath.row)%24+1];
        
        schedule_obj *obj = [self.scheduleArray objectAtIndex:indexPath.row];
        cell.backgroundColor = defaultColor;
        
        cell.numberLabel.backgroundColor = obj.backgroundColor;
        cell.numberLabel.font = [UIFont systemFontOfSize:10.0];
        cell.numberLabel.textColor = ([cell.numberLabel.backgroundColor isEqual: defaultColor]) ? [UIColor lightGrayColor] : [UIColor whiteColor];
        cell.labelWidth.constant = cell.bounds.size.width;
        cell.labelHeight.constant = cell.bounds.size.width;
//        cell.numberLabel.layer.cornerRadius = cell.labelWidth.constant / 2.0;
//        cell.numberLabel.layer.masksToBounds = YES;
        
        int num = indexPath.row%ONE_DAY_NUMBER;
        if (num == 0)
        {
            if ([((schedule_obj*)[self.scheduleArray objectAtIndex:(indexPath.row+1)]).backgroundColor isEqual:cell.numberLabel.backgroundColor]) {
                [cell setLabelLayer:LAYER_STYLE_SEMICIRCLE_LEFT];
            } else {
                [cell setLabelLayer:LAYER_STYLE_CIRCULAR];
            }
        }
        else if (num == 23)
        {
            if ([((schedule_obj*)[self.scheduleArray objectAtIndex:(indexPath.row-1)]).backgroundColor isEqual:cell.numberLabel.backgroundColor]) {
                [cell setLabelLayer:LAYER_STYLE_SEMICIRCLE_RIGHT];
            } else {
                [cell setLabelLayer:LAYER_STYLE_CIRCULAR];
            }
        }
        else
        {
            BOOL leftEuqal = [((schedule_obj*)[self.scheduleArray objectAtIndex:(indexPath.row-1)]).backgroundColor isEqual:cell.numberLabel.backgroundColor];
            BOOL rightEqual = [((schedule_obj*)[self.scheduleArray objectAtIndex:(indexPath.row+1)]).backgroundColor isEqual:cell.numberLabel.backgroundColor];
            if (leftEuqal && rightEqual) {
                [cell setLabelLayer:LAYER_STYLE_SQUARE];
            } else if (leftEuqal){
                [cell setLabelLayer:LAYER_STYLE_SEMICIRCLE_RIGHT];
            } else if (rightEqual) {
                [cell setLabelLayer:LAYER_STYLE_SEMICIRCLE_LEFT];
            } else {
                [cell setLabelLayer:LAYER_STYLE_CIRCULAR];
            }
        }
    }
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize;
    
    float height = (self.collectionView.bounds.size.height)/7;
    float width = (self.collectionView.bounds.size.width)/24;
    itemSize = CGSizeMake(width, height);
    
    return itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNScheduleViewCell *cell = (MNScheduleViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (indexPath.row >= 0 && indexPath.row < WEEK_DAY_COUNT*ONE_DAY_NUMBER)
    {
//        UIColor *defualtColor = [self getDefaultColor:indexPath.row];
//        
//        if ([cell.numberLabel.backgroundColor isEqual: defualtColor]) {
            _startPoint = cell.center;
            _endPoint = CGPointMake(cell.center.x + 1, cell.center.y + 1);
            if (_scheduleSceneSetView) {
                _scheduleSceneSetView.hidden = NO;
            } else {
                _scheduleSceneSetView = [[[NSBundle mainBundle] loadNibNamed:@"MNScheduleSceneSetView" owner:self options:nil] lastObject];
                _scheduleSceneSetView.frame = [UIScreen mainScreen].bounds;
                _scheduleSceneSetView.delegate = self;
                [self.app.window addSubview:_scheduleSceneSetView];
            }
//        }
//        else {
//            cell.numberLabel.backgroundColor = defualtColor;
//            //            cell.numberLabel.textColor = [UIColor lightGrayColor];
//            //            cell.backgroundColor = defualtColor;
//            ((schedule_obj *)[_scheduleArray objectAtIndex:indexPath.row]).backgroundColor = cell.numberLabel.backgroundColor;
//            [self finishSceneSetView:NO schedule:0];
//        }
    }
}

#pragma mark - Loading
- (void)loading:(BOOL)visible
{
    UIView *loadingView = [self.backView viewWithTag:1123002];
    if (loadingView==nil){
        loadingView = [self createLoadingView];
    }
    
    loadingView.frame = self.view.frame;
    self.backView.userInteractionEnabled = !visible;
    
    if (visible)
    {
        loadingView.hidden = NO;
    }
    
    loadingView.alpha = visible ? 0 : 1;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         loadingView.alpha = visible ? 1 : 0;
                     }
                     completion: ^(BOOL  finished) {
                         if (!visible) {
                             loadingView.hidden = YES;
                         }
                     }];
}

- (UIView *)createLoadingView
{
    UIView *loadingView = [[UIView alloc] init];
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleHeight;
    loadingView.tag = 1123002;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activity startAnimating];
    [activity sizeToFit];
    activity.center = CGPointMake(loadingView.center.x, loadingView.frame.size.height/3);
    activity.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleHeight;
    
    [loadingView addSubview:activity];
    [self.backView addSubview:loadingView];
    [self.backView bringSubviewToFront:loadingView];
    
    return loadingView;
}

#pragma mark - Notification
- (void)didRotate:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeLeft | orientation ==  UIDeviceOrientationLandscapeRight | orientation == UIDeviceOrientationPortrait)
    {
        for (UIView *view in self.mainView.subviews) {
            if (![view isMemberOfClass:[UICollectionView class]]) {
                [view removeFromSuperview];
            }
        }
        [self drawLineLayerForSchedule];
    }
}

#pragma mark - InterfaceOrientation
- (BOOL)shouldAutorotate
{
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [self.collectionView reloadData];
    }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    _transitionToSize = size;
    [self.collectionView reloadData];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else {
        return UIInterfaceOrientationMaskLandscape;
    }
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        return UIInterfaceOrientationPortrait;
    }
    else {
        return UIInterfaceOrientationLandscapeRight;
    }
}

- (void)finishSceneSetView:(BOOL)select schedule:(long)schedule
{
    UIColor *defaultColor;
    CGRect constantRect = CGRectMake(_startPoint.x, _startPoint.y, _endPoint.x - _startPoint.x, _endPoint.y - _startPoint.y);
    
    for (int i = 0 ; i < self.scheduleArray.count; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        MNScheduleViewCell *cell = (MNScheduleViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        defaultColor = [self getDefaultColor:i];
        
        if (select) {
            if (CGRectIntersectsRect(cell.frame, constantRect))
            {
                cell.numberLabel.backgroundColor = schedule == SCHEDULE_ACTIVE ? ACTIVECOLOR : AWAYCOLOR;
                cell.numberLabel.textColor = [UIColor whiteColor];
                ((schedule_obj *)[_scheduleArray objectAtIndex:indexPath.row]).backgroundColor = cell.numberLabel.backgroundColor;
            }
        } else {
            cell.numberLabel.backgroundColor = ((schedule_obj *)[_scheduleArray objectAtIndex:indexPath.row]).backgroundColor;
            cell.numberLabel.textColor = ([cell.numberLabel.backgroundColor isEqual: defaultColor]) ? [UIColor lightGrayColor] : [UIColor whiteColor];
        }
    }
    
    for (int i = 0 ; i < self.scheduleArray.count; i ++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        MNScheduleViewCell *cell = (MNScheduleViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        int num = indexPath.row%ONE_DAY_NUMBER;
        if (num == 0)
        {
            if ([((schedule_obj*)[self.scheduleArray objectAtIndex:(indexPath.row+1)]).backgroundColor isEqual:cell.numberLabel.backgroundColor]) {
                [cell setLabelLayer:LAYER_STYLE_SEMICIRCLE_LEFT];
            } else {
                [cell setLabelLayer:LAYER_STYLE_CIRCULAR];
            }
        }
        else if (num == 23)
        {
            if ([((schedule_obj*)[self.scheduleArray objectAtIndex:(indexPath.row-1)]).backgroundColor isEqual:cell.numberLabel.backgroundColor]) {
                [cell setLabelLayer:LAYER_STYLE_SEMICIRCLE_RIGHT];
            } else {
                [cell setLabelLayer:LAYER_STYLE_CIRCULAR];
            }
        }
        else
        {
            BOOL leftEuqal = [((schedule_obj*)[self.scheduleArray objectAtIndex:(indexPath.row-1)]).backgroundColor isEqual:cell.numberLabel.backgroundColor];
            BOOL rightEqual = [((schedule_obj*)[self.scheduleArray objectAtIndex:(indexPath.row+1)]).backgroundColor isEqual:cell.numberLabel.backgroundColor];
            if (leftEuqal && rightEqual) {
                [cell setLabelLayer:LAYER_STYLE_SQUARE];
            } else if (leftEuqal){
                [cell setLabelLayer:LAYER_STYLE_SEMICIRCLE_RIGHT];
            } else if (rightEqual) {
                [cell setLabelLayer:LAYER_STYLE_SEMICIRCLE_LEFT];
            } else {
                [cell setLabelLayer:LAYER_STYLE_CIRCULAR];
            }
        }
    }
}

@end
