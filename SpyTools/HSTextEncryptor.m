//
//  HSTextEncryptor.m
//  SpyTools
//
//  Created by Chip on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HSTextEncryptor.h"

@implementation HSTextEncryptor

/*Initializers*/
-(id)init{
    return [self initWithNSString:NULL];
}
-(id)initWithNSString:(NSString *)initializerString{
    self = [super init];
    if(self){
        stringToProcess = initializerString;
        stringLength = [initializerString length];
    }
    NSLog(@"HSTextEncryptor Initialized with string: %@",stringToProcess);
    return self;
}
/*Accessors*/
-(NSString *)stringToProcess{
    NSLog(@"HSTextEncryptor Accessed: %@", stringToProcess);
    return stringToProcess;
}
-(int)stringLength{
    NSLog(@"HSTextEncryptor String Length: %i", stringLength);
    return stringLength;
}
/*Action Methods*/
-(NSString *)encryptStringToProcessWithKey:(NSString *)keyString{
    NSArray *keyArray = [[NSArray alloc] initWithArray:keyStringToKeyArray(keyString)];
    NSString *encryptedString = [[NSString alloc] initWithString:encryptUTF8StringWithPad(stringToProcess, keyArray)];
    NSLog(@"HSTextEncryptor Encrypted String: %@",encryptedString);
    return encryptedString;
}
-(NSString *)decryptStringToProcessWithKey:(NSString *)keyString{
    NSArray *keyArray = [[NSArray alloc] initWithArray:keyStringToKeyArray(keyString)];
    NSString *decryptedString = [[NSString alloc] initWithString:decryptUTF8StringWithPad(stringToProcess, keyArray)];
    NSLog(@"HSTextEncryptor Decrypted String: %@",decryptedString);
    return decryptedString;
}

@end