//
//  ShoppingViewController.m
//  ShoppingSDK
//
//  Created by TEE on 2019/2/26.
//  Copyright © 2019 TEE. All rights reserved.
//

#import "ShoppingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NetworkManager.h"
#import "ProductView.h"
#import "UIImage+ShoppingSDK.h"
#import "HomeTableViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ProductDetailVC.h"
#define BUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ShoppingSDKBundle.Bundle"]

#define YJImageNamed(imageName)  ([UIImage imageNamed:[NSString stringWithFormat:@"%@/%@",BUNDLE_PATH,imageName]])

typedef enum{
    Success,
    Uploading,
}UploadImageStatus;

@interface ShoppingViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource>
/** AVFoundation相关
 AVCaptureSession对象是用来管理采集数据和输出数据的，它负责协调从哪里采集数据，输出到哪里。
 */
@property (nonatomic,strong) AVCaptureSession *session;
// 数据输入
@property (nonatomic,strong) AVCaptureDeviceInput *captureInput;
// 捕获的视频数据输出
@property (nonatomic,strong) AVCaptureVideoDataOutput *captureOutput;
// 捕获的元数据输出
@property (nonatomic,strong) AVCaptureMetadataOutput *metaDateOutput;

@property (nonatomic,strong) AVCaptureConnection *captureConnection;

@property(nonatomic,strong) UIImagePickerController *imagePicker; //声明全局的UIImagePickerController


@property (nonatomic,strong) dispatch_queue_t sample;
@property (nonatomic,strong) dispatch_queue_t faceQueue;
@property (nonatomic,strong) UIImageView *cameraView;


@property (nonatomic,strong) UIImageView *topLogoImageView;
@property (nonatomic,strong) UIImageView *bgView;
@property (nonatomic,strong) UIButton *cameraBtn;
@property (nonatomic,strong) UIButton *albumBtn;
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIButton *backButton;

@property (nonatomic,strong) UIView *tableViewBGView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSDictionary *clickDict;
// 选择照片或者拍照片时，之前的视频截取流在返回来数据的话不作响应
@property (nonatomic,assign)BOOL stopSession;

// 拍照或者选择相册照片
@property (nonatomic,strong)UIImage *selectImage;

//@property (nonatomic,assign) UploadImageStatus uploadImageStatus;
@property (nonatomic,strong) NSMutableArray *productViewArray;

 @property (nonatomic,assign) BOOL isHiddleTab;

@end

