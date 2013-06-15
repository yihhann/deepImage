//
//  YHMatchingViewController.h
//  deepImage
//
//  Created by Yihhann on 13/6/9.
//  Copyright (c) 2013年 Yihhann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHMatchingViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource> {
    NSMutableArray* m_matchingList;     // the index list of matching pictures
    NSMutableArray* m_cellStatusList;   // the status list of cells
    int m_clickedCell1, m_clickedCell2; // priviuse cliked cell
    // count down while the new game start
    int m_countDown;                    
    NSTimer* m_timerCountDown;
}
@property (retain, nonatomic) IBOutlet UICollectionView *m_collectionMatching;
@property (retain, nonatomic) IBOutlet UILabel *m_labelStatus;

// pass from maim page
@property (retain, nonatomic) NSMutableArray* m_pictureNameList;  // the list of picture names
// dimation of matching matrix
@property int m_matchingRows;
@property int m_matchingColumns;  

- (IBAction)BackButtonClicked:(id)sender;
- (IBAction)RenewButtonClicked:(id)sender;
// count down while the new game start
- (void) doCountDown:(NSTimer*)timer;
@end
