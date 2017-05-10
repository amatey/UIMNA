//
//  UMDialogTableViewCell.h
//  UMASS
//
//  Created by Mithun Reddy on 11/12/16.
//  Copyright © 2016 Mithun Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UMDialogTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *previousChatLbl;
@property (weak, nonatomic) IBOutlet UILabel *dialogNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *dialogCountLbl;

@end