@implementation ShoppingViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
//    self.navigationController.delegate = self;
//    self.tabBarController.tabBar.hidden = YES;
    
    if (self.fromDetail == YES) {
        [_session startRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _productViewArray = [NSMutableArray array];
    //通知中心是个单例
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    
    // 注册一个监听事件。第三个参数的事件名， 系统用这个参数来区别不同事件。
    [notiCenter addObserver:self selector:@selector(receiveNotification:) name:@"cesuo" object:nil];
    
//    [self.tabBarController.tabBar setHidden:YES];
    [self.view addSubview:self.cameraView];
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.albumBtn];
    [self.view addSubview:self.cameraBtn];
    
    [self.view addSubview:self.tableViewBGView];
    [self.view addSubview:self.topLogoImageView];
    [self.view addSubview:self.backButton];
    
//    self.uploadImageStatus = Success;
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    
    //一个AVCaptureDevice对象代表一个物理采集设备，我们可以通过该对象来设置物理设备的属性。
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *deviceF;
    for (AVCaptureDevice *device in devices )
    {
        if ( device.position == AVCaptureDevicePositionBack )
        {
            deviceF = device;
            break;
        }
    }
    _sample = dispatch_queue_create("sample", NULL);
    _faceQueue = dispatch_queue_create("face", NULL);
    
    AVCaptureDeviceInput*input = [[AVCaptureDeviceInput alloc] initWithDevice:deviceF error:nil];
    self.captureInput = input;
    
    
    //AVCaptureVideoDataOutput，作为视频数据的输出端。
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    self.captureOutput = output;
    
    [output setSampleBufferDelegate:self queue:_sample];
    
    AVCaptureMetadataOutput *metaout = [[AVCaptureMetadataOutput alloc] init];
    self.metaDateOutput = metaout;
    
    [metaout setMetadataObjectsDelegate:self queue:_faceQueue];
    self.session = [[AVCaptureSession alloc] init];
    [self.session beginConfiguration];
    
    if ([self.session canAddInput:self.captureInput]) {
        [self.session addInput:self.captureInput];
    }
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    }
    if ([self.session canAddOutput:self.captureOutput]) {
        [self.session addOutput:self.captureOutput];
    }
    if ([self.session canAddOutput:self.metaDateOutput]) {
        [self.session addOutput:self.metaDateOutput];
    }
    [self.session commitConfiguration];
    
    NSString *key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
    NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [output setVideoSettings:videoSettings];
     AVCaptureSession* session = (AVCaptureSession *)self.session;
    
    // 获取连接并设置视频方向为竖屏方向
    self.captureConnection = [self.captureOutput connectionWithMediaType:AVMediaTypeVideo];
    self.captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    //     设置是否为镜像，前置摄像头采集到的数据本来就是翻转的，这里设置为镜像把画面转回来 AVCaptureDevicePositionFront
    if (self.captureInput.device.position == AVCaptureDevicePositionFront && self.captureConnection.supportsVideoMirroring)
    {
        self.captureConnection.videoMirrored = YES;
    }
    
    //前置摄像头一定要设置一下 要不然画面是镜像
//    for (AVCaptureVideoDataOutput* output in session.outputs) {
//        for (AVCaptureConnection * av in output.connections) {
//            //判断是否是前置摄像头状态
//            if (av.supportsVideoMirroring) {
//                //镜像设置
//                av.videoOrientation = AVCaptureVideoOrientationPortrait;
//                av.videoMirrored = YES;
//            }
//        }
//    }
    
    [self.session startRunning];
}

- (void)dealloc {
   NSLog(@"dealloc");
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    [currentVC.navigationController setNavigationBarHidden:NO animated:YES];
}

-(UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        currentVC = rootVC;
    }
    return currentVC;
}

// @selector(receiveNotification:)方法， 即受到通知之后的事件
- (void)receiveNotification:(NSNotification *)noti
{
    NSLog(@"视频重新开始拾取帧画面");
    self.fromDetail = YES;
}

-(void)cameraImage {
    [self uploadImage:self.cameraView.image];
}

-(void)chooseImage {
    self.fromDetail = NO;
    self.stopSession = YES;
    [self.session stopRunning];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void)backButtonAction {
    [self.navigationController popViewControllerAnimated:true];
}


-(UIView *)tableViewBGView {
    if (!_tableViewBGView) {
        _tableViewBGView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height * 0.4,self.view.frame.size.width,self.view.frame.size.height * 0.6)];
        [_tableViewBGView addSubview:self.tableView];
        _tableViewBGView.backgroundColor = [UIColor whiteColor];
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(12, 0, 80, 50)];
        [button setTitle:@"隐藏" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button addTarget:self action:@selector(tableViewHidden) forControlEvents:UIControlEventTouchUpInside];
        [_tableViewBGView addSubview:button];
        [_tableViewBGView setHidden:YES];
    }
    return _tableViewBGView;
}

-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50,self.view.frame.size.width,self.tableViewBGView.frame.size.height - 50)];
//        [_tableView registerClass:[HomeTableViewCell class] forCellReuseIdentifier:@"HomeTableViewCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIImageView *)cameraView
{
    if (!_cameraView) {
        _cameraView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//        _cameraView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _cameraView;
}

- (UIButton *)albumBtn
{
    if (!_albumBtn) {
        _albumBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 80)/3, self.view.frame.size.height - 70, 40, 40)];
        UIImage *img = [UIImage getShoppingSDKImageWithName:@"get_local_image"];
        [_albumBtn addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
        [_albumBtn setImage:img forState:UIControlStateNormal];
    }
    return _albumBtn;
}

