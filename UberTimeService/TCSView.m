//
//  TCSView.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSView.h"

@implementation TCSView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1.0];
    UIColor* roundedRectangle43DropShadowColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.46];
    UIColor* roundedRectangle43InnerShadowColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.25];
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0];
    UIColor* roundedRectangle43Copy = [UIColor colorWithRed: 0 green: 0.235 blue: 1 alpha: .1];

    //// Gradient Declarations
    NSArray* whiteToTransparentColors = [NSArray arrayWithObjects:
                                         (id)color.CGColor,
                                         (id)fillColor.CGColor, nil];
    CGFloat whiteToTransparentLocations[] = {0, 1};
    CGGradientRef whiteToTransparent = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)whiteToTransparentColors, whiteToTransparentLocations);

    //// Shadow Declarations
    UIColor* roundedRectangle43DropShadow = roundedRectangle43DropShadowColor;
    CGSize roundedRectangle43DropShadowOffset = CGSizeMake(-1.1, 1.1);
    CGFloat roundedRectangle43DropShadowBlurRadius = 5;
    UIColor* roundedRectangle43InnerShadow = roundedRectangle43InnerShadowColor;
    CGSize roundedRectangle43InnerShadowOffset = CGSizeMake(-1.1, 1.1);
    CGFloat roundedRectangle43InnerShadowBlurRadius = 1;

    //// Group 6
    {
        //// Rounded Rectangle 43 copy Drawing
        UIBezierPath* roundedRectangle43CopyPath = [UIBezierPath bezierPath];
        [roundedRectangle43CopyPath moveToPoint: CGPointMake(4.37, 0)];
        [roundedRectangle43CopyPath addLineToPoint: CGPointMake(295.01, 0)];
        [roundedRectangle43CopyPath addCurveToPoint: CGPointMake(299.38, 2.92) controlPoint1: CGPointMake(297.42, 0) controlPoint2: CGPointMake(299.38, 1.31)];
        [roundedRectangle43CopyPath addLineToPoint: CGPointMake(299.38, 156.67)];
        [roundedRectangle43CopyPath addCurveToPoint: CGPointMake(295.01, 159.58) controlPoint1: CGPointMake(299.38, 158.28) controlPoint2: CGPointMake(297.42, 159.58)];
        [roundedRectangle43CopyPath addLineToPoint: CGPointMake(4.37, 159.58)];
        [roundedRectangle43CopyPath addCurveToPoint: CGPointMake(0, 156.67) controlPoint1: CGPointMake(1.95, 159.58) controlPoint2: CGPointMake(0, 158.28)];
        [roundedRectangle43CopyPath addLineToPoint: CGPointMake(0, 2.92)];
        [roundedRectangle43CopyPath addCurveToPoint: CGPointMake(4.37, 0) controlPoint1: CGPointMake(0, 1.31) controlPoint2: CGPointMake(1.95, 0)];
        [roundedRectangle43CopyPath closePath];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, roundedRectangle43DropShadowOffset, roundedRectangle43DropShadowBlurRadius, roundedRectangle43DropShadow.CGColor);
        [roundedRectangle43Copy setFill];
        [roundedRectangle43CopyPath fill];

        ////// Rounded Rectangle 43 copy Inner Shadow
        CGRect roundedRectangle43CopyBorderRect = CGRectInset([roundedRectangle43CopyPath bounds], -roundedRectangle43InnerShadowBlurRadius, -roundedRectangle43InnerShadowBlurRadius);
        roundedRectangle43CopyBorderRect = CGRectOffset(roundedRectangle43CopyBorderRect, -roundedRectangle43InnerShadowOffset.width, -roundedRectangle43InnerShadowOffset.height);
        roundedRectangle43CopyBorderRect = CGRectInset(CGRectUnion(roundedRectangle43CopyBorderRect, [roundedRectangle43CopyPath bounds]), -1, -1);

        UIBezierPath* roundedRectangle43CopyNegativePath = [UIBezierPath bezierPathWithRect: roundedRectangle43CopyBorderRect];
        [roundedRectangle43CopyNegativePath appendPath: roundedRectangle43CopyPath];
        roundedRectangle43CopyNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat xOffset = roundedRectangle43InnerShadowOffset.width + round(roundedRectangle43CopyBorderRect.size.width);
            CGFloat yOffset = roundedRectangle43InnerShadowOffset.height;
            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        roundedRectangle43InnerShadowBlurRadius,
                                        roundedRectangle43InnerShadow.CGColor);

            [roundedRectangle43CopyPath addClip];
            CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(roundedRectangle43CopyBorderRect.size.width), 0);
            [roundedRectangle43CopyNegativePath applyTransform: transform];
            [[UIColor grayColor] setFill];
            [roundedRectangle43CopyNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);

        [fillColor setStroke];
        roundedRectangle43CopyPath.lineWidth = 1;
        [roundedRectangle43CopyPath stroke];


        //// Group 4
        {
            CGContextSaveGState(context);
            CGContextSetAlpha(context, 0.15);
            CGContextBeginTransparencyLayer(context, NULL);


            //// Rounded Rectangle 43 copy GradientOverlay Drawing
            UIBezierPath* roundedRectangle43CopyGradientOverlayPath = [UIBezierPath bezierPath];
            [roundedRectangle43CopyGradientOverlayPath moveToPoint: CGPointMake(4.37, 0)];
            [roundedRectangle43CopyGradientOverlayPath addLineToPoint: CGPointMake(295.01, 0)];
            [roundedRectangle43CopyGradientOverlayPath addCurveToPoint: CGPointMake(299.38, 2.92) controlPoint1: CGPointMake(297.42, 0) controlPoint2: CGPointMake(299.38, 1.31)];
            [roundedRectangle43CopyGradientOverlayPath addLineToPoint: CGPointMake(299.38, 156.67)];
            [roundedRectangle43CopyGradientOverlayPath addCurveToPoint: CGPointMake(295.01, 159.58) controlPoint1: CGPointMake(299.38, 158.28) controlPoint2: CGPointMake(297.42, 159.58)];
            [roundedRectangle43CopyGradientOverlayPath addLineToPoint: CGPointMake(4.37, 159.58)];
            [roundedRectangle43CopyGradientOverlayPath addCurveToPoint: CGPointMake(0, 156.67) controlPoint1: CGPointMake(1.95, 159.58) controlPoint2: CGPointMake(0, 158.28)];
            [roundedRectangle43CopyGradientOverlayPath addLineToPoint: CGPointMake(0, 2.92)];
            [roundedRectangle43CopyGradientOverlayPath addCurveToPoint: CGPointMake(4.37, 0) controlPoint1: CGPointMake(0, 1.31) controlPoint2: CGPointMake(1.95, 0)];
            [roundedRectangle43CopyGradientOverlayPath closePath];
            CGContextSaveGState(context);
            [roundedRectangle43CopyGradientOverlayPath addClip];
            CGContextDrawLinearGradient(context, whiteToTransparent,
                                        CGPointMake(149.69, 159.58),
                                        CGPointMake(149.69, 0),
                                        kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
            CGContextRestoreGState(context);
            
            
            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
        }
    }
    
    
    //// Cleanup
    CGGradientRelease(whiteToTransparent);
    CGColorSpaceRelease(colorSpace);

}

@end
