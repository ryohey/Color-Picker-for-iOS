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


#import "SampleTopViewController.h"
#import "HRColorUtil.h"
#import "HRColorPickerView.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
#define NSTextAlignmentCenter    UITextAlignmentCenter
#endif

@implementation SampleTopViewController

- (void)openColorPicker:(id)sender{
    HRColorPickerViewController* controller;
    switch ([sender tag]) {
        case 0:
            controller = [HRColorPickerViewController.alloc initWithColor:self.view.backgroundColor
                                                                    style:HRColorPickerView.defaultStyle
                                                                saveStyle:HCPCSaveStyleSaveAlways];
            break;
        case 1:
            controller = [HRColorPickerViewController.alloc initWithColor:self.view.backgroundColor
                                                                    style:HRColorPickerView.fitScreenStyle
                                                                saveStyle:HCPCSaveStyleSaveAlways];
            break;
        case 2:
            controller = [HRColorPickerViewController.alloc initWithColor:self.view.backgroundColor
                                                                    style:HRColorPickerView.fullColorStyle
                                                                saveStyle:HCPCSaveStyleSaveAlways];
            break;
        case 3:{
            HRColorPickerStyle style;
            style.width = 320.0f;
            style.margin = 0;
            style.headerHeight = 106.0f;
            style.colorMapTileSize = 3.0f;
            style.colorMapSizeWidth = 100;
            style.colorMapSizeHeight = 100;
            style.brightnessLowerLimit = 0.0f;
            style.saturationUpperLimit = 1.0f;
            
            controller = [HRColorPickerViewController.alloc initWithColor:self.view.backgroundColor
                                                                    style:style
                                                                saveStyle:HCPCSaveStyleSaveAndCancel];
            break;}
            
        default:
            return;
            break;
    }
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - View lifecycle

- (UIButton *)createButtonWithTitle:(NSString *)title index:(int)index
{
    float offsetY = index * 60;
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.tag = index;
    [button setFrame:CGRectMake(10.0f, 30.0f + offsetY, 300.0f, 50.0f)];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openColorPicker:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    self.title = @"Color Picker by Hayashi311";
    
    NSString *titles[] = { @"Limited color ->", @"Limited color with Save button ->", @"Full color ->", @"Full color with Save button ->" };
    
    int i;
    for (i = 0; i < sizeof(titles) / sizeof(titles[0]); i++) {
        [self createButtonWithTitle:titles[i] index:i];
    }
    
    hexColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f,
                                                              self.view.frame.size.height-46.f,
                                                              320.f,
                                                              46.f)];
    hexColorLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [hexColorLabel setTextAlignment:NSTextAlignmentCenter];
    [hexColorLabel setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.4f]];
    [self.view addSubview:hexColorLabel];
    
    self.view.backgroundColor = UIColor.whiteColor;
}

#pragma mark - Hayashi311ColorPickerDelegate

- (void)colorPickerViewController:(HRColorPickerViewController *)colorPickerViewController didSelectColor:(UIColor*)color {
    [self.view setBackgroundColor:color];
    [hexColorLabel setText:[NSString stringWithFormat:@"#%06x",HexColorFromUIColor(color)]];
}

@end
