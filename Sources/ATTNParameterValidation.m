//
//  ATTNParameterValidation.m
//  Example
//
//  Created by Olivia Kim on 11/22/22.
//

#import <Foundation/Foundation.h>
#import "ATTNParameterValidation.h"


@implementation ATTNParameterValidation


+ (bool)isNotNil:(nullable NSObject *)inputValue {
  return ![ATTNParameterValidation isNil:inputValue];
}

+ (bool)isNil:(nullable NSObject *)inputValue {
  return inputValue == nil || [inputValue isKindOfClass:[NSNull class]];
}

+ (bool)isString:(nullable NSObject *)inputValue {
  return [inputValue isKindOfClass:[NSString class]];
}

+ (bool)isEmpty:(nullable NSString *)inputValue {
  return [inputValue length] == 0;
}

+ (bool)isStringAndNotEmpty:(nullable NSObject *)inputValue {
  return ([inputValue isKindOfClass:[NSString class]] && [(NSData *)inputValue length] > 0);
}

+ (void)verifyNotNil:(nonnull NSObject *)inputValue inputName:(nonnull const NSString *)inputName {
  if ([ATTNParameterValidation isNil:inputValue]) {
    [NSException raise:@"Input Was Nil" format:@"%@ should be non-nil", inputName];
  }
}

+ (void)verifyStringOrNil:(nullable NSString *)inputValue inputName:(nonnull const NSString *)inputName {
  if ([ATTNParameterValidation isNotNil:inputValue] && ![ATTNParameterValidation isStringAndNotEmpty:inputValue]) {
      [NSException raise:@"Bad Identifier" format:@"%@ should be a non-empty NSString", inputName];
    }
}

+ (void)verifyString:(nullable NSString *)inputValue inputName:(nonnull const NSString *)inputName {
  if ([ATTNParameterValidation isNil:inputValue]) {
    return;
  }
  if (![ATTNParameterValidation isString:inputValue]) {
    [NSException raise:@"Bad Identifier" format:@"%@ should be NSString", inputName];
  }
  if ([ATTNParameterValidation isEmpty:inputValue]) {
    NSLog(@"Identifier %@ should be non-empty", inputName);
  }
}

+ (void)verify1DStringDictionaryOrNil:(nullable NSDictionary *)inputValue inputName:(nonnull const NSString *)inputName {
  if (![ATTNParameterValidation isNotNil:inputValue])
    return;

  if (![inputValue isKindOfClass:[NSDictionary class]]) {
    [NSException raise:@"Bad Identifier" format:@"%@ should be of form NSDictionary<NSString *, NSString *> *", inputName];
  }

  for (id key in inputValue) {
    [ATTNParameterValidation verifyStringOrNil:[inputValue objectForKey:key] inputName:[NSString stringWithFormat:@"%@[%@]", inputName, key]];
  }
}


@end
