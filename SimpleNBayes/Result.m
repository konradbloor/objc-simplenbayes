#import "Result.h"


@implementation Result {

}
- (id)initWithClassificationResult:(NSDictionary *)classificationResult {
    self = [super init];
    if (self) {
        _classificationResult = classificationResult;
    }

    return self;
}

- (double)probabilityForClass:(NSString *)className {
    NSNumber *probability = [self.classificationResult objectForKey:className];
    return probability == nil ? 0 : [probability doubleValue];
}

- (NSString *)highestProbabilityClass
{
    double highestProbability = 0;
    NSString *categoryWithHighestProbability = nil;

    for(NSString *category in self.classificationResult) {
        double categoryProbability = [self probabilityForClass:category];
        if (categoryProbability >= highestProbability) {
            highestProbability = categoryProbability;
            categoryWithHighestProbability = category;
        }
    }

    return categoryWithHighestProbability;
}

@end