#import "_TCSTimedEntity.h"

typedef NS_ENUM(NSInteger, TCSTimedEntityColor) {

    TCSTimedEntityColorBlue = 0,
    TCSTimedEntityColorGreen,
    TCSTimedEntityColorYellow,
    TCSTimedEntityColorOrange,
    TCSTimedEntityColorPink,

};

extern TCSTimedEntityColor const kTCSTimedEntityDefaultColor;
extern TCSTimedEntityColor const kTCSTimedEntityMaxColor;

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

- (void)updateWithName:(NSString *)name
                 color:(NSInteger)color
              archived:(BOOL)archived
         entityVersion:(int64_t)entityVersion
         remoteDeleted:(BOOL)remoteDeleted
              remoteId:(NSString *)remoteId
            updateTime:(NSDate *)updateTime
         markAsUpdated:(BOOL)markAsUpdated;

@end
