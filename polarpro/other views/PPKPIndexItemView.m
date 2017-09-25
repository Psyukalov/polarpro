//
//  PPKPIndexItemView.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 13.06.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//



#import "PPKPIndexItemView.h"

#import "Macros.h"

#import "PPLocationsModel.h"
#import "PPGeomagneticStormModel.h"
#import "VPChartView.h"
#import "UITableView+PPCustomHeaderFooterView.h"
#import "VPActivityIndicatorView.h"
#import "PPUtils.h"

#import "PPKPIndexTableViewCell.h"


#define kMaxIndex (9.f)
#define kMiddleIndex (5.f)
#define kMinIndex (0.f)

#define kForecast (5)


@interface PPKPIndexItemView () <UITableViewDataSource, UITableViewDelegate, VPChartViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *leftMaxIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftMiddleIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftMinIndexLabel;

@property (weak, nonatomic) IBOutlet UILabel *rightMaxIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightMiddleIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightMinIndexLabel;

@property (weak, nonatomic) IBOutlet UILabel *firstDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray <NSDictionary *> *monthForecast;

@property (weak, nonatomic) IBOutlet VPChartView *chartView;

@property (strong, nonatomic) NSArray *indexes;

@property (strong, nonatomic) NSArray <UIView *> *chartElements;

@property (weak, nonatomic) IBOutlet VPActivityIndicatorView *activityIndicator;

@end


@implementation PPKPIndexItemView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadViewFromNib];
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadViewFromNib];
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadViewFromNib];
        [self setup];
    }
    return self;
}

- (void)loadViewFromNib {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *nib = [UINib nibWithNibName:@"PPKPIndexItemView"
                                bundle:bundle];
    UIView *view = (UIView *)[nib instantiateWithOwner:self
                                               options:nil].firstObject;
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setBackgroundColor:view.backgroundColor];
    [self addSubview:view];
    NSArray *attributes = @[@(NSLayoutAttributeLeft),
                            @(NSLayoutAttributeTop),
                            @(NSLayoutAttributeRight),
                            @(NSLayoutAttributeBottom)];
    for (NSNumber *attribute in attributes) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:[attribute unsignedIntegerValue]
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:[attribute unsignedIntegerValue]
                                                        multiplier:1.f
                                                          constant:0.f]];
    }
}

- (void)setup {
    _chartElements = @[_leftMaxIndexLabel,
                       _leftMiddleIndexLabel,
                       _leftMinIndexLabel,
                       _rightMaxIndexLabel,
                       _rightMiddleIndexLabel,
                       _rightMinIndexLabel,
                       _firstDateLabel,
                       _secondDateLabel,
                       _thirdDateLabel];
    [self hideElementsAnimated:NO];
    [_indexLabel setFont:[UIFont fontWithName:@"BN-Book"
                                         size:120.f]];
    [_leftMaxIndexLabel setText:[NSString stringWithFormat:@"%1.0f", kMaxIndex]];
    [_leftMiddleIndexLabel setText:[NSString stringWithFormat:@"%1.0f", kMiddleIndex]];
    [_leftMinIndexLabel setText:[NSString stringWithFormat:@"%1.0f", kMinIndex]];
    [_rightMaxIndexLabel setText:[NSString stringWithFormat:@"%1.0f", kMaxIndex]];
    [_rightMiddleIndexLabel setText:[NSString stringWithFormat:@"%1.0f", kMiddleIndex]];
    [_rightMinIndexLabel setText:[NSString stringWithFormat:@"%1.0f", kMinIndex]];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PPKPIndexTableViewCell class])
                                           bundle:nil]
     forCellReuseIdentifier:kKPIndexItemRI];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_chartView setDelegate:self];
    [self updateData];
    [PPUtils resizeLabelsInView:self.subviews.lastObject];
    [PPUtils resizeMarginsInView:self.subviews.lastObject];
}

- (void)hideElementsAnimated:(BOOL)animated {
    CGFloat alpha = 0.f;
    if (_indexLabel.alpha == alpha) {
        return;
    }
    if (animated) {
        [UIView animateWithDuration:.2f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [_indexLabel setAlpha:alpha];
                             [_descriptionLabel setAlpha:alpha];
                             [_cityLabel setAlpha:alpha];
                             for (UIView *view in _chartElements) {
                                 [view setAlpha:alpha];
                             }
                             [_chartView setAlpha:alpha];
                         }
                         completion:nil];
    } else {
        [_indexLabel setAlpha:alpha];
        [_descriptionLabel setAlpha:alpha];
        [_cityLabel setAlpha:alpha];
        for (UIView *view in _chartElements) {
            [view setAlpha:alpha];
        }
        [_chartView setAlpha:alpha];
    }
}

