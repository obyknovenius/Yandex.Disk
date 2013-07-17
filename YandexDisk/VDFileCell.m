//
//  VDFileCell.m
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/14/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import "VDFileCell.h"

@implementation VDFileCell

- (void)prepareForReuse
{
    self.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    self.creationDateLabel.hidden = self.creationDateCaptionLabel.hidden = YES;
    self.modificationDateLabel.hidden = self.modificationDateCaptionLabel.hidden = YES;
    self.sizeLabel.hidden = self.sizeCaptionLabel.hidden = YES;
}

@end
