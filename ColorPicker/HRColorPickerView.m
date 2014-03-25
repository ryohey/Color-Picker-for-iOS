/*-
 * Copyright (c) 2011 Ryota Hayashi
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR(S) ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR(S) BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $FreeBSD$
 */

#import "HRColorPickerView.h"
#import "HRCgUtil.h"
#import "HRBrightnessCursor.h"
#import "HRColorCursor.h"

@implementation HRColorPickerView

@synthesize delegate;

+ (HRColorPickerStyle)defaultStyle
{
    HRColorPickerStyle style;
    style.width = 320.0f;
    style.headerHeight = 106.0f;
    style.colorMapTileSize = 15.0f;
    style.colorMapSizeWidth = 20;
    style.colorMapSizeHeight = 20;
    style.brightnessLowerLimit = 0.4f;
    style.saturationUpperLimit = 0.95f;
    style.margin = 2.0f;
    return style;
}

+ (HRColorPickerStyle)fitScreenStyle
{
    CGSize defaultSize = [[UIScreen mainScreen] applicationFrame].size;
    defaultSize.height -= 44.f;
    
    HRColorPickerStyle style = [HRColorPickerView defaultStyle];
    style.colorMapSizeHeight = (defaultSize.height - style.headerHeight)/style.colorMapTileSize;
    
    float colorMapMargin = (style.width - (style.colorMapSizeWidth*style.colorMapTileSize))/2.f;
    style.headerHeight = defaultSize.height - (style.colorMapSizeHeight*style.colorMapTileSize) - colorMapMargin;
    
    return style;
}

+ (HRColorPickerStyle)fullColorStyle
{
    HRColorPickerStyle style = [HRColorPickerView defaultStyle];
    style.brightnessLowerLimit = 0.0f;
    style.saturationUpperLimit = 1.0f;
    return style;
}

+ (HRColorPickerStyle)fitScreenFullColorStyle
{
    HRColorPickerStyle style = [HRColorPickerView fitScreenStyle];
    style.brightnessLowerLimit = 0.0f;
    style.saturationUpperLimit = 1.0f;
    return style;
}


+ (CGSize)sizeWithStyle:(HRColorPickerStyle)style
{
    CGSize colorMapSize = CGSizeMake(style.colorMapTileSize * style.colorMapSizeWidth, style.colorMapTileSize * style.colorMapSizeHeight);
    float colorMapMargin = (style.width - colorMapSize.width) / 2.0f;
    return CGSizeMake(style.width, style.headerHeight + colorMapSize.height + colorMapMargin);
}

- (id)initWithFrame:(CGRect)frame defaultColor:(const HRRGBColor)defaultColor
{
    return [self initWithStyle:[HRColorPickerView defaultStyle] defaultColor:defaultColor];
}

