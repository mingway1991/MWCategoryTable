//
//  MWNewsModel.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/22.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <Foundation/Foundation.h>

@import YYKit;

NS_ASSUME_NONNULL_BEGIN

@interface MWNewsImageModel : NSObject

@property (nonatomic, copy) NSString *url;

@end

@interface MWNewsModel : NSObject

@property (nonatomic, copy) NSString *abstract;
@property (nonatomic, copy) NSString *article_genre;
@property (nonatomic, assign) NSTimeInterval behot_time;
@property (nonatomic, copy) NSString *chinese_tag;
@property (nonatomic, assign) NSInteger comments_count;
@property (nonatomic, copy) NSString *group_id;
@property (nonatomic, strong) NSNumber *group_source;
@property (nonatomic, strong) NSNumber *has_gallery;
@property (nonatomic, strong) NSNumber *has_video;
@property (nonatomic, copy) NSString *image_url;
@property (nonatomic, copy) NSString *item_id;
@property (nonatomic, strong) NSNumber *is_feed_ad;
@property (nonatomic, strong) NSNumber *is_stick;
@property (nonatomic, copy) NSString *media_avatar_url;
@property (nonatomic, copy) NSString *media_url;
@property (nonatomic, copy) NSString *middle_image;
@property (nonatomic, strong) NSNumber *middle_mode;
@property (nonatomic, strong) NSNumber *more_mode;
@property (nonatomic, strong) NSNumber *single_mode;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *source_url;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *tag_url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *video_duration_str;
@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, assign) NSNumber *video_play_count;
@property (nonatomic, strong) NSArray<MWNewsImageModel *> *image_list;

@end

NS_ASSUME_NONNULL_END
