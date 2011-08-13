//
//  PlayGameController.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayGameController.h"

#import "ResultController.h"
#import "ECTurn.h"
#import "Constants.h"

@implementation PlayGameController

@synthesize hintLabel;
@synthesize metadataLabel;
@synthesize turnTableView;
@synthesize guessTextField;
@synthesize guessButton;
@synthesize game;
@synthesize guessToolbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.guessTextField) {
        [guessTextField resignFirstResponder];
        ECTurn* newTurn = [ECTurn object];
        newTurn.guess = guessTextField.text;
        newTurn.updatedAt = newTurn.createdAt = [NSDate date];
        newTurn.user = [ECUser selfUser];
        newTurn.game = game;
        [[RKObjectManager sharedManager] postObject:newTurn delegate:self];
    }
    return YES;
}

-(void) keyboardWillShow:(NSNotification *)note {
    [self moveTextViewForKeyboard:note up:YES];
}

-(void) keyboardWillHide:(NSNotification *)note {
    [self moveTextViewForKeyboard:note up:NO];    
}


// This madness is needed so that the keyboard doesn't obscure the text-entry box.
- (void) moveTextViewForKeyboard:(NSNotification*)note up: (BOOL) up {
    NSDictionary* userInfo = [note userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newToolbarFrame = guessToolbar.frame;
    CGRect newTableViewFrame = turnTableView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    int delta = keyboardFrame.size.height * (up ? 1 : -1);
    
    newTableViewFrame.size.height -= delta;
    newToolbarFrame.origin.y -= delta;
    
    guessToolbar.frame = newToolbarFrame;
    turnTableView.frame = newTableViewFrame;
    
    [UIView commitAnimations];
}

- (IBAction)guessEditingDidEnd:(id)sender {
}

#pragma mark ResultControllerDelegate methods

- (void)resultOk:(ECTurn *)turn
{
    [self.navigationController popViewControllerAnimated:YES];
    [turnTableView reloadData];
}

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)_ 
{
    guessTextField.text = @"";
    if (game.doneAt) {
        guessTextField.hidden = YES;
    }
    [turnTableView reloadData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error 
{
	NSLog(@"Hit error: %@", error);
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Error" 
                          message:@"Error saving turn" 
                          delegate:nil 
                          cancelButtonTitle:@"Ok" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];    
    
}
#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    // Trigger data refresh every time the user goes to, or returns to, this view.
    [[RKObjectManager sharedManager] getObject:game delegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    hintLabel.text = game.hint;
    metadataLabel.text = [NSString stringWithFormat:@"%@ at %@", game.owner.name, game.createdAt];
    guessTextField.hidden = game.doneAt != nil;
   
    guessTextField.delegate = self;
    turnTableView.dataSource = self;
    turnTableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)viewDidUnload
{
    [self setHintLabel:nil];
    [self setTurnTableView:nil];
    [self setGuessTextField:nil];
    [self setGuessButton:nil];
    [self setMetadataLabel:nil];
    [self setGuessToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark UITableViewDelegate methods

static BOOL userCanGiveResultFor(ECGame *game, ECTurn *turn) {
    return game.doneAt == nil && game.owner.userID == [ECUser selfUser].userID && turn.result.intValue == ECResultNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECTurn* turn = [self turnAtIndexPath:indexPath];
    if (userCanGiveResultFor(game, turn)) {
        ResultController *resultController = [[ResultController alloc] initWithNibName:@"ResultController" bundle:nil];
        resultController.delegate = self;
        resultController.turn = turn;
        [self.navigationController pushViewController:resultController animated:YES];
        [resultController release];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return game.turns.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ECTurn* turn = [self turnAtIndexPath:indexPath];
    cell.textLabel.text = turn.guess;
    
    if (turn.result.intValue == ECResultWrong) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", turn.user.name, ECWrong];
        cell.detailTextLabel.textColor = [UIColor redColor];
    } else if (turn.result.intValue == ECResultRight) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", turn.user.name, ECRight];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];        
    } else {
        if (game.doneAt) {
            cell.detailTextLabel.text = turn.user.name;    
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ at %@", turn.user.name, turn.createdAt];
        }
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    if (userCanGiveResultFor(game, turn)) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (ECTurn *)turnAtIndexPath: (NSIndexPath *)indexPath {
    // TODO this resorts all turns for /each/ row... instead only sort when game changes.
    NSComparator byID = ^(id a, id b) {
        return [[b turnID] compare:[a turnID]];
    };
    NSArray *sorted = [[game.turns allObjects] sortedArrayUsingComparator:byID];                       
    ECTurn *turn = [sorted objectAtIndex:indexPath.row];
    return turn;
}


- (void)dealloc {
    [hintLabel release];
    [turnTableView release];
    [guessTextField release];
    [guessButton release];
    [metadataLabel release];
    [guessToolbar release];
    [super dealloc];
}
@end
