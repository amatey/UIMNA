//
//  UMMessageViewController.m
//  UMASS
//


#import "UMMessageViewController.h"
#import "QMCore.h"
#import "QBChatDialog+OpponentID.h"
// BELOW ITEMS FOR COLLECTION VIEW

#import "SPHCollectionViewcell.h"
#import "SPH_PARAM_List.h"
#import "iosMacroDefine.h"
#import "QMMessagesHelper.h"
static NSString *CellIdentifier = @"cellIdentifier";
@interface UMMessageViewController ()<QMChatServiceDelegate,QMContactListServiceDelegate,QMChatConnectionDelegate>
@property(nonatomic,strong)NSMutableArray *chatsData;
@property (weak, nonatomic) BFTask *contactRequestTask;

@end

@implementation UMMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[QMCore instance].chatService addDelegate:self];
    [[QMCore instance].contactListService addDelegate:self];
    [QMCore instance].activeDialogID = self.chatDialog.ID;
    self.chatsData = [[NSMutableArray alloc]init];
    // inserting messages
    if ([self storedMessages].count > 0) {
        
        // [self.chatDataSource addMessages:self.storedMessages];
        
        for (id message in [self storedMessages]) {
            NSString *textBy;
            //[self toQBMessage:message];
            QBChatMessage *msgID = [self toQBMessage:message];
            [self readMessage:msgID];
            NSUInteger opponentID = [self.chatDialog opponentID];
           // BOOL isFriend = [[QMCore instance].contactManager isFriendWithUserID:opponentID];
           /* if (msgID.messageType == QMMessageTypeContactRequest && msgID.senderID != self.senderID && !isFriend) {
                QBChatMessage *lastMessage = [[QMCore instance].chatService.messagesMemoryStorage lastMessageFromDialogID:self.chatDialog.ID];
                
                NSLog(@"it's a friend Request");
                [self showAlertWithTitle:@"Friend request !" message:@"" delegate:self antTag:101 onCompletion:^(int *index) {
                    
                    if (index == 0) {
                        //TODO: Accept
                        [self chatContactRequestDidAccept:true sender:self];
                    }else{
                        //TODO: Decline
                       // [self.navigationController popViewControllerAnimated:YES];
                        [self chatContactRequestDidAccept:false sender:self];
                    }
                    
                }];
                //TODO: Accept request Alert
               /* if ([lastMessage isEqual:item]) {
                    return [QMChatContactRequestCell class];
                }*/
           // }
            if ([[message valueForKey:@"senderID"] unsignedLongValue] == self.chatDialog.userID){
                textBy = kSTextByme;
            }else{
                textBy = kSTextByOther;
            }
            
            
            
            
            if (msgID.messageType == QMMessageTypeContactRequest && msgID.senderID != self.senderID ) {
                
            }else{
               [self adddMediaBubbledata:textBy mediaPath:[message valueForKey:@"text"] mtime:@"" thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:@""];
            }

            
        }
        [self.sphChatTable reloadData];
        
    }
    [self refreshMessages];
    //chat screen design
    
    UINib *cellNib = [UINib nibWithNibName:@"View" bundle:nil];
    [self.sphChatTable registerNib:cellNib forCellWithReuseIdentifier:CellIdentifier];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.sphChatTable addGestureRecognizer:tap];
    self.sphChatTable.backgroundColor =[UIColor clearColor];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.messageField.leftView = paddingView;
    self.messageField.leftViewMode = UITextFieldViewModeAlways;
    [self.sphChatTable reloadData];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"ChatBack.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    [self.sphChatTable setBackgroundColor:[UIColor colorWithPatternImage:image]];
}