- (id)initWithStyle:(HRColorPickerStyle)style defaultColor:(const HRRGBColor)defaultColor{
    CGSize size = [HRColorPickerView sizeWithStyle:style];
    CGRect frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    self = [super initWithFrame:frame];
    if (self) {
        _defaultRgbColor = defaultColor;
        _animating = FALSE;
        
        // パーツの配置
        CGSize colorMapSize = CGSizeMake(style.colorMapTileSize * style.colorMapSizeWidth, style.colorMapTileSize * style.colorMapSizeHeight);
        float colorMapSpace = (style.width - colorMapSize.width) / 2.0f;
        float headerPartsOriginY = (style.headerHeight - 40.0f)/2.0f;
        _currentColorFrame = CGRectMake(10.0f, headerPartsOriginY, 40.0f, 40.0f);
        _brightnessPickerFrame = CGRectMake(120.0f, headerPartsOriginY, style.width - 120.0f - 10.0f, 40.0f);
        _brightnessPickerTouchFrame = CGRectMake(_brightnessPickerFrame.origin.x - 20.0f,
                                                 headerPartsOriginY,
                                                 _brightnessPickerFrame.size.width + 40.0f,
                                                 _brightnessPickerFrame.size.height);
        
        _brightnessPickerView = [HRBrightnessPickerView.alloc initWithFrame:_brightnessPickerFrame];
        [self addSubview:_brightnessPickerView];
        
        _colorMapFrame = CGRectMake(colorMapSpace + 1.0f, style.headerHeight, colorMapSize.width, colorMapSize.height);
        
        _colorMapSideFrame = CGRectMake(_colorMapFrame.origin.x - 1.0f,
                                        _colorMapFrame.origin.y - 1.0f,
                                        _colorMapFrame.size.width,
                                        _colorMapFrame.size.height);
        
        _colorMapView = [HRColorMapView.alloc initWithFrame:_colorMapFrame];
        _colorMapView.tileSize = style.colorMapTileSize;
        _colorMapView.tileMargin = style.margin;
        _colorMapView.saturationUpperLimit = style.saturationUpperLimit;
        
        // RGBのデフォルトカラーをHSVに変換
        HRHSVColor color;
        HSVColorFromRGBColor(&_defaultRgbColor, &color);
        _colorMapView.currentHsvColor = color;
        
        [self addSubview:_colorMapView];
        
        _brightnessLowerLimit = style.brightnessLowerLimit;
        
        _brightnessCursor = [[HRBrightnessCursor alloc] initWithPoint:CGPointMake(_brightnessPickerFrame.origin.x, _brightnessPickerFrame.origin.y + _brightnessPickerFrame.size.height/2.0f)];
        
        // タイルの中心にくるようにずらす
        _colorCursor = [[HRColorCursor alloc] initWithPoint:(CGPoint){
            _colorMapFrame.origin.x - ([HRColorCursor cursorSize].width - style.colorMapTileSize)/2.0f - [HRColorCursor shadowSize]/2.0,
            _colorMapFrame.origin.y - ([HRColorCursor cursorSize].height - style.colorMapTileSize)/2.0f - [HRColorCursor shadowSize]/2.0
        }];
                        
        [self addSubview:_brightnessCursor];
        [self addSubview:_colorCursor];
        
        // 入力の初期化
        _isTapStart = FALSE;
        _isTapped = FALSE;
        _wasDragStart = FALSE;
        _isDragStart = FALSE;
        _isDragging = FALSE;
        _isDragEnd = FALSE;
        
        // 諸々初期化
        [self setBackgroundColor:[UIColor colorWithWhite:0.99f alpha:1.0f]];
        [self setMultipleTouchEnabled:FALSE];
        
        [self updateBrightnessCursor];
        [self updateColorCursor];
        
        // フレームレートの調整
        gettimeofday(&_lastDrawTime, NULL);
        
        _timeInterval15fps.tv_sec = 0.0;
        _timeInterval15fps.tv_usec = 1000000.0/15.0;
        
        _delegateHasSELColorWasChanged = FALSE;
    }
    return self;
}


- (HRRGBColor)RGBColor{
    HRHSVColor color = _colorMapView.currentHsvColor;
    HRRGBColor rgbColor;
    
    RGBColorFromHSVColor(&color, &rgbColor);
    return rgbColor;
}

- (float)BrightnessLowerLimit{
    return _brightnessLowerLimit;
}

- (void)setBrightnessLowerLimit:(float)brightnessUnderLimit{
    _brightnessLowerLimit = brightnessUnderLimit;
    [self updateBrightnessCursor];
}

- (float)SaturationUpperLimit{
    return _brightnessLowerLimit;
}

- (void)setSaturationUpperLimit:(float)saturationUpperLimit{
    _colorMapView.saturationUpperLimit = saturationUpperLimit;
    [self updateColorCursor];
}

/////////////////////////////////////////////////////////////////////////////
//
// プライベート
//
/////////////////////////////////////////////////////////////////////////////

