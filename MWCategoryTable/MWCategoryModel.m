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

@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, strong) MWCategoryTableManager *tableManager;

@end

@implementation MWCategoryModel

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *demo = @[@"哈哈哈",@"啥的",@"测试啊",@"测试",@"上电",@"所产生",@"v",@"的穿的"];
        _categoryName = demo[arc4random()%8];
    }
    return self;
}

- (NSString *)categoryName {
    return _categoryName;
}

- (id<MWCategoryTableManagerProtocol>)tableManager {
    if (!_tableManager) {
        self.tableManager = [[MWCategoryTableManager alloc] init];
    }
    return _tableManager;
}

@end
