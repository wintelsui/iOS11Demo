//
//  SimpleViewDragAndDropViewController.m
//  iOS11Demo
//
//  Created by wintel on 2017/11/6.
//Copyright © 2017年 wintel. All rights reserved.
//

#import "SimpleViewDragAndDropViewController.h"

#import <Lottie/Lottie.h>
#import "BFPaperButton.h"

@interface SimpleViewDragAndDropViewController ()
<
UITextDragDelegate,
UITextDropDelegate,
UIDragInteractionDelegate,
UIDropInteractionDelegate
>
{
    UIView *_dropView;
    LOTAnimationView *_scanAnimationView;
    LOTAnimationView *_checkAnimationView;
    LOTAnimationView *_loadingAnimationView;
    
    UIImageView *_dropAndDragView;
    UIImageView *_dropAndDragView2;
    BFPaperButton *_resetImageButton;
    
    NSDate *_dateLastDropUpdate;
    NSTimer *_timerLastDropUpdate;
    
    NSInteger _actionDragIndex;
    NSInteger _actionDropIndex;
}

@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property (weak, nonatomic) IBOutlet UITextView *myTextView;

@end

@implementation SimpleViewDragAndDropViewController

#pragma mark - SimpleViewDragAndDropViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    _actionDragIndex = 0;
    _actionDropIndex = 0;
    
    _myTextField.textDragDelegate = self;
    _myTextField.textDropDelegate = self;
    
    _myTextView.textDragDelegate = self;
    _myTextView.textDropDelegate = self;
    
    [self setupDropView];
    [self setupDropAndDragView];
    
    [self showSuccessAnimation:@0];
}


/**
 初始化一个支持拖放的 ImageView
 */
- (void)setupDropAndDragView{
    __weak typeof(self)weakself = self;
    _dropAndDragView = ({
        UIImageView *imageview = [[UIImageView alloc] init];
        [imageview setBackgroundColor:[UIColor lightGrayColor]];
        imageview.userInteractionEnabled = YES;
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        
        [weakself.view addSubview:imageview];
        //添加拖拽能力
        [weakself addDragAbilityForView:imageview];
        //添加拖放能力
        [weakself addDropAbilityForView:imageview];
        
        imageview;
    });
    
    _dropAndDragView2 = ({
        UIImageView *imageview = [[UIImageView alloc] init];
        [imageview setBackgroundColor:[UIColor lightGrayColor]];
        imageview.userInteractionEnabled = YES;
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        
        [weakself.view addSubview:imageview];
        
        //添加拖拽能力
        [weakself addDragAbilityForView:imageview];
        //添加拖放能力
        [weakself addDropAbilityForView:imageview];
        
        imageview;
    });
    
    [_dropAndDragView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_dropView.mas_top).offset(-20);
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(100);
    }];
    
    [_dropAndDragView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_dropAndDragView);
        make.height.width.equalTo(_dropAndDragView);
        make.left.equalTo(_dropAndDragView.mas_right).offset(10);
        make.right.mas_equalTo(-20);
    }];
    
    _resetImageButton = ({
        BFPaperButton *btn = [BFPaperButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundColor:RGBA(43, 150, 245,0.7)];
        btn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:@"设置照片" forState:UIControlStateNormal];
        [btn setImage:nil forState:UIControlStateNormal];
        
        btn.cornerRadius = 22.0f;
        btn.loweredShadowRadius = 22.0f;
        btn.liftedShadowRadius = 22.0f;
        btn.liftedShadowOffset = CGSizeMake(1, 1);
        btn.loweredShadowOffset = CGSizeMake(1, 1);
        
        [self.view addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_dropAndDragView.mas_top).mas_offset(-10);
            make.width.mas_equalTo(100.0f);
            make.height.mas_equalTo(44.0f);
            make.centerX.equalTo(weakself.view);
        }];
        
        btn;
    });
    [[_resetImageButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [weakself refreshDropAndDragViewImage];
    }];
    [weakself refreshDropAndDragViewImage];
}

- (void)refreshDropAndDragViewImage{
    {
        NSInteger number = arc4random() % 11 + 1;
        NSString *imageName = [NSString stringWithFormat:@"Aragaki_%ld.jpg",(long)number];
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@""];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            [_dropAndDragView setImage:image];
        }
    }
    {
        NSInteger number = arc4random() % 11 + 1;
        NSString *imageName = [NSString stringWithFormat:@"Aragaki_%ld.jpg",(long)number];
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@""];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            [_dropAndDragView2 setImage:image];
        }
    }
}

