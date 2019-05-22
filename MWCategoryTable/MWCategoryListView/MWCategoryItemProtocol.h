//
//  MWCategoryItemProtocol.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#ifndef MWCategoryItemProtocol_h
#define MWCategoryItemProtocol_h

#import "MWCategoryTableManagerProtocol.h"

@protocol MWCategoryItemProtocol <NSObject>

@required
- (NSString *)categoryName;
- (id<MWCategoryTableManagerProtocol>)tableManager;

@end

#endif /* MWCategoryItemProtocol_h */