- (void)update{
    // タッチのイベントの度、更新されます
    if (_isDragging || _isDragStart || _isDragEnd || _isTapped) {
        CGPoint touchPosition = _activeTouchPosition;
        if (CGRectContainsPoint(_colorMapFrame,touchPosition)) {
            
            int pixelCountX = _colorMapFrame.size.width / _colorMapView.tileSize;
            int pixelCountY = _colorMapFrame.size.height / _colorMapView.tileSize;
            HRHSVColor newHsv = _colorMapView.currentHsvColor;
            
            CGPoint newPosition = CGPointMake(touchPosition.x - _colorMapFrame.origin.x, touchPosition.y - _colorMapFrame.origin.y);
            
            float pixelX = (int)((newPosition.x) / _colorMapView.tileSize)/(float)pixelCountX; // X(色相)は1.0f=0.0fなので0.0f~0.95fの値をとるように
            float pixelY = (int)((newPosition.y) / _colorMapView.tileSize)/(float)(pixelCountY-1); // Y(彩度)は0.0f~1.0f
            
            HSVColorAt(&newHsv, pixelX, pixelY, _colorMapView.saturationUpperLimit, _colorMapView.currentHsvColor.v);
            
            HRHSVColor color = _colorMapView.currentHsvColor;
            if (!HRHSVColorEqualToColor(&newHsv,&color)) {
                _colorMapView.currentHsvColor = newHsv;
                [self setNeedsDisplay15FPS];
            }
            [self updateColorCursor];
        }else if(CGRectContainsPoint(_brightnessPickerTouchFrame,touchPosition)){
            HRHSVColor color = _colorMapView.currentHsvColor;
            if (CGRectContainsPoint(_brightnessPickerFrame,touchPosition)) {
                // 明度のスライダーの内側
                color.v = (1.0f - ((touchPosition.x - _brightnessPickerFrame.origin.x )/ _brightnessPickerFrame.size.width )) * (1.0f - _brightnessLowerLimit) + _brightnessLowerLimit;
            }else{
                // 左右をタッチした場合
                if (touchPosition.x < _brightnessPickerFrame.origin.x) {
                    color.v = 1.0f;
                }else if((_brightnessPickerFrame.origin.x + _brightnessPickerFrame.size.width) < touchPosition.x){
                    color.v = _brightnessLowerLimit;
                }
            }
            _colorMapView.currentHsvColor = color;
            [self updateBrightnessCursor];
            [self updateColorCursor];
            [self setNeedsDisplay15FPS];
        }
    }
    [self clearInput];
}

- (void)updateBrightnessCursor{
    // 明度スライダーの移動
    float brightnessCursorX = (1.0f - (_colorMapView.currentHsvColor.v - _brightnessLowerLimit)/(1.0f - _brightnessLowerLimit)) * _brightnessPickerFrame.size.width + _brightnessPickerFrame.origin.x;
    _brightnessCursor.transform = CGAffineTransformMakeTranslation(brightnessCursorX - _brightnessPickerFrame.origin.x, 0.0f);
    
}

- (void)updateColorCursor{
    // カラーマップのカーソルの移動＆色の更新
    
    CGFloat tileSize = _colorMapView.tileSize;
    int pixelCountX = _colorMapFrame.size.width / tileSize;
    int pixelCountY = _colorMapFrame.size.height / tileSize;
    CGPoint newPosition;
    newPosition.x = _colorMapView.currentHsvColor.h * (float)pixelCountX * tileSize + tileSize / 2.0f;
    newPosition.y = (1.0f - _colorMapView.currentHsvColor.s) * (1.0f / _colorMapView.saturationUpperLimit) * (float)(pixelCountY - 1) * tileSize + tileSize / 2.0f;
    _colorCursorPosition.x = (int)(newPosition.x / tileSize) * tileSize;
    _colorCursorPosition.y = (int)(newPosition.y / tileSize) * tileSize;
    
    HRRGBColor currentRgbColor = [self RGBColor];
    [_colorCursor setColorRed:currentRgbColor.r andGreen:currentRgbColor.g andBlue:currentRgbColor.b];
    
    _colorCursor.transform = CGAffineTransformMakeTranslation(_colorCursorPosition.x,_colorCursorPosition.y);
     
}

