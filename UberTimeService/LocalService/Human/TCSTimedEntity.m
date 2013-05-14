#import "TCSTimedEntity.h"
#import "UIColor+PBFoundation.h"

TCSTimedEntityColor const kTCSTimedEntityDefaultColor = TCSTimedEntityColorBlue;
TCSTimedEntityColor const kTCSTimedEntityMaxColor = TCSTimedEntityColorPink;

@implementation TCSTimedEntity

- (BOOL)isActive {
    return NO;
}

- (UIColor *)backgroundColor {
    return [TCSTimedEntity backgroundColorForTimerColor:self.color.integerValue];
}

- (UIColor *)backgroundBorderColor {
    return [TCSTimedEntity backgroundBorderColorForTimerColor:self.color.integerValue];
}

- (UIColor *)backgroundEditColor {
    return [TCSTimedEntity backgroundEditColorForTimerColor:self.color.integerValue];
}

- (UIColor *)backgroundEditBorderColor {
    return [TCSTimedEntity backgroundEditBorderColorForTimerColor:self.color.integerValue];
}

- (UIImage *)dragImage {
    return [TCSTimedEntity dragImageForTimerColor:self.color.integerValue];
}

+ (UIColor *)backgroundColorForTimerColor:(TCSTimedEntityColor)timerColor {

    NSInteger rgbHexValue = 0;

    if (timerColor > kTCSTimedEntityMaxColor) {
        timerColor = kTCSTimedEntityDefaultColor;
    }

    switch (timerColor) {
        case TCSTimedEntityColorBlue:
            rgbHexValue = 0x6dcff6;
            break;

        case TCSTimedEntityColorGreen:
            rgbHexValue = 0x99f9ab;
            break;

        case TCSTimedEntityColorYellow:
            rgbHexValue = 0xf6f999;
            break;

        case TCSTimedEntityColorOrange:
            rgbHexValue = 0xf9d499;
            break;

        case TCSTimedEntityColorPink:
            rgbHexValue = 0xf399f9;
            break;
    }

    return [UIColor colorWithRGBHex:rgbHexValue];
}

+ (UIColor *)backgroundBorderColorForTimerColor:(TCSTimedEntityColor)timerColor {

    NSInteger rgbHexValue = 0;

    if (timerColor > kTCSTimedEntityMaxColor) {
        timerColor = kTCSTimedEntityDefaultColor;
    }

    switch (timerColor) {
        case TCSTimedEntityColorBlue:
            rgbHexValue = 0x519bb8;
            break;

        case TCSTimedEntityColorGreen:
            rgbHexValue = 0x51b85d;
            break;

        case TCSTimedEntityColorYellow:
            rgbHexValue = 0xdcde2c;
            break;

        case TCSTimedEntityColorOrange:
            rgbHexValue = 0xde912c;
            break;

        case TCSTimedEntityColorPink:
            rgbHexValue = 0xc72cde;
            break;
    }

    return [UIColor colorWithRGBHex:rgbHexValue];

}

+ (UIColor *)backgroundEditColorForTimerColor:(TCSTimedEntityColor)timerColor {

    NSInteger rgbHexValue = 0;

    if (timerColor > kTCSTimedEntityMaxColor) {
        timerColor = kTCSTimedEntityDefaultColor;
    }

    switch (timerColor) {
        case TCSTimedEntityColorBlue:
            rgbHexValue = 0x256077;
            break;

        case TCSTimedEntityColorGreen:
            rgbHexValue = 0x1a6127;
            break;

        case TCSTimedEntityColorYellow:
            rgbHexValue = 0xf8ff00;
            break;

        case TCSTimedEntityColorOrange:
            rgbHexValue = 0xdb7100;
            break;

        case TCSTimedEntityColorPink:
            rgbHexValue = 0x791688;
            break;
    }

    return [UIColor colorWithRGBHex:rgbHexValue];

}

+ (UIColor *)backgroundEditBorderColorForTimerColor:(TCSTimedEntityColor)timerColor {

    NSInteger rgbHexValue = 0;

    if (timerColor > kTCSTimedEntityMaxColor) {
        timerColor = kTCSTimedEntityDefaultColor;
    }

    switch (timerColor) {
        case TCSTimedEntityColorBlue:
            rgbHexValue = 0x295566;
            break;

        case TCSTimedEntityColorGreen:
            rgbHexValue = 0x0f4a1a;
            break;

        case TCSTimedEntityColorYellow:
            rgbHexValue = 0xaca209;
            break;

        case TCSTimedEntityColorOrange:
            rgbHexValue = 0x784f18;
            break;

        case TCSTimedEntityColorPink:
            rgbHexValue = 0x51125a;
            break;
    }

    return [UIColor colorWithRGBHex:rgbHexValue];

}

+ (UIImage *)dragImageForTimerColor:(TCSTimedEntityColor)timerColor {

    if (timerColor > kTCSTimedEntityMaxColor) {
        timerColor = kTCSTimedEntityDefaultColor;
    }

    NSString *imageName;

    switch (timerColor) {
        case TCSTimedEntityColorBlue:
            imageName = @"blue_drag_dot.png";
            break;

        case TCSTimedEntityColorGreen:
            imageName = @"green_drag_dot.png";
            break;

        case TCSTimedEntityColorYellow:
            imageName = @"yellow_drag_dot.png";
            break;

        case TCSTimedEntityColorOrange:
            imageName = @"orange_drag_dot.png";
            break;

        case TCSTimedEntityColorPink:
            imageName = @"pink_drag_dot.png";
            break;
    }
    
    return [UIImage imageNamed:imageName];
    
}

- (void)updateWithName:(NSString *)name
                 color:(NSInteger)color
              archived:(BOOL)archived
         entityVersion:(int64_t)entityVersion
         remoteDeleted:(BOOL)remoteDeleted
              remoteId:(NSString *)remoteId
            updateTime:(NSDate *)updateTime
         markAsUpdated:(BOOL)markAsUpdated {

    self.name = name;
    self.colorValue = color;
    self.archivedValue = archived;

    [super
     updateWithEntityVersion:entityVersion
     remoteDeleted:remoteDeleted
     remoteId:remoteId
     updateTime:updateTime
     markAsUpdated:markAsUpdated];
}

@end
