//
//  HorizontalScrollView.m
//  paykey-ios-interview
//
//  Created by Ishay Weinstock on 12/16/14.
//  Copyright (c) 2014 Ishay Weinstock. All rights reserved.
//

#import "HorizontalTableView.h"

#define SEPARATOR_WIDTH 1
#define DEFAULT_CELL_WIDTH 100

@interface HorizontalTableView() <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *visibleCells;
@property (nonatomic, strong) NSMutableArray *hiddenCells;

@end

@implementation HorizontalTableView

- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.delegate = self;
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self defineCells];
}

- (void) layoutSubviews {
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    NSInteger numOfCells = [self.dataSource horizontalTableViewNumberOfCells:self];
    self.scrollView.contentSize = CGSizeMake(((DEFAULT_CELL_WIDTH + SEPARATOR_WIDTH) * numOfCells), self.frame.size.height);
    self.visibleCells = [[NSMutableDictionary alloc] init];
    self.hiddenCells = [[NSMutableArray alloc] init];
    [self defineCells];
}

- (UIView*) dequeueCell {
    UIView *cell = nil;
    if (self.hiddenCells.count > 0) {
        cell = [self.hiddenCells lastObject];
        [self.hiddenCells removeObject:cell];
    }
    return cell;
}

- (void) recycleCells :(NSMutableDictionary*)cells {
    NSArray *allKeys = [cells allKeys];
    for (int i = 0; i < allKeys.count; i++) {
        UIView *cell = [cells objectForKey:[allKeys objectAtIndex:i]];
        [self.hiddenCells addObject:cell];
        [cell removeFromSuperview];
    }
}

- (UIView*) generateCell: (NSInteger)index {
    UIView *cell = [self.dataSource horizontalTableView:self cellForIndex:index];
    [cell setFrame:CGRectMake(index * (DEFAULT_CELL_WIDTH + SEPARATOR_WIDTH), 0, DEFAULT_CELL_WIDTH, self.frame.size.height)];
    return cell;
}

- (void) defineCells {
    NSInteger firstVisibleCellIndex = self.scrollView.contentOffset.x / (DEFAULT_CELL_WIDTH + SEPARATOR_WIDTH);
    NSInteger lastVisibleCellIndex = (self.scrollView.contentOffset.x + self.frame.size.width) / (DEFAULT_CELL_WIDTH + SEPARATOR_WIDTH);
    
    NSMutableDictionary *visibleCellsCopy = [self.visibleCells mutableCopy];
    [self.visibleCells removeAllObjects];
    
    for (NSInteger currentIndex = firstVisibleCellIndex; currentIndex <= lastVisibleCellIndex; currentIndex++) {
        UIView *cell = [visibleCellsCopy objectForKey:[NSNumber numberWithInteger:currentIndex]];
        if (cell == nil) {
            cell = [self generateCell:currentIndex];
            [self.scrollView addSubview:cell];
            [self.visibleCells setObject:cell forKey:[NSNumber numberWithInteger:currentIndex]];
        } else {
            [visibleCellsCopy removeObjectForKey:[NSNumber numberWithInteger:currentIndex]];
            [self.visibleCells setObject:cell forKey:[NSNumber numberWithInteger:currentIndex]];
        }
    }
    
    [self recycleCells:visibleCellsCopy];
    visibleCellsCopy = nil;
}

@end
