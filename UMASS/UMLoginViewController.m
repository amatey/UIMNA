//
//  UMLoginViewController.m
//  UMASS
//


#import "UMLoginViewController.h"
#import "QMCore.h"
#import <SVProgressHUD/SVProgressHUD.h>
@interface UMLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) BFTask *task;
@property (assign, nonatomic)BOOL  isLoginSuccess;

@end

@implementation UMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doLogin:(id)sender {
    
    if (self.task != nil) {
        // task in progress
        return;
    }
    
    if (self.emailTextField.text.length == 0 || self.passwordTextField.text.length == 0) {
        
       // [self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) duration:kQMDefaultNotificationDismissTime];
    }
    else {
        [SVProgressHUD showWithStatus:@"Loging in"];
        QBUUser *user = [QBUUser user];
        user.email = self.emailTextField.text;
        user.password = self.passwordTextField.text;
        
       // [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_SIGNING_IN", nil) duration:0];
        
        __weak UINavigationController *navigationController = self.navigationController;
        
        @weakify(self);
        self.task = [[[QMCore instance].authService loginWithUser:user] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
            
            @strongify(self);
            //[navigationController dismissNotificationPanel];
            
            if (!task.isFaulted) {
                [SVProgressHUD dismiss];
                
                // navigate to home
//                [self performSegueWithIdentifier:@"LOGIN" sender:nil];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *initialViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"rootController"];
                [[UIApplication sharedApplication].keyWindow setRootViewController:initialViewController];
                [QMCore instance].currentProfile.accountType = QMAccountTypeEmail;
                [[QMCore instance].currentProfile synchronizeWithUserData:task.result];
                return [[QMCore instance].pushNotificationManager subscribeForPushNotifications];
            }
            
            return nil;
        }];
    }

    
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"LOGIN"] && _isLoginSuccess){
        return YES;
    }
    return NO;
}


@end
