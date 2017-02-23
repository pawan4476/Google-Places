//
//  ViewController.h
//  GooglePlaces
//
//  Created by Nagam Pawan on 1/3/17.
//  Copyright © 2017 Nagam Pawan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ModelClass.h"

#define kGOOGLE_API_KEY @"AIzaSyBU10QM4h0d43h72beldCt94jn15xE9Mk0"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface ViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate>
{
    
    CLLocationManager *locationManager;
    CLLocationCoordinate2D currentCenter;
    int currentDist;
    BOOL firstLaunch;
    
}
@property (weak, nonatomic) IBOutlet MKMapView *myMapView;
- (IBAction)mapType:(id)sender;
- (IBAction)zoomOut:(id)sender;


@end

