//
//  MWCategoryNewsCell.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/22.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWCategoryNewsCell.h"
#import "MWDefines.h"

@import YYKit;
@import SDWebImage;

const CGFloat kNewsCellLeftRightMargin = 20.f;
const CGFloat kNewsCellImageWidthHeightRate = 5.f/3.f; // 图片宽高比
const CGFloat kNewsCellImagePadding = 5.f;

@interface MWCategoryNewsCell ()

@property (nonatomic, strong) YYLabel *titleLabel;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViews;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) YYLabel *sourceLabel;

@end

@implementation MWCategoryNewsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.sourceLabel];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.lineView.frame = CGRectMake(kNewsCellLeftRightMargin, CGRectGetHeight(self.bounds)-.5f, CGRectGetWidth(self.bounds)-2*kNewsCellLeftRightMargin, .5f);
}

- (void)updateUIWithNewsModel:(MWNewsModel *)newsModel {
    CGFloat titleMaxWidth = MWScreenWidth-2*kNewsCellLeftRightMargin;
    YYTextLayout *titleTextLayout = [[self class] TextLayoutForNewModel:newsModel];
    self.titleLabel.textLayout = titleTextLayout;
    CGFloat titleLabelHeight = titleTextLayout.textBoundingSize.height;
    self.titleLabel.frame = CGRectMake(kNewsCellLeftRightMargin, 15.f, titleMaxWidth, ceilf(titleLabelHeight));
    
    CGFloat minY = CGRectGetMaxY(self.titleLabel.frame);
    
    if (newsModel.image_list.count > 0) {
        CGFloat imageMinX = kNewsCellLeftRightMargin;
        CGFloat imageMinY = minY+10.f;
        CGFloat imageViewWidth = ((MWScreenWidth-2*kNewsCellLeftRightMargin)-2*kNewsCellImagePadding)/3.f;
        CGFloat imageViewHeight = imageViewWidth/kNewsCellImageWidthHeightRate;
        NSInteger imageViewCount = self.imageViews.count;
        NSInteger imageCount = MIN(newsModel.image_list.count, 3);
        
        // 将存在的imageView显示出来
        for (NSInteger i=0; i<MIN(imageCount, imageViewCount); i++) {
            UIImageView *imageView = self.imageViews[i];
            imageView.hidden = NO;
            imageView.frame = CGRectMake(imageMinX+i*(imageViewWidth+kNewsCellImagePadding), imageMinY, imageViewWidth, imageViewHeight);
        }
        // 隐藏多余的imageView
        for (NSInteger i=imageCount; i<imageViewCount; i++) {
            UIImageView *imageView = self.imageViews[i];
            imageView.hidden = YES;
        }
        // 创建不足的imageView
        for (NSInteger i=imageViewCount; i<imageCount; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(imageMinX+i*(imageViewWidth+kNewsCellImagePadding), imageMinY, imageViewWidth, imageViewHeight);
            [self.contentView addSubview:imageView];
            [self.imageViews addObject:imageView];
        }
        // 显示图片
        for (NSInteger i=0; i<imageCount; i++) {
            MWNewsImageModel *imageModel = newsModel.image_list[i];
            UIImageView *imageView = self.imageViews[i];
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"https:", imageModel.url]]];
        }
        
        minY = imageMinY+imageViewHeight;
    } else {
        for (UIImageView *imageView in self.imageViews) {
            imageView.hidden = YES;
        }
    }
    
    minY += 10.f;
    self.sourceLabel.frame = CGRectMake(kNewsCellLeftRightMargin, minY, 160.f, 14.f);
    self.sourceLabel.attributedText = [[self class] SourceAttributedStringForNewsModel:newsModel];
}

+ (CGFloat)HeightForNewsModel:(MWNewsModel *)newsModel {
    CGFloat topMargin = 15.f;
    CGFloat titleLabelHeight = [[self class] TextLayoutForNewModel:newsModel].textBoundingSize.height;
    CGFloat titleAndImagePadding = 10.f;
    CGFloat imageViewWidth = ((MWScreenWidth-2*kNewsCellLeftRightMargin)-2*kNewsCellImagePadding)/3.f;
    CGFloat imageViewHeight = imageViewWidth/kNewsCellImageWidthHeightRate; // 宽高比 5:3
    CGFloat imageAndSourcePadding = 10.f;
    CGFloat sourceLabelHeight = 14.f;
    CGFloat bottomMargin = 15.f;
    
    CGFloat height = 0;
    if (newsModel.image_list.count > 0) {
        height = topMargin+ceilf(titleLabelHeight)+titleAndImagePadding+imageViewHeight+imageAndSourcePadding+sourceLabelHeight+bottomMargin;
    } else {
        height = topMargin+ceilf(titleLabelHeight)+imageAndSourcePadding+sourceLabelHeight+bottomMargin;
    }
    return height;
}

+ (YYTextLayout *)TextLayoutForNewModel:(MWNewsModel *)newsModel {
    CGFloat titleMaxWidth = MWScreenWidth-40;
    NSAttributedString *titleAttr = [self TitleAttributedStringForNewsModel:newsModel];
    YYTextContainer *titleContarer = [YYTextContainer new];
    titleContarer.size = CGSizeMake(titleMaxWidth, CGFLOAT_MAX);
    titleContarer.maximumNumberOfRows = 0;
    YYTextLayout *titleLayout = [YYTextLayout layoutWithContainer:titleContarer text:titleAttr];
    return titleLayout;
}

+ (NSAttributedString *)TitleAttributedStringForNewsModel:(MWNewsModel *)newsModel {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:newsModel.title];
    text.alignment = NSTextAlignmentLeft;
    text.lineSpacing = 5;
    text.font = [UIFont systemFontOfSize:16];
    text.color = [UIColor blackColor];
    return text;
}

+ (NSAttributedString *)SourceAttributedStringForNewsModel:(MWNewsModel *)newsModel {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:newsModel.source];
    text.alignment = NSTextAlignmentLeft;
    text.lineSpacing = 5;
    text.font = [UIFont systemFontOfSize:12];
    text.color = [UIColor lightGrayColor];
    return text;
}

#pragma mark - LazyLoad
- (YYLabel *)titleLabel {
    if (!_titleLabel) {
        self.titleLabel = [[YYLabel alloc] init];
    }
    return _titleLabel;
}

- (YYLabel *)sourceLabel {
    if (!_sourceLabel) {
        self.sourceLabel = [[YYLabel alloc] init];
    }
    return _sourceLabel;
}

- (NSMutableArray<UIImageView *> *)imageViews {
    if (!_imageViews) {
        self.imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

- (UIView *)lineView {
    if (!_lineView) {
        self.lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.0];
    }
    return _lineView;
}

@end
