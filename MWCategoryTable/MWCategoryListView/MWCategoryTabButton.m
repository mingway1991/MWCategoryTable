//
//  MWCategoryTabButton.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWCategoryTabButton.h"

// 字体大小
#define kMWCategoryTabButtonNormalFont [UIFont systemFontOfSize:18.f]
#define kMWCategoryTabButtonSelectedFont [UIFont boldSystemFontOfSize:18.f]
// 字间距
#define kMWCategoryTabButtonKern @(1.0f)

@interface MWCategoryTabButton ()

@property (nonatomic, assign) BOOL isSelect;

@end

@implementation MWCategoryTabButton

// 段落格式
+ (NSParagraphStyle *)paragraphStyle {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    return paragraphStyle;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    NSString *displayStr = self.category.categoryName;
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:displayStr];
    [attr addAttribute:NSParagraphStyleAttributeName value:[[self class] paragraphStyle] range:NSMakeRange(0, displayStr.length)];
    [attr addAttribute:NSKernAttributeName value:kMWCategoryTabButtonKern range:NSMakeRange(0, displayStr.length)];
    UIFont *font;
    if (self.isSelect) {
        font = kMWCategoryTabButtonSelectedFont;
        [attr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, displayStr.length)];
    } else {
        font = kMWCategoryTabButtonNormalFont;
        [attr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, displayStr.length)];
    }
    [attr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, displayStr.length)];
    
    CGFloat fontHeight = font.pointSize;
    CGFloat yOffset = (rect.size.height - fontHeight) / 2.0;
    CGRect textRect = CGRectMake(0, yOffset, rect.size.width, rect.size.height-yOffset);
    [attr drawInRect:textRect];
}

- (void)updateUIWithCategory:(id<MWCategoryItemProtocol>)category
                    isSelect:(BOOL)isSelect {
    self.category = category;
    self.isSelect = isSelect;
    [self setNeedsDisplay];
}

+ (CGFloat)WidthForCategory:(id<MWCategoryItemProtocol>)category {
    NSString *categoryName = category.categoryName;
    
    CGFloat maxWidth = 100.f;
    CGFloat categoryNameWidth = [categoryName boundingRectWithSize:CGSizeMake(maxWidth, 30.f) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: kMWCategoryTabButtonSelectedFont, NSParagraphStyleAttributeName: [[self class] paragraphStyle], NSKernAttributeName: kMWCategoryTabButtonKern} context:nil].size.width;
    return categoryNameWidth+20.f;
}

@end
