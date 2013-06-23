//
//  YHMatchingViewController.m
//  deepImage
//
//  Created by Yihhann on 13/6/9.
//  Copyright (c) 2013 Yihhann. All rights reserved.
//  Remark:
//    This is the gaming view controller.

#import <AVFoundation/AVFoundation.h>
#import "YHMatchingViewController.h"
#import "YHMatchingCell.h"


// status of a cell
#define YH_CELL_CLOSED_TO_MATCHED -2
#define YH_CELL_CLOSED_TO_OPEN -1
#define YH_CELL_CLOSED 0
#define YH_CELL_OPEN 1
#define YH_CELL_MATCHED 2

@interface YHMatchingViewController ()

@end

@implementation YHMatchingViewController

@synthesize m_labelClickCount;
@synthesize m_collectionMatching;
@synthesize m_labelStatus;

@synthesize m_pictureNameList;
@synthesize m_pictureTitleList;
@synthesize m_matchingRows;
@synthesize m_matchingColumns;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Set full size the background image
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Default@2x.png"] drawInRect:self.view.bounds];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    if( m_labelStatus.frame.origin.y <= m_collectionMatching.frame.origin.y + m_collectionMatching.frame.size.height )
    {
        m_labelStatus.hidden = YES;
    }

    
    // Init the matching list from the list of pictures
    m_matchingList = [[NSMutableArray alloc] init];
    m_cellStatusList = [[NSMutableArray alloc] init];
    srandom(time(NULL));
    [self renewMatchingList];
       
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Back to main view
- (IBAction)BackButtonClicked:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:Nil];
    [m_musicPlayer play];
}

// Renew the game
- (IBAction)RenewButtonClicked:(id)sender {
    [self renewMatchingList];
    [m_collectionMatching reloadData];
}

// implement function for Collection View
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

// implement function for Collection View to return the number of cells
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return m_matchingList.count;
}

// implement function for Collection View to set the size of cells
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int w = ( collectionView.frame.size.width - 4 ) / m_matchingColumns - 4;
    int h = ( collectionView.frame.size.height - 4 ) / m_matchingRows - 4;
    return CGSizeMake( w, h );
}

// implement function for Collection View to return a cell object
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YHMatchingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ACell" forIndexPath:indexPath];
    
    // Get the picture
    int idx = [m_matchingList[indexPath.row] integerValue];
    NSString *imageToLoad;
    if( idx >= 0 )
    {
        if( [m_cellStatusList[indexPath.row] integerValue] == YH_CELL_CLOSED ||
            [m_cellStatusList[indexPath.row] integerValue] == YH_CELL_CLOSED_TO_OPEN ||
            [m_cellStatusList[indexPath.row] integerValue] == YH_CELL_CLOSED_TO_MATCHED )
            imageToLoad = @"pictureQuestion.png";
        else
            imageToLoad = m_pictureNameList[idx];
    }
    else
        imageToLoad = Nil;  // odd mesh
    // Draw the frame
    UIGraphicsBeginImageContext(cell.frame.size);
    [[UIImage imageNamed:@"pictureFrame.png"] drawInRect:cell.bounds];
    float dframe = cell.bounds.size.width / 15;
    CGRect inRect = CGRectMake(cell.bounds.origin.x + dframe, cell.bounds.origin.y + dframe, cell.bounds.size.width - dframe * 2, cell.bounds.size.height - dframe * 2 );
    // Draw the picture
    if( imageToLoad )
        [[UIImage imageNamed:imageToLoad] drawInRect:inRect];
    cell.imageInside.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

// implement to get the event before a cell is selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // click on the odd mesh
    if( [m_matchingList[indexPath.row] integerValue] < 0 )
        return NO;     // do nothing
    
    // click on a closed picture
    if( [m_cellStatusList[indexPath.row] integerValue] == YH_CELL_CLOSED )
    {
        // count the clicks
        m_clickCount++;
        m_labelClickCount.text = [NSString stringWithFormat:@"%d", m_clickCount];

        m_cellStatusList[indexPath.row] = @(YH_CELL_CLOSED_TO_OPEN);
        //[m_collectionMatching reloadItemsAtIndexPaths:@[indexPath]];
        if( m_clickedCell2 >=0 )
            if( [m_cellStatusList[m_clickedCell2] integerValue] == YH_CELL_OPEN )
            {
                m_cellStatusList[m_clickedCell2] = @(YH_CELL_CLOSED);
                [m_collectionMatching reloadItemsAtIndexPaths:@[
                 [NSIndexPath indexPathForRow:m_clickedCell2 inSection:0]
                 ]];
            }
        if( m_clickedCell1 >= 0 )
            if( [m_matchingList[indexPath.row] integerValue] == [m_matchingList[m_clickedCell1] integerValue])
            {
                m_cellStatusList[indexPath.row] = @(YH_CELL_CLOSED_TO_MATCHED);
                m_cellStatusList[m_clickedCell1] = @(YH_CELL_MATCHED);
                //[m_collectionMatching reloadItemsAtIndexPaths:@[
                // [NSIndexPath indexPathForRow:m_clickedCell1 inSection:0]
                // ]];
            }
        m_clickedCell2 = m_clickedCell1;
        m_clickedCell1 = indexPath.row;
        //[m_collectionMatching reloadData];
    }

    return YES;
}

