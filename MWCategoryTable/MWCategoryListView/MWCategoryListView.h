//
//  MWCategoryListView.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

/*
 TODO：
 如果tableView正在刷新，切换分类，再切换回来，原始 contentInset bottom 40，切换回来 bottom变为0，造成底部上移40
 */

#import <UIKit/UIKit.h>
#import "MWCategoryItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWCategoryListView : UIView

@property (nonatomic, assign) CGFloat topInset;
@property (nonatomic, assign) CGFloat bottomInset;
@property (nonatomic, assign) CGFloat tabViewHeight; // 默认40
@property (nonatomic, strong) NSArray<id<MWCategoryItemProtocol>> *categories; // 设置分类条目，包含必要的协议
@property (nonatomic, strong) NSArray<NSValue *> *categoryContentInsets; // 设置分类内容相对内边距，默认UIEdgeInsetsZero

- (instancetype)initWithCategories:(NSArray<id<MWCategoryItemProtocol>> *)categories;
- (instancetype)initWithFrame:(CGRect)frame
                   categories:(NSArray<id<MWCategoryItemProtocol>> *)categories;

@end

NS_ASSUME_NONNULL_END