/**
 初始化一个支持放的 View
 */
- (void)setupDropView{
    __weak typeof(self)weakself = self;
    _dropView = ({
        UIView *view = [[UIView alloc] init];
        [view setBackgroundColor:RGBA(158, 221, 218, 0.5)];
        view.layer.cornerRadius = 5.0;
        view.layer.borderColor = RGBA(43, 150, 245, 0.5).CGColor;
        view.layer.borderWidth = 1.0;
        [view setUserInteractionEnabled:YES];
        
        [weakself.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(100);
            make.bottom.mas_equalTo(0 - 10 - IPHONEX_HEIGHT_SAFE_BOTTOM_VERTICAL);
            make.centerX.equalTo(weakself.view);
        }];
        
        //添加了拖放的能力
        [weakself addDropAbilityForView:view];
        
        view;
    });
    
    _scanAnimationView = ({
        LOTAnimationView *animationView = [LOTAnimationView animationNamed:@"AnimationScan"];
        animationView.loopAnimation = YES;
        [animationView setUserInteractionEnabled:NO];
        [_dropView addSubview:animationView];
        
        
        [animationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
            make.center.equalTo(_dropView);
        }];
        
        animationView;
    });
    [_scanAnimationView setHidden:NO];
    [_scanAnimationView play];
    
    _checkAnimationView = ({
        LOTAnimationView *animationView = [LOTAnimationView animationNamed:@"AnimationCheck"];
        animationView.loopAnimation = YES;
        [animationView setUserInteractionEnabled:NO];
        [_dropView addSubview:animationView];
        
        
        [animationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
            make.center.equalTo(_dropView);
        }];
        
        animationView;
    });
    [_checkAnimationView setHidden:YES];
    
    _loadingAnimationView = ({
        LOTAnimationView *animationView = [LOTAnimationView animationNamed:@"AnimationTriangle_loading"];
        animationView.loopAnimation = YES;
        [animationView setUserInteractionEnabled:NO];
        [_dropView addSubview:animationView];
        
        
        [animationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
            make.center.equalTo(_dropView);
        }];
        
        animationView;
    });
    [_loadingAnimationView setHidden:YES];
}

/**
 为视图添加拖拽能力

 @param view 视图
 */
- (void)addDragAbilityForView:(UIView *)view {
    UIDragInteraction *dragInteratcion = [[UIDragInteraction alloc] initWithDelegate:self];
    dragInteratcion.enabled = YES;
    [view addInteraction:dragInteratcion];
}

/**
 为视图添加拖放能力
 
 @param view 视图
 */
- (void)addDropAbilityForView:(UIView *)view {
    UIDropInteraction *dropInteraction = [[UIDropInteraction alloc] initWithDelegate:self];
    [view addInteraction:dropInteraction];
}

#pragma mark - -- UITextDragDelegate Start --

- (NSArray<UIDragItem *> *)textDraggableView:(UIView<UITextDraggable> *)textDraggableView itemsForDrag:(id<UITextDragRequest>)dragRequest{
    NSLog(@"textDraggableView:%@,itemsForDrag:",textDraggableView);
    return dragRequest.suggestedItems;
}

- (nullable UITargetedDragPreview *)textDraggableView:(UIView<UITextDraggable> *)textDraggableView dragPreviewForLiftingItem:(UIDragItem *)item session:(id<UIDragSession>)session{
    NSLog(@"textDraggableView:%@,dragPreviewForLiftingItem:",textDraggableView);
    
    UIDragPreviewParameters* params = [UIDragPreviewParameters new];
    params.backgroundColor = [UIColor clearColor];
    
    UITargetedDragPreview* preview = [[UITargetedDragPreview alloc] initWithView:textDraggableView parameters:params];
    [preview.view setBackgroundColor:RGB(155, 89, 182)];
    return preview;
}

- (void)textDraggableView:(UIView<UITextDraggable> *)textDraggableView willAnimateLiftWithAnimator:(id<UIDragAnimating>)animator session:(id<UIDragSession>)session{
    NSLog(@"textDraggableView:%@,willAnimateLiftWithAnimator:",textDraggableView);
}