// implement to get the event after a cell is selected
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Animate cell from close to open status
    if( [m_cellStatusList[indexPath.row] integerValue] == YH_CELL_CLOSED_TO_OPEN ||
        [m_cellStatusList[indexPath.row] integerValue] == YH_CELL_CLOSED_TO_MATCHED )
    {
        __block YHMatchingCell *cell = (YHMatchingCell *)[m_collectionMatching cellForItemAtIndexPath:indexPath];
        
        // Draw the frame
        UIGraphicsBeginImageContext(cell.frame.size);
        [[UIImage imageNamed:@"pictureFrame.png"] drawInRect:cell.imageInside.bounds];
        float dframe = cell.bounds.size.width / 15;
        CGRect inRect = CGRectMake(cell.imageInside.bounds.origin.x + dframe, cell.imageInside.bounds.origin.y + dframe, cell.imageInside.bounds.size.width - dframe * 2, cell.imageInside.bounds.size.height - dframe * 2 );
        // Draw the picture
        int idx = [m_matchingList[indexPath.row] integerValue];
        NSString *imageToLoad = m_pictureNameList[idx];
        [[UIImage imageNamed:imageToLoad] drawInRect:inRect];
        UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // animate
        [UIView animateWithDuration:0.5
            animations:^{
                cell.imageInside.frame = CGRectMake(0, cell.frame.size.height / 2, cell.frame.size.width, 0);
            } completion:^(BOOL finished) {
                cell.imageInside.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height );
                cell.imageInside.image = cellImage;
                [self checkGameCompletion];
            }];
        
        // Display image title
        m_labelStatus.text = m_pictureTitleList[idx];
        
        // set the status to open / matched
        if( [m_cellStatusList[indexPath.row] integerValue] == YH_CELL_CLOSED_TO_OPEN )
            m_cellStatusList[indexPath.row] = @(YH_CELL_OPEN);
        else if ( [m_cellStatusList[indexPath.row] integerValue] == YH_CELL_CLOSED_TO_MATCHED )
            m_cellStatusList[indexPath.row] = @(YH_CELL_MATCHED);
        //[m_collectionMatching reloadItemsAtIndexPaths:@[indexPath]];
    }

} // end of - (void)collectionView: didSelectItemAtIndexPath:

// Pick pictures randomly
-(void) renewMatchingList
{
    int i;
    int totMatch = m_matchingColumns * m_matchingRows;
    int randList[1000];

    // make a random list
    for( i = 0; i < m_pictureNameList.count; i++ )
    {
        if( i >= 1000 )
            break;
        randList[i] = i;
    }
    for( i = 0; i < 10000; i++ )
    {
        int r, s, t;
        r = ( random() % m_pictureNameList.count ) % 1000;
        s = ( random() % m_pictureNameList.count ) % 1000;
        t = randList[r];
        randList[r] = randList[s];
        randList[s] = t;
    }
    
    // pick pictures by the front of random list
    [m_matchingList removeAllObjects];
    for( i = 0; i < totMatch / 2; i++ )
    {
        [m_matchingList addObject:[NSNumber numberWithInt:randList[i]]];
        [m_matchingList addObject:[NSNumber numberWithInt:randList[i]]];
    }
    // shuffle the cards
    for( i = 0; i < 1000; i++ )
    {
        int r, s;
        NSNumber *t;
        r = random() % m_matchingList.count;
        s = random() % m_matchingList.count;
        t = m_matchingList[r];
        m_matchingList[r] = m_matchingList[s];
        m_matchingList[s] = t;
    }
    
    // odd mesh
    if( ( totMatch % 2 ) == 1 )
    {
        for( i = totMatch - 1; i > totMatch / 2; i-- )
            m_matchingList[i] = m_matchingList[i - 1];
        m_matchingList[totMatch/2] = [NSNumber numberWithInt:-1];
    }

    // open all pictures
    [m_cellStatusList removeAllObjects];
    for( i = 0; i < totMatch; i++ )
        [m_cellStatusList addObject:@(YH_CELL_OPEN)];
    m_clickedCell1 = -1;
    m_clickedCell2 = -1;
    
    // init the counter of clicks
    m_clickCount = 0;
    m_labelClickCount.text = [NSString stringWithFormat:@"%d", m_clickCount];

    // Count down animation
    m_countDown = 5;
    if (m_timerCountDown)
        [m_timerCountDown invalidate];
    m_timerCountDown = [NSTimer
                        scheduledTimerWithTimeInterval:1
                        target:self
                        selector:@selector(doCountDown:)
                        userInfo:Nil
                        repeats:YES];

} // end of -(void) renewMatchingList

