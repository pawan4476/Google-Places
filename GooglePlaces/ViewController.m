//
//  ViewController.m
//  GooglePlaces
//
//  Created by Nagam Pawan on 1/3/17.
//  Copyright © 2017 Nagam Pawan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize myMapView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myMapView.delegate = self;
    [self.myMapView setShowsUserLocation:YES];
    locationManager = [[CLLocationManager alloc]init];
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc]init];
    pointAnnotation.coordinate = locationManager.location.coordinate;

    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    firstLaunch = YES;
    [self.myMapView addAnnotation:pointAnnotation];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)queryGooglePlaces:(NSString *) googleType{
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", currentCenter.latitude, currentCenter.longitude, [NSString stringWithFormat:@"%i", currentDist], googleType, kGOOGLE_API_KEY];
    NSURL *googleRequestUrl = [NSURL URLWithString:url];
    dispatch_async(kBgQueue, ^{
        
        NSData *data = [NSData dataWithContentsOfURL:googleRequestUrl];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
        
    });
}

-(void)fetchedData:(NSData *)responseData{
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSArray *places = [json objectForKey:@"results"];
    NSLog(@"Google Data is: %@", places);
    [self plotPositions:places];
    
}

-(void)plotPositions:(NSArray *)data{
    
    for (id<MKAnnotation> annotation in myMapView.annotations)
    {
        if ([annotation isKindOfClass:[ModelClass class]])
        {
            [myMapView removeAnnotation:annotation];
        }
    }

    for (int i = 0; i < [data count]; i++) {
        
        NSDictionary *place = [data objectAtIndex:i];
        NSDictionary *geo = [place objectForKey:@"geometry"];
        NSString *name = [place objectForKey:@"name"];
        NSString *vicinity = [place objectForKey:@"vicinity"];
        NSDictionary *loc = [geo objectForKey:@"location"];
        CLLocationCoordinate2D placeCoord;
        placeCoord.latitude = [[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude = [[loc objectForKey:@"lng"] doubleValue];
        ModelClass *placeObject = [[ModelClass alloc] initWithName:name address:vicinity coordinate:placeCoord];
        [myMapView addAnnotation:placeObject];
        
    }
}

-(IBAction)toolBarButtonPressed:(id)sender{
    
    UIBarButtonItem *item = (UIBarButtonItem *)sender;
    NSString *buttonTitle = [item.title lowercaseString];
    [self queryGooglePlaces:buttonTitle];
    
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views{
    
    CLLocationCoordinate2D center = [mapView centerCoordinate];
    MKCoordinateRegion region;
    if (firstLaunch) {
        
        region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 1000, 1000);
        firstLaunch = NO;
        
    }
    
    else{
        
        region = MKCoordinateRegionMakeWithDistance(center, currentDist, currentDist);
        
    }
    
    [mapView setRegion:region animated:YES];
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    static NSString *identifier = @"ModelClass";
    if ([annotation isKindOfClass:[ModelClass class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.myMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
        }
        
        else{
            
            annotationView.annotation = annotation;
            
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        
        return annotationView;
        
    }
    
    return nil;
    
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    MKMapRect mRect = self.myMapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    currentDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    currentCenter = self.myMapView.centerCoordinate;
    
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    self.myMapView.centerCoordinate = userLocation.location.coordinate;
    
}
- (IBAction)mapType:(id)sender {
    
    if (self.myMapView.mapType == MKMapTypeStandard) {
        
        self.myMapView.mapType = MKMapTypeSatellite;
        
    }
    
    else{
        
        self.myMapView.mapType = MKMapTypeStandard;
        
    }
}

- (IBAction)zoomOut:(id)sender {
    
    MKCoordinateSpan span;
    span.latitudeDelta = myMapView.region.span.latitudeDelta*2;
    span.longitudeDelta = myMapView.region.span.longitudeDelta*2;
    MKCoordinateRegion region;
    region.span = span;
    region.center = myMapView.region.center;
    [self.myMapView setRegion:region];
    
}
@end
