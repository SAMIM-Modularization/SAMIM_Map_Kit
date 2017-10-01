//
//  SAMIMMapTextTableViewCell.m
//  SAMIMMapModule
//
//  Created by ZIKong on 2017/9/29.
//  Copyright © 2017年 youhuikeji. All rights reserved.
//

#import "SAMIMMapTextTableViewCell.h"

@implementation SAMIMMapTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.selectionStyle                = UITableViewCellSelectionStyleNone;
        self.textLabel.font                = [UIFont systemFontOfSize:16];
        self.detailTextLabel.font          = [UIFont systemFontOfSize:12];
        self.detailTextLabel.textColor     = [UIColor grayColor];
    }
    return self;
}

@end