- (void)textDraggableView:(UIView<UITextDraggable> *)textDraggableView dragSessionWillBegin:(id<UIDragSession>)session{
    NSLog(@"textDraggableView:%@,dragSessionWillBegin:",textDraggableView);
}

- (void)textDraggableView:(UIView<UITextDraggable> *)textDraggableView dragSessionDidEnd:(id<UIDragSession>)session withOperation:(UIDropOperation)operation{
    NSLog(@"textDraggableView:%@,dragSessionDidEnd:",textDraggableView);
}

#pragma mark - -- UITextDragDelegate End --

#pragma mark - -- UITextDropDelegate Start --

- (UITextDropEditability)textDroppableView:(UIView<UITextDroppable> *)textDroppableView willBecomeEditableForDrop:(id<UITextDropRequest>)drop{
    NSLog(@"textDraggableView:%@,willBecomeEditableForDrop:",textDroppableView);
    //UITextDropEditabilityNo：不可编辑模式，不允许拖拽内容到控件
    //UITextDropEditabilityTemporary：不可编辑模式拖拽内容到控件后仍为不可编辑模式
    //UITextDropEditabilityYes：不可编辑模式拖拽内容到控件后变可编辑模式
    return UITextDropEditabilityYes;
}

- (UITextDropProposal*)textDroppableView:(UIView<UITextDroppable> *)textDroppableView proposalForDrop:(id<UITextDropRequest>)drop{
//    NSLog(@"textDraggableView:%@,proposalForDrop:",textDroppableView);
    //*****该方法在拖拽过程中会多次且频繁的回调，所以尽量尽量做最少的工作。*****
    /**
     * -当拖动进入文本控件时，
     * -当文本位置*变化时，拖动移动到文本控件上
     * -当拖动会话更改时(例如添加的项)
     * 。。。。。。
     * 都会回调该方法
     */
    //改变拖拽行为
    return [[UITextDropProposal alloc] initWithDropOperation:UIDropOperationCopy];
}

- (void)textDroppableView:(UIView<UITextDroppable> *)textDroppableView willPerformDrop:(id<UITextDropRequest>)drop{
    NSLog(@"textDraggableView:%@,willPerformDrop:",textDroppableView);
    
}


- (nullable UITargetedDragPreview *)textDroppableView:(UIView<UITextDroppable> *)textDroppableView previewForDroppingAllItemsWithDefault:(UITargetedDragPreview *)defaultPreview{
    NSLog(@"textDroppableView:%@,previewForDroppingAllItemsWithDefault:",textDroppableView);
    //自定义预览
    [defaultPreview.view setBackgroundColor:RGB(192, 57, 43)];
    return defaultPreview;
}

- (void)textDroppableView:(UIView<UITextDroppable> *)textDroppableView dropSessionDidEnter:(id<UIDropSession>)session{
    NSLog(@"textDroppableView:%@,dropSessionDidEnter:",textDroppableView);
    //当内容被拖拽到支持拖放控件上方时（进入拖放控件frame），回调该方法
}

- (void)textDroppableView:(UIView<UITextDroppable> *)textDroppableView dropSessionDidUpdate:(id<UIDropSession>)session{
    //NSLog(@"textDroppableView:%@,dropSessionDidUpdate:",textDroppableView);
    //*****该方法在拖拽过程中会多次且频繁的回调，所以尽量尽量做最少的工作。*****
    //当内容被拖拽时，不停地回调此方法
}

- (void)textDroppableView:(UIView<UITextDroppable> *)textDroppableView dropSessionDidExit:(id<UIDropSession>)session{
    NSLog(@"textDroppableView:%@,dropSessionDidExit:",textDroppableView);
    //当内容被拖拽时，拖拽离开可放控件时回调此方法
}

- (void)textDroppableView:(UIView<UITextDroppable> *)textDroppableView dropSessionDidEnd:(id<UIDropSession>)session{
    NSLog(@"textDroppableView:%@,dropSessionDidEnd:",textDroppableView);
    //拖放结束时调用
}

#pragma mark - -- UITextDropDelegate End --

#pragma mark - -- UIDragInteractionDelegate Start --

/**
 第一个方法:
 在长按一个添加了 UIDragInteraction 属性的控件后，返回可供拖拽的 items，
 如果返回 nil，则不会进行任何拖拽行为，以及之后的代理方法
 */
