//
//  ZQFacePoint.h
//  ZQFaceSDK
//
//  Created by feng on 2020/3/10.
//

#import <Foundation/Foundation.h>

typedef enum {
    ZQFacePositionHair = 1,
    ZQFacePositionEye,
    ZQFacePositionLeftEye,   // 左眼
    ZQFacePositionRightEye,  // 右眼
    ZQFacePositionEar,
    ZQFacePositionNose,
    ZQFacePositionNostril,
    ZQFacePositionUperMouth,
    ZQFacePositionMouth,
    ZQFacePositionLip,
    ZQFacePositionChin,
    ZQFacePositionEyebrow,
    ZQFacePositionLeftEyebrow,
    ZQFacePositionRightEyebrow,
    ZQFacePositionCheek,
    ZQFacePositionNeck,
    ZQFacePositionFace,
} ZQFacePosition;

/**
 * 返回某位置对应的点
 */
@interface ZQFacePoint : NSObject

@property (nonatomic, assign) int top;   //左侧点索引
@property (nonatomic, assign) int left;   //左侧点索引
@property (nonatomic, assign) int center; //中间点索引
@property (nonatomic, assign) int right;  //右侧点索引
@property (nonatomic, assign) int bottom;  //右侧点索引

+ (instancetype)facePointForPosition:(ZQFacePosition)position;

@end
