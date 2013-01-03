#import <Foundation/Foundation.h>


@interface BayesCategory : NSObject

@property (nonatomic,retain) NSMutableDictionary *tokens;
@property (nonatomic,retain) NSNumber *examples;
@property (nonatomic,retain) NSNumber *totalTokens;

- (NSNumber *)countForToken:(NSString *)token;
- (void)incrementExamples;
- (void)addToken:(NSString *)token;
- (void)deleteToken:(NSString *)token;

@end