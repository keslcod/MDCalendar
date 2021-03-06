//
//  MDCalendar.m
//
//
//  Copyright (c) 2014 Michael DiStefano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "MDCalendar.h"
#import "NSDateFormatter+LocalizedSymbols.h"

@interface MDCalendarViewCell : UICollectionViewCell
@property (nonatomic, assign) NSDate  *date;

@property (nonatomic, assign) UIFont  *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) UIColor *highlightColor;
@property (nonatomic, assign) UIColor *indicatorColor;

@property (nonatomic, assign) CGFloat  borderHeight;
@property (nonatomic, assign) UIColor *borderColor;
@end

@interface MDCalendarViewCell  ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView  *highlightView;
@property (nonatomic, strong) UIView  *borderView;
@property (nonatomic, strong) UIView  *indicatorView;
@end

static NSString * const kMDCalendarViewCellIdentifier = @"kMDCalendarViewCellIdentifier";

@implementation MDCalendarViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        self.label = label;

        UIView *highlightView = [[UIView alloc] initWithFrame:CGRectZero];
        highlightView.hidden = YES;
        self.highlightView = highlightView;

        UIView *bottomBorderView = [[UIView alloc] initWithFrame:CGRectZero];
        bottomBorderView.hidden = YES;
        self.borderView = bottomBorderView;

        UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectZero];
        indicatorView.hidden = YES;
        self.indicatorView = indicatorView;

        [self.contentView addSubview:highlightView];
        [self.contentView addSubview:label];
        [self.contentView addSubview:bottomBorderView];
        [self.contentView addSubview:indicatorView];

        self.isAccessibilityElement = YES;
    }
    return self;
}

- (void)setDate:(NSDate *)date {
    _label.text = MDCalendarDayStringFromDate(date);
    self.accessibilityLabel = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
}

- (void)setFont:(UIFont *)font {
    _label.font = font;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    _label.textColor = textColor;
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightView.backgroundColor = highlightColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderView.backgroundColor = borderColor;
    _borderView.hidden = NO;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    _highlightView.hidden = !selected;
    _label.textColor = selected ? [UIColor whiteColor] : _textColor;
}

- (void)animateSelection {
    _highlightView.transform = CGAffineTransformMakeScale(.1f, .1f);

    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _highlightView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         nil;
                     }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGSize viewSize = self.contentView.bounds.size;
    _label.frame = CGRectMake(0, _borderHeight, viewSize.width, viewSize.height - _borderHeight);

    // bounds of highlight view 10% smaller than cell
    CGFloat highlightViewInset = viewSize.height * 0.1f;
    _highlightView.frame = CGRectInset(self.contentView.frame, highlightViewInset, highlightViewInset);
    _highlightView.layer.cornerRadius = CGRectGetHeight(_highlightView.bounds) / 2;

    _borderView.frame = CGRectMake(0, 0, viewSize.width, _borderHeight);

    CGFloat dotInset = viewSize.height * 0.45f;
    CGRect indicatorFrame = CGRectInset(self.contentView.frame, dotInset, dotInset);
    indicatorFrame.origin.y = _highlightView.frame.origin.y + _highlightView.frame.size.height - indicatorFrame.size.height * 1.5;
    _indicatorView.frame = indicatorFrame;
    _indicatorView.layer.cornerRadius = CGRectGetHeight(_indicatorView.bounds) / 2;

}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.contentView.backgroundColor = nil;
    _highlightView.hidden = YES;
    _label.text = @"";
    _label.textColor = _textColor;
}

#pragma mark - C Helpers

NSString * MDCalendarDayStringFromDate(NSDate *date) {
    return [NSString stringWithFormat:@"%d", (int)[date day]];
}

@end

@interface MDCalendarWeekdaysView : UIView
@property (nonatomic, strong) NSArray *dayLabels;

