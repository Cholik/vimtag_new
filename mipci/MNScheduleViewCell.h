//
//  MNScheduleViewCell.h
//  mipci
//
//  Created by mining on 16/4/15.
//
//

#define LAYER_STYLE_SQUARE              1001
#define LAYER_STYLE_CIRCULAR            1002
#define LAYER_STYLE_SEMICIRCLE_LEFT     1003
#define LAYER_STYLE_SEMICIRCLE_RIGHT    1004

#import <UIKit/UIKit.h>

@interface MNScheduleViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelHeight;

- (void)setLabelLayer:(NSInteger)index;

@end
