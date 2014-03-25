//
//  HRColorMapView.h
//  Hayashi311ColorPickerSample
//
//  Created by ryohey on 2014/03/25.
//

#import <UIKit/UIKit.h>
#import "HRColorUtil.h"

@interface HRColorMapView : UIView

@property (nonatomic) CGFloat tileSize;
@property (nonatomic) CGFloat tileMargin;
@property (nonatomic) CGFloat saturationUpperLimit;
@property (nonatomic) HRHSVColor currentHsvColor;

@end
