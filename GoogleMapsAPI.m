//
//  GoogleMapsAPI.m
//  CitiBike
//
//  Created by Dare Ryan on 5/10/14.
//  Copyright (c) 2014 drewtunney. All rights reserved.
//

#import "GoogleMapsAPI.h"
#import "CitiBikeAPI.h"


@implementation GoogleMapsAPI

+(void)displayDirectionsfromOriginLatitude:(CGFloat)originLat andOriginLongitude:(CGFloat)originLong toDestinationLatitude:(CGFloat)destinationLat andDestinationLongitude:(CGFloat)destinationLong onMap:(GMSMapView *)map withCompletion:(void (^)(NSDictionary *))completion
{
    NSString *directionsURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&key=%@&avoid=ferries&mode=bicycling", originLat, originLong,destinationLat,destinationLong,Web_Browser_Key];
    NSURL *url = [NSURL URLWithString:directionsURL];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            GMSPath *path = [GMSPath pathFromEncodedPath:JSONResponseDict[@"routes"][0][@"overview_polyline"][@"points"]];
            GMSPolyline *directionsLine;
            directionsLine = [GMSPolyline polylineWithPath:path];
            directionsLine.strokeWidth = 7;
            UIColor *lineColor = [UIColor colorWithRed:0.106 green:0.643 blue:1.0 alpha:0.75];
            directionsLine.strokeColor = lineColor;
            directionsLine.map = map;
            
            completion (JSONResponseDict);
        });
        
        if (error) {
            NSLog(@"%@", error);
        }
    }]resume];
}

+(void)getAddressForLocationReferenceID:(NSString *)ID withCompletion:(void (^)(NSArray *))completion
{
    NSString*urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@", ID, Web_Browser_Key];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSString *fullAddress;
        NSString *locationName = JSONResponseDict[@"result"][@"name"];
        
        
        if ([JSONResponseDict[@"result"][@"address_components"][0][@"long_name"] isEqualToString:@"New York"]) {
            fullAddress = [JSONResponseDict[@"result"][@"name"] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        }
        else{
            NSMutableArray *addressArray = [[NSMutableArray alloc]init];
            for (NSDictionary *components in JSONResponseDict[@"result"][@"address_components"]) {
                [addressArray addObject:components[@"long_name"]];
            }
            fullAddress = [addressArray componentsJoinedByString:@"+"];
            fullAddress = [fullAddress stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        }
        if (error) {
            NSLog(@"%@", error);
        }
        
        
        completion(@[fullAddress, locationName]);
    }]resume];
}

+(void)getCoordinatesForLocationForDestination:(NSString *)address withCompletion:(void (^)(NSDictionary *))completion
{
    NSString*urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true&key=%@", address, Web_Browser_Key];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        
        NSNumber *directionsDestinationLatitude = [NSNumber numberWithFloat:[JSONResponseDict[@"results"][0][@"geometry"][@"location"][@"lat"]floatValue]];
        NSNumber *directionsDestinationLongitude = [NSNumber numberWithFloat:[JSONResponseDict[@"results"][0][@"geometry"][@"location"][@"lng"]floatValue]];
        
        NSDictionary *coordinates = @{@"lat":directionsDestinationLatitude, @"lng":directionsDestinationLongitude};
        
        if (error) {
            NSLog(@"%@", error);
        }
        completion(coordinates);
    }]resume];
}

+(void)updateListWithSuggestedPlacesForName:(NSString *)textInput forLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude withCompletion:(void (^)(NSMutableArray *))completion
{
    NSMutableArray *responseDictArray = [[NSMutableArray alloc]init];
    NSString *searchString = [textInput stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%f,%f&radius=17000&sensor=true&key=%@", searchString, latitude, longitude, Web_Browser_Key];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *JSONResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        for (NSDictionary *location in JSONResponseDict[@"predictions"]) {
            [responseDictArray addObject:location];
        }
        
        if (error) {
            NSLog(@"%@", error);
        }
        completion(responseDictArray);
    }]resume];
}
@end