- (UIButton *)cameraBtn
{
    if (!_cameraBtn) {
        _cameraBtn = [[UIButton alloc] initWithFrame:self.view.bounds];
        _cameraBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 80)/3*2 + 40, self.view.frame.size.height - 70, 40, 40)];
        ;
        [_cameraBtn addTarget:self action:@selector(cameraImage) forControlEvents:UIControlEventTouchUpInside];

        UIImage *img = [UIImage getShoppingSDKImageWithName:@"get_preview_image"];
        [_cameraBtn setImage:img forState:UIControlStateNormal];
    }
    return _cameraBtn;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:self.view.bounds];
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 40, 40)];
        ;
        [_backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *img = [UIImage getShoppingSDKImageWithName:@"back_icon_white"];
        [_backButton setImage:img forState:UIControlStateNormal];
    }
    return _backButton;
}



- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 100)];
        _bottomView.backgroundColor = [UIColor blackColor];
    }
    return _bottomView;
}


- (UIImageView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 105, self.view.frame.size.width - 70, self.view.frame.size.height - 105 - 120)];
        UIImage *img = [UIImage getShoppingSDKImageWithName:@"camera_check_detection"];
        _bgView.image = img;
    }
    return _bgView;
}

- (UIImageView *)topLogoImageView
{
    if (!_topLogoImageView) {
        _topLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 75*40/35)/2, 24, 75*40/35, 40)];
        UIImage *img = [UIImage getShoppingSDKImageWithName:@"show_top_logo"];
        _topLogoImageView.image = img;
    }
    return _topLogoImageView;
}


#pragma TableView的隐藏
- (void) tableViewHidden {
    [self.tableViewBGView setHidden:YES];
}

- (void)updateUI:(NSArray *)array {
    for(ProductView *view in self.productViewArray) {
        [view removeFromSuperview];
    }
    [self.productViewArray removeAllObjects];
    for (int i = 0; i< array.count; i++) {
        ProductView *productView = [[ProductView alloc]initWithFrame:CGRectMake(70, 300  + 115 * i, (self.view.frame.size.width - 150), 80)];
        [productView setDict:array[i]];
        productView.clickBlock = ^(NSDictionary *dict){
            self.clickDict = dict;
            [self.tableViewBGView setHidden:NO];
            [self.view bringSubviewToFront:self.tableViewBGView];
            [self.tableView reloadData];
        };
        [self.view addSubview:productView];
        [self.productViewArray addObject:productView];
    }
}

// 使用captureOut:didOutputSampleBuffer:fromConnection方法将被捕获的视频抽样帧发送给抽样缓存委托，然后每个抽样缓存（CMSampleBufferRef）被转换成imageFromSampleBuffer中的一个UIImage对象。
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    UIImage *image = [UIImage imageFromPixelBuffer:sampleBuffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.cameraView.image = image;
    });
//    [self uploadImage:image];
}