- (nonnull NSArray<UIDragItem *> *)dragInteraction:(nonnull UIDragInteraction *)interaction itemsForBeginningSession:(nonnull id<UIDragSession>)session {
    _actionDragIndex = 1;
    NSLog(@"\n拖拽方法：%ld dragInteraction:%@ \nitemsForBeginningSession:%@",(long)_actionDragIndex,interaction.view,session);
    
    if (interaction.view == _dropAndDragView || interaction.view == _dropAndDragView2) {
        
        UIImageView *imageView = (UIImageView *)interaction.view;
        
        NSItemProvider *provider = [[NSItemProvider alloc] initWithObject:imageView.image];
        UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:provider];
        dragItem.localObject = imageView.image;
        
        return @[dragItem];
    }
    return nil;
}

/**
 方法二
 为 Lift 的 Item 提供一个预览视图
 返回 nil：该 item 没有预览效果，什么也看不到，会以为自己没有拖拽
 不实现该方法：使用默认UITargetedDragPreview
 */
- (nullable UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForLiftingItem:(UIDragItem *)item session:(id<UIDragSession>)session {
    _actionDragIndex++;
    NSLog(@"\n拖拽方法：%ld dragInteraction:%@ \npreviewForLiftingItem:%@ \nsession:%@",(long)_actionDragIndex,interaction.view,item,session);

    return [self dragTargetedDragPreviewForInteraction:interaction];
}

/**
 方法三
 当拖拽开始后，Item 离开，我们可以给当前视图添加一些动画
 */
- (void)dragInteraction:(UIDragInteraction *)interaction willAnimateLiftWithAnimator:(id<UIDragAnimating>)animator session:(id<UIDragSession>)session {
    _actionDragIndex++;
    NSLog(@"\n拖拽方法：%ld dragInteraction:%@ \nwillAnimateLiftWithAnimator:%@ \nsession:%@",(long)_actionDragIndex,interaction.view,animator,session);
    
    //预览视图离开后生成后，让原视图透明度降低，效果随意
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        interaction.view.alpha = 0.5;
    }];
}

/**
 方法四
 拖拽取消了后，第一个方法，这里提供一个取消后的预览视图
 */
- (nullable UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForCancellingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview {
    _actionDragIndex++;
    NSLog(@"\n拖拽方法：%ld dragInteraction:%@ \npreviewForCancellingItem:%@ \nwithDefault:%@",(long)_actionDragIndex,interaction.view,item,defaultPreview);
    
    return [self dragTargetedDragPreviewForInteraction:interaction];
}

/**
 方法五
 拖拽取消后，来一个取消动画是极好的，在这里添加一个取消动画
 */
- (void)dragInteraction:(UIDragInteraction *)interaction item:(UIDragItem *)item willAnimateCancelWithAnimator:(id<UIDragAnimating>)animator {
    _actionDragIndex++;
    NSLog(@"\n拖拽方法：%ld dragInteraction:%@ \nitem:%@ \nwillAnimateCancelWithAnimator:%@",(long)_actionDragIndex,interaction.view,item,animator);
    
    [animator addAnimations:^{
        interaction.view.alpha = 1;
    }];
}

/**
 方法六
 拖拽过程结束，动画结束，一切拖拽复原
 */
- (void)dragInteraction:(UIDragInteraction *)interaction session:(id<UIDragSession>)session didEndWithOperation:(UIDropOperation)operation {
    _actionDragIndex++;
    NSLog(@"\n拖拽方法：%ld dragInteraction:%@ \nsession:%@ \ndidEndWithOperation:%lu",(long)_actionDragIndex,interaction.view,session,(unsigned long)operation);
    
    [UIView animateWithDuration:0.25 animations:^{
        interaction.view.alpha = 1;
    } completion:nil];
}

/**
 附加方法
 向正在脱拽的 item 中追加 UIDragItem
 正在拖拽时点选其他支持拖拽的视图
 */
- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForAddingToSession:(id<UIDragSession>)session withTouchAtPoint:(CGPoint)point {
    NSLog(@"dragInteraction:%@ \nitemsForAddingToSession:%@ \nwithTouchAtPoint:%@",interaction.view,session,@(point));
    
    //当拖拽 _dropAndDragView  或者 _dropAndDragView2时候
    //点击了 _dropAndDragView2 或者 _dropAndDragView
    if (interaction.view == _dropAndDragView || interaction.view == _dropAndDragView2) {
        
        UIImageView *imageView = (UIImageView *)interaction.view;
        
        NSItemProvider *provider = [[NSItemProvider alloc] initWithObject:imageView.image];
        UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:provider];
        dragItem.localObject = imageView.image;
        
        return @[dragItem];
    }
    
    return nil;
}