@property (nonatomic, assign) UIColor *textColor;
@property (nonatomic, assign) UIFont  *font;
@end

@implementation MDCalendarWeekdaysView

@synthesize font = pFont;

+ (CGFloat)preferredHeightWithFont:(UIFont *)font {
    static CGFloat height;
    static dispatch_once_t onceTokenForWeekdayViewHeight;
    dispatch_once(&onceTokenForWeekdayViewHeight, ^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *day = [[formatter shortStandaloneWeekdaySymbols] firstObject];
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dayLabel.text = day;
        dayLabel.font = font;
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.adjustsFontSizeToFitWidth = YES;
        height = [dayLabel sizeThatFits:CGSizeZero].height;
    });
    return height;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSArray *weekdays = [formatter localizedShortWeekdaySymbols];
        NSMutableArray *dayLabels = [NSMutableArray new];
        for (NSString *day in weekdays) {
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            dayLabel.text = day;
            dayLabel.font = self.font;
            dayLabel.textAlignment = NSTextAlignmentCenter;
            dayLabel.adjustsFontSizeToFitWidth = YES;
            [dayLabels addObject:dayLabel];

            [self addSubview:dayLabel];

            self.isAccessibilityElement = YES;
        }

        self.dayLabels = dayLabels;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    return CGSizeMake(viewWidth, [MDCalendarWeekdaysView preferredHeightWithFont:self.font]);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat labelWidth = CGRectGetWidth(self.bounds) / [_dayLabels count];
    CGRect labelFrame = CGRectMake(0, 0, labelWidth, [MDCalendarWeekdaysView preferredHeightWithFont:self.font]);
    for (UILabel *label in _dayLabels) {
        label.frame = labelFrame;
        labelFrame = CGRectOffset(labelFrame, labelWidth, 0);
    }
}

- (void)setTextColor:(UIColor *)textColor {
    for (UILabel *label in _dayLabels) {
        label.textColor = textColor;
    }
}

- (void)setFont:(UIFont *)font {
    for (UILabel *label in _dayLabels) {
        label.font = font;
    }
}

#pragma mark - UIAccessibility

- (NSString *)accessibilityLabel {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSArray *weekdays = [formatter localizedStandaloneWeekdaySymbols];
    return [NSString stringWithFormat:@"Weekdays, %@ through %@", weekdays.firstObject, weekdays.lastObject];
}

@end

@interface MDCalendarHeaderView : UICollectionReusableView
@property (nonatomic, assign) NSDate *firstDayOfMonth;
@property (nonatomic, assign) BOOL    shouldShowYear;

@property (nonatomic, assign) UIFont  *font;
@property (nonatomic, assign) UIColor *textColor;

@property (nonatomic, assign) UIFont  *weekdayFont;
@property (nonatomic, assign) UIColor *weekdayTextColor;
@end

@interface MDCalendarHeaderView ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) MDCalendarWeekdaysView *weekdaysView;
@end

static NSString * const kMDCalendarHeaderViewIdentifier = @"kMDCalendarHeaderViewIdentifier";
static NSString * const kMDCalendarFooterViewIdentifier = @"kMDCalendarFooterViewIdentifier";
static CGFloat const kMDCalendarHeaderViewMonthBottomMargin     = 10.f;
static CGFloat const kMDCalendarHeaderViewWeekdayBottomMargin   = 5.f;


@implementation MDCalendarHeaderView

+ (CGFloat)preferredHeightWithMonthLabelFont:(UIFont *)monthFont
                              andWeekdayFont:(UIFont *)weekdayFont{
    static CGFloat headerHeight;
    static dispatch_once_t onceTokenForHeaderViewHeight;
    dispatch_once(&onceTokenForHeaderViewHeight, ^{
        CGFloat monthLabelHeight = [self heightForMonthLabelWithFont:monthFont];
        CGFloat weekdaysViewHeight = [MDCalendarWeekdaysView preferredHeightWithFont:weekdayFont];
        CGFloat marginHeights = kMDCalendarHeaderViewMonthBottomMargin + kMDCalendarHeaderViewWeekdayBottomMargin;
        headerHeight = monthLabelHeight + weekdaysViewHeight + marginHeights;
    });
    return headerHeight;
}