-(void)uploadImage:(UIImage *)image {
    
//    if (self.uploadImageStatus == Success) {
//        self.uploadImageStatus = Uploading;
    
//        NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    
    
        [SVProgressHUD show];
        NSData *data = [UIImage compressWithOrgImg:image];
        
        NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        NSDate *datenow = [NSDate date];
        NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
        NSDictionary *dict = @{
                               @"content":encodedImageStr,
                               @"db_id": @"101",
                               @"code": @"101",
                               @"randomValue": timeSp,
                               @"classid": @"0"
                               };
        [[NetworkManager shareNetworkManager] POSTUrl:@"https://ai.tee.com:443/starlink"
                                          contentType:@"application/x-www-form-urlencoded"
                                           parameters:dict success:^(id responseObject) {
                                               //NSLog(@"responseObject====%@",responseObject);
                                               // 将返回的值直接转化为 json 格式，然后再返回
                                               NSError *error;
                                               NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
                                               NSArray *idsArr = dict[@"data"];
                                               NSMutableArray *ids = [NSMutableArray arrayWithArray:idsArr];
                                               NSLog(@"ids====%@",ids);
                                               NSLog(@"ids====%@",error);
                                               NSString *url = @"http://api.380star.com/friendshop/36/goods/recommendgoodslist.do?heleId=";
                                               if (ids.count > 0) {
                                                   if (ids.count == 1) {
                                                       url = [url stringByAppendingString:ids.firstObject];
                                                   }else {
                                                       url = [url stringByAppendingString:ids.firstObject];
                                                       [ids removeObjectAtIndex:0];
                                                       for (NSString *idstr in ids) {
                                                           url = [url stringByAppendingString:[NSString stringWithFormat:@",%@",idstr]];
                                                       }
                                                   }
//                                                   url = @"http://api4test.380star.com/friendshop/36/goods/recommendgoodslist.do?heleId=48295,47083,47130";
                                                   [[NetworkManager shareNetworkManager] GETUrl:url parameters:nil success:^(id responseObject) {
                                                       [SVProgressHUD dismiss];
                                                       NSError *error;
                                                       NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
                                                       //NSLog(@"dict====%@",dict);
                                                       NSDictionary *dataDict = dict[@"data"];
                                                       NSArray *goods = dataDict[@"goodsInfo"];
                                                       ProductDetailVC *vc = [[ProductDetailVC alloc]init];
                                                       vc.image = self.cameraView.image;
                                                       vc.goods = goods;
                                                       [self.navigationController pushViewController:vc animated:YES];
//                                                       if (goods.count == 0) {
////                                                           self.uploadImageStatus = Success;
//                                                       }else {
////                                                           [self updateUI:goods];
//
//                                                       }
                                                   } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
                                                       NSLog(@"responseObject====%@",error);
//                                                       self.uploadImageStatus = Success;
                                                       ProductDetailVC *vc = [[ProductDetailVC alloc]init];
                                                       vc.image = self.cameraView.image;
//                                                       vc.goods = goods;
                                                       [self.navigationController pushViewController:vc animated:YES];
                                                   }];
                                               }
                                               
                                           } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
                                               NSLog(@"responseObject====%@",error);
//                                               self.uploadImageStatus = Success;
                                           }];
//    }
    
}

- (void)clickCell:(NSDictionary *)dict {
    NSLog(@"点击了产品：%@, 如果需要捕捉该事件，可以重新 clickCell 这个方法",dict);
}

#pragma mark - AVCaptureSession Delegate -
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    //当检测到了人脸会走这个回调
    NSLog(@"metadataObjects===%@",metadataObjects);
    //self.currentMetadata = metadataObjects;
    for (AVMetadataFaceObject *object in metadataObjects) {
        if (object.yawAngle >= 315) {//左转头
        }else if (object.yawAngle >= 45 && object.yawAngle <= 90){//右转头
            
        }
    }
}

#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.clickDict[@"commList"];
    return array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *cell = [HomeTableViewCell cellWithTableView:tableView];
    NSArray *array = self.clickDict[@"commList"];
    cell.dict = array[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.clickDict[@"commList"];
    NSDictionary *dict = array[indexPath.row];
    [self clickCell:dict];
}



#pragma mark - UIImagePickerControllerDelegate

//从相机或者相册界面弹出
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [_session startRunning];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
//    [_session stopRunning];
    
    _stopSession = YES;
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.selectImage = image;
    self.cameraView.image = image;
//    for(ProductView *view in self.productViewArray) {
//        [view removeFromSuperview];
//    }
//    [self.productViewArray removeAllObjects];
//    self.uploadImageStatus = Success;
    [self uploadImage:image];
//     self.fromDetail = YES;
//    dispatch_queue_t queueA = dispatch_queue_create("com.yiyaaixuexi.queueA", NULL);
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), queueA, ^{
//        self.fromDetail = YES;
//    });
}


@end
