//
//  TabBarControllerViewController.m
//  Example - Local
//
//  Created by Reagan Smith on 1/10/24.
//

#import "TabBarControllerViewController.h"
#import "ViewController.h"
#import "ProductViewController.h"

@interface TabBarControllerViewController ()

@end

@implementation TabBarControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *firstViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    UIViewController *secondViewController = [storyboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
    
    firstViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Main" image:[UIImage imageNamed:@"first_icon"] tag:0];
    secondViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Products" image:[UIImage imageNamed:@"second_icon"] tag:1];
    
    self.tabBar.barTintColor = [UIColor redColor];self.tabBar.tintColor = [UIColor blueColor];
    
    self.viewControllers = @[firstViewController, secondViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
