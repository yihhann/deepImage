//
//  YHViewController.m
//  deepImage
//
//  Created by Yihhann on 13/5/19.
//  Copyright (c) 2013 Yihhann. All rights reserved.
//  Remark:
//    This is the main view controller.

#import <AVFoundation/AVFoundation.h>
#import "YHViewController.h"
#import "YHMatchingViewController.h"

// tag of labels to handle touch events
#define YH_LABEL_COLUMN 101
#define YH_LABEL_ROW    102

// Album data structures
typedef struct {
    NSString *prefix;
    NSString *titleName;
    int totalImage;
    NSMutableArray *imageTitleList;
} YHAlbum;
int TotalAlbums;
YHAlbum AlbumList[1000];


@interface YHViewController ()

@end

@implementation YHViewController

@synthesize m_ColumnStepper;
@synthesize m_RowStepper;
@synthesize m_MatrixColumn;
@synthesize m_MatrixRow;
@synthesize m_AlbumPicker;
@synthesize m_SetupButton;
@synthesize m_PlayButton;
@synthesize m_ImageAlbum;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // Set full size the background image
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Default@2x.png"] drawInRect:self.view.bounds];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
       
    // Init Album Picker
    [self initAlbumList];
    [m_AlbumPicker selectRow:2 inComponent:0 animated:YES];
    // preview the default album
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doPreviewDefaultAlbum:) userInfo:nil repeats:NO];
    
    // play the theme music
    [m_audioPlayer play];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [m_MatrixColumn release];
    [m_MatrixRow release];
    [m_ColumnStepper release];
    [m_RowStepper release];
    [m_AlbumPicker release];
    [m_PlayButton release];
    [m_ImageAlbum release];
    [m_SetupButton release];
    [super dealloc];
}

// Changing the columns of photo matrix
- (IBAction)ColumnStep:(id)sender {
    UIStepper *stepper=(UIStepper *)sender;
    m_MatrixColumn.text =[NSString stringWithFormat:@"%d", (int)stepper.value];
  
    if (m_ColumnStepper.maximumValue < m_RowStepper.maximumValue )
    {
        if( stepper.value > m_RowStepper.value )
        {
            m_RowStepper.value = stepper.value;
            m_MatrixRow.text = m_MatrixColumn.text;
        }
        else if( stepper.value < m_RowStepper.value - 1 )
        {
            m_RowStepper.value = stepper.value + 1;
            m_MatrixRow.text = [NSString stringWithFormat:@"%d", (int)stepper.value + 1];
        }
    }
    else
    {
        if( stepper.value > m_RowStepper.value + 1 )
        {
            m_RowStepper.value = stepper.value - 1;
            m_MatrixRow.text = [NSString stringWithFormat:@"%d", (int)stepper.value - 1];
        }
        else if( stepper.value < m_RowStepper.value )
        {
            m_RowStepper.value = stepper.value;
            m_MatrixRow.text = m_MatrixColumn.text;;
        }
    }
}

// Changing the rows of photo matrix
- (IBAction)RowStep:(id)sender {
    UIStepper *stepper=(UIStepper *)sender;
    m_MatrixRow.text =[NSString stringWithFormat:@"%d", (int)stepper.value];

    if (m_ColumnStepper.maximumValue < m_RowStepper.maximumValue )
    {
        if( stepper.value < m_ColumnStepper.value )
        {
            m_ColumnStepper.value = stepper.value;
            m_MatrixColumn.text = m_MatrixRow.text;
        }
        else if( stepper.value > m_ColumnStepper.value + 1 )
        {
            m_ColumnStepper.value = stepper.value - 1;
            m_MatrixColumn.text = [NSString stringWithFormat:@"%d", (int)stepper.value - 1];
        }
    }
    else
    {
        if( stepper.value < m_ColumnStepper.value - 1 )
        {
            m_ColumnStepper.value = stepper.value + 1;
            m_MatrixColumn.text = [NSString stringWithFormat:@"%d", (int)stepper.value + 1];
        }
        else if( stepper.value > m_ColumnStepper.value )
        {
            m_ColumnStepper.value = stepper.value;
            m_MatrixColumn.text = m_MatrixRow.text;
        }
    }
}

