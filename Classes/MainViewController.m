//
//  MainViewController.m
//  Wizard Blood
//
//  Created by Scott Daniel on 9/7/10.
//  Copyright Scott Daniel 2010. All rights reserved.
//

#import "MainViewController.h"
#import "Wizard_BloodAppDelegate.h"

@implementation MainViewController

@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark -
#pragma mark General Methods

- (NSString *) dataFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	lifeCounterArray = [[NSMutableArray alloc] init];
	
	for ( int i = 200; i >= -200; i-- )
	{
		NSString *myString = [NSString stringWithFormat:@"%i", i];
		[lifeCounterArray addObject:myString];
	}
	
	// Sets the life totals to the saved data if it they have been changed since the last loadView
	
	for (int i=0; i<6; i++) {
		[LifeCounter selectRow:180 inComponent:i animated:NO];
	}
	
	NSString *filePath = [self dataFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
		for (int i=0; i<6; i++) {
			if ([[array objectAtIndex:i] integerValue] != 180)
			{
				[LifeCounter selectRow:[[array objectAtIndex:i] integerValue] inComponent:i animated:NO];
			}
		}
		[array release];
	}
	
	UIApplication *app = [UIApplication sharedApplication];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:app];
	
	[super viewDidLoad];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[LifeCounter reloadAllComponents];
}

// Implement viewWillAppear: to do additional setup before the view is presented. You might, for example, fetch objects from the managed object context if necessary.
- (void)viewWillAppear:(BOOL)animated {
	// The pickerView reloads all the components in case anything was changed on the flipside settings
	[LifeCounter reloadAllComponents];
	
	for (int i=0; i<6; i++) {
		[LifeCounter selectRow:180 inComponent:i animated:NO];
	}
	
	NSString *filePath = [self dataFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
		for (int i=0; i<6; i++) {
			if ([[array objectAtIndex:i] integerValue] != 180)
			{
				[LifeCounter selectRow:[[array objectAtIndex:i] integerValue] inComponent:i animated:NO];
			}
		}
		
		[array release];
	}
	
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return ((interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) && (interfaceOrientation != UIInterfaceOrientationPortrait));
}


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark PickerView Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 6;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [lifeCounterArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [lifeCounterArray objectAtIndex:row];
}

// Saving info to Core Data every time user selects a new row

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSManagedObjectContext *context =
	[self.fetchedResultsController managedObjectContext];
	NSEntityDescription *entity =
	[[self.fetchedResultsController fetchRequest] entity];
	NSManagedObject *newManagedObject = 
	[NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
	
	[newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
	
	//Iterates through each component and sets the value to the appropriate key
	for (int j=0; j < [LifeCounter numberOfComponents]; j++) {
		NSString *keyName = [NSString stringWithFormat:@"lifeTotal%i",j];
		[newManagedObject setValue:[NSNumber numberWithInteger:[LifeCounter selectedRowInComponent:j]] forKey:keyName];
	}
	
	NSError *error;
	if (![context save:&error]) {
		NSLog(@"Error saving entity: %@", [error localizedDescription]);
	}	
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSMutableArray *array = [[NSMutableArray alloc] init];
	
	for (int i=0; i<6; i++) {
		[array addObject:[NSNumber numberWithInteger:[LifeCounter selectedRowInComponent:i]]];
	}

	[array writeToFile:[self dataFilePath] atomically:YES];
	[array release];	
}

- (void) applicationWillTerminate:(NSNotification *)notification {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	for (int i=0; i<6; i++) {
		[array addObject:[NSNumber numberWithInteger:[LifeCounter selectedRowInComponent:i]]];
	}
	
	[array writeToFile:[self dataFilePath] atomically:YES];
	[array release];
}

#pragma mark -
#pragma mark Button Methods

- (IBAction) resetButtonPressed: (id) sender
{
	
	for (int i=0; i<6; i++) {
		[LifeCounter selectRow:180 inComponent:i animated:NO];
	}
}

- (IBAction)showInfo:(id)sender {    
    NSMutableArray *array = [[NSMutableArray alloc] init];
	
	for (int i=0; i<6; i++) {
		[array addObject:[NSNumber numberWithInteger:[LifeCounter selectedRowInComponent:i]]];
	}
	
	[array writeToFile:[self dataFilePath] atomically:YES];
	[array release];
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}

#pragma mark -
#pragma mark fetchedResultsController

-(NSFetchedResultsController *)fetchedResultsController {
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	Wizard_BloodAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LifeCounts" inManagedObjectContext:managedObjectContext];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
			[fetchRequest setSortDescriptors:sortDescriptors];
			[sortDescriptor release];
			[sortDescriptors release];
	
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchBatchSize:20];
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"LifeCounts"];
	frc.delegate = self;
	_fetchedResultsController = frc;
	[fetchRequest release];
	
	return _fetchedResultsController;
}

	
#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[LifeCounter release];
	[lifeCounterArray release];
	[_fetchedResultsController release];
    [super dealloc];
}


@end