-(void)loadData{
    [QMCore instance].activeDialogID = self.chatDialog.ID;
    self.chatsData = [[NSMutableArray alloc]init];
    // inserting messages
    if ([self storedMessages].count > 0) {
        
        // [self.chatDataSource addMessages:self.storedMessages];
        
        for (id message in [self storedMessages]) {
            NSString *textBy;
            if ([[message valueForKey:@"senderID"] unsignedLongValue] == self.chatDialog.userID)
                textBy = kSTextByme;
            else
                textBy = kSTextByOther;
            
            [self adddMediaBubbledata:textBy mediaPath:[message valueForKey:@"text"] mtime:@"" thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:@""];
            
        }
        [self.sphChatTable reloadData];
        
    }
    [self refreshMessages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard
{
    [self.view endEditing:YES];
}

-(void)scrollTableview
{
    
    NSInteger item = [self collectionView:self.sphChatTable numberOfItemsInSection:0] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:0];
//    [self.sphChatTable
//     scrollToItemAtIndexPath:lastIndexPath
//     atScrollPosition:UICollectionViewScrollPositionBottom
//     animated:NO];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.chatsData.count>2) {
        [self performSelector:@selector(scrollTableview) withObject:nil afterDelay:0.0];
    }
    
    CGRect msgframes=self.msgInPutView.frame;
    //CGRect btnframes=self.sendChatBtn.frame;
    CGRect tableviewframe=self.sphChatTable.frame;
    msgframes.origin.y=self.view.frame.size.height-290;
    tableviewframe.size.height-=200;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.msgInPutView.frame=msgframes;
        self.sphChatTable.frame=tableviewframe;
    }];
    
    
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{ CGRect msgframes=self.msgInPutView.frame;
    //CGRect btnframes=self.sendChatBtn.frame;
    CGRect tableviewframe=self.sphChatTable.frame;
    
    msgframes.origin.y=self.view.frame.size.height-50;
    tableviewframe.size.height+=200;
    self.sphChatTable.frame=tableviewframe;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.msgInPutView.frame=msgframes;
    }];

}

- (NSUInteger)senderID {
    return [QMCore instance].currentProfile.userData.ID;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    SPH_PARAM_List *feed_data=[[SPH_PARAM_List alloc]init];
    feed_data=[self.chatsData objectAtIndex:indexPath.row];
    
    if ([feed_data.chat_media_type isEqualToString:kSTextByme]||[feed_data.chat_media_type isEqualToString:kSTextByOther])
    {
        
        NSStringDrawingContext *ctx = [NSStringDrawingContext new];
        NSAttributedString *aString = [[NSAttributedString alloc] initWithString:feed_data.chat_message];
        UITextView *calculationView = [[UITextView alloc] init];
        [calculationView setAttributedText:aString];
        CGRect textRect = [calculationView.text boundingRectWithSize: CGSizeMake(TWO_THIRDS_OF_PORTRAIT_WIDTH, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:calculationView.font} context:ctx];
        
        return CGSizeMake(306,textRect.size.height+40);
    }
    
    
    return CGSizeMake(306, 90);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.chatsData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPHCollectionViewcell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       for (UIView *v in [cell.contentView subviews])
                           [v removeFromSuperview];
                       
                       if ([self.sphChatTable.indexPathsForVisibleItems containsObject:indexPath])
                       {
                           [cell setFeedData:(SPH_PARAM_List*)[self.chatsData objectAtIndex:indexPath.row]];
                       }
                   });
    return cell;
}



- (void)updateOpponentOnlineStatus {
    
    BOOL isOnline = [[QMCore instance].contactManager isUserOnlineWithID:[self.chatDialog opponentID]];
    //[self setOpponentOnlineStatus:isOnline];
}

- (NSArray *)storedMessages {
    
    return [[QMCore instance].chatService.messagesMemoryStorage messagesWithDialogID:self.chatDialog.ID];
}

