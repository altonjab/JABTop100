//
//  ViewController.m
//  JAB
//
//  Created by Joe Bradley on 11/16/14.
//  Copyright (c) 2014 JAB. All rights reserved.
//

#import "ViewController.h"
#import "AppDataManager.h"

NSString * const ViewControllerWordsTableViewCellIdentifier = @"ViewControllerWordsTableViewCellIdentifier";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *wordsTableView;
@property (weak, nonatomic) IBOutlet UILabel *wordsDetailOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *wordsDetailTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *wordsDetailThreeLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // When data is setup or refreshed be notified
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(liveDataChanged)
                                                 name:AppDataManagerLiveDataRefreshedNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Call the web service to get json data
    [[AppDataManager sharedManager] invokeServiceCall];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark - Table view data source and delegate methods
////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger result = 0;

    if ([[[AppDataManager sharedManager] liveData] count]) {
        result = [[[AppDataManager sharedManager] liveData] count];
    }
    
    return result;
}

// Returns cell (row) containing info from words dictionary using the index path row as an index of words array
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result;
    NSDictionary *wordDataDictionary = [[[AppDataManager sharedManager] liveData] objectAtIndex:indexPath.row];
    
    result = [tableView dequeueReusableCellWithIdentifier:ViewControllerWordsTableViewCellIdentifier];

    if (result == nil ) {
        result = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                        reuseIdentifier:ViewControllerWordsTableViewCellIdentifier];
        
        result.selectionStyle = UITableViewCellSelectionStyleDefault;
        result.backgroundColor = [UIColor clearColor];
        result.textLabel.textColor = [UIColor lightGrayColor];
        result.detailTextLabel.textColor = [UIColor darkGrayColor];
    }
    
    result.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [wordDataDictionary valueForKey:@"ngram"], [wordDataDictionary valueForKey:@"count"]];
    result.detailTextLabel.text = [NSString stringWithFormat:@"%@", [wordDataDictionary valueForKey:@"tfidf"]];

    return result;
}

// Selection of a row (cell) displays info using the index path row as an index of the words array
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *wordDataDictionary = [[[AppDataManager sharedManager] liveData] objectAtIndex:indexPath.row];

    self.wordsDetailOneLabel.text = [wordDataDictionary valueForKey:@"ngram"];
    self.wordsDetailTwoLabel.text = [NSString stringWithFormat:@"%@", [wordDataDictionary valueForKey:@"count"]];
    self.wordsDetailThreeLabel.text = [NSString stringWithFormat:@"%@", [wordDataDictionary valueForKey:@"tfidf"]];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark - Private methods
////////////////////////////////////////////////////////////////////////

- (void)liveDataChanged {
    // Refresh word table view data
    [self.wordsTableView reloadData];
}

@end
