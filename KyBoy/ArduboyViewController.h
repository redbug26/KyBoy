//
//  ArduboyViewController.h
//  KyBoy
//
//  Created by Miguel Vanhove on 2018/04/21.
//  Copyright (c) 2018 Miguel Vanhove. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
#import "KKDrawView.h"


@interface ArduboyViewController : UIViewController <UIWebViewDelegate, NSFileManagerDelegate> {
    
    KKDrawView *m_oglView;
    
    UIImageView *key_up;
    UIImageView *key_down;
    UIImageView *key_left;
    UIImageView *key_right;
    UIImageView *key_a;
    UIImageView *key_b;
}


@end
