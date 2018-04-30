#import "ArduboyViewController.h"

extern unsigned char kkButtonState;

@implementation ArduboyViewController



#pragma mark --

- (id)init {
    if (self =[super init]) {
        self.title = NSLocalizedString(@"About", @"Series title");
        self.tabBarItem.image = [UIImage imageNamed:@"145-persondot.png"];
    }
    return self;
}

- (void)viewDidLoad {
    
//    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    CGRect bounds = [UIScreen mainScreen].bounds;

    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circuitboard.jpg"]];
    background.frame = bounds;
    background.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:background];

    
    m_oglView = [[KKDrawView alloc] initWithFrame:CGRectMake(0, 50, bounds.size.width, bounds.size.width/2) width:128 height:64 fps:60];
    m_oglView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1];
//    m_oglView.parent = self;
    
    [self.view addSubview:m_oglView];
    
    
    CGRect keyboardFrame = CGRectZero;
    
    keyboardFrame.size.width = bounds.size.width - 10*2;
    keyboardFrame.origin.x = 10;
    keyboardFrame.size.height = 200;
    keyboardFrame.origin.y = bounds.size.height - 200 - 20;
    
    int w, h;
    
    w = keyboardFrame.size.width / 6;
    h = keyboardFrame.size.height / 4;
    
    key_up = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key_up.png"]];
    key_up.frame = CGRectMake(keyboardFrame.origin.x + w * 1, keyboardFrame.origin.y + h * 1, 48, 48);
    key_up.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:key_up];
    
    key_down = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key_down.png"]];
    key_down.frame = CGRectMake(keyboardFrame.origin.x + w * 1, keyboardFrame.origin.y + h * 3, 48, 48);
    key_down.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:key_down];
    
    key_left = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key_left.png"]];
    key_left.frame = CGRectMake(keyboardFrame.origin.x + w * 0, keyboardFrame.origin.y + h * 2, 48, 48);
    key_left.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:key_left];
    
    key_right = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key_right.png"]];
    key_right.frame = CGRectMake(keyboardFrame.origin.x + w * 2,  keyboardFrame.origin.y + h * 2, 48, 48);
    key_right.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:key_right];

    key_a = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key_a.png"]];
    key_a.frame = CGRectMake(keyboardFrame.origin.x + w * 4,  keyboardFrame.origin.y + h * 3, 48, 48);
    key_a.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:key_a];
    
    key_b = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key_b.png"]];
    key_b.frame = CGRectMake(keyboardFrame.origin.x + w * 5,  keyboardFrame.origin.y + h * 2, 48, 48);
    key_b.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:key_b];
    
    
    
    
    self.view.backgroundColor=[UIColor blackColor];
    
    [super viewDidLoad];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    
    CGPoint location = [touch locationInView:self.view];
    
    UIView *viewEffect = nil;
    
    if (CGRectContainsPoint(key_left.frame, location)) {
        kkButtonState |= (1 << 5); // Left
        viewEffect = key_left;
    }
    else if (CGRectContainsPoint(key_right.frame, location)) {
        kkButtonState |= (1 << 6); // Right
        viewEffect = key_right;
    }
    else if (CGRectContainsPoint(key_up.frame, location)) {
        kkButtonState |= (1 << 7); // Up
        viewEffect = key_up;
    }
    else if (CGRectContainsPoint(key_down.frame, location)) {
        kkButtonState |= (1 << 4); // Down
        viewEffect = key_down;
    }
    else if (CGRectContainsPoint(key_a.frame, location)) {
        kkButtonState |= (1 << 3); // A
        viewEffect = key_a;
    }
    else if (CGRectContainsPoint(key_b.frame, location)) {
        kkButtonState |= (1 << 2); // B
        viewEffect = key_b;
    }
    
    if (viewEffect != nil) {
        [UIView beginAnimations:@"" context:NULL];
        [viewEffect setAlpha:(0.0)];
        [UIView setAnimationDuration:0.5];
        [UIView commitAnimations];
    }
    
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    
    CGPoint location = [touch locationInView:self.view];
    
    
    //    if (gb.ipc.keys_pressed != 0) {
    UIView *viewEffect = nil;
    
    if (CGRectContainsPoint(key_left.frame, location)) {
        viewEffect = key_left;
    }
    else if (CGRectContainsPoint(key_right.frame, location)) {
        viewEffect = key_right;
    }
    else if (CGRectContainsPoint(key_up.frame, location)) {
        viewEffect = key_up;
    }
    else if (CGRectContainsPoint(key_down.frame, location)) {
        viewEffect = key_down;
    }
    else if (CGRectContainsPoint(key_a.frame, location)) {
        viewEffect = key_a;
    }
    else if (CGRectContainsPoint(key_b.frame, location)) {
        viewEffect = key_b;
    }
    
    
    if (viewEffect != nil) {
        [UIView beginAnimations:@"" context:NULL];
        [viewEffect setAlpha:(1.0)];
        [UIView setAnimationDuration:0.5];
        [UIView commitAnimations];
    }
    //    }
    
    [key_up setAlpha:(1.0)];
    [key_down setAlpha:(1.0)];
    [key_left setAlpha:(1.0)];
    [key_right setAlpha:(1.0)];
    
    kkButtonState=0;
}

#pragma mark - Hardware keyboard support

- (BOOL)canBecomeFirstResponder {
    return YES;
}


- (void)dismissSettingsView {
    
    m_oglView.isPaused=false;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}




@end
