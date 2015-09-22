//
//  ViewController.m
//  BackgroundDownloadTaskDemo
//
//  Created by Alex Shevlyakov on 22.09.15.
//
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController () <NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *ibProgressView;
@property (weak, nonatomic) IBOutlet UIImageView *ibImageView;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ibProgressView.progress = 0.0;
    self.ibImageView.image = nil;
    
    NSString *backgroundIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:backgroundIdentifier];
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)crashDidPressed:(id)sender
{
    NSLog(@"Crash");
    exit(0);
}

- (IBAction)loadDidPressed:(id)sender
{
    NSLog(@"Load");
    
    if (self.downloadTask == nil) {
        self.ibProgressView.progress = 0.0;
        self.ibImageView.image = nil;
        
        NSURL *imageUrl = [NSURL URLWithString:@"https://parklandsgreens.files.wordpress.com/2013/10/grass-covered-earth.jpg"];
        
        self.downloadTask = [self.session downloadTaskWithURL:imageUrl];
        [self.downloadTask resume];
    }
}


#pragma mark - 

//- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error
//{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
// completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
//{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session NS_AVAILABLE_IOS(7_0)
//{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}



- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil) {
        NSLog(@"Task %@ completed successfully", task);
    } else {
        NSLog(@"Task %@ completed with error: %@", task, [error localizedDescription]);
    }
    self.downloadTask = nil;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.sessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.sessionCompletionHandler;
        appDelegate.sessionCompletionHandler = nil;
        completionHandler();
    }
    NSLog(@"Task complete");
}

- (NSURL *)imageLocationUrl
{
    NSURL *documents = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [documents URLByAppendingPathComponent:@"image.jpg"];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.ibProgressView.progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    
    [fileManager removeItemAtURL:[self imageLocationUrl] error:NULL]; // Remove file at the destination if it already exists.
    [fileManager copyItemAtURL:location toURL:[self imageLocationUrl] error:&error];
    
    if ([fileManager fileExistsAtPath:[location path]]) {
        NSError *error = nil;
        [fileManager moveItemAtURL:location toURL:[self imageLocationUrl] error:&error];
        
        if (error) {
            NSLog(@"Unable to move temporary file to destination. %@, %@", error, error.userInfo);
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.ibProgressView.progress = 1.0;
        self.ibImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self imageLocationUrl]]];
    });
}


@end
