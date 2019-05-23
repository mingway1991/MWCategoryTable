//
//  MWNewsCellModel.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/23.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWNewsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWNewsCellModel : NSObject

@property (nonatomic, strong) MWNewsModel *newsModel;
// 左右内边距
@property (nonatomic, assign) CGFloat leftRightMargin;
// 标题
@property (nonatomic, strong) NSAttributedString *titleAttributedString;
@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, strong) YYTextLayout *titleTextLayout;
// 图片
@property (nonatomic, assign) BOOL hasImage;
@property (nonatomic, assign) CGFloat imageMinY;
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, assign) CGFloat imagePadding;
// 来源
@property (nonatomic, strong) NSAttributedString *sourceAttributedString;
@property (nonatomic, assign) CGRect sourceFrame;
@property (nonatomic, strong) YYTextLayout *sourceTextLayout;
// 底部的线
@property (nonatomic, assign) BOOL hasLine;
@property (nonatomic, assign) CGRect lineFrame;

@property (nonatomic, assign) CGFloat cellHeight;

@end

NS_ASSUME_NONNULL_END
