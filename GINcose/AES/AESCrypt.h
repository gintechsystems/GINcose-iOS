//
//  AESCrypt.h
//  GINcose
//
//  Created by Joe Ginley on 3/9/17.
//  Copyright © 2017 GINtech Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AESCrypt : NSObject

NS_ASSUME_NONNULL_BEGIN

+ (nullable NSData *)encryptData:(NSData *)data usingKey:(NSData *)key error:(NSError **)error;

NS_ASSUME_NONNULL_END

@end