/**
获得一个拖拽预览

 @param interaction 拖拽视图
 @return 获得一个拖拽预览
 */
- (UITargetedDragPreview *)dragTargetedDragPreviewForInteraction:(UIDragInteraction *)interaction{
    UIView *interactionView = interaction.view;
    
    CGRect visibleRect = interaction.view.bounds;
    if ([interactionView isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)interactionView;
        if (imageView.contentMode == UIViewContentModeScaleAspectFit) {
            UIImage *image = imageView.image;
            CGFloat x = 0;
            CGFloat y = 0;
            CGFloat width = 0;
            CGFloat height = 0;
            if (image.size.width / image.size.height > visibleRect.size.width / visibleRect.size.height) {
                width = visibleRect.size.width;
                height = width * image.size.height / image.size.width;
            }else{
                height = visibleRect.size.height;
                width = image.size.width * height / image.size.height;
            }
            x = (visibleRect.size.width - width) / 2.0f;
            y = (visibleRect.size.height - height) / 2.0f;
            
            visibleRect = CGRectMake(x, y, width, height);
        }
    }
    
    UIDragPreviewParameters *previewParameters = [[UIDragPreviewParameters alloc] init];
    previewParameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:visibleRect cornerRadius:10];
    
    UITargetedDragPreview *dragPreview = [[UITargetedDragPreview alloc] initWithView:interactionView parameters:previewParameters];
    
    return dragPreview;
}

#pragma mark - -- UIDragInteractionDelegate End --

#pragma mark - -- UIDropInteractionDelegate Start --

/**
 方法一
 一个支持拖放的视图，判断是否允许当前拖拽到该视图上的类型拖放至此
 */
- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session {
    
    _actionDropIndex++;
    NSLog(@"\n拖放方法：%ld dropInteraction:%@ canHandleSession:%@",(long)_actionDropIndex,interaction.view,session);
    
    if (interaction.view == _dropView) {
        return [session canLoadObjectsOfClass:[UIImage class]];
    }
    // 可以加载image的控件都可以
    return NO;
}

/**
 方法二
 一个支持拖放的视图，当拖拽的视图到这个视图上时回调该方法
 */
- (void)dropInteraction:(UIDropInteraction *)interaction sessionDidEnter:(id<UIDropSession>)session {
    _actionDropIndex++;
    NSLog(@"\n拖放方法：%ld dropInteraction:%@ sessionDidEnter:%@",(long)_actionDropIndex,interaction.view,session);
    if (interaction.view == _dropView) {
        [self showSuccessAnimation:@(1)];
    }
    
    _dateLastDropUpdate = [NSDate date];
}

/**
 方法三
 一个支持拖放的视图，当拖拽的视图在这个视图上时回调该方法；
 该方法会不停，多次回调，当拖拽离开该视图，该视图并不会知道离开了视图，只会不再回调该方法
 */
- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session {
    _dateLastDropUpdate = [NSDate date];
    [self timerLastDropUpdateStart];
//    _actionDropIndex++;
//    NSLog(@"\n拖放方法：%ld dropInteraction:%@ sessionDidUpdate:%@",(long)_actionDropIndex,interaction.view,session);
    
    //这里可以根据 session.localDragSession 是否存在判断，拖拽来本应用还是其他应用
    UIDropProposal *dropProposal = [[UIDropProposal alloc] initWithDropOperation:UIDropOperationCopy];
    return dropProposal;
}

/**
 方法四
 一个支持拖放的视图，当拖拽的视图在这个视图上时回调该方法；
 */
- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session {
    
    _actionDropIndex++;
    NSLog(@"\n拖放方法：%ld dropInteraction:%@ performDrop:%@",(long)_actionDropIndex,interaction.view,session);
    
    
    [self timerLastDropUpdateEnd];
    
    for (UIDragItem *item in session.items) {
        //为 _dropAndDragView 设置一个图片
        
        [item.itemProvider loadObjectOfClass:[UIImage class]
                           completionHandler:^(id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIImage *image = (UIImage *)object;
                 if (image) {
                     _dropAndDragView.image = image;
                 }
             });
         }];
    }

