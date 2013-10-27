//
//  YHViewController.h
//  deepImage
//
//  Created by Yihhann on 13/5/19.
//  Copyright (c) 2013 Yihhann. All rights reserved.
//  Remark:
//    This is the main view controller.

#import <UIKit/UIKit.h>
@class AVAudioPlayer;

@interface YHViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    NSMutableArray* m_albumNameList;    // for the list of album names
    SystemSoundID sidThemeMusic;        // the theme music
}
@property (retain, nonatomic) IBOutlet UIStepper *m_ColumnStepper;
@property (retain, nonatomic) IBOutlet UIStepper *m_RowStepper;
@property (retain, nonatomic) IBOutlet UILabel *m_MatrixColumn;
@property (retain, nonatomic) IBOutlet UILabel *m_MatrixRow;
@property (retain, nonatomic) IBOutlet UIPickerView *m_AlbumPicker;
@property (retain, nonatomic) IBOutlet UIButton *m_SetupButton;
@property (retain, nonatomic) IBOutlet UIButton *m_PlayButton;
@property (retain, nonatomic) IBOutlet UIImageView *m_ImageAlbum;

- (IBAction)ColumnStep:(id)sender;
- (IBAction)RowStep:(id)sender;
- (IBAction)AlbumButtomClicked:(id)sender;
- (IBAction)PlayButtonClicked:(id)sender;
- (IBAction)SetupButtonClicked:(id)sender;



@end