+ (CGFloat)heightForMonthLabelWithFont:(UIFont *)font {
    static CGFloat monthLabelHeight;
    static dispatch_once_t onceTokenForMonthLabelHeight;

    dispatch_once(&onceTokenForMonthLabelHeight, ^{
        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        monthLabel.textAlignment = NSTextAlignmentCenter;
        monthLabel.font = font;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        monthLabel.text = [formatter monthSymbols].firstObject;
        monthLabelHeight = [monthLabel sizeThatFits:CGSizeZero].height;
    });

    return monthLabelHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;

        MDCalendarWeekdaysView *weekdaysView = [[MDCalendarWeekdaysView alloc] initWithFrame:CGRectZero];
        [self addSubview:weekdaysView];
        self.weekdaysView = weekdaysView;

        [self addSubview:label];
        self.label = label;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGSize viewSize = self.bounds.size;
    _label.frame = CGRectMake(0, 0, viewSize.width, (viewSize.height / 3 * 2) - kMDCalendarHeaderViewMonthBottomMargin);
    _weekdaysView.frame = CGRectMake(0, CGRectGetMaxY(_label.frame) + kMDCalendarHeaderViewMonthBottomMargin, viewSize.width, viewSize.height - CGRectGetHeight(_label.bounds) - kMDCalendarHeaderViewWeekdayBottomMargin);
}

- (CGSize)sizeThatFits:(CGSize)size {
    static BOOL firstTime = YES;
    static CGSize calendarHeaderViewSize;
    if (firstTime) {
        calendarHeaderViewSize = CGSizeMake([super sizeThatFits:size].width, [MDCalendarHeaderView preferredHeightWithMonthLabelFont:self.font andWeekdayFont:self.weekdayFont]);
    }
    return calendarHeaderViewSize;
}

- (void)setFirstDayOfMonth:(NSDate *)firstDayOfMonth {
    _firstDayOfMonth = firstDayOfMonth;
    NSInteger monthIndex = [firstDayOfMonth month];
    NSArray *monthSymbols = [@[ @"Zero" ] arrayByAddingObjectsFromArray:[[[NSDateFormatter alloc] init] monthSymbols]];
    NSString *monthString = monthSymbols[monthIndex];
    NSString *yearString = [NSString stringWithFormat:@" %d", (int)[firstDayOfMonth year]];
    _label.text = _shouldShowYear ? [monthString stringByAppendingString:yearString] : monthString;
}

- (void)setFont:(UIFont *)font {
    _label.font = font;
}

- (void)setTextColor:(UIColor *)textColor {
    _label.textColor = textColor;
}

- (void)setWeekdayFont:(UIFont *)weekdayFont {
    _weekdaysView.font = weekdayFont;
}

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor {
    _weekdaysView.textColor = weekdayTextColor;
}


@end

@interface MDCalendarFooterView : UICollectionReusableView
@property (nonatomic, assign) CGFloat  borderHeight;
@property (nonatomic, assign) UIColor *borderColor;
@end

@interface MDCalendarFooterView ()
@property (nonatomic, strong) UIView *bottomBorder;
@end

@implementation MDCalendarFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *bottomBorderView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:bottomBorderView];
        self.bottomBorder = bottomBorderView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _bottomBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), _borderHeight);
}

- (void)setBorderColor:(UIColor *)borderColor {
    _bottomBorder.backgroundColor = borderColor;
}

@end

@interface MDCalendar () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, assign) NSDate *currentDate;
@end

#define DAYS_IN_WEEK 7
#define MONTHS_IN_YEAR 12

