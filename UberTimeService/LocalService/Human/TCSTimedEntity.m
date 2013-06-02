#import "TCSTimedEntity.h"
#import "UIColor+PBFoundation.h"

TCSTimedEntityColor const kTCSTimedEntityDefaultColor = TCSTimedEntityColorBlue;
TCSTimedEntityColor const kTCSTimedEntityMaxColor = TCSTimedEntityColorPink;

@implementation TCSTimedEntity

- (BOOL)isActive {
    return NO;
}

- (UIColor *)backgroundColor {
    return [TCSTimedEntity backgroundColorForTimerColor:self.colorValue];
}

- (UIColor *)backgroundEditColor {
    return [TCSTimedEntity backgroundEditColorForTimerColor:self.colorValue];
}

+ (UIColor *)backgroundColorForTimerColor:(TCSTimedEntityColor)timerColor {

    NSInteger rgbHexValue = 0;

    if (timerColor > kTCSTimedEntityMaxColor) {
        timerColor = kTCSTimedEntityDefaultColor;
    }

    switch (timerColor) {
        case TCSTimedEntityColorBlue:
            rgbHexValue = 0x003CFF;
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

- (void)updateWithName:(NSString *)name
                 color:(NSInteger)color
              archived:(BOOL)archived
     filteredModifiers:(NSInteger)filteredModifiers
               keyCode:(NSInteger)keyCode
             modifiers:(NSInteger)modifiers
                 order:(NSInteger)order
         entityVersion:(int64_t)entityVersion
              remoteId:(NSString *)remoteId
            updateTime:(NSDate *)updateTime
         markAsUpdated:(BOOL)markAsUpdated {

    self.name = [self nonNullValue:name];
    self.colorValue = color;
    self.archivedValue = archived;
    self.filteredModifiersValue = filteredModifiers;
    self.keyCodeValue = keyCode;
    self.modifiersValue = modifiers;
    self.orderValue = order;

    [super
     updateWithEntityVersion:entityVersion
     remoteId:remoteId
     updateTime:updateTime
     markAsUpdated:markAsUpdated];
}

@end
