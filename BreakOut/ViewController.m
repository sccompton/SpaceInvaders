//
//  ViewController.m
//  BreakOut
//
//  Created by Stephen Compton on 1/16/14.
//  Copyright (c) 2014 Stephen Compton. All rights reserved.
//

#import "ViewController.h"
#import "PaddleView.h"
#import "BallView.h"
#import "BlockView.h"
#import "BlockImageView.h"
#import "BreakOut.h"
#import "MissileImageView.h"

@interface ViewController ()<UICollisionBehaviorDelegate>

{
    __weak IBOutlet UIButton *gameOverButton;
    __weak IBOutlet UIButton *startButton;
    __weak IBOutlet UILabel *scorePlayer2Label;
    __weak IBOutlet UILabel *scorePlayer1Label;
    __weak IBOutlet PaddleView *paddleView;
    UIDynamicAnimator *dynamicAnimator;
    __weak IBOutlet BallView *ballView;
    UIPushBehavior *pushBehavior;
    __weak IBOutlet UILabel *currentLevelLabel;
    UICollisionBehavior *collisionBehavior;
    UIDynamicItemBehavior *blockDynamicBehavior;
    UISnapBehavior *snapBall;
    UIDynamicItemBehavior *missileDynamicBehavior;
    UIView *gameBoard;

    __weak IBOutlet UIImageView *ballImageView;
    NSMutableArray *player1LifeImages;
    NSMutableArray *player2LifeImages;
    float xLocation;
    float yLocation;
    BlockImageView *temp;
    BreakOut *game;
    __weak IBOutlet UIImageView *paddleImageView;
    CGPoint setMissileLocation;
    MissileImageView *newMissile;
}

@end

@implementation ViewController


- (IBAction)onFireButtonPressed:(id)sender {
    
    newMissile = [[MissileImageView alloc] initWithFrame: CGRectMake(xLocation, yLocation, 5.0, 15.0)];
    newMissile.backgroundColor = [UIColor redColor];
    [self.view addSubview:newMissile];
    [collisionBehavior addItem: newMissile];
    [missileDynamicBehavior addItem: newMissile];
    [dynamicAnimator addBehavior:missileDynamicBehavior];

    [gameBoard addSubview:newMissile];

    
    pushBehavior = [[UIPushBehavior alloc] initWithItems:@[newMissile] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = CGVectorMake(0.0, -1.0);
    pushBehavior.magnitude = 0.2;
    [dynamicAnimator addBehavior:pushBehavior];
    pushBehavior.active = YES;
    

   /* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[newMissile, ballView, paddleView]];
    collisionBehavior.collisionDelegate=self;
    collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [dynamicAnimator addBehavior:collisionBehavior];*/


}


- (IBAction)dragPaddle:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    paddleView.center = CGPointMake ([panGestureRecognizer locationInView:self.view].x, paddleView.center.y);
    [dynamicAnimator updateItemUsingCurrentState:paddleView];
    
    xLocation = (paddleView.center.x);
    yLocation = (paddleView.center.y - 30);
    
    
}
- (IBAction)onStartGameButtonPressed:(id)sender
{
    [dynamicAnimator removeBehavior:snapBall];
    pushBehavior.active = YES;
//    [dynamicAnimator updateItemUsingCurrentState:ballView];
   
    startButton.hidden =YES;
    
}

- (IBAction)onGameOverButtonPressed:(id)sender {
    [self restartGame];
    ballView.center = CGPointMake(160.0, self.view.center.y);
    [dynamicAnimator updateItemUsingCurrentState:ballView];

}

