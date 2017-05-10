//
//  MNLANDeviceViewCell.h
//  mipci
//
//  Created by mining on 16/11/10.
//
//

#import <UIKit/UIKit.h>
#import "mipc_data_object.h"
#import "mipc_agent.h"
#import "mme_ios.h"

@protocol MNLANDeviceViewCellDelegate <NSObject>

- (void)managerLocalAgent:(mipc_agent *)agent withDev:(m_dev *)dev;
- (void)recordVideoPlay:(m_dev *)dev with:(BOOL)isPlay;
- (mipc_agent*)getAgentWithDev:(m_dev *)dev;
- (void)updateCellOfflineWithDev:(m_dev *)dev;
- (void)updateCellInvalidWithDev:(m_dev *)dev;

@end

@interface MNLANDeviceViewCell : UICollectionViewCell

@property (strong, nonatomic) m_dev *device;

@property (copy, nonatomic) NSString *deviceID;
@property (assign, nonatomic) long alarmCounts;
@property (copy, nonatomic) NSString *status;
@property (strong,nonatomic) MMediaEngine    *engine;
@property (assign,nonatomic) BOOL isPlay;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundPlayView;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressActivityIndicato;

@property (weak, nonatomic) id<MNLANDeviceViewCellDelegate> delegate;

-(void)localLoadWebImage:(BOOL)isLoadCache devType:(NSString *)devType deviceID:(NSString *)currentDeviceID;
-(void)cancelNetworkRequest;
-(void)loadMediaPlay;
-(void)mediaEndPlay;
-(void)resetMediaPlay:(BOOL)isPlay withAgent:(mipc_agent *)agent;

@end
