//
//  AESCrypt.m
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

#import "AESCrypt.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation AESCrypt

+ (NSData *)encryptData:(NSData *)data usingKey:(NSData *)key error:(NSError * _Nullable __autoreleasing *)error
{
    NSMutableData *dataOut = [[NSMutableData alloc] initWithCapacity:16];
    
    CCCryptorStatus status = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES,
                                     kCCOptionECBMode,
                                     key.bytes,
                                     key.length,
                                     NULL,
                                     data.bytes,
                                     data.length,
                                     dataOut.mutableBytes,
                                     dataOut.length,
                                     NULL);
    
    return status == kCCSuccess ? dataOut : nil;
}

@end
