//
//  MNPostViewController.h
//  mipci
//
//  Created by mining on 15/11/26.
//
//

#import <UIKit/UIKit.h>

@interface MNPostViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic)  NSURL *url;
@end
