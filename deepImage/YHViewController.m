//
//  YHViewController.m
//  deepImage
//
//  Created by Yihhann on 13/5/19.
//  Copyright (c) 2013年 Yihhann. All rights reserved.
//

#import "YHViewController.h"
#import "YHMatchingViewController.h"

@interface YHViewController ()

@end

@implementation YHViewController

@synthesize m_ColumnStepper;
@synthesize m_RowStepper;
@synthesize m_MatrixColumn;
@synthesize m_MatrixRow;
@synthesize m_AlbumPicker;
@synthesize m_PlayButton;

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
    m_albumNameList = [[NSMutableArray alloc] initWithObjects:
        @"Fruits", @"Animals", @"Famous People", @"Japanese Fifty Sounds", @"English Alphabet", nil];
    m_AlbumPicker.dataSource = self;
    [m_AlbumPicker selectRow:2 inComponent:0 animated:YES];
    m_AlbumPicker.delegate = self;
    
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
    [super dealloc];
}

// Changing the columns of photo matrix
- (IBAction)ColumnStep:(id)sender {
    UIStepper *stepper=(UIStepper *)sender;
    m_MatrixColumn.text =[NSString stringWithFormat:@"%d", (int)stepper.value];
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

// Changing the rows of photo matrix
- (IBAction)RowStep:(id)sender {
    UIStepper *stepper=(UIStepper *)sender;
    m_MatrixRow.text =[NSString stringWithFormat:@"%d", (int)stepper.value];
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

// Play Button Clicked
- (IBAction)PlayButtonClicked:(id)sender {
    YHMatchingViewController* matchingViewController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"Matching"];
    
    // Pass the picture list in the selected album
    int total_picture = 18;
    NSString *album_prefix = @"FamousPeople";
    int i;
    matchingViewController.m_pictureNameList = [[NSMutableArray alloc] init];
    for ( i = 0; i < total_picture; i++ )
        [matchingViewController.m_pictureNameList addObject:
            [NSString stringWithFormat:@"%@.%03d.jpg", album_prefix, i + 1] ];
    matchingViewController.m_matchingColumns = [m_MatrixColumn.text integerValue];
    matchingViewController.m_matchingRows = [m_MatrixRow.text integerValue];
 
    matchingViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:matchingViewController animated:YES completion:nil];
}


// Build in function to return the number of components
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// Build in function
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

// Build in function
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

//選擇UIPickView中的項目時會出發的內建函式
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //plurkLabel.text = [NSString stringWithFormat:@"%@ :", [plurk objectAtIndex:row]];
}

@end
