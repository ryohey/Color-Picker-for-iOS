//
//  HRBrightnessPickerView.m
//  Hayashi311ColorPickerSample
//
//  Created by ryohey on 2014/03/25.
//

#import "HRBrightnessPickerView.h"

#define kCornerRadius 5.0

@implementation HRBrightnessPickerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _gradientLayer = CAGradientLayer.layer;
        _gradientLayer.frame = (CGRect){
            CGPointZero,
            frame.size
        };
        _gradientLayer.startPoint = CGPointZero;
        _gradientLayer.endPoint = (CGPoint){1, 0};
        _gradientLayer.cornerRadius = kCornerRadius;
        [self.layer addSublayer:_gradientLayer];
        
        self.layer.cornerRadius = kCornerRadius;
        
        self.layer.borderColor = [UIColor.blackColor colorWithAlphaComponent:0.2].CGColor;
        self.layer.borderWidth = 1.0;
    }
    return self;
}

@end
