//
//  MNMessageViewCell.h
//  mipci
//
//  Created by weken on 15/2/9.
//
//

#import <UIKit/UIKit.h>
//@class MNMessageViewCell; // Forward declare Custom Cell for the property
//@protocol MNMenuDelegate <NSObject>
//@optional
////- (void)menuItemDelete:(id)sender forCell:(MNMessageViewCell*)cell;
//@end

@interface MNMessageViewCell : UICollectionViewCell 

@property (copy, nonatomic) NSString *deviceID;
@property (copy, nonatomic) NSString *token;
@property (copy, nonatomic) NSString *type;

@property (assign, nonatomic) long messageID;
//@property (weak, nonatomic) id<MNMenuDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *markImageView;
@property (weak, nonatomic) IBOutlet UILabel *warnlabel;


-(void)loadWebImage;
-(void)cancelNetworkRequest;

@end
