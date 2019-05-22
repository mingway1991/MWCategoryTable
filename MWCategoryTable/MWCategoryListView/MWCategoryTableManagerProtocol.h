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
- (UIEdgeInsets)inset;
- (UIScrollView *)contentTableView;

@end

#endif /* MWCategoryTableManagerProtocol_h */
