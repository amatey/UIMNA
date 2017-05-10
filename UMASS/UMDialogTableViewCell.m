//
//  UMDialogTableViewCell.m
//  UMASS
//
//  Created by Mithun Reddy on 11/12/16.
//  Copyright © 2016 Mithun Reddy. All rights reserved.
//

#import "UMDialogTableViewCell.h"

@implementation UMDialogTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.dialogNameLbl.layer.cornerRadius = 25.0;
    self.dialogCountLbl.layer.cornerRadius = 10.0;

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
