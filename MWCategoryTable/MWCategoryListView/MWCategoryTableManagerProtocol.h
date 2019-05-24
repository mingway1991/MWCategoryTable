//
//  MWCategoryTableManagerProtocol.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#ifndef MWCategoryTableManagerProtocol_h
#define MWCategoryTableManagerProtocol_h

#import <UIKit/UIKit.h>

@protocol MWCategoryTableManagerProtocol <NSObject>

@required
- (UIEdgeInsets)inset;  // 默认传UIEdgeInsetsZero，如果需要在table上l预留空间，则设置对应的值
- (UIScrollView *)contentTableView; // 返回scrollView、tableView、collectionView，用于内容显示

@optional
- (void)didAppear; // 已经显示当前分类内容视图
- (void)didDisappear; // 当前分类内容视图已经消失

@end

#endif /* MWCategoryTableManagerProtocol_h */
