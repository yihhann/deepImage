//
//  YHMatchingViewController.m
//  deepImage
//
//  Created by Yihhann on 13/6/9.
//  Copyright (c) 2013年 Yihhann. All rights reserved.
//

#import "YHMatchingViewController.h"

@interface YHMatchingViewController ()

@end

@implementation YHMatchingViewController

@synthesize m_collectionMatching;
@synthesize m_labelStatus;

@synthesize m_pictureNameList;
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
}

// Renew the game
- (IBAction)RenewButtonClicked:(id)sender {
    [self renewMatchingList];
    [m_collectionMatching reloadData];
}

// Build in function for Collection View
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

// Build in function for Collection View
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return m_matchingColumns * m_matchingRows;
}

// Build in function for Collection View to set the size of cells
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int w = ( collectionView.frame.size.width - 4 ) / m_matchingColumns - 4;
    int h = ( collectionView.frame.size.height - 4 ) / m_matchingRows - 4;
    return CGSizeMake( w, h );
}

// Build in function for Collection View to return a cell object
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ACell" forIndexPath:indexPath];
    
    // Get the picture
    int idx = [m_matchingList[indexPath.row] integerValue];
    NSString *imageToLoad;
    if( idx >= 0 )
    {
        if( [m_cellStatusList[indexPath.row] integerValue] > 0 )
            imageToLoad = m_pictureNameList[idx];
        else
        {
            // ==== DEBUG ====
            // if not matched
            imageToLoad = @"pictureQuestion.png";
        }
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
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    // Catch click event
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    [cell addSubview:btn];
    [btn addTarget:self action:@selector(cellClicked:event:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

// catch the evnet of cell clicked
- (IBAction)cellClicked:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:m_collectionMatching];
    NSIndexPath *indexPath = [m_collectionMatching indexPathForItemAtPoint: currentTouchPosition];
    
    // click on the odd mesh
    if( [m_matchingList[indexPath.row] integerValue] < 0 )
        return;     // do nothing
    
    // click on a closed picture
    if( [m_cellStatusList[indexPath.row] integerValue] == 0 )
    {
        m_cellStatusList[indexPath.row] = @(1);
        if( m_clickedCell2 >=0 )
            if( [m_cellStatusList[m_clickedCell2] integerValue] == 1)
                m_cellStatusList[m_clickedCell2] = @(0);
        if( m_clickedCell1 >= 0 )
            if( [m_matchingList[indexPath.row] integerValue] == [m_matchingList[m_clickedCell1] integerValue])
            {
                m_cellStatusList[indexPath.row] = @(2);
                m_cellStatusList[m_clickedCell1] = @(2);
            }
        m_clickedCell2 = m_clickedCell1;
        m_clickedCell1 = indexPath.row;
        [m_collectionMatching reloadData];
    }
    //[m_collectionMatching reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];

    NSLog(@"indexPath.row = %d,  [m_matchingList[indexPath.row] integerValue]=%d", indexPath.row,  [m_matchingList[indexPath.row] integerValue] );
    
}


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
        [m_cellStatusList addObject:@(1)];
    m_clickedCell1 = -1;
    m_clickedCell2 = -1;

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
         duration:0.8
         options:UIViewAnimationOptionTransitionCrossDissolve
         completion:^(BOOL finished) {
             if( nextLabel.text.integerValue > 0 )
                 nextLabel.text = @" ";
             else
             {
                 // end of count down
                 nextLabel.text = @"Pick the matched pictures...";
                 nextLabel.font = [UIFont systemFontOfSize:22];
             }
             m_labelStatus = nextLabel;
         }
         ];
    }
    
    if( m_countDown > 0 )
    {
        m_countDown--;
    }
    else
    {
        // close all pictures
        int i;
        for( i = 0; i < m_cellStatusList.count; i++ )
            m_cellStatusList[i] = @(0);
        [m_collectionMatching reloadData];
        // stop timer
        [timer invalidate];
        m_timerCountDown = Nil;
    }
}

- (void)dealloc {
    [m_collectionMatching release];
    [m_matchingList release];
    [m_labelStatus release];
    [super dealloc];
}
@end
