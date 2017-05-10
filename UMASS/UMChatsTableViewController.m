//
//  UMChatsTableViewController.m
//  UMASS
//


#import "UMChatsTableViewController.h"
#import "QMDialogsDataSource.h"
#import "QMPlaceholderDataSource.h"
#import "QMDialogsSearchDataSource.h"
#import "QMPushNotificationManager.h"
#import "QMTasks.h"
#import "QBChatDialog+OpponentID.h"
#import "UMDialogTableViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UMMessageViewController.h"
static const NSInteger kQMUnAuthorizedErrorCode = -1011;


@interface UMChatsTableViewController ()<
QMUsersServiceDelegate,
QMChatServiceDelegate,
QMChatConnectionDelegate,

UITableViewDelegate,
UISearchControllerDelegate,
UISearchResultsUpdating,

QMPushNotificationManagerDelegate,
QMDialogsDataSourceDelegate
>

@property (strong, nonatomic) UISearchController *searchController;

/**
 *  Data sources
 */
@property (strong, nonatomic) QMDialogsDataSource *dialogsDataSource;
@property (strong, nonatomic) QMPlaceholderDataSource *placeholderDataSource;
@property (strong, nonatomic) QMDialogsSearchDataSource *dialogsSearchDataSource;

@property (weak, nonatomic) BFTask *addUserTask;
@property (strong, nonatomic) id observerWillEnterForeground;

@end

@implementation UMChatsTableViewController{
    NSMutableArray *itemsArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    itemsArray = [[self items] mutableCopy];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        // skip view controller setup if app was
        // instantinated to send a message from background
        return;
    }
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    [self.tableView setEditing:YES]
    // search implementation
    //[self configureSearch];
    
    // Data sources init
    [self configureDataSources];
    
    // registering nibs for current VC and search results VC
    //[self registerNibs];
    
    // Subscribing delegates
    [[QMCore instance].chatService addDelegate:self];
    [[QMCore instance].usersService addDelegate:self];
    
    [self performAutoLoginAndFetchData];
    
    // adding refresh control task
    if (self.refreshControl) {
        
        self.refreshControl.backgroundColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(updateDialogsAndEndRefreshing)
                      forControlEvents:UIControlEventValueChanged];
    }
    
    @weakify(self);
    // adding notification for showing chat connection
    self.observerWillEnterForeground = [[NSNotificationCenter defaultCenter]
                                        addObserverForName:UIApplicationWillEnterForegroundNotification
                                        object:nil
                                        queue:nil
                                        usingBlock:^(NSNotification * _Nonnull __unused note) {
                                            
                                            @strongify(self);
                                            if (![QBChat instance].isConnected) {
                                                NSLog(@"Failed to connect to chats");
                                                // [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_CONNECTING", nil) duration:0];
                                            }
                                        }];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:true];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier  isEqualToString: @"CHAT_SCREEN"]) {
        UMMessageViewController *detailVC = segue.destinationViewController;
        NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
        QBChatDialog *chatDialog = self.items[selectedPath.row];
        detailVC.chatDialog = chatDialog;
    }
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self items] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UMDialogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UMDialogTableViewCell" forIndexPath:indexPath];
    QBChatDialog *chatDialog = self.items[indexPath.row];
    QBUUser *recipient = [[QMCore instance].usersService.usersMemoryStorage userWithID:[chatDialog opponentID]];
    cell.userNameLbl.text = recipient.fullName;
    cell.previousChatLbl.text = chatDialog.lastMessageText;
    
    if (chatDialog.unreadMessagesCount == 0) {
        [cell.dialogCountLbl setHidden:YES];
    }
    cell.dialogCountLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)chatDialog.unreadMessagesCount];
    cell.dialogNameLbl.text = [[recipient.fullName substringToIndex:2] uppercaseString];
    // Configure the cell...
    
    return cell;
}

- (BOOL)tableView:(UITableView *)__unused tableView canEditRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)__unused tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        QBChatDialog *chatDialog = self.items[indexPath.row];
        
        BFContinuationBlock completionBlock = ^id _Nullable(BFTask * _Nonnull __unused task) {
            
            if ([[QMCore instance].activeDialogID isEqualToString:chatDialog.ID]) {
                
                //                [(QMSplitViewController *)self.splitViewController showPlaceholderDetailViewController];
            }
            
            [SVProgressHUD dismiss];
            return nil;
        };
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        if (chatDialog.type == QBChatDialogTypeGroup) {
            
            chatDialog.occupantIDs = [[QMCore instance].contactManager occupantsWithoutCurrentUser:chatDialog.occupantIDs];
            [[[QMCore instance].chatManager leaveChatDialog:chatDialog] continueWithSuccessBlock:completionBlock];
        }
        else {
            // private and public group chats
          //  [[[QMCore instance].chatService deleteDialogWithID:chatDialog.ID] continueWithSuccessBlock:completionBlock];
            
            [[QMCore instance].chatService.messagesMemoryStorage deleteMessagesWithDialogID:chatDialog.ID];
            [self.tableView endEditing:YES];
            [self.tableView reloadData];
            [SVProgressHUD dismiss];

        }