// Default spacing
static CGFloat const kMDCalendarViewItemSpacing    = 0.f;
static CGFloat const kMDCalendarViewLineSpacing    = 1.f;
static CGFloat const kMDCalendarViewSectionSpacing = 10.f;

@implementation MDCalendar

- (instancetype)init {
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing  = kMDCalendarViewItemSpacing;
        layout.minimumLineSpacing       = kMDCalendarViewLineSpacing;
        self.layout = layout;
        layout.headerReferenceSize = CGSizeMake(300, 30);

        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate   = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.allowsMultipleSelection = YES;

        [_collectionView registerClass:[MDCalendarViewCell class] forCellWithReuseIdentifier:kMDCalendarViewCellIdentifier];
        [_collectionView registerClass:[MDCalendarHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMDCalendarHeaderViewIdentifier];
        [_collectionView registerClass:[MDCalendarFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kMDCalendarFooterViewIdentifier];


        // Default Configuration
        self.startDate      = [self currentDateSansTime];
        _selectedDates		= @[];
        self.endDate        = [[_startDate dateByAddingMonths:3] lastDayOfMonth];

        self.dayFont        = [UIFont systemFontOfSize:17];
        self.weekdayFont    = [UIFont systemFontOfSize:12];

        self.cellBackgroundColor    = nil;
        self.highlightColor         = self.tintColor;

        self.headerBackgroundColor  = nil;
        self.headerFont             = [UIFont systemFontOfSize:20];

        self.textColor          = [UIColor darkGrayColor];
        self.headerTextColor    = _textColor;
        self.weekdayTextColor   = _textColor;

        self.canSelectDaysBeforeStartDate = YES;

        [self addSubview:_collectionView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _collectionView.frame = self.bounds;
    [self scrollCalendarToDate:_selectedDates.firstObject animated:NO];
}

#pragma mark - Custom Accessors

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _collectionView.backgroundColor = backgroundColor;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _collectionView.contentInset = contentInset;
}

- (void)setItemSpacing:(CGFloat)itemSpacing {
    _layout.minimumInteritemSpacing = itemSpacing;
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _layout.minimumLineSpacing = lineSpacing;
}

- (CGFloat)lineSpacing {
    return _layout.minimumLineSpacing;
}

- (void)setBorderHeight:(CGFloat)borderHeight {
    _borderHeight = borderHeight;
    if (borderHeight) {
        self.lineSpacing = 0.f;
    }
}

- (NSDate *)currentDate {
    return [NSDate date];
}

- (NSDate *)currentDateSansTime {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSCalendarUnitMonth|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit fromDate:now];
    return [calendar dateFromComponents:components];
}

- (void)setSelectedDates:(NSArray *)selectedDates {
    if (_selectedDates != selectedDates) {
        _selectedDates = selectedDates;

        [_selectedDates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [self indexPathForDate:obj];
            [_collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }];
    }
}

#pragma mark - Public Methods

- (void)scrollCalendarToDate:(NSDate *)date animated:(BOOL)animated {
    UICollectionView *collectionView = _collectionView;
    NSIndexPath *indexPath = [self indexPathForDate:date];
    NSSet *visibleIndexPaths = [NSSet setWithArray:[collectionView indexPathsForVisibleItems]];
    if (indexPath && ![visibleIndexPaths containsObject:indexPath]) {
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:animated];
    }
}

#pragma mark - Private Methods & Helper Functions

- (NSInteger)monthForSection:(NSInteger)section {
    NSDate *firstDayOfMonth = [[_startDate firstDayOfMonth] dateByAddingMonths:section];
    return [firstDayOfMonth month];
}

- (NSDate *)dateForFirstDayOfSection:(NSInteger)section {
    return [[_startDate firstDayOfMonth] dateByAddingMonths:section];
}

- (NSDate *)dateForLastDayOfSection:(NSInteger)section {
    NSDate *firstDayOfMonth = [self dateForFirstDayOfSection:section];
    return [firstDayOfMonth lastDayOfMonth];
}

