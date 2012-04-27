//
//  spyAppDelegate.h
//  SpyTools
//
//  Created by Chip on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSTextEncryptor.h"
#import "HSImageEncryptor.h"
#import "HSKeyLibrary.h"

@interface spyAppDelegate : NSObject <NSApplicationDelegate>{
    BOOL        stTextFits;
}
/*Global*/
@property (weak) IBOutlet NSTabView *glTabView;
/*Text Encryption*/
@property (weak) IBOutlet NSSegmentedControl *teOperationSelector;
@property (weak) IBOutlet NSTextField *teInputTextField;
@property (weak) IBOutlet NSSegmentedControl *teKeyTypeSelector;
@property (weak) IBOutlet NSSegmentedControl *teKeyLengthSelector;
@property (weak) IBOutlet NSButton *teGenerateKeyButton;
@property (weak) IBOutlet NSButton *teProcessButton;
@property (weak) IBOutlet NSTextField *teOutputText;
@property (weak) IBOutlet NSTextField *teInformationLabel;
@property (weak) IBOutlet NSTextField *teInputTextLabel;
@property (weak) IBOutlet NSTextField *teKeyFieldLabel;
@property (weak) IBOutlet NSTextField *teOutputTextLabel;
@property (weak) IBOutlet NSBox *teRandomKeyBox;
@property (weak) IBOutlet NSTextField *teKeyTextField;
@property (weak) IBOutlet NSTextField *teKeyTypeLabel;
@property (weak) IBOutlet NSTextField *teKeyLengthLabel;
/*Text In Image Encryption*/
@property (weak) IBOutlet NSSegmentedControl *tiOperationSelector;
@property (weak) IBOutlet NSSegmentedControl *tiKeyTypeSelector;
@property (weak) IBOutlet NSTextField *tiInputTextField;
@property (weak) IBOutlet NSImageView *tiInputImageWell;
@property (weak) IBOutlet NSSegmentedControl *tiKeyLengthSelector;
@property (weak) IBOutlet NSTextField *tiKeyTextField;
@property (weak) IBOutlet NSButton *tiGenerateKeyButton;
@property (weak) IBOutlet NSButton *tiProcessButton;
@property (weak) IBOutlet NSTextField *tiOutputTextField;
@property (weak) IBOutlet NSTextField *tiInputTextLabel;
@property (weak) IBOutlet NSTextField *tiOutputTextLabel;
@property (weak) IBOutlet NSProgressIndicator *tiProgressIndicator;


/*Interface Methods-----------------------*/
-(IBAction)operationSelectorChange:(id)sender;
-(IBAction)keyTypeSelectorChange:(id)sender;
/*Text Encryption*/
-(IBAction)generateRandomKey:(id)sender;
-(IBAction)generateRandomPassphrase:(id)sender;
-(IBAction)generateKeySelector:(id)sender;
-(IBAction)oneTimePadEncryptText:(id)sender;
-(IBAction)onetimePadDecryptText:(id)sender;
-(IBAction)oneTimePadSelector:(id)sender;
/*Text in Image Encryption*/
-(IBAction)tiGenerateRandomKey:(id)sender;
-(IBAction)tiGenerateRandomPassphrase:(id)sender;
-(IBAction)tiGenerateKeySelector:(id)sender;
/*Image in Image Encryption*/


@property (assign) IBOutlet NSWindow *window;
@end
