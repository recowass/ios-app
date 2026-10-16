#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

static NSString * const OlmosURLKey = @"OlmosPanelURL";

@interface OlmosViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) UIButton *reloadButton;
@property(nonatomic, strong) UIButton *addressButton;
@property(nonatomic, strong) UILabel *statusLabel;
@end

@implementation OlmosViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // Device-only presentation: leave the hosted panel and its state logic untouched.
    // Attribute selectors follow every state refresh without polling or observers.
    NSString *panelStyle = @"(function(){var s=document.createElement('style');"
        "s.textContent='#devices .device{-webkit-transform:translate(-50%,-50%) scale(1.2)!important;"
        "transform:translate(-50%,-50%) scale(1.2)!important;}' +"
        "'#devices .device[style*=\"rgb(34, 197, 94)\"],"
        "#devices .device[style*=\"rgb(34,197,94)\"],"
        "#devices .device[style*=\"#22c55e\"]{color:#ffd400!important;}';"
        "(document.head||document.documentElement).appendChild(s);}());";
    [config.userContentController addUserScript:[[WKUserScript alloc]
        initWithSource:panelStyle injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
        forMainFrameOnly:YES]];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.backgroundColor = [UIColor blackColor];
    self.webView.opaque = NO;
    [self.view addSubview:self.webView];
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setTitle:@"Recargar" forState:UIControlStateNormal];
    self.reloadButton.backgroundColor = [UIColor colorWithWhite:0.12 alpha:0.9];
    [self.reloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.reloadButton addTarget:self action:@selector(loadPanel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.reloadButton];
    self.addressButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addressButton setTitle:@"Dirección" forState:UIControlStateNormal];
    self.addressButton.backgroundColor = self.reloadButton.backgroundColor;
    [self.addressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addressButton addTarget:self action:@selector(editAddress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addressButton];
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.95];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.webView.URL) [self loadPanel];
}
- (BOOL)prefersStatusBarHidden { return YES; }
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect bounds = self.view.bounds;
    self.webView.frame = bounds;
    self.reloadButton.frame = CGRectMake(8, CGRectGetHeight(bounds) - 48, 100, 40);
    self.addressButton.frame = CGRectMake(116, CGRectGetHeight(bounds) - 48, 100, 40);
    self.statusLabel.frame = CGRectMake(12, 65, CGRectGetWidth(bounds) - 24, 110);
}
- (void)loadPanel {
    NSString *address = [[NSUserDefaults standardUserDefaults] stringForKey:OlmosURLKey];
    if (!address.length) { [self editAddress]; return; }
    self.statusLabel.text = @"Cargando Los Olmos…";
    self.statusLabel.hidden = NO;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:address]
        cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30]];
}
- (void)editAddress {
    if (self.presentedViewController) return;
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Dirección del panel"
        message:@"Introduce la URL completa de tu panel local. Se guarda solamente en este dispositivo."
        preferredStyle:UIAlertControllerStyleAlert];
    [dialog addTextFieldWithConfigurationHandler:^(UITextField *field) {
        field.text = [[NSUserDefaults standardUserDefaults] stringForKey:OlmosURLKey];
        field.placeholder = @"http://servidor:8123/local/panel/index.html";
        field.keyboardType = UIKeyboardTypeURL;
        field.autocapitalizationType = UITextAutocapitalizationTypeNone;
        field.autocorrectionType = UITextAutocorrectionTypeNo;
    }];
    __weak typeof(self) weakSelf = self;
    [dialog addAction:[UIAlertAction actionWithTitle:@"Abrir" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *value = [dialog.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSURL *url = [NSURL URLWithString:value];
        if (!url.host.length || !([url.scheme.lowercaseString isEqualToString:@"http"] || [url.scheme.lowercaseString isEqualToString:@"https"])) {
            weakSelf.statusLabel.text = @"Dirección inválida. Pulsa Dirección e introduce una URL http o https completa.";
            weakSelf.statusLabel.hidden = NO;
            return;
        }
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:OlmosURLKey];
        [weakSelf loadPanel];
    }]];
    [dialog addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:dialog animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.statusLabel.hidden = YES;
}
- (void)showError:(NSError *)error {
    if (error.code == NSURLErrorCancelled && [error.domain isEqualToString:NSURLErrorDomain]) return;
    self.statusLabel.text = [NSString stringWithFormat:@"No se pudo abrir el panel. Comprueba la Wi-Fi y pulsa Recargar.\n%@", error.localizedDescription];
    self.statusLabel.hidden = NO;
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self showError:error];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self showError:error];
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    // Avoid an endless reload loop on an old device with limited memory.
    self.statusLabel.text = @"El visor se ha detenido. Pulsa Recargar para volver a abrir el panel.";
    self.statusLabel.hidden = NO;
}
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
    forNavigationAction:(WKNavigationAction *)action windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!action.targetFrame) [webView loadRequest:action.request];
    return nil;
}
@end

@interface OlmosAppDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic, strong) UIWindow *window;
@end
@implementation OlmosAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[OlmosViewController alloc] init];
    [self.window makeKeyAndVisible];
    application.idleTimerDisabled = YES;
    return YES;
}
- (void)applicationDidBecomeActive:(UIApplication *)application { application.idleTimerDisabled = YES; }
- (void)applicationWillResignActive:(UIApplication *)application { application.idleTimerDisabled = NO; }
@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([OlmosAppDelegate class]));
    }
}
