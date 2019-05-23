//
//  MWCategoryModel.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWCategoryModel.h"
#import "MWCategoryTableManager.h"
#import "MWCategoryTableManagerProtocol.h"

@interface MWCategoryModel ()

@property (nonatomic, strong) MWCategoryTableManager *tableManager;

@end

@implementation MWCategoryModel

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (MWCategoryTableManager *)tableManager {
    if (!_tableManager) {
        self.tableManager = [[MWCategoryTableManager alloc] init];
        _tableManager.parentCategoryModel = self;
    }
    return _tableManager;
}

@end
