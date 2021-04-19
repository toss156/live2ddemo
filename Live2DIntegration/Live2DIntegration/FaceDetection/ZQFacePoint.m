//
//  ZQFacePoint.m
//  ZQFaceSDK
//
//  Created by feng on 2020/3/10.
//

#import "ZQFacePoint.h"

@interface ZQFacePoint()

@end

@implementation ZQFacePoint

+ (instancetype)facePointForPosition:(ZQFacePosition)position {
    ZQFacePoint *point = [ZQFacePoint new];
    if (position == ZQFacePositionHair) {
        point.left = 0;
        point.center = 43;
        point.right = 32;
    } else if (position == ZQFacePositionEye) {
        point.left = 52;
        point.center = 43;
        point.right = 61;
    } else if (position == ZQFacePositionLeftEye) {
        point.top = 72;
        point.left = 52;
        point.center = 104;
        point.right = 55;
        point.bottom = 73;
    } else if (position == ZQFacePositionRightEye) {
        point.top = 75;
        point.left = 58;
        point.center = 105;
        point.right = 61;
        point.bottom = 76;
    } else if (position == ZQFacePositionEar) {
        point.left = 2;
        point.center = 44;
        point.right = 30;
    } else if (position == ZQFacePositionNose) {
        point.left = 82;
        point.center = 46;
        point.right = 83;
    } else if (position == ZQFacePositionNostril) {
        point.left = 47;
        point.center = 49;
        point.right = 51;
    } else if (position == ZQFacePositionUperMouth) {
        point.left = 93;
        point.center = 92;
        point.right = 91;
    } else if (position == ZQFacePositionMouth) {
        point.top = 98;
        point.left = 96;
        point.center = 102;
        point.right = 100;
        point.bottom = 102;
    } else if (position == ZQFacePositionLip) {
        point.left = 96;
        point.center = 93;
        point.right = 90;
    } else if (position == ZQFacePositionChin) {
        point.left = 16;
        point.center = 17;
        point.right = 18;
    } else if (position == ZQFacePositionEyebrow) {
        point.left = 33;
        point.center = 43;
        point.right = 42;
    } else if (position == ZQFacePositionLeftEyebrow) {
        point.left = 33;
        point.center = 35;
        point.right = 37;
    } else if (position == ZQFacePositionRightEyebrow) {
        point.left = 38;
        point.center = 40;
        point.right = 42;
    } else if (position == ZQFacePositionCheek) {
        point.left = 7;
        point.center = 46;
        point.right = 25;
    } else if (position == ZQFacePositionNeck) {
        point.left = 13;
        point.center = 17;
        point.right = 20;
    } else if (position == ZQFacePositionFace) {
        point.left = 4;
        point.center = 46;
        point.right = 28;
    }
    return point;
}

@end