// count down while the new game start
- (void) doCountDown:(NSTimer *)timer
{
    // while the screen is high enough
    if( m_labelStatus.frame.origin.y > m_collectionMatching.frame.origin.y + m_collectionMatching.frame.size.height )
    {
        // Change the counting lable with animation
        UILabel * nextLabel = [[UILabel alloc] initWithFrame:
                               m_labelStatus.frame];
        nextLabel.text = [NSString stringWithFormat:@"%d", m_countDown];
        nextLabel.font = [UIFont systemFontOfSize:72];
        nextLabel.textAlignment = m_labelStatus.textAlignment;
        nextLabel.textColor = m_labelStatus.textColor;
        nextLabel.backgroundColor = m_labelStatus.backgroundColor;
        nextLabel.opaque = m_labelStatus.opaque;
        nextLabel.shadowColor = m_labelStatus.shadowColor;
        nextLabel.shadowOffset = m_labelStatus.shadowOffset;
        
        [UIView
         transitionFromView:m_labelStatus
         toView:nextLabel
         duration:0.7
         options:UIViewAnimationOptionTransitionCrossDissolve
         completion:^(BOOL finished) {
             if( nextLabel.text.integerValue > 0 )
                 nextLabel.text = @" ";
             else
             {
                 // Localize
                 nextLabel.text = NSLocalizedStringFromTable(@"Pick the matched pictures...", @"common", nil);
                 nextLabel.font = [UIFont systemFontOfSize:42];
                 nextLabel.adjustsFontSizeToFitWidth = YES;
             }
             m_labelStatus = nextLabel;
         }
         ];
    }
    
    // Play countdown voice
    if( m_voicePlayer != Nil )
    {
        if( m_voicePlayer.playing )
            [m_voicePlayer stop];
        [m_voicePlayer release];
    }
    NSString* key = [NSString stringWithFormat:@"count%d", m_countDown];
    NSString* filename = NSLocalizedStringFromTable(key, @"common", @"voice file name" );
    NSURL* fileURL = [[ NSBundle mainBundle] URLForResource:filename withExtension:@"mp3"];
    m_voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:Nil];
    [m_voicePlayer prepareToPlay];
    [m_voicePlayer play];

    // next countdown
    if( m_countDown > 0 )
    {
        m_countDown--;
    }
    else
    {
        // close all pictures
        int i;
        for( i = 0; i < m_cellStatusList.count; i++ )
            m_cellStatusList[i] = @(YH_CELL_CLOSED);
        [m_collectionMatching reloadData];
        // stop timer
        [timer invalidate];
        m_timerCountDown = Nil;
    }
} // end of (void) doCountDown:(NSTimer *)timer

// check if the game is completed
- (void) checkGameCompletion
{
    int i;

    // check
    for( i = 0; i < m_cellStatusList.count; i++ )
        if( [m_cellStatusList[i] integerValue] != YH_CELL_MATCHED )
            if ([m_matchingList[i] integerValue] >= 0 )
                return;
    
    // Completed
    int leastClick = (m_matchingRows * m_matchingColumns) / 2 * 2;
    if( m_clickCount > leastClick )
        m_labelStatus.text = NSLocalizedStringFromTable(@"Well Done!", @"common", @"Game is completed" );
    else
        m_labelStatus.text = NSLocalizedStringFromTable(@"You are so amazing!", @"common", @"Game is completed in the least clicks" );
    
    // Play well done voice
    if( m_clickCount > leastClick )
    {
        if( m_voicePlayer != Nil )
        {
            if( m_voicePlayer.playing )
                [m_voicePlayer stop];
            [m_voicePlayer release];
        }
        NSURL* fileURL = [[ NSBundle mainBundle] URLForResource:@"applause" withExtension:@"mp3"];
        m_voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:Nil];
        [m_voicePlayer prepareToPlay];
        [m_voicePlayer play];
    }
    else
        [m_amazingPlayer play];
    
}

// implement to play music further
-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        if( m_musicPlayer != Nil )
        {
            if( m_musicPlayer.playing )
                [m_musicPlayer stop];
            [m_musicPlayer release];
        }
        NSURL* fileURL = [[ NSBundle mainBundle] URLForResource:@"back_piano" withExtension:@"mp3"];
        m_musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:Nil];
        [m_musicPlayer prepareToPlay];
        
        if( m_amazingPlayer != Nil )
        {
            if( m_amazingPlayer.playing )
                [m_amazingPlayer stop];
            [m_amazingPlayer release];
        }
        fileURL = [[ NSBundle mainBundle] URLForResource:@"amazing" withExtension:@"mp3"];
        m_amazingPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:Nil];
        [m_amazingPlayer prepareToPlay];

        m_voicePlayer = Nil;
    }
    return self;
}

- (void)dealloc {
    [m_collectionMatching release];
    [m_matchingList release];
    [m_labelStatus release];
    [m_labelClickCount release];
    [super dealloc];
}
@end
