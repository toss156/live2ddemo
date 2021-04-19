//
//  Live2DSprite.m
//  Live2DIntegration
//
//  Created by feng on 2020/12/30.
//

#import "Live2DSprite.h"
#import "L2DModel.h"
#import "MetalRender.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <MNNFaceDetection/MNNFaceDetection.h>
#import <MNNFaceDetection/MNNFaceDetector.h>
#import "ZQFacePoint.h"

static CGFloat distance(CGPoint first, CGPoint second) {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX * deltaX + deltaY * deltaY);
}

static CGPoint centerPoint(CGPoint first, CGPoint second) {
    CGFloat deltaX = (second.x + first.x) / 2;
    CGFloat deltaY = (second.y + first.y) / 2;
    return CGPointMake(deltaX, deltaY);
}

static CGPoint lookAtPoint(CGPoint point, CGPoint zeroPoint) {
    CGFloat deltaX = point.x - zeroPoint.x;
    CGFloat deltaY = point.y - zeroPoint.y;
    CGFloat dist = sqrt(deltaX * deltaX + deltaY * deltaY);
    return CGPointMake(deltaX/dist, deltaY/dist);
}


@interface Live2DSprite () <MTKViewDelegate, MetalRenderDelegate>

@property (nonatomic, strong) L2DModel *model;
@property (nonatomic, strong) MetalRender *renderer;
@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic) MTLViewport viewPort;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) NSMutableArray <MetalRender *> *renderers;

@property (nonatomic, strong) MNNFaceDetectionReport *faceInfo;

@end

@implementation Live2DSprite

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.renderers = @[].mutableCopy;
        [self setupMtkView];
        [self startRenderWithMetal];
    }
    return self;
}

- (void)loadModelName:(NSString *)modelName {
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@/%@.model3", modelName, modelName] ofType:@"json"];
    self.model = [[L2DModel alloc] initWithJsonPath:path];
    [self resetRender];
}

- (void)resetRender {
    if (self.renderer) {
        [self removeRenderer:self.renderer];
    }
    self.renderer = [[MetalRender alloc] init];
    self.renderer.scale = 1.5;
    self.renderer.delegate = self;
    self.renderer.model = self.model;
    [self addRenderer:self.renderer];
}

- (void)startRenderWithMetal {
    if (!self.mtkView) {
        return;
    }
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    
    self.commandQueue = device.newCommandQueue;
    
    self.mtkView.device = device;
    
    self.mtkView.paused = false;
    self.mtkView.hidden = false;
    
    for (MetalRender *render in self.renderers) {
        [render startWithView:self.mtkView];
    }
}

- (void)stopMetalRender {
    self.mtkView.paused = true;
    self.mtkView.hidden = true;
    self.mtkView.device = nil;
}

- (void)addRenderer:(MetalRender *)render {
    if (!self.mtkView) {
        return;
    }
    [self.renderers addObject:render];
    
    if (self.mtkView.paused) {
        if (self.renderers.count == 1) {
            [self startRenderWithMetal];
        }
    } else {
        [render startWithView:self.mtkView];
    }
}

- (void)removeRenderer:(MetalRender *)render {
    [self.renderers removeAllObjects];
    if (self.renderers.count == 0) {
        [self stopMetalRender];
    }
}

- (void)setupMtkView {
    self.mtkView = [[MTKView alloc] initWithFrame:self.bounds];
    [self addSubview:self.mtkView];
    self.mtkView.delegate = self;
    self.mtkView.framebufferOnly = true;
    self.mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    self.mtkView.clearColor = MakeMTLColor;
    self.mtkView.opaque = NO;
    [self updateMTKViewPort];
}

- (void)updateMTKViewPort {
    CGSize size = self.mtkView.drawableSize;
    MTLViewport viewport = {};
    viewport.znear = 0.0;
    viewport.zfar = 1.0;
    if (size.width > size.height) {
        viewport.originX = 0.0;
        viewport.originY = (size.height - size.width) * 0.5;
        viewport.width = size.width;
        viewport.height = size.width;
    } else {
        viewport.originX = (size.width - size.height) * 0.5;
        viewport.originY = 0.0;
        viewport.width = size.height;
        viewport.height = size.height;
    }
    // 调整显示大小
    self.viewPort = viewport;
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    [self updateMTKViewPort];
    for (MetalRender *render in self.renderers) {
        [render drawableSizeWillChange:self.mtkView size:size];
    }
}

- (void)drawInMTKView:(MTKView *)view {
    NSTimeInterval time = 1.0 / 30.f;
    
    for (MetalRender *render in self.renderers) {
        [render update:time];
    }
    
    if (view.currentDrawable) {
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        if (!commandBuffer) {
            return;
        }
        //先清空一次
        MTLRenderPassDescriptor *renderOldDescriptor = [[MTLRenderPassDescriptor alloc] init];
        renderOldDescriptor.colorAttachments[0].texture = view.currentDrawable.texture;
        renderOldDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderOldDescriptor.colorAttachments[0].clearColor = MakeMTLColor; // 设置默认颜色
        id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:renderOldDescriptor];
        [encoder endEncoding];
        // 然后创建
        MTLRenderPassDescriptor *renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
        renderPassDescriptor.colorAttachments[0].texture = view.currentDrawable.texture;
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionLoad;
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        renderPassDescriptor.colorAttachments[0].clearColor = MakeMTLColor; // 设置默认颜色
        
        for (MetalRender *render in self.renderers) {
            [render beginRenderWithTime:time viewPort:self.viewPort commandBuffer:commandBuffer passDescriptor:renderPassDescriptor];
        }
        [commandBuffer presentDrawable:view.currentDrawable];
        [commandBuffer commit];
    }
}

