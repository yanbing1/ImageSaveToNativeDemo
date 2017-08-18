//
//  ViewController.m
//  ImageSaveToNativeDemo
//
//  Created by 曹燕兵 on 2017/8/18.
//  Copyright © 2017年 曹燕兵. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()<UIGestureRecognizerDelegate,NSURLSessionDelegate>
@property(nonatomic,strong)UIWebView *webview;
@end

@implementation ViewController
//https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/2047158/beerhenge.jpg
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.webview = [[UIWebView alloc]initWithFrame:self.view.frame];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/2047158/beerhenge.jpg"]]];
    UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    
    [self.webview addGestureRecognizer:ges];
    [self.view addSubview:self.webview];
    
}
-(void)longPress:(UILongPressGestureRecognizer*)ges{
    if (ges.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint touchPoint = [ges locationInView:self.webview];
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *urlToSave = [self.webview stringByEvaluatingJavaScriptFromString:imgURL];
    if (urlToSave.length == 0) {
        return;
    }
    
    UIAlertController *alertVC =  [UIAlertController alertControllerWithTitle:@"提示" message:@"你真的要保存图片到相册吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"真的啊" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveImageToDiskWithUrl:urlToSave];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"大哥，我点错了，不好意思" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:okAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];

}
- (void)saveImageToDiskWithUrl:(NSString *)imageUrl{
    NSURL *url = [NSURL URLWithString:imageUrl];
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue new]];
    
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    
    NSURLSessionDownloadTask  *task = [session downloadTaskWithRequest:imgRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            return ;
        }
        NSData * imageData = [NSData dataWithContentsOfURL:location];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImage * image = [UIImage imageWithData:imageData];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
        });
    }];
    [task resume];
}
- (void)imageSavedToPhotosAlbum:(UIImage*)image didFinishSavingWithError:  (NSError*)error contextInfo:(id)contextInfo{
    NSString*message =@"嘿嘿";
    if(!error) {
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"提示" message:@"成功保存到相册" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil];
        [alertControl addAction:action];
        [self presentViewController:alertControl animated:YES completion:nil];
    }else{
        message = [error description];
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertControl addAction:action];
        [self presentViewController:alertControl animated:YES completion:nil];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
@end
