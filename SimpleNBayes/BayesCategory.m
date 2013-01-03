#import "BayesCategory.h"


@implementation BayesCategory {

}
- (id)init {
    self = [super init];
    if (self) {
        self.tokens = [[NSMutableDictionary alloc] init];
        self.examples = [[NSNumber alloc] initWithInt:0];
        self.totalTokens = [[NSNumber alloc] initWithInt:0];
    }

    return self;
}

- (NSNumber *)countForToken:(NSString *)token {
    NSNumber *count = [self.tokens objectForKey:token];
    return count == nil ? [[NSNumber alloc] initWithInt:0] : count;
}

- (void)incrementExamples {
    self.examples = [[NSNumber alloc] initWithInt:[self.examples intValue]+1];
}


- (void)addToken:(NSString *)token {
    NSNumber *countForToken = [self countForToken:token];
    [self.tokens setObject:[[NSNumber alloc] initWithInt:[countForToken intValue]+1] forKey:token];
    self.totalTokens = [[NSNumber alloc] initWithInt:[self.totalTokens intValue]+1];

}

- (void)deleteToken:(NSString *)token {
    NSNumber *countForToken = [self countForToken:token];
    if([countForToken intValue] > 0)
    {
        [self.tokens removeObjectForKey:token];
        self.totalTokens = [[NSNumber alloc] initWithInt:[self.totalTokens intValue]-1];
    }
}

@end