//        [itemsArray removeObjectAtIndex:0];
//        [tableView beginUpdates];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                         withRowAnimation:UITableViewRowAnimationFade];
//        [tableView endUpdates];
        
    }
}

#pragma MARK -- GET CHAT DATA SOURCE ---
- (void)configureDataSources {
    
    //    self.dialogsDataSource = [[QMDialogsDataSource alloc] init];
    //    self.dialogsDataSource.delegate = self;
    //    self.placeholderDataSource  = [[QMPlaceholderDataSource alloc] init];
    //    self.tableView.dataSource = self.placeholderDataSource;
    
    //    QMDialogsSearchDataProvider *searchDataProvider = [[QMDialogsSearchDataProvider alloc] init];
    //    searchDataProvider.delegate = self.searchResultsController;
    //
    //    self.dialogsSearchDataSource = [[QMDialogsSearchDataSource alloc] initWithSearchDataProvider:searchDataProvider];
}

- (void)performAutoLoginAndFetchData {
    
    //    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_CONNECTING", nil) duration:0];
    [SVProgressHUD showWithStatus:@"Loading.."];
    __weak UINavigationController *navigationController = self.navigationController;
    
    @weakify(self);
    [[[[QMCore instance] login] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        @strongify(self);
        if (task.isFaulted) {
            
            // [navigationController dismissNotificationPanel];
            
            if (task.error.code == kQMUnAuthorizedErrorCode
                || (task.error.code == kBFMultipleErrorsError
                    && ([task.error.userInfo[BFTaskMultipleErrorsUserInfoKey][0] code] == kQMUnAuthorizedErrorCode
                        || [task.error.userInfo[BFTaskMultipleErrorsUserInfoKey][1] code] == kQMUnAuthorizedErrorCode))) {
                        
                        return [[QMCore instance] logout];
                    }
        }
        
        if ([QMCore instance].pushNotificationManager.pushNotification != nil) {
            
            [[QMCore instance].pushNotificationManager handlePushNotificationWithDelegate:self];
        }
        NSLog(@"All Chats:%@",[self items]);
        [self updateDialogsAndEndRefreshing];
        return [BFTask cancelledTask];
        
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        if (!task.isCancelled) {
            
            // [self performSegueWithIdentifier:kQMSceneSegueAuth sender:nil];
        }
        
        return nil;
    }];
}

///////  This is used to fetch all the chats data from data base keep it up -------

- (NSMutableArray *)items {
    
    return [[[QMCore instance].chatService.dialogsMemoryStorage dialogsSortByLastMessageDateWithAscending:NO] mutableCopy];
}

- (void)updateDialogsAndEndRefreshing {
    
    @weakify(self);
    [[QMTasks taskFetchAllData] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        @strongify(self);
        NSLog(@"All Chats:%@",[self items]);
        [self forEach];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
        return nil;
    }];
}


-(void)forEach{
    
    for (QBChatDialog *chatDialog in self.items) {
        
        QBUUser *recipient = [[QMCore instance].usersService.usersMemoryStorage userWithID:[chatDialog opponentID]];
        NSLog(@"USER &&:%@",recipient.fullName);
    }
    //    QBChatDialog *chatDialog = self.items[indexPath.row];
    //    QBUUser *recipient = [[QMCore instance].usersService.usersMemoryStorage userWithID:[chatDialog opponentID]];
    //    if (chatDialog.type == QBChatDialogTypePrivate) {
    //
    //        QBUUser *recipient = [[QMCore instance].usersService.usersMemoryStorage userWithID:[chatDialog opponentID]];
    //
    //        if (recipient.fullName != nil) {
    //
    //            [cell setTitle:recipient.fullName placeholderID:[chatDialog opponentID] avatarUrl:recipient.avatarUrl];
    //        }
    //        else {
    //
    //            [cell setTitle:NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil) placeholderID:[chatDialog opponentID] avatarUrl:nil];
    //        }
    //    } else {
    //
    //        [cell setTitle:chatDialog.name placeholderID:chatDialog.ID.hash avatarUrl:chatDialog.photo];
    //    }
    //
    //    // there was a time when updated at didn't exist
    //    // in order to support old dialogs, showing their date as last message date
    //    NSDate *date = chatDialog.updatedAt ?: chatDialog.lastMessageDate;
    //
    //    NSString *time = [QMDateUtils formattedShortDateString:date];
    //    [cell setTime:time];
    //    [cell setBody:chatDialog.lastMessageText];
    //    [cell setBadgeNumber:chatDialog.unreadMessagesCount];
    
}

@end
