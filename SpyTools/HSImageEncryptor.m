//
//  HSImageEncryptor.m
//  SpyTools
//
//  Created by Chip on 4/18/12.
//  Copyright (c) 2012 __Héctor Sánchez__. All rights reserved.
//

#import "HSImageEncryptor.h"

@implementation HSImageEncryptor
@synthesize imageBitmapRep;
@synthesize imageWidth;
@synthesize imageHeight;
@synthesize bitsPerPixel;
@synthesize numberOfComponents;

/*Initializers*/
-(id)init{
    return [self initWithData:NULL];
}
-(id)initWithData:(NSData *)imageData{
    self = [super init];
    if(self){
        imageBitmapRep = [[NSBitmapImageRep alloc] initWithData:imageData];
        imageWidth = CGImageGetWidth([imageBitmapRep CGImage]);
        imageHeight = CGImageGetHeight([imageBitmapRep CGImage]);
        bitsPerPixel = [imageBitmapRep bitsPerPixel];
        numberOfComponents = [imageBitmapRep samplesPerPixel];
        NSLog(@"[%i,%i]::[bpp:%i - noc:%i]", imageWidth, imageHeight, bitsPerPixel, numberOfComponents);
    }
    return self;
}
/*Action Methods*/
-(NSBitmapImageRep *)encryptImageWithBits:(int)numberOfBits andString:(NSString *)stringToBeEncrypted{
    
    char *testChar = NSStringToCharArray(prepareStringForEncryption(stringToBeEncrypted));
    int sizeOfString = strlen(testChar);
    
    unsigned long tempPixelValues[numberOfComponents];
    
    int characterBitsIndex = 0;
    int characterNumberIndex = 0;
    
    NSMutableArray *characterBinary = [[NSMutableArray alloc] initWithArray:characterToBinaryArray(testChar[characterNumberIndex], numberOfBits)];
    for (int j=0; j<imageHeight; j++) {
        for (int i=0; i<imageWidth; i++) {
            /*Get current index components*/
            [[self imageBitmapRep] getPixel:tempPixelValues atX:i y:j];
            /*Process pixel's color components*/
            for (int k=0; k<numberOfComponents; k++) {
                
                /*Check if character bit index is higher or equal to the number of allowed bits*/
                if (characterBitsIndex>=(numberOfBits)) {
                    /*Reset bit index and increment character index*/
                    characterBitsIndex = 0;
                    characterNumberIndex++;
                    /*Move to next character*/
                    characterBinary = characterToBinaryArray(testChar[characterNumberIndex], numberOfBits);
                }
                
                /*Conversion of color component to binary array*/
                NSArray *tempComponentBitArray = [[NSArray alloc] initWithArray:characterToBinaryArray(tempPixelValues[k], numberOfBits)];
                /*Modification of the original pixel according to the character's current bit*/
                NSArray *tempModifiedBitArray = [[NSArray alloc] initWithArray:setBitWithArrayValue(tempComponentBitArray, characterBinary, characterBitsIndex, 0)];
                /*Conversion of the color component's bits to an integer and assignement to the components array*/
                tempPixelValues[k]=binaryArrayToCharacter(tempModifiedBitArray, numberOfBits);
                
                /*Check if the string has ended so that the array is repeated*/
                if (characterNumberIndex>=sizeOfString) {
                    characterNumberIndex = 0;
                }
                characterBitsIndex++;
            }
            
            [[self imageBitmapRep] setPixel:tempPixelValues atX:i y:j];
        }
    }
    free(testChar);
    NSLog(@"Data has been succesfully encrypted!");
    //NSData *dataOutput = [[self imageBitmapRep] representationUsingType:NSPNGFileType properties:nil];
    return [self imageBitmapRep];
}
-(NSString *)decryptImageWithBits:(int)numberOfBits{
    
    /*Declaration of reading variables*/
    unsigned long readTempPixelValues[numberOfComponents];
    NSMutableArray *readString = [[NSMutableArray alloc] init];
    NSMutableArray *readCharacterBinary = [[NSMutableArray alloc] initWithCapacity:numberOfBits];
    NSArray *readComponent;
    
    int readCharacterIndex = 0; 
    /*-----Read characters from image-----*/
    for (int j=0; j<imageHeight; j++){
        for (int i=0; i<imageWidth; i++) {
            
            /*Read current pixel's component values*/
            [imageBitmapRep getPixel:readTempPixelValues atX:i y:j];
            
            /*Add components LSB to character array*/
            for(int k=0; k<numberOfComponents; k++){
                readComponent = characterToBinaryArray(readTempPixelValues[k], numberOfBits);
                [readCharacterBinary insertObject:[readComponent objectAtIndex:0] atIndex:readCharacterIndex];
                
                if (readCharacterIndex>=7) {
                    [readString addObject:[NSNumber numberWithInt:binaryArrayToCharacter(readCharacterBinary, numberOfBits)]];
                    readCharacterIndex = 0;
                }else {
                    readCharacterIndex++;                
                }
            }
        }
    }
    
    NSString *readNSString = [[NSString alloc] initWithCString:NSArrayToCharArray(readString) encoding:4];
    return readNSString;
}

