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

- (void)prepareForReuse {
    [super prepareForReuse];
    for (UIImageView *imageView in self.imageViews) {
        imageView.image = nil;
    }
}

- (void)updateUIWithNewsCellModel:(MWNewsCellModel *)newsCellModel {
    self.titleLabel.attributedText = newsCellModel.titleAttributedString;
    self.titleLabel.frame = newsCellModel.titleFrame;
    self.titleLabel.textLayout = newsCellModel.titleTextLayout;
    
    if (newsCellModel.hasImage) {
        CGFloat imageMinX = newsCellModel.leftRightMargin;
        NSInteger imageViewCount = self.imageViews.count;
        NSInteger imageCount = MIN(newsCellModel.newsModel.image_list.count, 3);
        
        // 将存在的imageView显示出来
        for (NSInteger i=0; i<MIN(imageCount, imageViewCount); i++) {
            UIImageView *imageView = self.imageViews[i];
            imageView.hidden = NO;
            imageView.frame = CGRectMake(imageMinX+i*(newsCellModel.imageWidth+newsCellModel.imagePadding), newsCellModel.imageMinY, newsCellModel.imageWidth, newsCellModel.imageHeight);
        }
        // 隐藏多余的imageView
        for (NSInteger i=imageCount; i<imageViewCount; i++) {
            UIImageView *imageView = self.imageViews[i];
            imageView.hidden = YES;
        }
        // 创建不足的imageView
        for (NSInteger i=imageViewCount; i<imageCount; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(imageMinX+i*(newsCellModel.imageWidth+newsCellModel.imagePadding), newsCellModel.imageMinY, newsCellModel.imageWidth, newsCellModel.imageHeight);
            [self.contentView addSubview:imageView];
            [self.imageViews addObject:imageView];
        }
        // 显示图片
        for (NSInteger i=0; i<imageCount; i++) {
            MWNewsImageModel *imageModel = newsCellModel.newsModel.image_list[i];
            UIImageView *imageView = self.imageViews[i];
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"https:", imageModel.url]]];
        }
    } else {
        for (UIImageView *imageView in self.imageViews) {
            imageView.hidden = YES;
        }
    }
    
    self.sourceLabel.attributedText = newsCellModel.sourceAttributedString;
    self.sourceLabel.frame = newsCellModel.sourceFrame;
    self.sourceLabel.textLayout = newsCellModel.sourceTextLayout;
    
    self.lineView.hidden = !newsCellModel.hasLine;
    self.lineView.frame = newsCellModel.lineFrame;
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