- (NSInteger)offsetForSection:(NSInteger)section {
    NSDate *firstDayOfMonth = [self dateForFirstDayOfSection:section];
    return [firstDayOfMonth localizedWeekday] - 1;
}

- (NSInteger)remainderForSection:(NSInteger)section {
    NSDate *lastDayOfMonth = [self dateForLastDayOfSection:section];
    NSInteger weekday = [lastDayOfMonth weekday];
    return DAYS_IN_WEEK - weekday;
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [_startDate dateByAddingMonths:indexPath.section];
    NSDateComponents *components = [date components];
    components.day = indexPath.item + 1;
    date = [NSDate dateFromComponents:components];

    NSInteger offset = [self offsetForSection:indexPath.section];
    if (offset) {
        date = [date dateByAddingDays:-offset];
    }

    return date;
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date {
    NSIndexPath *indexPath = nil;
    if (date) {
        NSDate *firstDayOfCalendar = [_startDate firstDayOfMonth];
        NSInteger section = [firstDayOfCalendar numberOfMonthsUntilEndDate:date];
        NSInteger dayOffset = [self offsetForSection:section];
        NSInteger dayIndex = [date day] + dayOffset - 1;
        indexPath = [NSIndexPath indexPathForItem:dayIndex inSection:section];
    }
    return indexPath;
}

- (CGRect)frameForHeaderForSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:section];
    UICollectionViewLayoutAttributes *attributes = [_collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect frameForFirstCell = attributes.frame;
    CGFloat headerHeight = [self collectionView:_collectionView layout:_layout referenceSizeForHeaderInSection:section].height;
    return CGRectOffset(frameForFirstCell, 0, -headerHeight);
}

- (void)scrollCalendarToTopOfSection:(NSInteger)section animated:(BOOL)animated {
    CGRect headerRect = [self frameForHeaderForSection:section];
    CGPoint topOfHeader = CGPointMake(0, headerRect.origin.y - _collectionView.contentInset.top);
    [_collectionView setContentOffset:topOfHeader animated:animated];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_startDate numberOfMonthsUntilEndDate:_endDate] + 1;    // Adding 1 necessary to show month of end date
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDate *firstDayOfMonth = [self dateForFirstDayOfSection:section];
    NSInteger month = [firstDayOfMonth month];
    NSInteger year  = [firstDayOfMonth year];
    return [NSDate numberOfDaysInMonth:month forYear:year] + [self offsetForSection:section] + [self remainderForSection:section];
}

