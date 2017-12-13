//
//  PPAdModel.m
//  polarpro
//
//  Created by Vladimir Psyukalov on 13.12.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#import "PPAdModel.h"


@implementation PPAd

- (CGFloat)showTime {
    return _type == PPAdTypeImage ? _showTime : 0.f;
}

@end


@implementation PPAdModel

- (void)adsWithCompletion:(void (^)(NSArray<PPAd *> *, NSError *))completion {
    if (completion) {
        // TODO: Test;
        PPAd *ad0 = [PPAd new];
        ad0.type = PPAdTypeImage;
        ad0.URL = @"https://www.bhphotovideo.com/images/images1000x1000/polar_pro_850454006048_strapmount_gopro_backpack_scuba_mount_1144813.jpg";
        ad0.actionURL = @"https://vk.com";
        ad0.showTime = 2.f;
        
        PPAd *ad1 = [PPAd new];
        ad1.type = PPAdTypeImage;
        ad1.URL = @"http://image.helipal.com/polarpro-filter-p4p-cinema-shutter-big.jpg";
        ad1.actionURL = @"https://www.facebook.com";
        ad1.showTime = 2.f;
        
        PPAd *ad5 = [PPAd new];
        ad5.type = PPAdTypeGIF;
        ad5.URL = @"https://media1.giphy.com/media/3o7qE52FdzR7awdCo0/giphy.gif";
        ad1.actionURL = @"https://ok.ru";
        //
        completion(@[ad0, ad1, ad5], nil);
    }
}

@end