// implement touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    
    // simulate touch on lables as on steppers
    if (touch.view.tag == YH_LABEL_COLUMN) {
        if( m_ColumnStepper.value < m_ColumnStepper.maximumValue )
            m_ColumnStepper.value = m_ColumnStepper.value + 1;
        else
            m_ColumnStepper.value = m_ColumnStepper.minimumValue;
        [self ColumnStep:m_ColumnStepper];
    }
    else if (touch.view.tag == YH_LABEL_ROW) {
        if( m_RowStepper.value < m_RowStepper.maximumValue )
            m_RowStepper.value = m_RowStepper.value + 1;
        else
            m_RowStepper.value = m_RowStepper.minimumValue;
        [self RowStep:m_RowStepper];
    }
}


// Click on album images to play
- (IBAction)AlbumButtomClicked:(id)sender {
    [self PlayButtonClicked:sender];
}


// Play Button Clicked
- (IBAction)PlayButtonClicked:(id)sender {
    YHMatchingViewController* matchingViewController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"Matching"];
    int iAlbum = [m_AlbumPicker selectedRowInComponent:0];
    
    // Pass the picture list in the selected album
    int total_picture = AlbumList[iAlbum].totalImage;
    NSString *album_prefix = AlbumList[iAlbum].prefix;
    int i;
    matchingViewController.m_pictureNameList = [[[NSMutableArray alloc] init] autorelease];
    matchingViewController.m_pictureTitleList = [[[NSMutableArray alloc] init] autorelease];
    matchingViewController.m_pictureAudioList = [[[NSMutableArray alloc] init] autorelease];
    for ( i = 0; i < total_picture; i++ )
    {
        [matchingViewController.m_pictureNameList addObject:
            [NSString stringWithFormat:@"%@.%03d.jpg", album_prefix, i + 1] ];
        [matchingViewController.m_pictureTitleList addObject:
            AlbumList[iAlbum].imageTitleList[i]];
        [matchingViewController.m_pictureAudioList addObject:
            [NSString stringWithFormat:@"%@.%03d", album_prefix, i + 1] ];
    }
    matchingViewController.m_matchingColumns = [m_MatrixColumn.text integerValue];
    matchingViewController.m_matchingRows = [m_MatrixRow.text integerValue];
 
    matchingViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:matchingViewController animated:YES completion:nil];
    
    // stop the theme music
    [m_audioPlayer stop];
}

// Setup Button clicked
- (IBAction)SetupButtonClicked:(id)sender {
    UINavigationController* navigationSetup =
        [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationSetup"];
    [self presentViewController:navigationSetup animated:YES completion:nil];
    
}


// implement function to return the number of components
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// implement function to return the number of row
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [m_albumNameList count];
            break;
            
        // Never
        default:
            return 0;
            break;
    }
}

// implement function the return the title for row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [m_albumNameList objectAtIndex:row];
            break;
            
        // Never
        default:
            return @"Error";
            break;
    }
}

// implement function to catch the event of selecting a row
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    int iAlbum = row;
    int total_picture = AlbumList[iAlbum].totalImage;
    NSString *album_prefix = AlbumList[iAlbum].prefix;
    [self previewAlbum:album_prefix withNumberOf:total_picture];
}

// show preview after a monent (can not show on "viewDidLoad" event)
-(void)doPreviewDefaultAlbum:(NSTimer *)timer {
    int iAlbum = [m_AlbumPicker selectedRowInComponent:0];
    int total_picture = AlbumList[iAlbum].totalImage;
    NSString *album_prefix = AlbumList[iAlbum].prefix;
    [self previewAlbum:album_prefix withNumberOf:total_picture];
}