-(NSBitmapImageRep *)encryptImageWithBits:(int)numberOfBits andData:(NSData *)dataToBeEncrypted{
    
    int dataLength = [dataToBeEncrypted length];
    /*Creating buffer for data*/
    unsigned char testCharTemp[dataLength];
    [dataToBeEncrypted getBytes:testCharTemp];
    
    /*Data Length Header*/
    int sizeOfString = dataLength;
    NSArray *binaryLength = characterToBinaryArray(dataLength, dataLengthBits);
    //NSLog(@"%i::%@", dataLength, binaryLength);
    unsigned char testChar[dataLength+dataLengthBits];
    for (int i=0; i<dataLength+dataLengthBits; i++) {
        if (i<dataLengthBits) {
            testChar[i]=[[binaryLength objectAtIndex:i] intValue];
        }else {
            testChar[i]=testCharTemp[i-dataLengthBits];
        }
    }
    
    /*Image processing*/
    unsigned long tempPixelValues[numberOfComponents];
    int characterBitsIndex = 0;
    int characterNumberIndex = 0;
    NSMutableArray *characterBinary = [[NSMutableArray alloc] initWithArray:characterToBinaryArray(testChar[characterNumberIndex], numberOfBits)];
    for (int j=0; j<imageHeight; j++) {
        for (int i=0; i<imageWidth; i++) {
            /*Get current index components*/
            [[self imageBitmapRep] getPixel:tempPixelValues atX:i y:j];
            /*Process pixel's color components*/
            for (int k=0; k<numberOfComponents; k++) {
                /*Check if character bit index is higher or equal to the number of allowed bits*/
                if (characterBitsIndex>=(numberOfBits)) {
                    /*Reset bit index and increment character index*/
                    characterBitsIndex = 0;
                    characterNumberIndex++;
                    /*Move to next character*/
                    characterBinary = characterToBinaryArray(testChar[characterNumberIndex], numberOfBits);
                }
                
                /*Conversion of color component to binary array*/
                NSArray *tempComponentBitArray = [[NSArray alloc] initWithArray:characterToBinaryArray(tempPixelValues[k], numberOfBits)];
                /*Modification of the original pixel according to the character's current bit*/
                NSArray *tempModifiedBitArray = [[NSArray alloc] initWithArray:setBitWithArrayValue(tempComponentBitArray, characterBinary, characterBitsIndex, 0)];
                /*Conversion of the color component's bits to an integer and assignement to the components array*/
                tempPixelValues[k]=binaryArrayToCharacter(tempModifiedBitArray, numberOfBits);
                
                //NSLog(@"[%i,%i,%@]", binaryArrayToCharacter(tempComponentBitArray,8), binaryArrayToCharacter(tempModifiedBitArray, 8), [characterBinary objectAtIndex:characterBitsIndex]);
                
                /*Check if the string has ended so that the array is repeated*/
                if (characterNumberIndex>=sizeOfString) {
                    characterNumberIndex = 0;
                }
                characterBitsIndex++;
            }
            
            [[self imageBitmapRep] setPixel:tempPixelValues atX:i y:j];
        }
    }
    //free(testChar);
    NSLog(@"Data has been succesfully encrypted!");
    //NSData *dataOutput = [[self imageBitmapRep] representationUsingType:NSPNGFileType properties:nil];
    return [self imageBitmapRep];
}
-(NSData *)decryptImageDataWithBits:(int)numberOfBits{
    
    /*Declaration of reading variables*/
    unsigned long readTempPixelValues[numberOfComponents];
    NSMutableArray *readString = [[NSMutableArray alloc] init];
    NSMutableArray *readCharacterBinary = [[NSMutableArray alloc] initWithCapacity:numberOfBits];
    NSArray *readComponent;
    
    int readCharacterIndex = 0; 
    /*-----Read characters from image-----*/
    for (int j=0; j<imageHeight; j++){
        for (int i=0; i<imageWidth; i++) {
            
            /*Read current pixel's component values*/
            [imageBitmapRep getPixel:readTempPixelValues atX:i y:j];
            
            /*Add components LSB to character array*/
            for(int k=0; k<numberOfComponents; k++){
                readComponent = characterToBinaryArray(readTempPixelValues[k], numberOfBits);
                [readCharacterBinary insertObject:[readComponent objectAtIndex:0] atIndex:readCharacterIndex];
                
                if (readCharacterIndex>=7) {
                    /*Key Change for Decryption!!!!!!!!!*/
                    [readString addObject:[NSNumber numberWithInt:binaryArrayToCharacter(readCharacterBinary, numberOfBits)]];
                    readCharacterIndex = 0;
                }else {
                    readCharacterIndex++;                
                }
            }
        }
    }
    
    /*Raw array manipulation and final decryption*/
    NSMutableArray *lengthArray = [[NSMutableArray alloc] init];
    for (int i=0; i<dataLengthBits; i++) {
        [lengthArray addObject:[readString objectAtIndex:i]];
    }
    int dataLength = binaryArrayToCharacter(lengthArray, dataLengthBits);
    //NSLog(@"%i",dataLength);
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (int k=dataLengthBits; k<[readString count]; k++) {
        [dataArray addObject:[readString objectAtIndex:k]];
    }
    
    unsigned char outputBuffer[dataLength];
    //*outputBuffer = NSArrayToUnsignedCharArray(decryptedImageArray);
    for (int i=0; i<dataLength; i++) {
        outputBuffer[i]=[[dataArray objectAtIndex:i] intValue];
        //NSLog(@"IO: [%i,%@,%i]@%i",inputBuffer[i],[decryptedImageArray objectAtIndex:i],outputBuffer[i],i);
    }
    
    NSLog(@"Data has been succesfully decrypted");
    NSData *dataOutput = [[NSData alloc] initWithBytes:outputBuffer length:dataLength];
    return dataOutput;
}

