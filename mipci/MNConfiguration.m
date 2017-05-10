//
//  MNConfiguration.m
//  mipci
//
//  Created by mining on 15/8/26.
//
//

#import "MNConfiguration.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((((rgbValue) & 0xFF0000) >> 16))/255.f \
green:((((rgbValue) & 0xFF00) >> 8))/255.f \
blue:(((rgbValue) & 0xFF))/255.f alpha:1.0]

//static global variable
static MNConfiguration *configuration;

@implementation MNConfiguration

+ (MNConfiguration *)shared_configuration
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configuration = [[super allocWithZone:nil] init];
    });
    
    return configuration;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [self shared_configuration];
}

- (id)init
{
    self = [super init];
    [self readConfiguration];
    
    return  self;
}

- (void)readConfiguration
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"configuration" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    NSLog(@"%@",data);
    
    self.interfaceBackgroundColor = [self getColorFromString:[NSString stringWithString:[data objectForKey:@"interfaceBackgroundColor"]]];
    self.labelTextColor = [self getColorFromString:[NSString stringWithString:[data objectForKey:@"labelTextColor"]]];
    self.labelBackgroundColor = [self getColorFromString:[NSString stringWithString:[data objectForKey:@"labelBackgroundColor"]]];
    self.buttonTintColor = [self getColorFromString:[NSString stringWithString:[data objectForKey:@"buttonTintColor"]]];
    self.buttonBackgroundColor = [self getColorFromString:[NSString stringWithString:[data objectForKey:@"buttonBackgroundColor"]]];
    self.navigationBarTintColor = [self getColorFromString:[NSString stringWithString:[data objectForKey:@"navigationBarTintColor"]]];
    self.navigationBarTitleColor = [self getColorFromString:[NSString stringWithString:[data objectForKey:@"navigationBarTitleColor"]]];
    self.tabBarTintColor = [self getColorFromString:[NSString stringWithString:[data objectForKey:@"tabBarTintColor"]]];
    self.switchTintColor = [self getColorFromString:[NSString stringWithString:[data objectForKey:@"switchTintColor"]]];
    self.color =[self getColorFromString:[NSString stringWithString:[data objectForKey:@"color"]]];
    self.buttonTitleColor =[self getColorFromString:[NSString stringWithString:[data objectForKey:@"buttonTitleColor"]]];
    self.buttonColor =[self getColorFromString:[NSString stringWithString:[data objectForKey:@"buttonColor"]]];
    self.loginButtonTitleColor = [self getColorFromString:[NSString stringWithString:[data objectForKey:@"loginButtonTitleColor"]]];
    self.is_luxcam = [[data objectForKey:@"luxcam"] boolValue];
    self.is_ebitcam = [[data objectForKey:@"ebitcam"] boolValue];
    self.is_mipc = [[data objectForKey:@"mipc"] boolValue];
    self.is_itelcamera = [[data objectForKey:@"itelcamera"] boolValue];
    self.alert_independent = [data objectForKey:@"alert_independent"];
    self.is_vimtag = [[data objectForKey:@"vimtag"] boolValue];
    self.is_SereneViewer = [[data objectForKey:@"sereneViewer"] boolValue];
    self.is_ehawk = [[data objectForKey:@"ehawk"] boolValue];
    self.is_eyedot = [[data objectForKey:@"eyedot"] boolValue];
    self.is_avuecam = [[data objectForKey:@"avuecam"] boolValue];
    self.is_kean = [[data objectForKey:@"kean"] boolValue];
    self.is_prolab = [[data objectForKey:@"prolab"] boolValue];
    self.is_eyeview = [[data objectForKey:@"eyeview"] boolValue];
    self.is_maxCAM = [[data objectForKey:@"maxCAM"] boolValue];
    self.is_bosma = [[data objectForKey:@"bosma"] boolValue];
    self.is_whiteBackground = [[data objectForKey:@"whiteBackground"] boolValue];
}

-(UIColor*)getColorFromString:(NSString *)string
{
    if ([string isEqualToString:@"red"]) {
        return [UIColor redColor];
    }
    else if([string isEqualToString:@"green"])
    {
        UIColor *color = [UIColor colorWithRed:76/255. green:200./255. blue:110./255. alpha:1.0];
        return color;
    }
    else if ([string isEqualToString:@"white"])
    {
        return [UIColor whiteColor];
    }
    else if ([string isEqualToString:@"black"])
    {
        return [UIColor blackColor];
    }
    else if ([string isEqualToString:@"darkgreen"])
    {
        UIColor *color = [UIColor colorWithRed:0.0 green:0.45 blue:0.2 alpha:1.0];
        return color;
    }
    else if ([string isEqualToString:@"vimtag"])
    {
        UIColor *color = [UIColor colorWithRed:0/255. green:169./255. blue:189./255. alpha:1.0];
        return color;
    }
    else if ([string isEqualToString:@"mipc"])
    {
        UIColor *color = [UIColor colorWithRed:75/255. green:214./255. blue:99./255. alpha:1.0];
        return color;
    }
    else if ([string isEqualToString:@"dongsys"])
    {
        UIColor *color = [UIColor colorWithRed:47/255. green:160./255. blue:233./255. alpha:1.0];
        return color;
    }
    else if([string isEqualToString:@"vimtagTint"])
    {
        UIColor *color = [UIColor colorWithRed:30./255. green:179./255. blue:198./255. alpha:1.0];
        return color;
    }
    else if([string isEqualToString:@"blue"])
    {
        UIColor *color = [UIColor colorWithRed:0./255. green:122./255. blue:255./255. alpha:1.0];
        return color;
    }
    else if ([string isEqualToString:@"bosma"])
    {
        UIColor *color = [UIColor colorWithRed:5./255. green:187./255. blue:252./255. alpha:0.6];
        return color;
    }
    else if ([string isEqualToString:@"ebit"])
    {
        UIColor *color = [UIColor colorWithRed:252./255. green:120./255. blue:48./255. alpha:1.0];
        return color;
    }
    else if ([string isEqualToString:@"ebitText"])
    {
        UIColor *color = UIColorFromRGB(0x5c5c66);
        return color;
    }
    else if ([string isEqualToString:@"ebitNavTint"])
    {
        UIColor *color = [UIColor colorWithRed:245./255. green:245./255. blue:245./255. alpha:1.0];
        return color;
    }
    else if ([string isEqualToString:@"ebitNavTitle"])
    {
        UIColor *color = [UIColor colorWithRed:97./255. green:97./255. blue:107./255. alpha:1.0];
        return color;
    }
    else if ([string isEqualToString:@"mipcNavTint"])
    {
        UIColor *color = UIColorFromRGB(0x2988cc);
        return color;
    }
    else if ([string isEqualToString:@"mipcText"])
    {
        UIColor *color = UIColorFromRGB(0x6b7a99);
        return color;
    }
    
    return nil;
}

@end