- (void)renderUpdateWithRender:(MetalRender *)renderer durationTime:(NSTimeInterval)duration {
    if (self.faceInfo && self.faceInfo.keyPoints) {
        // 头部转动
        [self.model setModelParameterNamed:@"ParamAngleX" withValue:-self.faceInfo.yaw * 360.0 / M_PI];
        [self.model setModelParameterNamed:@"ParamAngleY" withValue:self.faceInfo.pitch * 360.0 / M_PI];
        [self.model setModelParameterNamed:@"ParamAngleZ" withValue:self.faceInfo.roll * 360.0 / M_PI];
        
        // 眼睛
        ZQFacePoint *eyeLeftPoint = [ZQFacePoint facePointForPosition:ZQFacePositionLeftEye];
        ZQFacePoint *eyeRightPoint = [ZQFacePoint facePointForPosition:ZQFacePositionRightEye];
        
        CGFloat l_eye_w = [self getPointDistance:eyeLeftPoint.left otherPoint:eyeLeftPoint.right];
        CGFloat l_eye_h = [self getPointDistance:eyeLeftPoint.top otherPoint:eyeLeftPoint.bottom];
        CGFloat l_eye_blink = l_eye_h / (l_eye_w * 0.25);
        l_eye_blink = MIN(MAX(0.0, l_eye_blink), 1.0);
        
        CGFloat r_eye_w = [self getPointDistance:eyeRightPoint.left otherPoint:eyeRightPoint.right];
        CGFloat r_eye_h = [self getPointDistance:eyeRightPoint.top otherPoint:eyeRightPoint.bottom];
        CGFloat r_eye_blink = r_eye_h / (r_eye_w * 0.25);
        r_eye_blink = MIN(MAX(0.0, r_eye_blink), 1.0);
        
        [self.model setModelParameterNamed:@"ParamEyeLOpen" withValue:l_eye_blink];
        [self.model setModelParameterNamed:@"ParamEyeROpen" withValue:r_eye_blink];
        
        // 眉毛
        ZQFacePoint *leftEyeBrowPoint = [ZQFacePoint facePointForPosition:ZQFacePositionLeftEyebrow];
        ZQFacePoint *rightEyeBrowPoint = [ZQFacePoint facePointForPosition:ZQFacePositionRightEyebrow];
        CGFloat l_eye_brow_w = [self getPointDistance:leftEyeBrowPoint.left otherPoint:leftEyeBrowPoint.right];
        CGFloat l_eye_brow_h = [self getPointDistance:leftEyeBrowPoint.center otherPoint:eyeLeftPoint.center];
        CGFloat l_eye_brow = (1.0 - (0.75 * l_eye_brow_w)/l_eye_brow_h) * 4.0;
        l_eye_brow = MIN(MAX(-1.0, l_eye_brow), 1.0);
        
        CGFloat r_eye_brow_w = [self getPointDistance:rightEyeBrowPoint.left otherPoint:rightEyeBrowPoint.right];
        CGFloat r_eye_brow_h = [self getPointDistance:rightEyeBrowPoint.center otherPoint:eyeRightPoint.center];
        CGFloat r_eye_brow = (1.0 - (0.75 * r_eye_brow_w)/r_eye_brow_h) * 4.0;
        r_eye_brow = MIN(MAX(-1.0, r_eye_brow), 1.0);
        [self.model setModelParameterNamed:@"ParamBrowLY" withValue:l_eye_brow];
        [self.model setModelParameterNamed:@"ParamBrowRY" withValue:r_eye_brow];
        
        // 瞳孔
        CGPoint pos1 = self.faceInfo.keyPoints[eyeLeftPoint.top];
        CGPoint pos2 = self.faceInfo.keyPoints[eyeLeftPoint.bottom];
        CGPoint l_eye_ball = self.faceInfo.keyPoints[eyeLeftPoint.center];
        CGPoint l_eye_center = centerPoint(pos1, pos2);
        CGPoint eyeball = lookAtPoint(l_eye_ball, l_eye_center);
        
        [self.model setModelParameterNamed:@"ParamEyeBallX" withValue:eyeball.x * 1.5];
        [self.model setModelParameterNamed:@"ParamEyeBallY" withValue:eyeball.y * 1.5];
        
        // 嘴巴
        ZQFacePoint *mousePoint = [ZQFacePoint facePointForPosition:ZQFacePositionMouth];
        CGFloat mouse_w = [self getPointDistance:mousePoint.left otherPoint:mousePoint.right];
        CGFloat mouse_h = [self getPointDistance:mousePoint.top otherPoint:mousePoint.bottom];
        CGFloat mouse_open = mouse_h / (mouse_w * 0.3);
        mouse_open = MIN(MAX(0.0, mouse_open), 1.5);
        
        [self.model setModelParameterNamed:@"ParamMouthOpenY" withValue:mouse_open];
    }
}

- (void)setFaceDetectionData:(MNNFaceDetectionReport *)faceDetectionReport {
    self.faceInfo = faceDetectionReport;
}

- (CGFloat)getPointDistance:(NSInteger)point otherPoint:(NSInteger)otherPoint {
    CGPoint pos1 = self.faceInfo.keyPoints[point];
    CGPoint pos2 = self.faceInfo.keyPoints[otherPoint];
    CGFloat dist = distance(pos1, pos2);
    return dist;
}

@end
