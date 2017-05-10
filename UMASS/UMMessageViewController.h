//
//  UMMessageViewController.h
//  UMASS
//


#import <JSQMessagesViewController/JSQMessagesViewController.h>
typedef void(^actionCallBack)(int *index);


@interface UMMessageViewController : UIViewController <UIActionSheetDelegate>

@property (strong, nonatomic, nullable) QBChatDialog *chatDialog;
@property (weak, nonatomic) IBOutlet UICollectionView *sphChatTable;
@property (weak, nonatomic) IBOutlet UIView *msgInPutView;
@property (weak, nonatomic) IBOutlet UITextField *messageField;

@end
