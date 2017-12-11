//
//  VPHorizontalPickerView.h
//
//  Created by Владимир Псюкалов on 18.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, VPState) {
    VPDefaultState,
    VPSelectedState
};


@class VPHorizontalPickerView;


@protocol VPHorizontalPickerViewDelegate <NSObject>

@required

- (NSUInteger)numberOfItemsInPickerView:(VPHorizontalPickerView *)pickerView;

- (NSString *)pickerView:(VPHorizontalPickerView *)pickerView titleForItemAtIndex:(NSUInteger)index;

@optional

- (CGFloat)marginBetweenItemsInPickerView:(VPHorizontalPickerView *)pickerView;

- (NSString *)pickerView:(VPHorizontalPickerView *)pickerView secondTitleForItemAtIndex:(NSUInteger)index;

- (void)pickerView:(VPHorizontalPickerView *)pickerView didSelectItemAtIndex:(NSUInteger)index;

@end


@interface VPHorizontalPickerView : UIView

@property (strong, nonatomic) id<VPHorizontalPickerViewDelegate> delegate;

@property (assign, nonatomic) NSUInteger selectedIndex;

@property (assign, nonatomic) CGFloat padding;

@property (assign, nonatomic) BOOL useSound;
@property (assign, nonatomic) BOOL useSecondTitle;

- (void)setSelectedIndex:(NSUInteger)selectedIndex
                animated:(BOOL)animated;

- (void)setFont:(UIFont *)font
       forState:(VPState)state;

- (void)setColor:(UIColor *)color
        forState:(VPState)state;

- (void)setSecondFont:(UIFont *)font
             forState:(VPState)state;

- (void)setSecondColor:(UIColor *)color
              forState:(VPState)state;

- (void)reloadData;

@end