//    如果拖拽来自本应用，可以知道原来视图的坐标
//    if (session.localDragSession) {
//        CGPoint dropPoint = [session locationInView:self.view];
//    }
}

/**
 方法五
 为拖放添加一个预览视图
 */
- (UITargetedDragPreview *)dropInteraction:(UIDropInteraction *)interaction previewForDroppingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview {
    
    _actionDropIndex++;
    NSLog(@"\n拖放方法：%ld dropInteraction:%@ previewForDroppingItem:%@ withDefault:%@",(long)_actionDropIndex,interaction.view,item,defaultPreview);
    
    if (item.localObject) {
        CGPoint dropPoint = defaultPreview.view.center;
        UIDragPreviewTarget *previewTarget = [[UIDragPreviewTarget alloc] initWithContainer:_dropAndDragView center:dropPoint];
        return [defaultPreview retargetedPreviewWithTarget:previewTarget];
    } else {
        return nil;
    }
}

/**
 方法六
 为拖放添加一个动画，并庆祝拖放过程圆满成功
 */
- (void)dropInteraction:(UIDropInteraction *)interaction item:(UIDragItem *)item willAnimateDropWithAnimator:(id<UIDragAnimating>)animator {
    
    _actionDropIndex++;
    NSLog(@"\n拖放方法：%ld dropInteraction:%@ item:%@ willAnimateDropWithAnimator:%@",(long)_actionDropIndex,interaction.view,item,animator);
    
    [self showSuccessAnimation:@2];
    [self performSelector:@selector(showSuccessAnimation:) withObject:@0 afterDelay:2];
}

#pragma mark - -- UIDropInteractionDelegate End --




#pragma mark - Public
 
#pragma mark - Private
- (void)timerLastDropUpdateStart{
    if (_timerLastDropUpdate == nil) {
        _timerLastDropUpdate = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerLastDropUpdateAction:) userInfo:nil repeats:YES];
    }else{
        [_timerLastDropUpdate fire];
    }
}

- (void)timerLastDropUpdateAction:(NSTimer *)timer{
    BOOL isDropEnd = YES;
    if (_dateLastDropUpdate != nil) {
        NSDate *now = [NSDate date];
        if ([now timeIntervalSinceDate:_dateLastDropUpdate] < 2) {
            //如果现在比最后更细时间打2秒，就结束
            isDropEnd = NO;
        }
    }
    if (isDropEnd) {
        [self showSuccessAnimation:@0];
        [self timerLastDropUpdateEnd];
    }
}
- (void)timerLastDropUpdateEnd{
    if (_timerLastDropUpdate != nil) {
        [_timerLastDropUpdate invalidate];
        _timerLastDropUpdate = nil;
    }
}
#pragma mark - Getter
 
#pragma mark - Setter

#pragma mark - Others

- (IBAction)endEditingPressed:(id)sender {
    [self.view endEditing:YES];
}

- (void)showSuccessAnimation:(NSNumber *)mode{
    if ([mode isEqualToNumber:@0]) {
        //Scaning
        [_loadingAnimationView setHidden:YES];
        [_loadingAnimationView stop];
        
        [_checkAnimationView setHidden:YES];
        [_checkAnimationView stop];
        
        [_scanAnimationView setHidden:NO];
        [_scanAnimationView play];
    }else if ([mode isEqualToNumber:@1]) {
        //Loading
        [_checkAnimationView setHidden:YES];
        [_checkAnimationView stop];
        
        [_scanAnimationView setHidden:YES];
        [_scanAnimationView stop];
        
        [_loadingAnimationView setHidden:NO];
        [_loadingAnimationView play];
    }else if ([mode isEqualToNumber:@2]) {
        //Success
        [_loadingAnimationView setHidden:YES];
        [_loadingAnimationView stop];
        
        [_scanAnimationView setHidden:YES];
        [_scanAnimationView stop];
        
        [_checkAnimationView setHidden:NO];
        [_checkAnimationView play];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    _myTextField.textDragDelegate = nil;
    _myTextField.textDropDelegate = nil;
    
    _myTextView.textDragDelegate = nil;
    _myTextView.textDropDelegate = nil;
    
}
@end
