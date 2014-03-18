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

#import "HRColorPickerViewController.h"
#import "HRColorPickerView.h"

@implementation HRColorPickerViewController

- (id)initWithColor:(UIColor*)defaultColor style:(HRColorPickerStyle)style saveStyle:(HCPCSaveStyle)saveStyle
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _style = style;
        _color = defaultColor;
        _saveStyle = saveStyle;
    }
    return self;
}

- (void)viewDidLoad {
    
    HRRGBColor rgbColor;
    RGBColorFromUIColor(_color, &rgbColor);
    
    _colorPickerView = [[HRColorPickerView alloc] initWithStyle:_style defaultColor:rgbColor];
    
    [self.view addSubview:_colorPickerView];
    
    if (_saveStyle == HCPCSaveStyleSaveAndCancel) {
        UIBarButtonItem *buttonItem;
        
        buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
        self.navigationItem.leftBarButtonItem = buttonItem;
        
        buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTapped:)];
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_saveStyle == HCPCSaveStyleSaveAlways) {
        [self saveColor];
    }
}

- (void)saveColor {
    if (self.delegate) {
        HRRGBColor rgbColor = [_colorPickerView RGBColor];
        UIColor *color = [UIColor colorWithRed:rgbColor.r green:rgbColor.g blue:rgbColor.b alpha:1.0f];
        [_delegate colorPickerViewController:self didSelectColor:color];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonTapped:(id)sender {
    [self saveColor];
}

- (void)cancelButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
