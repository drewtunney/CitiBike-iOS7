//
//  SplashScreenVC.m
//  CitiBike
//
//  Created by Dare Ryan on 5/20/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "SplashScreenVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Reachability/Reachability.h>
#import "Constants.h"
#import "NetworkUnavailableVC.h"
#import "MapVC.h"
#import "DemoViewController.h"

@interface SplashScreenVC ()

@end

@implementation SplashScreenVC

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
    [self.view setBackgroundColor:[UIColor orangeColor]];
    
       // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"DemoDone"]) {
        Reachability *reach = [Reachability reachabilityWithHostname:@"www.maps.google.com"];
        
        reach.reachableBlock = ^(Reachability *reach)
        {
            NSLog(@"Reachable");
            dispatch_async(dispatch_get_main_queue(), ^{
                {
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    MapVC *mapVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"MapVC"];
                    [self presentViewController:mapVC animated:YES completion:nil];
                    [reach stopNotifier];
                }
            });
        };
        reach.unreachableBlock = ^(Reachability *reach)
        {
            NSLog(@"Unreachable");
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                NetworkUnavailableVC *mapVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"NetworkUnavailableVC"];
                [self presentViewController:mapVC animated:YES completion:nil];
                [reach stopNotifier];
                
            });
        };
        [reach startNotifier];
    }
    else{
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DemoViewController *demoVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"DemoVC"];
        [self presentViewController:demoVC animated:YES completion:nil];
        
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