#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [self dateForIndexPath:indexPath];

    MDCalendarViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMDCalendarViewCellIdentifier forIndexPath:indexPath];

    cell.backgroundColor = _cellBackgroundColor;
    cell.font = _dayFont;
    cell.textColor = [cell isSelected] ? [UIColor whiteColor] : _textColor;
    cell.date = date;
    cell.highlightColor = _highlightColor;
    cell.borderHeight = _borderHeight;
    cell.borderColor = _borderColor;

    BOOL showIndicator = NO;
    if ([_delegate respondsToSelector:@selector(calendarView:shouldShowIndicatorForDate:)]) {
        showIndicator = [_delegate calendarView:self shouldShowIndicatorForDate:date];
    }

    NSInteger sectionMonth = [self monthForSection:indexPath.section];

    // Disable non-selectable cells
    if (![self collectionView:collectionView shouldSelectItemAtIndexPath:indexPath]) {
        cell.textColor = [date isEqualToDateSansTime:[self currentDate]] ? cell.textColor : [cell.textColor colorWithAlphaComponent:0.2];
        //		cell.userInteractionEnabled = NO;

        // If the cell is outside the selectable range, and it is not today, tell the user
        // that it is an invalid date ("dimmed" is what Apple uses for disabled buttons).
        cell.accessibilityLabel = [cell.accessibilityLabel stringByAppendingString:@", dimmed"];
    }

    // Handle showing cells outside of current month
    cell.accessibilityElementsHidden = NO;
    if ([date month] != sectionMonth) {
        if (_showsDaysOutsideCurrentMonth) {
            cell.backgroundColor = [cell.backgroundColor colorWithAlphaComponent:0.2];
            cell.textColor = [cell.textColor colorWithAlphaComponent:0.2];
        } else {
            cell.label.text = @"";
            showIndicator = NO;
            cell.accessibilityElementsHidden = YES;
        }
        //		cell.userInteractionEnabled = NO;
    }

    cell.indicatorColor = showIndicator ? _indicatorColor : [UIColor clearColor];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    UICollectionReusableView *view;

    if (kind == UICollectionElementKindSectionHeader) {
        MDCalendarHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMDCalendarHeaderViewIdentifier forIndexPath:indexPath];

        headerView.backgroundColor = _headerBackgroundColor;
        headerView.font = _headerFont;
        headerView.weekdayFont = _weekdayFont;
        headerView.textColor = _headerTextColor;
        headerView.weekdayTextColor = _weekdayTextColor;

        NSDate *date = [self dateForFirstDayOfSection:indexPath.section];
        headerView.shouldShowYear = [date year] != [_startDate year];
        headerView.firstDayOfMonth = date;

        view = headerView;
    } else if (kind == UICollectionElementKindSectionFooter) {
        MDCalendarFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kMDCalendarFooterViewIdentifier forIndexPath:indexPath];
        footerView.borderHeight = _showsBottomSectionBorder ? _borderHeight : 0.f;
        footerView.borderColor  = _borderColor;
        view = footerView;
    }

    return view;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [self dateForIndexPath:indexPath];

    NSMutableArray *mHighlights = [self.selectedDates mutableCopy];
    [mHighlights addObject:date];
    self.selectedDates = [NSArray arrayWithArray:mHighlights];

    [_delegate calendarView:self didSelectDate:date];

    MDCalendarViewCell *cell = (MDCalendarViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell animateSelection];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [self dateForIndexPath:indexPath];

    NSMutableArray *mHighlights = [self.selectedDates mutableCopy];
    [mHighlights removeObject:date];
    self.selectedDates = [NSArray arrayWithArray:mHighlights];

    [_delegate calendarView:self didDeselectDate:date];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [self dateForIndexPath:indexPath];
    
    if ([date isBeforeDate:[self currentDateSansTime]] && !_canSelectDaysBeforeStartDate) {
        return NO;
    }
    
    NSInteger sectionMonth = [self monthForSection:indexPath.section];
    if ([date month] != sectionMonth) {
        if (_showsDaysOutsideCurrentMonth) {
            return NO;
        }
    }
    
    if ([_delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)]) {
        return [_delegate calendarView:self shouldSelectDate:date];
    }
    
    return YES;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth = [self cellWidth];
    CGFloat cellHeight = cellWidth;
    return CGSizeMake(cellWidth, cellHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat boundsWidth = collectionView.bounds.size.width;
    return CGSizeMake(boundsWidth, [MDCalendarHeaderView preferredHeightWithMonthLabelFont:_headerFont andWeekdayFont:_weekdayFont]);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(self.bounds), kMDCalendarViewSectionSpacing);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat boundsWidth = collectionView.bounds.size.width;
    CGFloat remainingPoints = boundsWidth - ([self cellWidth] * DAYS_IN_WEEK);
    return UIEdgeInsetsMake(0, remainingPoints / 2, 0, remainingPoints / 2);
}

// Helpers

- (CGFloat)cellWidth {
    CGFloat boundsWidth = _collectionView.bounds.size.width;
    return floor(boundsWidth / DAYS_IN_WEEK) - kMDCalendarViewItemSpacing;
}

@end
