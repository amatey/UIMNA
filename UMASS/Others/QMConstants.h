//
//  QMConstants.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#ifndef QMConstants_h
#define QMConstants_h

#ifdef DEBUG

#define ILog(...) do { NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]); } while(0)

#else

#define ILog(...) do { } while (0)

#endif

// storyboards
static NSString *const kQMMainStoryboard = @"Main";
static NSString *const kQMChatStoryboard = @"Chat";
static NSString *const kQMSettingsStoryboard = @"Settings";

static NSString *const kQMPushNotificationDialogIDKey = @"dialog_id";
static NSString *const kQMPushNotificationUserIDKey = @"user_id";

static NSString *const kQMDialogsUpdateNotificationMessage = @"Notification message";
static NSString *const kQMContactRequestNotificationMessage = @"Contact request";
static NSString *const kQMLocationNotificationMessage = @"Location";
static NSString *const kQMCallNotificationMessage = @"Call notification";

static const CGFloat kQMBaseAnimationDuration = 0.2f;
static const CGFloat kQMSlashAnimationDuration = 0.1f;
static const CGFloat kQMDefaultNotificationDismissTime = 2.0f;
static const CGFloat kQMShadowViewHeight = 0.5f;

static const CLLocationDegrees MKCoordinateSpanDefaultValue = 250;


/**
 *  Segue identifiers that used in project
 */

static NSString *const kQMSceneSegueAuth                    = @"SceneSegueAuth";
static NSString *const kQMSceneSegueLogin                   = @"SceneSegueLogin";
static NSString *const kQMSceneSegueChat                    = @"SceneSegueChat";
static NSString *const kQMSceneSegueMain                    = @"SceneSegueMain";
static NSString *const kQMSceneSegueStart                   = @"SceneSegueStart";
static NSString *const kQMSceneSegueFriendDetails           = @"SceneSegueFriendDetails";
static NSString *const kQMSceneSegueProfile                 = @"SceneSegueProfile";
static NSString *const kQMSceneSegueNewMessage              = @"SceneSegueNewMessage";
static NSString *const kQMSceneSegueNewMessageContactList   = @"SceneSegueNewMessageContactList";
static NSString *const kQMSceneSegueUserInfo                = @"SceneSegueUserInfo";
static NSString *const KQMSceneSegueGroupInfo               = @"SceneSegueGroupInfo";
static NSString *const KQMSceneSegueGroupOccupants          = @"SceneSegueGroupOccupants";
static NSString *const kQMSceneSegueGroupAddUsers           = @"SceneSegueGroupAddUsers";
static NSString *const kQMSceneSegueGroupName               = @"SceneSegueGroupName";
static NSString *const kQMSceneSegueUpdateUser              = @"SceneSegueUpdateUser";
static NSString *const kQMSceneSegueFeedback                = @"SceneSegueFeedback";
static NSString *const kQMSceneSeguePassword                = @"SceneSeguePassword";

#endif /* QMConstants_h */
