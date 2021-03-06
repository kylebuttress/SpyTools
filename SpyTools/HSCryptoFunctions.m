//
//  HSCryptoModel.m
//  SpyTools
//
//  Created by Chip on 4/17/12.
//  Copyright (c) 2012 __Héctor Sánchez__. All rights reserved.
//

#import "HSCryptoFunctions.h"

@implementation HSCryptoFunctions

/*Text Encryption Functions*/
/*One Time Pad*/
int fixEncryptToPrintableUTF8(int summValue, int highPrintable, int lowPrintable){
    /*Corrects the value of the encrypted character if it lies beyond the printable characters set*/
    return ((summValue-lowPrintable) % (highPrintable-lowPrintable))+lowPrintable;
}
int fixDecryptToPrintableUTF8(int summValue, int highPrintable, int lowPrintable){
    /*Corrects the value of the decrypted character if it lies beyond the printable characters set*/
    int rotateTimes = abs(summValue-lowPrintable)/((highPrintable-lowPrintable));
    if (abs(summValue-lowPrintable)%(highPrintable-lowPrintable)==0) {
        summValue = lowPrintable;
    }
    if ((summValue-lowPrintable)<0) {
        summValue=(rotateTimes+1)*(highPrintable-lowPrintable)+summValue;
    }
    return summValue;
}
NSArray *generateRandomPad(int padSize, int maxNumber){
    /*Generates a random key given the size and the maximum allowed number of values each part of the key can have*/
    NSMutableArray *phaseArray = [[NSMutableArray alloc] initWithCapacity:padSize];
    for (int i=0; i<padSize; i++) {
        [phaseArray addObject:[[NSNumber alloc] initWithInt:arc4random() % maxNumber+1]];
    }
    return phaseArray;
}
NSString *generateRandomKey(int keyLength, int maxNumber){
    /*Returns a random passphrase from the key array*/
    NSArray *keyArray = [[NSArray alloc] initWithArray:generateRandomPad(keyLength, maxNumber)];
    char *keyCharArray = NSArrayToCharArray(keyArray);
    NSLog(@"%s",keyCharArray);
    NSString *returnString = [[NSString alloc] initWithCString:keyCharArray encoding:4];
    return returnString;
}
NSString *encryptUTF8StringWithPad(NSString *inputString, NSArray *padArray){
    /*Encrypts a string given a key in the form of an array*/
    NSString *preparedString = [[NSString alloc] initWithString:inputString];
    int stringLength = [preparedString length];
    int tempPhase = 0;
    char *tempCString = (char *)malloc(stringLength*sizeof(char)+sizeof(char));
    strcpy(tempCString, [preparedString cStringUsingEncoding:4]);
    
    int j=0;
    for (int i=0; i<(stringLength); i++) {
        tempPhase = tempCString[i]+[[padArray objectAtIndex:j] intValue];
        tempCString[i]= fixEncryptToPrintableUTF8(tempPhase,126,32);
        if (j<[padArray count]-1) {
            j++;
        }else {
            j=0;
        }
    }
    NSString *returnString = [[NSString alloc] initWithCString:tempCString encoding:4];
    free(tempCString);
    return returnString;
}
NSString *decryptUTF8StringWithPad(NSString *inputString, NSArray *padArray){
    /*Encrypts a string given a key in the form of an array*/
    int stringLength = [inputString length];
    int tempPhase = 0;
    char *tempCString = (char *)malloc(stringLength*sizeof(char)+sizeof(char));
    strcpy(tempCString, [inputString cStringUsingEncoding:4]);
    
    int j=0;
    for (int i=0; i<(stringLength); i++) {
        tempPhase = tempCString[i]-[[padArray objectAtIndex:j] intValue];
        tempCString[i]= fixDecryptToPrintableUTF8(tempPhase,126,32);
        //Fix index for small pad (if the pad is smaller than the text the pad is repeated)
        if (j<[padArray count]-1) {
            j++;
        }else {
            j=0;
        }
    }
    NSString *returnString = [[NSString alloc] initWithCString:tempCString encoding:4];
    free(tempCString);
    return returnString;
}
NSString *padArrayToString(NSArray *padArray){
    /*Converts a key array to a string*/
    NSMutableString *arrayString = [[NSMutableString alloc] init];
    for (int i=0; i<[padArray count]; i++) {
        [arrayString appendFormat:@"%i",[[padArray objectAtIndex:i] intValue]];
        if (i<[padArray count]-1) {
            [arrayString appendString:@","];
            
        }
    }
    return arrayString;
}
NSArray *keyStringToKeyArray(NSString *stringToSplit){
    /*Converts a string to a key array*/
    NSArray *tempArray = [[NSArray alloc] initWithArray:[stringToSplit componentsSeparatedByString:@","]];
    NSMutableArray *tempIntArray = [[NSMutableArray alloc] init];
    for (int i=0; i<[tempArray count]; i++) {
        [tempIntArray addObject:[[NSNumber alloc] initWithInt:[[tempArray objectAtIndex:i] intValue]]];
    }
    return tempIntArray;
}
NSString *prepareStringForEncryption(NSString *inputString){
    /*Prepares a string for encryption*/
    NSString *myString = inputString;
    NSData *stringData = [myString dataUsingEncoding: NSASCIIStringEncoding allowLossyConversion: YES];
    NSString *cleanString = [[NSString alloc] initWithData: stringData encoding: NSASCIIStringEncoding];
    return cleanString;
}
NSArray *NSStringToKeyArray(NSString *inputString){
    /*Converts a string into an array that can be used ass an encryption key*/
    char *encryptionCharArray = NSStringToCharArray(inputString);
    NSMutableArray *keyArray = [[NSMutableArray alloc] initWithCapacity:[inputString length]];
    for (int j=0; j<[inputString length]; j++) {
        [keyArray addObject:[NSNumber numberWithInt:encryptionCharArray[j]]];
    }
    return keyArray;
}
/*Substitution Cypher*/
NSArray *generateAllowedCharactersArray(int minUTF, int maxUTF){
    /*Generates an array with the allowed C character values*/
    NSMutableArray *allowedCharactersArray = [[NSMutableArray alloc] initWithCapacity:(maxUTF-minUTF)];
    for(int i=minUTF; i<maxUTF;i++){
        [allowedCharactersArray addObject:[NSNumber numberWithInt:i]];
    }
    return allowedCharactersArray;
}
NSArray *generateRequiredCharactersArray(NSString *stringToProcess){
    char *stringToBeEncrypted = NSStringToCharArray(prepareStringForEncryption(stringToProcess));
    NSMutableArray *requiredCharactersArray = [[NSMutableArray alloc] init];
    for(int i=0;i<strlen(stringToBeEncrypted);i++){
        int counter = 0;
        for(int k=0;k<[requiredCharactersArray count];k++){
            if(stringToBeEncrypted[i]==[[requiredCharactersArray objectAtIndex:k] intValue]){
                counter++;
            }
        }
        if(counter==0){
            [requiredCharactersArray addObject:[NSNumber numberWithInt:stringToBeEncrypted[i]]];
        }
    }
    NSLog(@"Required Characters:%@",requiredCharactersArray);
    return requiredCharactersArray;
}
NSArray *generateRandomSubstitutionKey(NSArray *requiredCharactersArray, NSArray *allowedCharactersArray){
    NSMutableArray *mutableAllowedCharactersArray = [[NSMutableArray alloc] initWithArray:allowedCharactersArray];
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];
    for (int i=0; i<[requiredCharactersArray count]; i++) {
        int randomValue = arc4random()%[mutableAllowedCharactersArray count];
        [keyArray addObject:[mutableAllowedCharactersArray objectAtIndex:randomValue]];
        [mutableAllowedCharactersArray removeObjectAtIndex:randomValue];
    }
    NSLog(@"Substitution Key: %@",keyArray); 
    return keyArray;
}
NSString *encryptSubstitution(NSString *stringToBeEncryptedIn, NSArray *requiredCharactersArray, NSArray *keyArray){
    char *stringToBeEncrypted = NSStringToCharArray(prepareStringForEncryption(stringToBeEncryptedIn));
    //NSLog(@"%s",stringToBeEncrypted);
    for (int i=0; i<strlen(stringToBeEncrypted); i++) {
        for (int j=0; j<[requiredCharactersArray count]; j++) {
            if (stringToBeEncrypted[i]==[[requiredCharactersArray objectAtIndex:j] intValue]) {
                //NSLog(@"[%c (%i) = %c (%i)]",stringToBeEncrypted[i],stringToBeEncrypted[i],[[keyArray objectAtIndex:j] intValue],[[keyArray objectAtIndex:j] intValue]);
                stringToBeEncrypted[i]=[[keyArray objectAtIndex:j] intValue];
                break;
            }
        }
    }
    NSString *returnString = [[NSString alloc] initWithCString:stringToBeEncrypted encoding:4];
    NSLog(@"%@", returnString);
    return returnString;
}
NSString *decryptSubstitution(NSString *stringToBeDecryptedIn, NSArray *requiredCharactersArray, NSArray *keyArray){
    char *stringToBeEncrypted = NSStringToCharArray(prepareStringForEncryption(stringToBeDecryptedIn));
    for (int i=0; i<strlen(stringToBeEncrypted); i++) {
        for (int j=0; j<[requiredCharactersArray count]; j++) {
            if (stringToBeEncrypted[i]==[[keyArray objectAtIndex:j] intValue]) {
                stringToBeEncrypted[i]=[[requiredCharactersArray objectAtIndex:j] intValue];
                //NSLog(@"[%c (%i) = %c (%i)]",stringToBeEncrypted[i],stringToBeEncrypted[i],[[keyArray objectAtIndex:j] intValue],[[keyArray objectAtIndex:j] intValue]);
                break;
            }
        }
    }
    NSString *returnString = [[NSString alloc] initWithCString:stringToBeEncrypted encoding:4];
    NSLog(@"%@", returnString);
    return returnString;
}

