//
//  Live2DSprite.h
//  Live2DIntegration
//
//  Created by feng on 2020/12/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MNNFaceDetectionReport;

@interface Live2DSprite : UIView

- (void)loadModelName:(NSString *)modelName;

- (void)setFaceDetectionData:(MNNFaceDetectionReport *)faceDetectionReport;

@end

NS_ASSUME_NONNULL_END
