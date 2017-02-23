//
//  ModelClass.m
//  GooglePlaces
//
//  Created by Nagam Pawan on 1/3/17.
//  Copyright © 2017 Nagam Pawan. All rights reserved.
//

#import "ModelClass.h"

@implementation ModelClass
@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;

-(id)initWithName:(NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate{
    
    if ((self = [super init])) {
        
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
        
    }
    
    return self;
    
}

-(NSString *)title{
    
    if ([_name isKindOfClass:[NSNull class]])
        
        return @"Unknown Charge";
    
    else
        
        return _name;
    
}

-(NSString *)subtitle{
    
    return _address;
    
}
@end