/*Image Encryption Functions*/
char *NSStringToCharArray(NSString *inputString){
    /*Converts a NSString object to a char array*/
    NSString *preparedString = [[NSString alloc] initWithString:prepareStringForEncryption(inputString)];
    int stringLength = [preparedString length];
    char *tempCString = (char *)malloc(stringLength*sizeof(char)+sizeof(char));
    strcpy(tempCString, [preparedString cStringUsingEncoding:4]);
    return tempCString;
    /*Remember to free char array after using*/
}
char *NSArrayToCharArray(NSArray *inputArray){
    int stringLength = [inputArray count];
    char *tempCString = (char *)malloc(stringLength*sizeof(char)+sizeof(char));
    for (int i=0; i<stringLength; i++) {
        tempCString[i] = [[inputArray objectAtIndex:i] intValue];
    }
    /*Remember to free char array after using*/
    return tempCString;
}
NSMutableArray *characterToBinaryArray(int characterToConvert, int bitsNumber){
    int mask = 1;
    NSMutableArray *bitsArray = [[NSMutableArray alloc] initWithCapacity:bitsNumber];
    for (int i = 0; i<bitsNumber; i++) {
        if((characterToConvert&mask)>0){
            [bitsArray addObject:[[NSNumber alloc] initWithInt:1]];
        }else {
            [bitsArray addObject:[[NSNumber alloc] initWithInt:0]];
        }
        mask = 2*mask;
    }
    return bitsArray;
}
int binaryArrayToCharacter(NSArray *bitsArray, int bitsNumber){
    int characterValue = 0;
    int mask = 1;
    for (int i = 0; i<bitsNumber; i++) {
        characterValue = mask*[[bitsArray objectAtIndex:i] intValue] + characterValue;
        mask=2*mask;
    }
    return characterValue;
}
NSArray *setBitWithArrayValue(NSArray *inputArray, NSArray *modifierArray, int bitInput, int bitReplaced){
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (int i = 0; i<[inputArray count]; i++) {
        if (i==bitReplaced) {
            [returnArray addObject:[modifierArray objectAtIndex:bitInput]];
        }else {
            [returnArray addObject:[inputArray objectAtIndex:i]];
        }
    }
    return returnArray;
}
int checkIndex(int maxValue, int indexValue){
    if (indexValue>=maxValue-1){
        return 0;
    }else{
        return indexValue+1;
    }
}
NSString *bitArrayDescriptor(NSArray *inputArray){
    NSMutableString *outputString = [[NSMutableString alloc] initWithString:@"["];
    int arraySize = [inputArray count]-1;
    for(int i=0; i<=arraySize; i++){
        [outputString appendFormat:@"%i", [[inputArray objectAtIndex:(arraySize-i)] intValue]];
    }
    [outputString appendFormat:@"]"];
    return outputString;
}
int imageToEncryptInSizeInBits(NSBitmapImageRep *imageToAnalyze){
    int imageWidth = CGImageGetWidth([imageToAnalyze CGImage]);
    int imageHeight = CGImageGetHeight([imageToAnalyze CGImage]);
    return imageWidth*imageHeight*[imageToAnalyze samplesPerPixel];
}
int imageToBeEncryptedRequiredSize(NSBitmapImageRep *imageToAnalyze, int numberOfBits){
    int imageWidth = CGImageGetWidth([imageToAnalyze CGImage]);
    int imageHeight = CGImageGetHeight([imageToAnalyze CGImage]);
    return imageWidth*imageHeight*[imageToAnalyze samplesPerPixel]*numberOfBits+dataLengthBits;
}
int stringToBeEncryptedRequiredSize(NSString *stringToAnalyze){
    return [stringToAnalyze length]*8;
}
float calculateCompressionFactor(NSData *imageToEncryptIn, NSData *imageToBeEncrypted){
    NSBitmapImageRep *imageToEncryptInBMP = [[NSBitmapImageRep alloc] initWithData:imageToEncryptIn];
    NSBitmapImageRep *imageToBeEncryptedBMP = [[NSBitmapImageRep alloc] initWithData:imageToBeEncrypted];
    
    int availableSize = imageToEncryptInSizeInBits(imageToEncryptInBMP);
    int requiredSize=0;
    
    BOOL finishedFlag = FALSE;
    float compressionFactor=1;
    
    
    while (!finishedFlag) {
        NSLog(@"Compression Factor: %f", compressionFactor);
        compressionFactor = compressionFactor-0.05;
        NSDictionary* jpegOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithDouble:compressionFactor], NSImageCompressionFactor,
                                     [NSNumber numberWithBool:NO], NSImageProgressive,
                                     nil];
        NSData *imageBeEncryptedConverted = [imageToBeEncryptedBMP representationUsingType:NSJPEGFileType properties:jpegOptions];
        requiredSize = [imageBeEncryptedConverted length]*8+30;
        
        if (requiredSize<availableSize) {
            NSLog(@"Compression Factor: %f", compressionFactor);
            finishedFlag = TRUE;
        }
        if (compressionFactor<0) {
            break;
        }
    }
    return compressionFactor;
}
unsigned char *encryptCharArrayAllowingOverflow(unsigned char *charArray, NSString *keyString){
    NSArray *keyArray = [[NSArray alloc] initWithArray:NSStringToKeyArray(keyString)];
    int j=0;
    for (int i=0; i<sizeof(charArray)/sizeof(unsigned char); i++) {
        charArray[i]=charArray[i]+[[keyArray objectAtIndex:j] intValue];
        if (j<[keyArray count]-1) {
            j++;
        }else {
            j=0;
        }
    }
    return charArray;
}

