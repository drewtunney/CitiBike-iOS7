//
//  LocationsViewController.m
//  CitiBike
//
//  Created by Dare Ryan on 5/9/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "LocationsViewController.h"
#import "Constants.h"
#import "GoogleMapsAPI.h"

@interface LocationsViewController ()
- (IBAction)textFieldEditingChanged:(id)sender;
- (IBAction)returnPressed:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *responseDictArray;
@property (strong, nonatomic) NSString *selectedLocation;

@end

@implementation LocationsViewController

@synthesize locationDelegate = _locationDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.textField.delegate = self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.responseDictArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.responseDictArray[indexPath.row][@"description"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedLocation = self.responseDictArray[indexPath.row][@"reference"];
    if ([self.locationDelegate respondsToSelector:@selector(secondViewControllerDismissed:)]) {
        [self.locationDelegate secondViewControllerDismissed:self.selectedLocation];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textFieldEditingChanged:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateSearchResults) object:nil];
    
    [self performSelector:@selector(updateSearchResults) withObject:nil afterDelay:0.75];
}

- (IBAction)returnPressed:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateSearchResults) object:nil];
    [self updateSearchResultsWithCompletion:^{
        if ([self.responseDictArray count]==0 && ![self.textField.text isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No locations found" message:@"There are no locations matching you search query" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else{
            self.selectedLocation = self.responseDictArray[0][@"reference"];
            if ([self.locationDelegate respondsToSelector:@selector(secondViewControllerDismissed:)]) {
                [self.locationDelegate secondViewControllerDismissed:self.selectedLocation];
            }
           dispatch_async(dispatch_get_main_queue(), ^{
               [self dismissViewControllerAnimated:YES completion:nil];
           });
        }
    }];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateSearchResultsWithCompletion:(void (^)())completion
{
    [GoogleMapsAPI updateListWithSuggestedPlacesForName:self.textField.text forLatitude:self.latitude andLongitude:self.longitude withCompletion:^(NSMutableArray *responseObjects) {
        self.responseDictArray = responseObjects;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        completion();
    }];
}

-(void)updateSearchResults
{
    [GoogleMapsAPI updateListWithSuggestedPlacesForName:self.textField.text forLatitude:self.latitude andLongitude:self.longitude withCompletion:^(NSMutableArray *responseObjects) {
        self.responseDictArray = responseObjects;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.textField resignFirstResponder];
}


@end