-(NSBitmapImageRep *)encryptImageWithBits:(int)numberOfBits andData:(NSData *)dataToBeEncrypted andKey:(NSString *)keyString{
    NSLog(@"Encrypting with key: %@",keyString);
    
    /*Creating buffer for data*/
    int dataLength = [dataToBeEncrypted length];
    unsigned char testCharTemp[dataLength];
    [dataToBeEncrypted getBytes:testCharTemp];
    
    /*Data Length Header*/
    int sizeOfString = dataLength;
    NSArray *binaryLength = characterToBinaryArray(dataLength, dataLengthBits);
    //NSLog(@"%i::%@", dataLength, binaryLength);
    unsigned char testChar[dataLength+dataLengthBits];
    for (int i=0; i<dataLength+dataLengthBits; i++) {
        if (i<dataLengthBits) {
            testChar[i]=[[binaryLength objectAtIndex:i] intValue];
        }else {
            testChar[i]=testCharTemp[i-dataLengthBits];
        }
    }
    
    /*Encryption*/
    NSArray *keyArray = [[NSArray alloc] initWithArray:NSStringToKeyArray(prepareStringForEncryption(keyString))];
    int j=0;
    for (int i=0; i<sizeof(testChar)/sizeof(unsigned char); i++) {
        testChar[i]=testChar[i]+[[keyArray objectAtIndex:j] intValue];
        if (j<[keyArray count]-1) {
            j++;
        }else {
            j=0;
        }
    }
    
    /*Image processing*/
    unsigned long tempPixelValues[numberOfComponents];
    int characterBitsIndex = 0;
    int characterNumberIndex = 0;
    NSMutableArray *characterBinary = [[NSMutableArray alloc] initWithArray:characterToBinaryArray(testChar[characterNumberIndex], numberOfBits)];
    for (int j=0; j<imageHeight; j++) {
        for (int i=0; i<imageWidth; i++) {
            /*Get current index components*/
            [[self imageBitmapRep] getPixel:tempPixelValues atX:i y:j];
            /*Process pixel's color components*/
            for (int k=0; k<numberOfComponents; k++) {
                /*Check if character bit index is higher or equal to the number of allowed bits*/
                if (characterBitsIndex>=(numberOfBits)) {
                    /*Reset bit index and increment character index*/
                    characterBitsIndex = 0;
                    characterNumberIndex++;
                    /*Move to next character*/
                    characterBinary = characterToBinaryArray(testChar[characterNumberIndex], numberOfBits);
                }
                
                /*Conversion of color component to binary array*/
                NSArray *tempComponentBitArray = [[NSArray alloc] initWithArray:characterToBinaryArray(tempPixelValues[k], numberOfBits)];
                /*Modification of the original pixel according to the character's current bit*/
                NSArray *tempModifiedBitArray = [[NSArray alloc] initWithArray:setBitWithArrayValue(tempComponentBitArray, characterBinary, characterBitsIndex, 0)];
                /*Conversion of the color component's bits to an integer and assignement to the components array*/
                tempPixelValues[k]=binaryArrayToCharacter(tempModifiedBitArray, numberOfBits);
                
                //NSLog(@"[%i,%i,%@]", binaryArrayToCharacter(tempComponentBitArray,8), binaryArrayToCharacter(tempModifiedBitArray, 8), [characterBinary objectAtIndex:characterBitsIndex]);
                
                /*Check if the string has ended so that the array is repeated*/
                if (characterNumberIndex>=sizeOfString) {
                    characterNumberIndex = 0;
                }
                characterBitsIndex++;
            }
            
            [[self imageBitmapRep] setPixel:tempPixelValues atX:i y:j];
        }
    }
    //free(testChar);
    NSLog(@"Data has been succesfully encrypted!");
    //NSData *dataOutput = [[self imageBitmapRep] representationUsingType:NSPNGFileType properties:nil];
    return [self imageBitmapRep];
}
-(NSData *)decryptImageDataWithBits:(int)numberOfBits andKey:(NSString *)keyString{
    NSLog(@"Decrypting with key: %@",keyString);
    /*Declaration of reading variables*/
    unsigned long readTempPixelValues[numberOfComponents];
    NSMutableArray *readString = [[NSMutableArray alloc] init];
    NSMutableArray *readCharacterBinary = [[NSMutableArray alloc] initWithCapacity:numberOfBits];
    NSArray *readComponent;
    
    int readCharacterIndex = 0; 
    /*-----Read characters from image-----*/
    for (int j=0; j<imageHeight; j++){
        for (int i=0; i<imageWidth; i++) {
            
            /*Read current pixel's component values*/
            [imageBitmapRep getPixel:readTempPixelValues atX:i y:j];
            
            /*Add components LSB to character array*/
            for(int k=0; k<numberOfComponents; k++){
                readComponent = characterToBinaryArray(readTempPixelValues[k], numberOfBits);
                [readCharacterBinary insertObject:[readComponent objectAtIndex:0] atIndex:readCharacterIndex];
                
                if (readCharacterIndex>=7) {
                    /*Key Change for Decryption!!!!!!!!!*/
                    [readString addObject:[NSNumber numberWithInt:binaryArrayToCharacter(readCharacterBinary, numberOfBits)]];
                    readCharacterIndex = 0;
                }else {
                    readCharacterIndex++;                
                }
            }
        }
    }
    
    /*Decryption*/
    NSArray *keyArray = [[NSArray alloc] initWithArray:NSStringToKeyArray(prepareStringForEncryption(keyString))];
    int j=0;
    for (int i=0; i<[readString count]; i++) {
        int phased = [[readString objectAtIndex:i] intValue]-[[keyArray objectAtIndex:j] intValue];
        [readString replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:phased]];
        if (j<[keyArray count]-1) {
            j++;
        }else {
            j=0;
        }
    }
    
    /*Raw array manipulation and final decryption*/
    NSMutableArray *lengthArray = [[NSMutableArray alloc] init];
    for (int i=0; i<dataLengthBits; i++) {
        [lengthArray addObject:[readString objectAtIndex:i]];
    }
    int dataLength = binaryArrayToCharacter(lengthArray, dataLengthBits);
    //NSLog(@"%i",dataLength);
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (int k=dataLengthBits; k<[readString count]; k++) {
        [dataArray addObject:[readString objectAtIndex:k]];
    }
    
    unsigned char outputBuffer[dataLength];
    //*outputBuffer = NSArrayToUnsignedCharArray(decryptedImageArray);
    for (int i=0; i<dataLength; i++) {
        outputBuffer[i]=[[dataArray objectAtIndex:i] intValue];
        //NSLog(@"IO: [%i,%@,%i]@%i",inputBuffer[i],[decryptedImageArray objectAtIndex:i],outputBuffer[i],i);
    }
    
    NSLog(@"Data has been succesfully decrypted");
    NSData *dataOutput = [[NSData alloc] initWithBytes:outputBuffer length:dataLength];
    return dataOutput;
}

@end