- (void)refreshMessages {
    
    @weakify(self);
    // Retrieving message from Quickblox REST history and cache.
    [[QMCore instance].chatService messagesWithChatDialogID:self.chatDialog.ID iterationBlock:^(QBResponse * __unused response, NSArray *messages, BOOL * __unused stop) {
        
        @strongify(self);
        if (messages.count > 0) {
            
            //[self.chatDataSource addMessages:messages];
            NSLog(@"Messages:%@",messages);
            if ([self storedMessages].count > 0) {
                
                // [self.chatDataSource addMessages:self.storedMessages];
                
                for (id message in [self storedMessages]) {
                    NSString *textBy;
                    if ([[message valueForKey:@"senderID"] unsignedLongValue] == self.chatDialog.userID)
                        textBy = kSTextByme;
                    else
                        textBy = kSTextByOther;
                    
                    [self adddMediaBubbledata:textBy mediaPath:[message valueForKey:@"text"] mtime:@"" thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:@""];
                    
                }
                [self.sphChatTable reloadData];
                
            }
            
        }
    }];
}
- (IBAction)sendMessageNow:(id)sender
{
//    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    QBChatMessage *message = [QMMessagesHelper chatMessageWithText:self.messageField.text
                                                          senderID:[self senderID]
                                                      chatDialogID:self.chatDialog.ID
                                                          dateSent:[NSDate date]];
    [self _sendMessage:message];
    [self.sphChatTable reloadData];
    [self scrollTableview];
    if ([self.messageField.text length]>0) {
        BOOL isfromMe = YES;
        if (isfromMe)
        {
            [self adddMediaBubbledata:kSTextByme mediaPath:self.messageField.text mtime:[formatter stringFromDate:[NSDate date]] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:@""];
            self.messageField.text = @"";
            [self.view endEditing:YES];
            //[self adddMediaBubbledata:textBy mediaPath:[message valueForKey:@"text"] mtime:@"" thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:@""]
            //[self performSelector:@selector(messageSent:) withObject:rowNum afterDelay:1];
           // isfromMe=NO;
        }
        else
        {
            //[self adddMediaBubbledata:kSTextByOther mediaPath:self.messageField.text mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:[self genRandStringLength:7]];
            //isfromMe=YES;
        }
        
        [self.sphChatTable reloadData];
        [self scrollTableview];
    }
}

- (void)_sendMessage:(QBChatMessage *)message {
    
    [[[QMCore instance].chatService sendMessage:message toDialog:self.chatDialog saveToHistory:YES saveToStorage:YES] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        //[QMSoundManager playMessageSentSound];
        
        return nil;
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)__unused chatService {
    
    [self refreshMessages];
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        [self updateOpponentOnlineStatus];
    }
}

- (void)chatServiceChatDidReconnect:(QMChatService *)__unused chatService {
    
    [self refreshMessages];
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        [self updateOpponentOnlineStatus];
    }
}

- (void)chatServiceChatDidAccidentallyDisconnect:(QMChatService *)__unused chatService {
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        // chat disconnected, updating title status for user
        
        //[self setOpponentOnlineStatus:NO];
    }
}

-(void)adddMediaBubbledata:(NSString*)mediaType  mediaPath:(NSString*)mediaPath mtime:(NSString*)messageTime thumb:(NSString*)thumbUrl  downloadstatus:(NSString*)downloadstatus sendingStatus:(NSString*)sendingStatus msg_ID:(NSString*)msgID
{
    
    SPH_PARAM_List *feed_data=[[SPH_PARAM_List alloc]init];
    feed_data.chat_message=mediaPath;
    feed_data.chat_date_time=messageTime;
    feed_data.chat_media_type=mediaType;
    feed_data.chat_send_status=sendingStatus;
    feed_data.chat_Thumburl=thumbUrl;
    feed_data.chat_downloadStatus=downloadstatus;
    feed_data.chat_messageID=msgID;
    [_chatsData addObject:feed_data];
}

#pragma MARK --- CHAT SERVICE DELEGATES ----------

- (void)chatService:(QMChatService *)chatService didLoadMessagesFromCache:(NSArray QB_GENERIC(QBChatMessage *) *)messages forDialogID:(NSString *)dialogID;{
    
    NSLog(@"didLoadMessagesFromCache:%@",messages);
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray QB_GENERIC(QBChatDialog *) *)chatDialogs;{
    
    NSLog(@"didAddChatDialogsToMemoryStorage:%@",chatDialogs);

}
- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID;{
    NSLog(@"didAddMessageToMemoryStorage:%@",message);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    if ([[message valueForKey:@"senderID"] unsignedLongValue] == self.chatDialog.userID){
    }else{
        [self adddMediaBubbledata:kSTextByOther mediaPath:message.text mtime:[formatter stringFromDate:[NSDate date]] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:@""];
        [self.sphChatTable reloadData];
    }
}