- (void)setupLevel:(NSInteger)level
{
    blockDynamicBehavior = [[UIDynamicItemBehavior alloc] init];
    blockDynamicBehavior.allowsRotation = NO;
    blockDynamicBehavior.density = 50000.0;
    
  
    for (UIView *tempBlock in game.blocks)
    {
        [tempBlock removeFromSuperview];
    }
 
    [game setGameForLevel:level];
   
    for (BlockImageView *newBlock in game.blocks)
    {
        
        [gameBoard addSubview:newBlock];
        [collisionBehavior addItem: newBlock];
        [blockDynamicBehavior addItem: newBlock];
        
        [self.view addSubview:newBlock];
        [dynamicAnimator addBehavior:blockDynamicBehavior];
        
        [gameBoard addSubview:newBlock];
        
        pushBehavior = [[UIPushBehavior alloc] initWithItems:@[newBlock] mode:UIPushBehaviorModeInstantaneous];
        pushBehavior.pushDirection = CGVectorMake(0.0, 100.0);
        pushBehavior.magnitude = 700.0;
        [dynamicAnimator addBehavior:pushBehavior];
        pushBehavior.active = YES;
        
        
    }
    
    [dynamicAnimator addBehavior:blockDynamicBehavior];
    ballView.center = CGPointMake(160.0, self.view.center.y);
    [dynamicAnimator updateItemUsingCurrentState:ballView];
}

- (void)restartGame
{
    gameOverButton.hidden = YES;
    startButton.hidden = NO;
    game = [BreakOut new];
//    [BreakOut setNumberOfLifes:3];
    
    [game initGameForPlayers:_numberOfPlayers];
    
    scorePlayer1Label.text = [NSString stringWithFormat:@"%i", game.player1Score];
    scorePlayer2Label.text = [NSString stringWithFormat:@"%i", game.player2Score];

    
    UIDynamicItemBehavior *ballDynamicBehavior;
    UIDynamicItemBehavior *paddleDynamicBehavior;

    
    snapBall = [[UISnapBehavior alloc] initWithItem:ballView snapToPoint: CGPointMake(160.0, 220)];
    [dynamicAnimator updateItemUsingCurrentState:paddleView];
    [dynamicAnimator addBehavior:snapBall];
   
    dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:gameBoard];
    pushBehavior = [[UIPushBehavior alloc] initWithItems:@[ballView] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = CGVectorMake(0.5, 1.0);
    pushBehavior.active = YES;
    pushBehavior.magnitude = 0.2;
    [dynamicAnimator addBehavior:pushBehavior];
    
    //paddlePushBehavior = [[UIPushBehavior alloc] initWithItems:@[paddleViewTwo] mode:UIPushBehaviorModeInstantaneous];
    
    
    collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[ballView, paddleView]];
    collisionBehavior.collisionDelegate=self;
    collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    collisionBehavior.translatesReferenceBoundsIntoBoundary = NO;
    
    [dynamicAnimator addBehavior:collisionBehavior];
    
    paddleDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[paddleView]];
    paddleDynamicBehavior.allowsRotation = NO;
    paddleDynamicBehavior.density = 10000.0;
    
    [dynamicAnimator addBehavior:paddleDynamicBehavior];
    
    
    ballDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[ballView]];
    ballDynamicBehavior.allowsRotation = NO;
    ballDynamicBehavior.elasticity = 1.0;
    ballDynamicBehavior.friction = 0.0;
    ballDynamicBehavior.resistance = 0.0;
    
    [dynamicAnimator addBehavior:ballDynamicBehavior];

    
    [self setupLevel:(game.currentPlayer==1) ? game.player1Level : game.player2Level];
    [self refreshScore];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden =YES;

    
    ballImageView.image = [UIImage imageNamed:@"bomb2.png"];

    
        paddleImageView.image = [UIImage imageNamed:@"images.png"];
    
    gameBoard = self.view;
    
    player1LifeImages = [NSMutableArray array];
    player2LifeImages = [NSMutableArray array];
    
    for (int x=0; x< 5; x++)
    {
        UIImageView *life = [[UIImageView alloc] initWithFrame: (CGRectMake(20+(x*25), (600), 20.0, 5.0))];
        life.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PlayerLife20x5.png"]];
    //    [life sizeToFit];
        [self.view addSubview:life];
        [player1LifeImages addObject:life];
        
        life = [[UIImageView alloc] initWithFrame: CGRectMake(170+(x*25), (600), 20.0, 5.0)];
        life.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PlayerLife20x5.png"]];
    //    [life sizeToFit];
        [self.view addSubview:life];
        [player2LifeImages addObject:life];
    }
   [startButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Start.png"]]];
    [self restartGame];
    

}



