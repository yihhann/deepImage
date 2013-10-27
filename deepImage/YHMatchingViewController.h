//
//  YHMatchingViewController.h
//  deepImage
//
//  Created by Yihhann on 13/6/9.
        //  Remark:
//    This is the gaming view controller.

#import <UIKit/UIKit.h>
@class AVAudioPlayer;

#define YH_TT_PLAYERS 8

@interface YHMatchingViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource> {
    NSMutableArray* m_cellPictureList;  // the index list of matching pictures
    NSMutableArray* m_cellStatusList;   // the status list of cells
    int m_clickedCell1, m_clickedCell2; // privious cliked cell
    int m_clickCount;                   // total clicks in a game
    // count down while the new game start
    int m_countDown;                    
    NSTimer* m_timerCountDown;
    SystemSoundID sidGoBackMusic;        // the going back music
}
@property (retain, nonatomic) IBOutlet UILabel *m_labelClickCount;
@property (retain, nonatomic) IBOutlet UICollectionView *m_collectionMatching;
@property (retain, nonatomic) IBOutlet UILabel *m_labelStatus;

//   the list of picture names
@property (retain, nonatomic) NSMutableArray* m_pictureNameList;
//   the list of picture titles to display
@property (retain, nonatomic) NSMutableArray* m_pictureTitleList;
//   the list of picture titles to display
@property (retain, nonatomic) NSMutableArray* m_pictureAudioList;
//   dimation of matching matrix
@property int m_matchingRows;
@property int m_matchingColumns;


- (IBAction)BackButtonClicked:(id)sender;
- (IBAction)RenewButtonClicked:(id)sender;
// count down while the new game start
- (void) doCountDown:(NSTimer*)timer;
@end
