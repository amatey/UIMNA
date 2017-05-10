//
//  AppDelegate.m
//  UMASS
//


#import "AppDelegate.h"
#import <Quickblox/Quickblox.h>
#import "QMCore.h"
#import "QMImages.h"
#import "QMHelpers.h"

#define DEVELOPMENT 1

#if DEVELOPMENT == 0

// Production
static const NSUInteger kQMApplicationID = 47626;
static NSString * const kQMAuthorizationKey = @"9v3CpXfdMBOymkM";
static NSString * const kQMAuthorizationSecret = @"FCGnERncL-2L2GP";
static NSString * const kQMAccountKey = @"2tRnCCcsryppgREaZEwC";

#else

// Development
static const NSUInteger kQMApplicationID = 47626;
static NSString * const kQMAuthorizationKey = @"9v3CpXfdMBOymkM";
static NSString * const kQMAuthorizationSecret = @"FCGnERncL-2L2GP";
static NSString * const kQMAccountKey = @"2tRnCCcsryppgREaZEwC";

#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    application.applicationIconBadgeNumber = 0;
    //http://map.umassd.edu/map/?id=692#!ct/8268,8267,8402,8264,8262,8257
    // Quickblox settings
    [QBSettings setApplicationID:kQMApplicationID];
    [QBSettings setAuthKey:kQMAuthorizationKey];
    [QBSettings setAuthSecret:kQMAuthorizationSecret];
    [QBSettings setAccountKey:kQMAccountKey];
    
    [QBSettings setAutoReconnectEnabled:YES];
    [QBSettings setCarbonsEnabled:YES];
    
#if DEVELOPMENT == 0
    [QBSettings setLogLevel:QBLogLevelNothing];
    [QBSettings disableXMPPLogging];
    [QMServicesManager enableLogging:NO];
#else
    [QBSettings setLogLevel:QBLogLevelDebug];
    [QBSettings enableXMPPLogging];
    [QMServicesManager enableLogging:YES];
#endif
    
    // QuickbloxWebRTC settings
//    [QBRTCClient initializeRTC];
//    [QBRTCConfig setICEServers:[[QMCore instance].callManager quickbloxICE]];
//    [QBRTCConfig mediaStreamConfiguration].audioCodec = QBRTCAudioCodecISAC;
//    [QBRTCConfig setStatsReportTimeInterval:0.0f]; // set to 1.0f to enable stats report
    
    // Registering for remote notifications
   // [self registerForNotification];
    [self registerForNotification];

    // Configuring app appearance
    UIColor *mainTintColor = [UIColor colorWithRed:238.0f/255.0f green:165.0f/255.0f blue:37.0f/255.0f alpha:1.0f];
    [[UINavigationBar appearance] setTintColor:mainTintColor];
    [[UISearchBar appearance] setTintColor:mainTintColor];
    [[UITabBar appearance] setTintColor:mainTintColor];
    
    // Configuring searchbar appearance
    [[UISearchBar appearance] setSearchBarStyle:UISearchBarStyleMinimal];
    [[UISearchBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setBackgroundImage:QMStatusBarBackgroundImage() forBarPosition:0 barMetrics:UIBarMetricsDefault];
    
   // [SVProgressHUD setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.92f]];
    

    
    // Handling push notifications if needed
    if (launchOptions != nil) {
        
        NSDictionary *pushNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        [QMCore instance].pushNotificationManager.pushNotification = pushNotification;
    }
    

    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)registerForNotification {
    
    NSSet *categories = nil;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings
                                                        settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                        categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)__unused application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [QMCore instance].pushNotificationManager.deviceToken = deviceToken;
}


@end
