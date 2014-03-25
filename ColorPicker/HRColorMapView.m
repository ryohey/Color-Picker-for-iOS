//
//  HRColorMapView.m
//  Hayashi311ColorPickerSample
//
//  Created by ryohey on 2014/03/25.
//

#import "HRColorMapView.h"

@interface HRColorMapView ()

@property (nonatomic, strong) UIImage *image;

@end

@implementation HRColorMapView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = UIColor.clearColor;
    }
    
    return self;
}

- (void)setTileSize:(CGFloat)tileSize {
    _tileSize = tileSize;
    [self updateImage];
}

- (void)setTileMargin:(CGFloat)tileMargin {
    _tileMargin = tileMargin;
    [self updateImage];
}

- (void)setSaturationUpperLimit:(CGFloat)saturationUpperLimit {
    _saturationUpperLimit = saturationUpperLimit;
    [self updateImage];
}

- (void)setCurrentHsvColor:(HRHSVColor)currentHsvColor {
    _currentHsvColor = currentHsvColor;
    [self updateImage];
}

/// recreate color map image
- (void)updateImage {
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float height;
    int pixelCountX = CGRectGetWidth(self.frame) / _tileSize;
    int pixelCountY = CGRectGetHeight(self.frame) / _tileSize;
    
    HRHSVColor pixelHsv;
    HRRGBColor pixelRgb;
    for (int j = 0; j < pixelCountY; ++j) {
        height =  _tileSize * j;
        float pixelY = (float)j/(pixelCountY-1); // Y(彩度)は0.0f~1.0f
        for (int i = 0; i < pixelCountX; ++i) {
            float pixelX = (float)i/pixelCountX; // X(色相)は1.0f=0.0fなので0.0f~0.95fの値をとるように
            HSVColorAt(&pixelHsv, pixelX, pixelY, _saturationUpperLimit, _currentHsvColor.v);
            RGBColorFromHSVColor(&pixelHsv, &pixelRgb);
            CGContextSetRGBFillColor(context, pixelRgb.r, pixelRgb.g, pixelRgb.b, 1.0f);
            CGContextFillRect(context, CGRectMake(_tileSize*i, height, _tileSize-_tileMargin, _tileSize-_tileMargin));
        }
    }
    
    _image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)drawRect:(CGRect)rect {
    if (!_image) {
        [self updateImage];
    }
    [_image drawInRect:rect];
}

@end