-(BOOL)shouldStartAgain
{
    if (game.blocks.count == 0) {
        return YES;
    }else
    {return NO;
    }
}

#pragma mark UICollisionBehaviorDelegate
- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if (p.y > 560)
    {
        [game lostBall];
        [self refreshScore];
        
        startButton.hidden = NO;
        
        ballView.center = CGPointMake(160.0, self.view.center.y);
        [dynamicAnimator updateItemUsingCurrentState:ballView];
   
        snapBall = [[UISnapBehavior alloc] initWithItem:ballView snapToPoint: CGPointMake(160.0, 300.0)];
        pushBehavior.active = YES;
        [dynamicAnimator addBehavior:snapBall];
        
        [game flipPlayer];
        
        
    }
}

- (void)refreshScore
{
    scorePlayer1Label.text = [NSString stringWithFormat:@"%i", game.player1Score];
    scorePlayer2Label.text = [NSString stringWithFormat:@"%i", game.player2Score];

    
    if(game.currentPlayer ==1)
    {
    currentLevelLabel.text = [NSString stringWithFormat:@"%i", game.player1Level];
        scorePlayer1Label.textColor = [UIColor redColor];
        scorePlayer2Label.textColor = [UIColor whiteColor];
    }
    else
    {
        currentLevelLabel.text = [NSString stringWithFormat:@"%i", game.player2Level];
        scorePlayer2Label.textColor = [UIColor redColor];
        scorePlayer1Label.textColor = [UIColor whiteColor];
    }

    
    for (int x=0; x< game.numberOfLifes; x++)
    {
        UIImageView *life = [player1LifeImages objectAtIndex:x];
        if (game.player1Lifes > x)
        {
            life.hidden = NO;
        }
        else
        {
            life.hidden = YES;
        }
        
        life = [player2LifeImages objectAtIndex:x];
        if (game.player2Lifes >= x)
        {
            life.hidden = NO;
        }
        else
        {
            life.hidden = YES;
        }
        
    }
    
    if (game.gameOver)
    {
        if (game.player1Lifes == 0)
        {
            [gameOverButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"FPlayer2Wins.png"]]];
        }
        else
        {
            [gameOverButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"FPlayer1Wins.png"]]];
        }
        gameOverButton.hidden = NO;
        
    }
}

- (void)removeItem:(id)item
{

    [game hitBlock:item];
    
    [self refreshScore];
    
    [collisionBehavior removeItem:item];
    [dynamicAnimator updateItemUsingCurrentState:item];
    
    [((BlockImageView*)item) startAnimating];
    [UIImageView animateWithDuration:0.5 animations:^{
        ((BlockImageView*)item).alpha = 0;
    }];
    
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p


{
    if ([item1 isKindOfClass:[PaddleView class]] && [item2 isKindOfClass:[BlockImageView class]]) {
        
        paddleView.alpha = 0;
        [collisionBehavior removeItem:paddleView];
        [dynamicAnimator updateItemUsingCurrentState:paddleView];
        gameOverButton.hidden = NO;
        
        
    }
    if (([item2 isKindOfClass:[PaddleView class]]) && ([item2 isKindOfClass:[BlockImageView class]])) {
        
        paddleView.alpha = 0;
        [collisionBehavior removeItem:paddleView];
        [dynamicAnimator updateItemUsingCurrentState:paddleView];
        gameOverButton.hidden = NO;
        
    }

    else
        
    {
    
     if ([item1 isKindOfClass:[BlockImageView class]]) {
    
        [collisionBehavior removeItem:item2];
        [dynamicAnimator updateItemUsingCurrentState:item2];
    
        newMissile.alpha = 0;
       [self removeItem:item1];
        
    }
    
    if ([item2 isKindOfClass:[BlockImageView class]]) {
        
        [collisionBehavior removeItem:item1];
        
        [dynamicAnimator updateItemUsingCurrentState:item1];
        newMissile.alpha = 0;
        
        [self removeItem:item2];
    }
    
    if(game.levelFinished)
    {
        // next Level

        [self setupLevel:(game.currentPlayer==1) ? game.player1Level : game.player2Level];
        
    }

}

}

@end
