#import "_TCSTimedEntity.h"

typedef NS_ENUM(NSInteger, TCSTimedEntityColor) {

    TCSTimedEntityColorBlue = 0,
    TCSTimedEntityColorGreen,
    TCSTimedEntityColorYellow,
    TCSTimedEntityColorOrange,
    TCSTimedEntityColorPink,

};

@interface TCSTimedEntity : _TCSTimedEntity {}

@property (nonatomic, readonly, getter = isActive) BOOL active;

- (UIColor *)backgroundColor;
- (UIColor *)backgroundBorderColor;
- (UIColor *)backgroundEditColor;
- (UIColor *)backgroundEditBorderColor;
- (UIImage *)dragImage;

+ (UIColor *)backgroundColorForTimerColor:(TCSTimedEntityColor)timerColor;
+ (UIColor *)backgroundBorderColorForTimerColor:(TCSTimedEntityColor)timerColor;
+ (UIColor *)backgroundEditColorForTimerColor:(TCSTimedEntityColor)timerColor;
+ (UIColor *)backgroundEditBorderColorForTimerColor:(TCSTimedEntityColor)timerColor;
+ (UIImage *)dragImageForTimerColor:(TCSTimedEntityColor)timerColor;

@end