/*Prototypes*/
/*unsigned char NSArrayToUnsignedCharArray(NSArray *inputArray){
    int length = [inputArray count];
    unsigned char outputBuffer[length];
    for (int i=0; i<length; i++) {
        outputBuffer[i]=[[inputArray objectAtIndex:i] intValue];
        //NSLog(@"IO: [%i,%@,%i]@%i",inputBuffer[i],[decryptedImageArray objectAtIndex:i],outputBuffer[i],i);
    }
    return *outputBuffer;
}*/
NSArray *NSBitmapImageRepToNSArray(NSBitmapImageRep *inputImage, int numberOfComponents){
    
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    int imageWidth = CGImageGetWidth([inputImage CGImage]);
    int imageHeight = CGImageGetHeight([inputImage CGImage]);
    
    unsigned long tempPixelValues[numberOfComponents];
    
    [imageArray addObject:[NSNumber numberWithInt:imageWidth]];
    [imageArray addObject:[NSNumber numberWithInt:imageHeight]];
    
    for (int j=0; j<imageHeight; j++) {
        for (int i=0; i<imageWidth; i++) {
            [inputImage getPixel:tempPixelValues atX:i y:j];
            for (int k=0; k<numberOfComponents; k++) {
                //NSLog(@"[%i,%i]::[%i]",j,i,k);
                [imageArray addObject:[NSNumber numberWithInt:tempPixelValues[k]]];
            }
        }
    }
    return imageArray;    
}
NSBitmapImageRep *NSArrayToNSBitmapImageRep(NSArray *inputArray, int numberOfComponents){
    NSBitmapImageRep *image = [[NSBitmapImageRep alloc] init];
    
    int imageWidth = [[inputArray objectAtIndex:0] intValue];
    int imageHeight = [[inputArray objectAtIndex:1] intValue];
    
    unsigned long tempPixelValues[numberOfComponents];
    
    int arrayIndex = 2;
    
    for (int j=0; j<imageHeight; j++) {
        for (int i=0; i<imageWidth; i++) {
            for (int k=0; k<numberOfComponents; k++) {
                tempPixelValues[k] = [[inputArray objectAtIndex:arrayIndex] intValue];
                arrayIndex++;
            }
            [image setPixel:tempPixelValues atX:i y:j];
        }
    }
    
    return image;
}



@end