- (void)chatService:(QMChatService *)chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog;{
    NSLog(@"didReceiveNotificationMessage:%@",message);
}

- (void)readMessage:(QBChatMessage *)message {
    
    if (message.senderID != self.senderID && ![message.readIDs containsObject:@(self.senderID)]) {
        
        [[[QMCore instance].chatService readMessage:message] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            if (task.isFaulted) {
                
                ILog(@"Problems while marking message as read! Error: %@", task.error);
            }
            else if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
                
                [UIApplication sharedApplication].applicationIconBadgeNumber--;
            }
            
            return nil;
        }];
    }
}

-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate antTag:(int)tag onCompletion:(actionCallBack)completion;
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Accept", @"OK action")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      // UITextField *login = alertController.textFields.firstObject;
                                      completion(0);
                                  }];
    UIAlertAction *closeAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Reject", @"OK action")
                                  style:UIAlertActionStyleCancel
                                  handler:^(UIAlertAction *action)
                                  {
                                      // UITextField *login = alertController.textFields.firstObject;
                                      completion(1);
                                  }];
    [alertController addAction:okAction];
    [alertController addAction:closeAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(QBChatMessage *)toQBMessage:(NSDictionary *)dict{
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.ID = [dict valueForKey:@"ID"];
    message.text = [dict valueForKey:@"text"];
    message.recipientID = [[dict valueForKey:@"recipientID"] longLongValue];
    message.senderID = [[dict valueForKey:@"senderID"] longLongValue];
    //message.dateSent = self.dateSend;
    message.dialogID = [dict valueForKey:@"dialogID"];
    message.customParameters = [dict valueForKey:@"customParameters"];
    message.read = [[dict valueForKey:@"read"] boolValue];
    //message.updatedAt = self.updateAt;
   // message.createdAt = self.createAt;
   // message.delayed = self.delayed.boolValue;
   // message.readIDs = [[self objectsWithBinaryData:self.readIDs] copy];
   // message.deliveredIDs = [[self objectsWithBinaryData:self.deliveredIDs] copy];
    return message;
}
- (NSData *)binaryDataWithObject:(id)object {
    
    NSData *binaryData = [NSKeyedArchiver archivedDataWithRootObject:object];
    return binaryData;
}
- (id)objectsWithBinaryData:(NSData *)data {
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

#pragma mark QMChatActionsHandler protocol

- (void)chatContactRequestDidAccept:(BOOL)accept sender:(id)sender {
    
   
    
    QBUUser *opponentUser = [[QMCore instance].usersService.usersMemoryStorage userWithID:[self.chatDialog opponentID]];
    //[self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    if (accept) {
        
       // NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
       // QBChatMessage *currentMessage = [self.chatDataSource messageForIndexPath:indexPath];
        
        __weak UINavigationController *navigationController = self.navigationController;
        
        @weakify(self);
        self.contactRequestTask = [[[QMCore instance].contactManager addUserToContactList:opponentUser] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            @strongify(self);
           // [navigationController dismissNotificationPanel];
            
            if (!task.isFaulted) {
                
               // [self.chatDataSource updateMessage:currentMessage];
                
            }
            
            return nil;
        }];
    }
    else {
        
        __weak UINavigationController *navigationController = self.navigationController;
        
        @weakify(self);
        self.contactRequestTask = [[[[QMCore instance].contactManager rejectAddContactRequest:opponentUser] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            if (!task.isFaulted) {
                
                return [[QMCore instance].chatService deleteDialogWithID:self.chatDialog.ID];
            }
            
            return [BFTask cancelledTask];
            
        }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            @strongify(self);
            //[navigationController dismissNotificationPanel];
            
            if (!task.isCancelled && !task.isFaulted) {
                
                if (self.splitViewController.isCollapsed) {
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else {
                    
                   // [(QMSplitViewController *)self.splitViewController showPlaceholderDetailViewController];
                }
            }
            
            return nil;
        }];
    }
}

@end
