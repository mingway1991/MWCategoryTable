//
//  MWNewsModel.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/22.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWNewsModel.h"

@implementation MWNewsImageModel

@end

@implementation MWNewsModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"image_list" : [MWNewsImageModel class]};
}

@end
