//
//  MainViewController.h
//  Wizard Blood
//
//  Created by Scott Daniel on 9/7/10.
//  Copyright Scott Daniel 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import <CoreData/CoreData.h>
#define kFilename @"data.plist"

@interface MainViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, FlipsideViewControllerDelegate, NSFetchedResultsControllerDelegate> 
{
	IBOutlet UIPickerView *LifeCounter;
	NSMutableArray *lifeCounterArray;
	
	@private
	NSFetchedResultsController *_fetchedResultsController;
}

@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

- (IBAction)showInfo:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;
- (NSString *) dataFilePath;

@end