- (void)setNeedsDisplay15FPS{
    // 描画を20FPSに制限します
    timeval now,diff;
    gettimeofday(&now, NULL);
    timersub(&now, &_lastDrawTime, &diff);
    if (timercmp(&diff, &_timeInterval15fps, >)) {
        _lastDrawTime = now;
        [self setNeedsDisplay];
        if (_delegateHasSELColorWasChanged) {
            [delegate colorWasChanged:self];
        }
    }else{
        return;
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    HRRGBColor currentRgbColor = [self RGBColor];
    
    /////////////////////////////////////////////////////////////////////////////
    //
    // 明度
    //
    /////////////////////////////////////////////////////////////////////////////
    
    UIColor* darkColorFromHsv = [UIColor colorWithHue:_colorMapView.currentHsvColor.h
                                           saturation:_colorMapView.currentHsvColor.s
                                           brightness:_brightnessLowerLimit
                                                alpha:1.0f];
    
    UIColor* lightColorFromHsv = [UIColor colorWithHue:_colorMapView.currentHsvColor.h
                                            saturation:_colorMapView.currentHsvColor.s
                                            brightness:1.0f
                                                 alpha:1.0f];
    
    _brightnessPickerView.gradientLayer.colors = @[(id)lightColorFromHsv.CGColor,
                                                   (id)darkColorFromHsv.CGColor];
    
    /////////////////////////////////////////////////////////////////////////////
    //
    // カレントのカラー
    //
    /////////////////////////////////////////////////////////////////////////////
    
    CGContextSaveGState(context);
    HRDrawSquareColorBatch(context, CGPointMake(CGRectGetMidX(_currentColorFrame), CGRectGetMidY(_currentColorFrame)), &currentRgbColor, _currentColorFrame.size.width/2.0f);
    CGContextRestoreGState(context);
    
    /////////////////////////////////////////////////////////////////////////////
    //
    // RGBのパーセント表示
    //
    /////////////////////////////////////////////////////////////////////////////
    
    [[UIColor darkGrayColor] set];
    
    float textHeight = 20.0f;
    float textCenter = CGRectGetMidY(_currentColorFrame) - 5.0f;
    [[NSString stringWithFormat:@"R:%3d%%",(int)(currentRgbColor.r*100)] drawAtPoint:CGPointMake(_currentColorFrame.origin.x+_currentColorFrame.size.width+10.0f, textCenter - textHeight) withFont:[UIFont boldSystemFontOfSize:12.0f]];
    [[NSString stringWithFormat:@"G:%3d%%",(int)(currentRgbColor.g*100)] drawAtPoint:CGPointMake(_currentColorFrame.origin.x+_currentColorFrame.size.width+10.0f, textCenter) withFont:[UIFont boldSystemFontOfSize:12.0f]];
    [[NSString stringWithFormat:@"B:%3d%%",(int)(currentRgbColor.b*100)] drawAtPoint:CGPointMake(_currentColorFrame.origin.x+_currentColorFrame.size.width+10.0f, textCenter + textHeight) withFont:[UIFont boldSystemFontOfSize:12.0f]];
}


/////////////////////////////////////////////////////////////////////////////
//
// 入力
//
/////////////////////////////////////////////////////////////////////////////

- (void)clearInput{
    _isTapStart = FALSE;
    _isTapped = FALSE;
    _isDragStart = FALSE;
	_isDragEnd = FALSE;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([touches count] == 1) {
        UITouch* touch = [touches anyObject];
        [self setCurrentTouchPointInView:touch];
        _wasDragStart = TRUE;
        _isTapStart = TRUE;
        _touchStartPosition.x = _activeTouchPosition.x;
        _touchStartPosition.y = _activeTouchPosition.y;
        [self update];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch* touch = [touches anyObject];
    if ([touch tapCount] == 1) {
        _isDragging = TRUE;
        if (_wasDragStart) {
            _wasDragStart = FALSE;
            _isDragStart = TRUE;
        }
        [self setCurrentTouchPointInView:[touches anyObject]];
        [self update];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch* touch = [touches anyObject];
    
    if (_isDragging) {
        _isDragEnd = TRUE;
    }else{
        if ([touch tapCount] == 1) {
            _isTapped = TRUE;
        }
    }
    _isDragging = FALSE;
    [self setCurrentTouchPointInView:touch];
    [self update];
    [NSTimer scheduledTimerWithTimeInterval:1.0/20.0 target:self selector:@selector(setNeedsDisplay15FPS) userInfo:nil repeats:FALSE];
}

- (void)setCurrentTouchPointInView:(UITouch *)touch{
    CGPoint point;
	point = [touch locationInView:self];
    _activeTouchPosition.x = point.x;
    _activeTouchPosition.y = point.y;
}

- (void)setDelegate:(NSObject<HRColorPickerViewDelegate>*)picker_delegate{
    delegate = picker_delegate;
    _delegateHasSELColorWasChanged = FALSE;
    // 微妙に重いのでメソッドを持っているかどうかの判定をキャッシュ
    if ([delegate respondsToSelector:@selector(colorWasChanged:)]) {
        _delegateHasSELColorWasChanged = TRUE;
    }
}

- (void)BeforeDealloc{
    // 何も実行しません
}


@end
