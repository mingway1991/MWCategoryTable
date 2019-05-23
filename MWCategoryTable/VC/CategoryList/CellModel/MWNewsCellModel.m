//
//  MWNewsCellModel.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/23.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWNewsCellModel.h"
#import "MWCategoryNewsCell.h"
#import "MWDefines.h"

@interface MWNewsCellModel ()

@property (nonatomic, assign) CGFloat imageWidthHeightRate;

@end

@implementation MWNewsCellModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hasLine = YES;
        self.leftRightMargin = 20.f;
        self.imageWidthHeightRate = 5.f/3.f;
        self.imagePadding = 5.f;
        self.imageWidth = ((MWScreenWidth-2*self.leftRightMargin)-2*self.imagePadding)/3.f;
        self.imageHeight = self.imageWidth/self.imageWidthHeightRate;
    }
    return self;
}

- (void)setNewsModel:(MWNewsModel *)newsModel {
    _newsModel = newsModel;
    _cellHeight = 0;
    [self _generateTitleAttributedString];
    [self _generateSourceAttributedString];
    [self _generateTitleFrame];
    [self _generateImageFrame];
    [self _generateSourceFrame];
    [self _generateLineFrame];
}

- (CGFloat)cellHeight {
    if (_cellHeight == 0 && _newsModel) {
        self.cellHeight = CGRectGetMaxY(self.lineFrame);
    }
    return _cellHeight;
}

#pragma mark - Private
- (void)_generateTitleAttributedString {
    NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithString:self.newsModel.title?:@""];
    titleAttributedString.alignment = NSTextAlignmentLeft;
    titleAttributedString.lineSpacing = 5;
    titleAttributedString.font = [UIFont systemFontOfSize:16];
    titleAttributedString.color = [UIColor blackColor];
    self.titleAttributedString = titleAttributedString;
}

- (void)_generateSourceAttributedString {
    NSMutableAttributedString *sourceAttributedString = [[NSMutableAttributedString alloc] initWithString:self.newsModel.source?:@""];
    sourceAttributedString.alignment = NSTextAlignmentLeft;
    sourceAttributedString.lineSpacing = 5;
    sourceAttributedString.font = [UIFont systemFontOfSize:12];
    sourceAttributedString.color = [UIColor lightGrayColor];
    self.sourceAttributedString = sourceAttributedString;
}

- (void)_generateTitleFrame {
    CGFloat titleMaxWidth = MWScreenWidth-2*self.leftRightMargin;
    YYTextContainer *titleContarer = [YYTextContainer new];
    titleContarer.size = CGSizeMake(titleMaxWidth, CGFLOAT_MAX);
    titleContarer.maximumNumberOfRows = 0;
    YYTextLayout *titleLayout = [YYTextLayout layoutWithContainer:titleContarer text:self.titleAttributedString];
    self.titleTextLayout = titleLayout;
    self.titleFrame = CGRectMake(self.leftRightMargin, 15.f, titleMaxWidth, titleLayout.textBoundingSize.height);
}

- (void)_generateImageFrame {
    self.hasImage = self.newsModel.image_list.count==0 ? NO : YES;
    self.imageMinY = CGRectGetMaxY(self.titleFrame)+10.f;
}

- (void)_generateSourceFrame {
    CGFloat sourceMaxWidth = MWScreenWidth-2*self.leftRightMargin;
    YYTextContainer *sourceContarer = [YYTextContainer new];
    sourceContarer.size = CGSizeMake(sourceMaxWidth, CGFLOAT_MAX);
    sourceContarer.maximumNumberOfRows = 1;
    YYTextLayout *sourceLayout = [YYTextLayout layoutWithContainer:sourceContarer text:self.sourceAttributedString];
    self.sourceTextLayout = sourceLayout;
    self.sourceFrame = CGRectMake(self.leftRightMargin, self.hasImage ? self.imageMinY+self.imageHeight+10.f : CGRectGetMaxY(self.titleFrame)+10.f, sourceLayout.textBoundingSize.width, 14.f);
}

- (void)_generateLineFrame {
    CGFloat lineWidth = MWScreenWidth-2*self.leftRightMargin;
    self.lineFrame = CGRectMake(self.leftRightMargin, CGRectGetMaxY(self.sourceFrame)+14.5f, lineWidth, .5f);
}

@end
