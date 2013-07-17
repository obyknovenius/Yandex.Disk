//
//  VDFileCell.h
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/14/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDFileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *creationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *modificationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@property (weak, nonatomic) IBOutlet UILabel *creationDateCaptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *modificationDateCaptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeCaptionLabel;

@end
