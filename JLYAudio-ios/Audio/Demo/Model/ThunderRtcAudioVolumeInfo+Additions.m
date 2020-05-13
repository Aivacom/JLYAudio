//
//  ThunderRtcAudioVolumeInfo+Additions.m
//  JLYAudio
//
//  Created by iPhuan on 2019/10/21.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "ThunderRtcAudioVolumeInfo+Additions.h"
#include <objc/message.h>


static char const * const kIsMutedKey = "kRoomOwnerKey";


@implementation ThunderRtcAudioVolumeInfo (Additions)

- (BOOL)isMuted {
    NSNumber *value = objc_getAssociatedObject(self, kIsMutedKey);
    return value.boolValue;
}

- (void)setIsMuted:(BOOL)isMuted {
    objc_setAssociatedObject(self, kIsMutedKey, @(isMuted), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
