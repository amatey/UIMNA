//
//  SecondViewController.m
//  UMASS
//


#import "SecondViewController.h"

@interface SecondViewController ()<MKMapViewDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initConstraints];
    
    [self addAllPins];
}

-(void)initViews
{
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    MKCoordinateRegion region = self.mapView.region;
    region.center = CLLocationCoordinate2DMake(41.63109758, -71.00652695);
    region.span.longitudeDelta = 0.01;
    region.span.latitudeDelta = 0.01;
    [self.mapView setRegion:region animated:NO];
}

-(void)initConstraints
{
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    id views = @{
                 @"mapView": self.mapView
                 };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|" options:0 metrics:nil views:views]];
}

-(void)addAllPins
{
    self.mapView.delegate=self;
    
    NSArray *name=[[NSArray alloc]initWithObjects:
                   @"Corsair Shuttle stop- Campus entrance",
                   @"Charlton College of Business (CCB)",
                   @"Charlton College of Business Learning Pavilion",
                   @"Emergency Call Box",
                   @"College Now",
                   @"Library Cafe",
                   @"Blue & Gold Welcome Center",
                   @"Foster Administration",
                   @"Bank of America ATM",
                   @"Book Store",
                   nil];
    
    NSMutableArray *arrCoordinateStr = [[NSMutableArray alloc] initWithCapacity:name.count];
    
    [arrCoordinateStr addObject:@"41.63199972, -71.00626409"];
    [arrCoordinateStr addObject:@"41.62933334, -71.00799143"];
    [arrCoordinateStr addObject:@"41.6290687, -71.00859225"];
    [arrCoordinateStr addObject:@"41.62928824, -71.00784123"];
    [arrCoordinateStr addObject:@"41.62946967, -71.00714922"];
    [arrCoordinateStr addObject:@"41.62944562, -71.00700974"];
    [arrCoordinateStr addObject:@"41.62911682, -71.00429535"];
    [arrCoordinateStr addObject:@"41.62842815, -71.00445226"];
    [arrCoordinateStr addObject:@"41.62871284, -71.00445226"];
    [arrCoordinateStr addObject:@"41.62865571, -71.00450456"];
    
    
    for(int i = 0; i < name.count; i++)
    {
        [self addPinWithTitle:name[i] AndCoordinate:arrCoordinateStr[i]];
    }
}

-(void)addPinWithTitle:(NSString *)title AndCoordinate:(NSString *)strCoordinate
{
    MKPointAnnotation *mapPin = [[MKPointAnnotation alloc] init];
    strCoordinate = [strCoordinate stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *components = [strCoordinate componentsSeparatedByString:@","];
    
    double latitude = [components[0] doubleValue];
    double longitude = [components[1] doubleValue];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    mapPin.title = title;
    mapPin.coordinate = coordinate;
    
    [self.mapView addAnnotation:mapPin];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [mapView deselectAnnotation:view.annotation animated:YES];
    float lat = [[view annotation] coordinate]. latitude;
    float longg = [[view annotation] coordinate]. longitude;
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f&q=%f,%f",lat,longg,lat,longg]];
        [[UIApplication sharedApplication] openURL:url];
    } else {
        NSLog(@"Can't use comgooglemaps://");
    
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
