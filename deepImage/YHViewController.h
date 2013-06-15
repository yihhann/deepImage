//
//  YHViewController.h
//  deepImage
//
//  Created by Yihhann on 13/5/19.
//  Copyright (c) 2013年 Yihhann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    NSMutableArray* m_albumNameList;    // for the list of album names
}
@property (retain, nonatomic) IBOutlet UIStepper *m_ColumnStepper;
@property (retain, nonatomic) IBOutlet UIStepper *m_RowStepper;
@property (retain, nonatomic) IBOutlet UILabel *m_MatrixColumn;
@property (retain, nonatomic) IBOutlet UILabel *m_MatrixRow;
@property (retain, nonatomic) IBOutlet UIPickerView *m_AlbumPicker;
@property (retain, nonatomic) IBOutlet UIButton *m_PlayButton;

- (IBAction)ColumnStep:(id)sender;
- (IBAction)RowStep:(id)sender;
- (IBAction)PlayButtonClicked:(id)sender;



@end