- (void)updateData {
    PPGeomagneticStormModel *stormModel = [PPGeomagneticStormModel sharedModel];
    [self hideElementsAnimated:YES];
    if (!stormModel.isThreeDaysKP || !stormModel.isMonthKP) {
        [_activityIndicator start];
    }
    PPLocationsModel *locationModel = [PPLocationsModel sharedModel];
    [_cityLabel setText:locationModel.locations.firstObject.name];
    [stormModel updateThreeDaysForecastWithCompletion:^(BOOL success, NSArray *dates, NSArray *values) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success) {
                return;
            }
            [_activityIndicator stopWithComlpetion:^{
                CGFloat summ = 0.f;
                for (NSUInteger i = 0; i <= kKPIndexesInOneDay - 1; i++) {
                    summ += [values[i] floatValue];
                }
                CGFloat index = summ / kKPIndexesInOneDay;
                [_indexLabel setText:[NSString stringWithFormat:@"%1.0f", index]];
                if (index <= 3.f) {
                    [_descriptionLabel setText:LOCALIZE(@"low_risk")];
                    [_descriptionLabel setTextColor:RGB(238.f, 184.f, 24.f)];
                } else if (index > 3.f && index <= 5.f) {
                    [_descriptionLabel setText:LOCALIZE(@"medium_risk")];
                    [_descriptionLabel setTextColor:RGB(238.f, 184.f, 24.f)];
                } else {
                    [_descriptionLabel setText:LOCALIZE(@"high_risk")];
                    [_descriptionLabel setTextColor:RGB(238.f, 24.f, 24.f)];
                }
                [UIView animateWithDuration:.6f
                                      delay:0.f
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     [_indexLabel setAlpha:1.f];
                                     [_descriptionLabel setAlpha:1.f];
                                     [_cityLabel setAlpha:1.f];
                                 }
                                 completion:nil];
                NSUInteger counter = 0;
                for (UILabel *label in @[_firstDateLabel, _secondDateLabel, _thirdDateLabel]) {
                    [label setText:dates[counter]];
                    counter++;
                }
                _indexes = values;
                [_chartView reloadData];
                [_chartView setAlpha:1.f];
            }];
        });
    }];
    [stormModel updateMonthForecastWithCompletion:^(BOOL success, NSArray <NSDictionary *> *responce) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success) {
                return;
            }
            [_activityIndicator stopWithComlpetion:^{
                NSMutableArray <NSDictionary *> *result = [[NSMutableArray alloc] init];
                NSUInteger index = 0;
                for (NSUInteger i = 0; i <= responce.count - 1; i++) {
                    if ([responce[i][@"date"] isEqualToString:[self stringWithSpecialFormatterFromDate:[NSDate date]]]) {
                        index = i;
                    }
                }
                for (NSUInteger i = index; i <= index + kForecast - 1; i++) {
                    if (i <= responce.count - 1) {
                        [result addObject:responce[i]];
                    }
                }
                _monthForecast = result;
                [_tableView reloadData];
                [_tableView fadeInOutVisibleCellsHidden:YES
                                               animated:NO];
                [_tableView fadeInOutVisibleCellsHidden:NO
                                               animated:YES];
            }];
        });
    }];
}

#pragma mark - VPChartViewDelegate

- (NSUInteger)numberOfChartsForChartView:(VPChartView *)chartView {
    return _indexes.count;
}

- (CGFloat)minValueForChartView:(VPChartView *)chartView {
    return 0.f;
}

- (CGFloat)maxValueForChartView:(VPChartView *)chartView {
    return 9.f;
}

- (CGFloat)chartView:(VPChartView *)chartView valueForIndex:(NSUInteger)index {
    return [_indexes[index] floatValue];
}

- (CGFloat)dangerValueForChartView:(VPChartView *)chartView {
    return 5.f;
}

- (void)didCompleteAnimationForChartView:(VPChartView *)chartView {
    for (UIView *view in _chartElements) {
        [UIView animateWithDuration:.6f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [view setAlpha:1.f];
                         } completion:nil];
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _monthForecast.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PPKPIndexTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kKPIndexItemRI
                                                                    forIndexPath:indexPath];
    if (_monthForecast.count > 0) {
        [cell setDate:_monthForecast[indexPath.row][@"date"]];
        [cell setIndex:[_monthForecast[indexPath.row][@"index"] floatValue]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.f * [PPUtils screenRate];
}

#pragma mark - Other methods

- (NSString *)stringWithSpecialFormatterFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]]; // Geomagnetic Storm Medel use american service.
    [dateFormatter setDateFormat:@"yyyy MMM dd"];
    return [dateFormatter stringFromDate:date];
}

@end
