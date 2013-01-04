#import "ClassificationEntry.h"

@implementation ClassificationEntry

- (id)initWithName:(NSString *)categoryName andProbability:(NSNumber *)guessProbability {
    self = [super init];
    if (self) {
        self.name = categoryName;
        self.probability = guessProbability;
    }
    return self;
}

- (NSString *)getPercentage
{
    return [NSString stringWithFormat:@"%.1f%%", [self.probability floatValue]*100];
}

- (NSComparisonResult)compare:(ClassificationEntry *)anotherGuess
{
    return [anotherGuess.probability compare:self.probability];
}

- (double)probabilityAsDouble
{
    return self.probability == nil ? 0 : [self.probability doubleValue];
}


@end