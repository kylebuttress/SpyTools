//
//  spyAppDelegate.m
//  SpyTools
//
//  Created by Chip on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "spyAppDelegate.h"

@implementation spyAppDelegate
@synthesize iiOperationSelector;
@synthesize iiInputImageWell;
@synthesize iiInputImageToBeEncryptedWell;
@synthesize iiInputImageLabel;
@synthesize iiInputToBeEncryptedLabel;
@synthesize iiOutputFormatSelector;
@synthesize iiOutputImageWell;
@synthesize iiOutputImageLabel;
@synthesize iiProcessButton;
@synthesize iiProgressIndicator;
@synthesize iiAnalyzeLabel;
@synthesize tiOperationSelector;
@synthesize tiKeyTypeSelector;
@synthesize tiInputTextField;
@synthesize tiInputImageWell;
@synthesize tiKeyLengthSelector;
@synthesize tiKeyTextField;
@synthesize tiGenerateKeyButton;
@synthesize tiProcessButton;
@synthesize tiOutputTextField;
@synthesize tiInputTextLabel;
@synthesize tiOutputTextLabel;
@synthesize tiProgressIndicator;
@synthesize tiOutputFormatSelector;
@synthesize tiKeyTextLabel;
@synthesize tiImageInputLabel;
@synthesize tiImageOutputLabel;
@synthesize tiOutputImageWell;
@synthesize tiAnalyzeLabel;
@synthesize teOperationSelector;
@synthesize teInputTextField;
@synthesize teKeyTypeSelector;
@synthesize teKeyLengthSelector;
@synthesize teGenerateKeyButton;
@synthesize teProcessButton;
@synthesize teOutputText;
@synthesize teInformationLabel;
@synthesize teRandomKeyBox;
@synthesize teKeyTextField;
@synthesize teKeyTypeLabel;
@synthesize teKeyLengthLabel;
@synthesize teInputTextLabel;
@synthesize teKeyFieldLabel;
@synthesize teOutputTextLabel;
@synthesize glTabView;

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    tiTextFits = FALSE;
    iiImageFits = FALSE;
    [iiProcessButton setEnabled:FALSE];
    [tiProcessButton setEnabled:FALSE];
    [self operationSelectorChange:self];
    [self tiOperationSelectorChange:self];
    [self iiOperationSelectorChange:self];
    [tiProgressIndicator setHidden:TRUE];
    [iiProgressIndicator setHidden:TRUE];
    
    /*Debug*/
    NSString *testString = [[NSString alloc] initWithString:@"The cake is a Lie!"];
    char *stringToBeEncrypted = NSStringToCharArray(prepareStringForEncryption(testString));
    //NSLog(@"%s",stringToBeEncrypted);
    
    /*Generate an array with the allowed characters*/
    NSMutableArray *allowedCharactersArray = [[NSMutableArray alloc] initWithArray: generateAllowedCharactersArray(32,127)];
    //NSLog(@"%@", allowedCharactersArray);

    /*Generate an array containing the characters to be encrypted*/
    NSMutableArray *requiredCharactersArray = [[NSMutableArray alloc] initWithArray:generateRequiredCharactersArray(testString)];
    //NSLog(@"Required Characters:%@",requiredCharactersArray);
    
    /*Order required characters*/
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [requiredCharactersArray sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    NSLog(@"Ordered Required Characters: %@", requiredCharactersArray);
    
    /*Generate random key*/
    NSMutableArray *keyArray = [[NSMutableArray alloc] initWithArray:generateRandomSubstitutionKey(requiredCharactersArray, allowedCharactersArray)];
    
    /*Encrypt*/
    NSString *encryptedString = [[NSString alloc] initWithString:encryptSubstitution(testString, requiredCharactersArray, keyArray)];
    //NSLog(@"%s",stringToBeEncrypted);
    
    /*Decrypt*/
    char *encryptedChar = NSStringToCharArray(encryptedString);
    for (int i=0; i<strlen(encryptedChar); i++) {
        for (int j=0; j<[requiredCharactersArray count]; j++) {
            if (encryptedChar[i]==[[keyArray objectAtIndex:j] intValue]) {
                encryptedChar[i]=[[requiredCharactersArray objectAtIndex:j] intValue];
            }
        }
    }
    NSLog(@"%s",encryptedChar);
}
/*Interface Methods*/
-(IBAction)operationSelectorChange:(id)sender{
    [self keyTypeSelectorChange:self];
    if ([teOperationSelector selectedSegment]==0) {
        [teKeyTypeSelector setEnabled:TRUE];
        [teKeyLengthSelector setEnabled:TRUE];
        [teGenerateKeyButton setEnabled:TRUE];
        [teProcessButton setTitle:@"Encrypt"];
        [teKeyFieldLabel setStringValue:@"Encryption Key:"];
        [teKeyLengthLabel setEnabled:TRUE];
        [teKeyTypeLabel setEnabled:TRUE];
        [teInputTextLabel setStringValue:@"Text to be Encrypted:"];
        [teOutputTextLabel setStringValue:@"Encrypted Text:"];
    }else {
        [teKeyTypeSelector setEnabled:FALSE];
        [teKeyLengthSelector setEnabled:FALSE];
        [teGenerateKeyButton setEnabled:FALSE];
        [teProcessButton setTitle:@"Decrypt"];
        [teKeyFieldLabel setStringValue:@"Decryption Key:"];
        [teKeyLengthLabel setEnabled:FALSE];
        [teKeyTypeLabel setEnabled:FALSE];
        [teInputTextLabel setStringValue:@"Text to be Decrypted:"];
        [teOutputTextLabel setStringValue:@"Decrypted Text:"];
    }
    
    [teOutputText setStringValue:@""];
    [teInputTextField setStringValue:@""];
}
-(IBAction)keyTypeSelectorChange:(id)sender{
    if (([teKeyTypeSelector selectedSegment]==0)&&([teOperationSelector selectedSegment]==0)) {
        [teKeyLengthSelector setEnabled:TRUE];
    }else {
        [teKeyLengthSelector setEnabled:FALSE];
    }
}
-(IBAction)tiOperationSelectorChange:(id)sender{
    [self tiKeyTypeSelectorChange:self];
    if ([tiOperationSelector selectedSegment]==0) {
        [tiKeyTypeSelector setEnabled:TRUE];
        [tiKeyLengthSelector setEnabled:TRUE];
        [tiGenerateKeyButton setEnabled:TRUE];
        [tiProcessButton setTitle:@"Encrypt"];
        [tiKeyTextLabel setStringValue:@"Encryption Key:"];
        [tiInputTextLabel setStringValue:@"Text to be Encrypted:"];
        [tiOutputTextLabel setStringValue:@"Encrypted Text:"];
        [tiKeyTypeSelector setEnabled:TRUE];
        [tiInputTextField setEnabled:TRUE];
        [tiImageInputLabel setStringValue:@"Image to Encrypt In:"];
        [tiOutputFormatSelector setEnabled:TRUE];
        [tiOutputImageWell setEnabled:TRUE];
        [tiOutputTextField setEnabled:FALSE];
    }else {
        [tiKeyTypeSelector setEnabled:FALSE];
        [tiKeyLengthSelector setEnabled:FALSE];
        [tiGenerateKeyButton setEnabled:FALSE];
        [tiProcessButton setTitle:@"Decrypt"];
        [tiKeyTextLabel setStringValue:@"Decryption Key:"];
        //[tiInputTextLabel setStringValue:@"Text to be Decrypted:"];
        [tiOutputTextLabel setStringValue:@"Decrypted Text:"];
        [tiKeyTypeSelector setEnabled:FALSE];
        [tiInputTextField setEnabled:FALSE];
        [tiImageInputLabel setStringValue:@"Image to Decrypt:"];
        [tiOutputFormatSelector setEnabled:FALSE];
        [tiOutputImageWell setEnabled:FALSE];
        [tiOutputTextField setEnabled:TRUE];
        [tiOutputImageWell setImage:NULL];
        
        [tiInputTextField setStringValue:@""];
        [tiInputImageWell setImage:NULL];
        [tiOutputImageWell setImage:NULL];
        [tiOutputTextField setStringValue:@""];
    }
}
-(IBAction)tiKeyTypeSelectorChange:(id)sender{
    if (([tiKeyTypeSelector selectedSegment]==0)&&([tiOperationSelector selectedSegment]==0)) {
        [tiKeyLengthSelector setEnabled:TRUE];
    }else {
        [tiKeyLengthSelector setEnabled:FALSE];
    } 
}
-(IBAction)iiOperationSelectorChange:(id)sender{
    if ([iiOperationSelector selectedSegment]==0) {
        [iiProcessButton setTitle:@"Encrypt"];
        [iiInputImageLabel setStringValue:@"Image to Encrypt In:"];
        [iiOutputFormatSelector setEnabled:TRUE];
        [iiInputImageToBeEncryptedWell setEnabled:TRUE];
        [iiOutputImageLabel setStringValue:@"Encrypted Image:"];
    }else {
        [iiProcessButton setTitle:@"Decrypt"];
        [iiInputImageLabel setStringValue:@"Image to Decrypt:"];
        [iiOutputFormatSelector setEnabled:FALSE];
        [iiInputImageToBeEncryptedWell setEnabled:FALSE];
        [iiOutputImageLabel setStringValue:@"Decrypted Image:"];
    }  
    [iiOutputImageWell setImage:NULL];
    [iiInputImageWell setImage:NULL];
    [iiInputImageToBeEncryptedWell setImage:NULL];
}
/*Text Encryption*/
-(IBAction)generateRandomKey:(id)sender{
    int inputStringLength = [[teInputTextField stringValue] length];
    float lengthFraction = 1;
    if ([teKeyLengthSelector selectedSegment]==0) {
        lengthFraction = 1;
    }else if ([teKeyLengthSelector selectedSegment]==1) {
        lengthFraction = .5;
    }else {
        lengthFraction = .25;
    }
    int keyLength = lengthFraction*inputStringLength;
    NSArray *randomlyGeneratedKey = generateRandomPad(keyLength, 122-32);
    [teKeyTextField setStringValue:padArrayToString(randomlyGeneratedKey)];
    
    //NSLog(@"[Input String Length: %i :: Key Length: %i]", inputStringLength, keyLength);
}
-(IBAction)generateRandomPassphrase:(id)sender{
    HSKeyLibrary *keyObject = [[HSKeyLibrary alloc] initWithFileName:@"1984"];
    NSString *encryptionString = [[keyObject keysArray] objectAtIndex:(arc4random()%[[keyObject keysArray] count])];
    [teKeyTextField setStringValue:encryptionString];
}
-(IBAction)generateKeySelector:(id)sender{
    if ([teKeyTypeSelector selectedSegment]==0) {
        [self generateRandomKey:self];
    }else {
        [self generateRandomPassphrase:self];
    }
}
-(IBAction)oneTimePadEncryptText:(id)sender{
    NSString *stringToEncrypt = [[NSString alloc] initWithString:[teInputTextField stringValue]];
    NSString *keyString = [[NSString alloc] initWithString:[teKeyTextField stringValue]];
    HSTextEncryptor *encryptorObject = [[HSTextEncryptor alloc] initWithNSString:stringToEncrypt];
    NSString *encryptedString = [encryptorObject encryptProcessAutoSelector:keyString];
    [teOutputText setStringValue:encryptedString];
}
-(IBAction)onetimePadDecryptText:(id)sender{
    NSString *stringToDecrypt = [[NSString alloc] initWithString:[teInputTextField stringValue]];
    NSString *keyString = [[NSString alloc] initWithString:[teKeyTextField stringValue]];
    HSTextEncryptor *encryptorObject = [[HSTextEncryptor alloc] initWithNSString:stringToDecrypt];
    NSString *decryptedString = [encryptorObject decryptProcessAutoSelector:keyString];
    [teOutputText setStringValue:decryptedString]; 
}
-(IBAction)oneTimePadSelector:(id)sender{
    if ([teOperationSelector selectedSegment]==0) {
        [self oneTimePadEncryptText:self];
    }else {
        [self onetimePadDecryptText:self];
    }
}
/*Text in Image Encryption*/
-(IBAction)tiGenerateRandomKey:(id)sender{
    int inputStringLength = [[tiInputTextField stringValue] length];
    float lengthFraction = 1;
    if ([tiKeyLengthSelector selectedSegment]==0) {
        lengthFraction = 1;
    }else if ([tiKeyLengthSelector selectedSegment]==1) {
        lengthFraction = .5;
    }else {
        lengthFraction = .25;
    }
    int keyLength = lengthFraction*inputStringLength;
    NSArray *randomlyGeneratedKey = generateRandomPad(keyLength, 122-32);
    [tiKeyTextField setStringValue:padArrayToString(randomlyGeneratedKey)]; 
}
-(IBAction)tiGenerateRandomPassphrase:(id)sender{
    HSKeyLibrary *keyObject = [[HSKeyLibrary alloc] initWithFileName:@"1984"];
    NSString *encryptionString = [[keyObject keysArray] objectAtIndex:(arc4random()%[[keyObject keysArray] count])];
    [tiKeyTextField setStringValue:encryptionString];
}
-(IBAction)tiGenerateKeySelector:(id)sender{
    if ([tiKeyTypeSelector selectedSegment]==0) {
        [self tiGenerateRandomKey:self];
    }else if([tiKeyTypeSelector selectedSegment]==1){
        [self tiGenerateRandomPassphrase:self];
    }
}
-(IBAction)tiOneTimePadEncryptText:(id)sender{
    NSString *stringToEncrypt = [[NSString alloc] initWithString:[tiInputTextField stringValue]];
    NSString *keyString = [[NSString alloc] initWithString:[tiKeyTextField stringValue]];
    HSTextEncryptor *encryptorObject = [[HSTextEncryptor alloc] initWithNSString:stringToEncrypt];
    NSString *encryptedString = [encryptorObject encryptProcessAutoSelector:keyString];
    stringToProcess = encryptedString;
    [tiOutputTextField setStringValue:encryptedString];
}
-(IBAction)tiOnetimePadDecryptText:(id)sender{
    NSString *stringToDecrypt = [[NSString alloc] initWithString:stringToProcess];
    NSString *keyString = [[NSString alloc] initWithString:[tiKeyTextField stringValue]];
    HSTextEncryptor *encryptorObject = [[HSTextEncryptor alloc] initWithNSString:stringToDecrypt];
    NSString *decryptedString = [encryptorObject decryptProcessAutoSelector:keyString];
    [tiOutputTextField setStringValue:decryptedString]; 
}
-(IBAction)tiOneTimePadSelector:(id)sender{
    if ([tiOperationSelector selectedSegment]==0) {
        [self tiOneTimePadEncryptText:self];
    }else {
        [self tiOnetimePadDecryptText:self];
    }
}
-(IBAction)tiEncryptSteganography:(id)sender{
    NSLog(@"Text in Image Steganography encryption started.");
    [tiProgressIndicator setHidden:FALSE];
    [tiProgressIndicator startAnimation:self];
    
    [self tiOneTimePadEncryptText:self];
    NSData *imageData = [[NSData alloc] initWithData:[[tiInputImageWell image] TIFFRepresentation]];
    HSImageEncryptor    *imageObject = [[HSImageEncryptor alloc] initWithData:imageData];
    NSBitmapImageRep    *bitmapRep = [imageObject encryptImageWithBits:8 andString:stringToProcess];
    NSImage *imageToWell = [[NSImage alloc] initWithData:imageData];
    [tiOutputImageWell setImage:imageToWell];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory,NSUserDomainMask, YES);
    NSString *desktopPath = [paths objectAtIndex:0];
    
    if([tiOutputFormatSelector selectedSegment]==0){
        NSData *dataOutput = [bitmapRep representationUsingType:NSBMPFileType properties:nil];
        NSString *fullWriteString = [[NSString alloc] initWithFormat:@"%@/%@",desktopPath,@"EncryptedImage.bmp"];
        [dataOutput writeToFile:fullWriteString atomically: NO];
    }else if([tiOutputFormatSelector selectedSegment]==1){
        NSData *dataOutput = [bitmapRep representationUsingType:NSPNGFileType properties:nil];
        NSString *fullWriteString = [[NSString alloc] initWithFormat:@"%@/%@",desktopPath,@"EncryptedImage.png"];
        [dataOutput writeToFile:fullWriteString atomically: NO];
    }else if ([tiOutputFormatSelector selectedSegment]==2) {
        NSData *dataOutput = [bitmapRep representationUsingType:NSTIFFFileType properties:nil];
        NSString *fullWriteString = [[NSString alloc] initWithFormat:@"%@/%@",desktopPath,@"EncryptedImage.tiff"];
        [dataOutput writeToFile:fullWriteString atomically: NO];
    }
    
    [tiProgressIndicator setHidden:TRUE];
    [tiProgressIndicator stopAnimation:self];
    NSLog(@"Text in Image Steganography encryption finished.");
}
-(IBAction)tiDecryptSteganography:(id)sender{
    NSLog(@"Text in Image Steganography decryption started.");
    [tiProgressIndicator setHidden:FALSE];
    [tiProgressIndicator startAnimation:self];
    
    NSData *imageData = [[NSData alloc] initWithData:[[tiInputImageWell image] TIFFRepresentation]];
    HSImageEncryptor  *imageObject2 = [[HSImageEncryptor alloc] initWithData:imageData];
    NSString *stringOutput = [[NSString alloc] initWithString:[imageObject2 decryptImageWithBits:8]];
    NSLog(@"%@",stringOutput);
    stringToProcess = stringOutput;
    NSLog(@"String to Decrypt: %@",stringToProcess);
    [tiOutputTextField setStringValue:stringOutput];
    
    [self tiOnetimePadDecryptText:self];
    
    [tiProgressIndicator setHidden:TRUE];
    [tiProgressIndicator stopAnimation:self];
    NSLog(@"Text in Image Steganography decryption finished.");
}
-(IBAction)tiTextSteganographySelector:(id)sender{
    if ([tiOperationSelector selectedSegment]==0) {
        [self tiEncryptSteganography:self];
    }else {
        [self tiDecryptSteganography:self];
    }
}
-(IBAction)tiSizeCheck:(id)sender{
    NSData *imageToEncryptIn = [[NSData alloc] initWithData:[[tiInputImageWell image] TIFFRepresentation]];
    NSBitmapImageRep *imageToEncryptInBMP = [[NSBitmapImageRep alloc] initWithData:imageToEncryptIn];
    int availableSize = imageToEncryptInSizeInBits(imageToEncryptInBMP);
    NSString *analyzeString;
    int requiredSize = stringToBeEncryptedRequiredSize([tiInputTextField stringValue]);
    if (availableSize>requiredSize) {
        analyzeString = [[NSString alloc] initWithFormat:@"Available Space:\t%i \nRequired Space:\t%i \nText fits the available space.",availableSize,requiredSize];
        [tiProcessButton setEnabled:TRUE];
    }else {
        analyzeString = [[NSString alloc] initWithFormat:@"Available Space:\t%i \nRequired Space:\t%i \nText does not fit the available space.",availableSize,requiredSize];
        [tiProcessButton setEnabled:FALSE];
    }
    [tiAnalyzeLabel setStringValue:analyzeString];
}
/*Image in Image Encription*/
-(IBAction)iiEncryptImage:(id)sender{
    NSLog(@"Image in Image Encryption Started.");
    [iiProgressIndicator setHidden:FALSE];
    [iiProgressIndicator startAnimation:self];
    
    NSData *imageToEncryptIn = [[NSData alloc] initWithData:[[iiInputImageWell image] TIFFRepresentation]];
    NSData *imageToBeEncrypted = [[NSData alloc] initWithData:[[iiInputImageToBeEncryptedWell image] TIFFRepresentation]];
    
    NSBitmapImageRep *tempConversion = [[NSBitmapImageRep alloc] initWithData:imageToBeEncrypted];
    NSData *imageConvertedToEncrypt = [tempConversion representationUsingType:NSPNGFileType properties:NULL];
    
    HSImageEncryptor *imageEncryptorObject = [[HSImageEncryptor alloc] initWithData:imageToEncryptIn];
    NSBitmapImageRep *imageEncryptedBitmap = [imageEncryptorObject encryptImageWithBits:8 andData:imageConvertedToEncrypt];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory,NSUserDomainMask, YES);
    NSString *desktopPath = [paths objectAtIndex:0];
    
    
    if([iiOutputFormatSelector selectedSegment]==0){
        NSData *dataOutput = [imageEncryptedBitmap representationUsingType:NSBMPFileType properties:nil];
        NSString *fullWriteString = [[NSString alloc] initWithFormat:@"%@/%@",desktopPath,@"EncryptedImage.bmp"];
        [dataOutput writeToFile:fullWriteString atomically: NO];
    }else if([iiOutputFormatSelector selectedSegment]==1){
        NSData *dataOutput = [imageEncryptedBitmap representationUsingType:NSPNGFileType properties:nil];
        NSString *fullWriteString = [[NSString alloc] initWithFormat:@"%@/%@",desktopPath,@"EncryptedImage.png"];
        [dataOutput writeToFile:fullWriteString atomically: NO];
    }else if ([iiOutputFormatSelector selectedSegment]==2) {
        NSData *dataOutput = [imageEncryptedBitmap representationUsingType:NSTIFFFileType properties:nil];
        NSString *fullWriteString = [[NSString alloc] initWithFormat:@"%@/%@",desktopPath,@"EncryptedImage.tiff"];
        [dataOutput writeToFile:fullWriteString atomically: NO];
    }
    
    NSImage *imageEncrypted = [[NSImage alloc] init];
    [imageEncrypted addRepresentation:imageEncryptedBitmap];
    [iiOutputImageWell setImage:imageEncrypted];

    NSLog(@"Image in Image Encryption Finished.");
    [iiProgressIndicator setHidden:TRUE];
    [iiProgressIndicator stopAnimation:self];
}
-(IBAction)iiDecryptImage:(id)sender{
    NSLog(@"Image in Image Decryption Started.");
    [iiProgressIndicator setHidden:FALSE];
    [iiProgressIndicator startAnimation:self];
    
    NSData *encryptedImageData = [[NSData alloc] initWithData:[[iiInputImageWell image] TIFFRepresentation]];
    HSImageEncryptor *imageEncryptedObject = [[HSImageEncryptor alloc] initWithData:encryptedImageData];
    NSData *dataOutput = [imageEncryptedObject decryptImageDataWithBits:8];
    
    NSImage *imageEncrypted = [[NSImage alloc] initWithData:dataOutput];
    [iiOutputImageWell setImage:imageEncrypted];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory,NSUserDomainMask, YES);
    NSString *desktopPath = [paths objectAtIndex:0];
    NSString *fullWriteString = [[NSString alloc] initWithFormat:@"%@/%@",desktopPath,@"DecryptedImage.png"];
    [dataOutput writeToFile:fullWriteString atomically:NO];
    
    NSLog(@"Image in Image Encryption Finished.");
    [iiProgressIndicator setHidden:TRUE];
    [iiProgressIndicator stopAnimation:self];
}
-(IBAction)iiImageSteganographySelector:(id)sender{
    if ([iiOperationSelector selectedSegment]==0) {
        [self iiEncryptImage:self];
    }else {
        [self iiDecryptImage:self];
    }
}
-(IBAction)iiSizeCheck:(id)sender{
    NSData *imageToEncryptIn = [[NSData alloc] initWithData:[[iiInputImageWell image] TIFFRepresentation]];
    NSData *imageToBeEncrypted = [[NSData alloc] initWithData:[[iiInputImageToBeEncryptedWell image] TIFFRepresentation]];
    NSBitmapImageRep *imageToEncryptInBMP = [[NSBitmapImageRep alloc] initWithData:imageToEncryptIn];
    NSBitmapImageRep *imageToBeEncryptedBMP = [[NSBitmapImageRep alloc] initWithData:imageToBeEncrypted];
    int availableSize = imageToEncryptInSizeInBits(imageToEncryptInBMP);
    int requiredSize = imageToBeEncryptedRequiredSize(imageToBeEncryptedBMP, 8);
    NSString *analyzeString;
    if (availableSize>requiredSize) {
        analyzeString = [[NSString alloc] initWithFormat:@"Available Space:\t%i \nRequired Space:\t%i \nImage fits the available space.",availableSize,requiredSize];
        iiImageFits = TRUE;
        [iiProcessButton setEnabled:TRUE];
    }else {
        analyzeString = [[NSString alloc] initWithFormat:@"Available Space:\t%i \nRequired Space:\t%i \nImage does not fit the available space.",availableSize,requiredSize];
        [iiProcessButton setEnabled:FALSE];
    }
    
    [iiAnalyzeLabel setStringValue:analyzeString];
}

@end