// Draw a preview of selected album
- (void) previewAlbum:(NSString *)prefix withNumberOf:(int)total_picture {
    int i;
    
    UIGraphicsBeginImageContext( m_ImageAlbum.frame.size);
    for ( i = total_picture; i >= 0 ; i-- )
    {
        NSString *imageToLoad;
        CGRect rect;
        int startX;
        
        if( i >= 4 )
            startX = ( m_ImageAlbum.bounds.size.width - m_ImageAlbum.bounds.size.height * 2 ) / total_picture * (total_picture - i);
        else
            startX = ( m_ImageAlbum.bounds.size.width - m_ImageAlbum.bounds.size.height * 2 ) / total_picture * (total_picture - i) + m_ImageAlbum.bounds.size.height * (4 - i ) / 4 - i * i;
        rect = CGRectMake(
                          startX,
                          m_ImageAlbum.bounds.size.height / total_picture * i,
                          m_ImageAlbum.bounds.size.height / total_picture * ( total_picture - i ),
                          m_ImageAlbum.bounds.size.height / total_picture * ( total_picture - i )
                          );
        
        // Draw the frame
        [[UIImage imageNamed:@"pictureFrame.png"] drawInRect:rect];
        float dframe = rect.size.width / 15;
        CGRect inRect = CGRectMake(rect.origin.x + dframe, rect.origin.y + dframe, rect.size.width - dframe * 2, rect.size.height - dframe * 2 );
        // Draw the picture
        imageToLoad = [NSString stringWithFormat:@"%@.%03d.jpg", prefix, i + 1];
        [[UIImage imageNamed:imageToLoad] drawInRect:inRect];
    }
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [m_ImageAlbum initWithImage:img];
    
}

// Init the list of album
- (void) initAlbumList
{
    int buildInAlbums = 5;
    int userAlbums = 0;
    int i;
    
    TotalAlbums = buildInAlbums + userAlbums;
    if( TotalAlbums > sizeof(AlbumList) / sizeof(AlbumList[0]) )
        TotalAlbums = sizeof(AlbumList) / sizeof(AlbumList[0]);
    m_albumNameList = [[NSMutableArray alloc] init];
    
    // set unique prefix strings 
    for( i = 0; i < TotalAlbums; i++ )
    {
        switch (i) {
            case 0:
                AlbumList[i].prefix = @"Fruits";
                break;
            case 1:
                AlbumList[i].prefix = @"Animals";
                break;
            case 2:
                AlbumList[i].prefix = @"FamousPeople";
                break;
            case 3:
                AlbumList[i].prefix = @"JapaneseFiftySounds";
                break;
            case 4:
                AlbumList[i].prefix = @"EnglishAlphabet";
                break;
                
            default:
                AlbumList[i].prefix = [NSString stringWithFormat:@"UserWork%03d", i - 4];
                break;
        }
        // get other information from string files
        NSString *stringFile = [NSString stringWithFormat:@"Album%@", AlbumList[i].prefix];
        AlbumList[i].titleName = NSLocalizedStringFromTable( @"AlbumTitle", stringFile, @"Album Title Name to display" );
        [m_albumNameList addObject:AlbumList[i].titleName];
        AlbumList[i].totalImage = [NSLocalizedStringFromTable( @"totalImage", stringFile, @"total images in this album" ) integerValue];
        // get image titles
        NSString *key, *value;
        AlbumList[i].imageTitleList = [[NSMutableArray alloc] init];
        int j;
        for( j = 0; j < AlbumList[i].totalImage; j++ )
        {
            key = [NSString stringWithFormat:@"ImageTitle%03d", j + 1];
            value = NSLocalizedStringFromTable( key, stringFile, @"Image Title Name to display" );
            [AlbumList[i].imageTitleList addObject:value];
        }
    }
    
} // end of (void) initAlbumList

// implement to play music further
-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        NSURL* fileURL = [[ NSBundle mainBundle] URLForResource:@"theme_piano" withExtension:@"mp3"];
        m_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:Nil];
        [m_audioPlayer prepareToPlay];
    }
    return self;
}

@end
