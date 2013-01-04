#import <SimpleNBayes/ClassificationResult.h>
#import <SimpleNBayes/BayesCategory.h>
#import "SimpleNBayes.h"

@implementation SimpleNBayes


//todo bitmask?
- (id)initWithBinarized:(BOOL)ifBinarized debug:(BOOL)ifDebug logVocab:(BOOL)ifLogVocab assumeUniform:(BOOL)ifAssumeUniform  {
    self = [super init];
    if (self) {
        self.debug = ifDebug;
        self.k = [[NSNumber alloc] initWithInt:1];
        self.binarized = ifBinarized;
        self.logVocab = ifLogVocab;
        self.assumeUniform = ifAssumeUniform;
        self.vocab = [[NSMutableDictionary alloc] init];
        self.data = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (id)init {
    return [self initWithBinarized:NO debug:NO logVocab:NO assumeUniform:NO];
}

- (void)purgeLessThan:(int)threshold
{
    NSMutableArray *tokensToRemoveFromVocab = [[NSMutableArray alloc] init];
    for(NSString *token in [self.vocab allKeys]) {
        int count = 0;
        for(BayesCategory *category in [self.data allValues])
        {
            count += [[category countForToken:token] intValue];
        }

        if(count < threshold)
        {
            for(BayesCategory *category in [self.data allValues]) {
                [category deleteToken:token];
            }
            [tokensToRemoveFromVocab addObject:token];
        }
    }

    [self.vocab removeObjectsForKeys:tokensToRemoveFromVocab];
}


- (BayesCategory *)getCategoryForName:(NSString *)categoryName {
    BayesCategory *category = [self.data objectForKey:categoryName];
    if (category == nil) {
        category = [[BayesCategory alloc] init];
        [self.data setObject:category forKey:categoryName];
    }
    return category;
}

- (void)train:(NSArray *)tokensToTrain forCategory:(NSString *)category {

    BayesCategory *categoryData = [self getCategoryForName:category];
    [categoryData incrementExamples];

    if(self.binarized) {  //we only want unique values in array of binarized
        tokensToTrain = [self uniqueArrayFrom:tokensToTrain];
    }

    for (NSString *word in tokensToTrain) {
        [self.vocab setObject:[[NSNumber alloc] initWithInt:1] forKey:word];
        [categoryData addToken:word];
    }

}

- (NSMutableArray *)uniqueArrayFrom:(NSArray *)candidateArray
{
    NSMutableArray* uniqueValues = [[NSMutableArray alloc] init];
    for(id token in candidateArray)
    {
        if(![uniqueValues containsObject:token])
        {
            [uniqueValues addObject:token];
        }
    }
   return uniqueValues;

}

- (ClassificationResult *)classify:(NSArray *)tokensToClassify {

    if(self.debug)
    {
        NSLog(@"Classify: %@",[tokensToClassify componentsJoinedByString:@", "]);
    }

    if(self.binarized) {  //we only want unique values in array of binarized
        tokensToClassify = [self uniqueArrayFrom:tokensToClassify];
    }

    NSDictionary *probabilities = [self calculateProbabilities:tokensToClassify];

    if(self.debug)
    {
        NSLog(@"Results: %@",probabilities);
    }

    return [[ClassificationResult alloc] initWithClassificationResult:probabilities];

}

- (NSNumber *)totalExamples {
    int sum = 0;
    for (BayesCategory *category in [self.data allValues])
    {
        sum += [category.examples intValue];
    }
    return [[NSNumber alloc] initWithInt:sum];
}

- (NSNumber *)vocabSize {
    if (self.logVocab) {
        return [[NSNumber alloc] initWithDouble:log([self.vocab count])];
    }
    return [[NSNumber alloc] initWithUnsignedInteger:[self.vocab count]];
}

- (NSDictionary *)calculateProbabilities:(NSArray *)tokens {

    NSMutableDictionary *probabilityNumerator = [[NSMutableDictionary alloc] init];
    NSNumber *vocabSize = [self vocabSize];

    for (NSString *categoryName in [self.data allKeys])
    {
        BayesCategory *category = [self.data objectForKey:categoryName];

        double categoryProbability;
        if(self.assumeUniform) {
            categoryProbability = log(1/(float)[self.data count]);
        } else {
            categoryProbability = log([category.examples doubleValue]/[[self totalExamples] doubleValue]);
        }

        double logProbability = 0;
        double cat_denominator = [[category totalTokens] doubleValue] + ([self.k doubleValue] * [vocabSize doubleValue]);

        for(id token in tokens)
        {
            logProbability += log( ([[category countForToken:token] doubleValue] + [self.k doubleValue]) / cat_denominator );
        }

        [probabilityNumerator setObject:[[NSNumber alloc] initWithDouble:(logProbability+categoryProbability)] forKey:categoryName];
    }

    double normalizer = 0;
    for (NSNumber *numerator in [probabilityNumerator allValues])
    {
        normalizer += [numerator doubleValue];
    }

    NSMutableDictionary *intermed = [[NSMutableDictionary alloc] init];
    double renormalizer = 0;
    for (NSString *categoryName in [probabilityNumerator allKeys])
    {
        double numerator = [[probabilityNumerator objectForKey:categoryName] doubleValue];
        double intermediate = (normalizer/numerator);
        [intermed setObject:[[NSNumber alloc] initWithDouble:intermediate] forKey:categoryName];
        renormalizer += intermediate;
    }

    NSMutableDictionary *finalProbabilities = [[NSMutableDictionary alloc] init];
    for(NSString *categoryName in [intermed allKeys]) {
        NSNumber *value = [intermed objectForKey:categoryName];
        double renormalized = [value doubleValue]/renormalizer;
        [finalProbabilities setObject:[[NSNumber alloc] initWithDouble:renormalized] forKey:categoryName];
    }
    return finalProbabilities;
}

- (NSNumber *)countForToken:(NSString *)token inCategory:(NSString *)categoryName
{
    BayesCategory *category = [self.data objectForKey:categoryName];
    return [category countForToken:token];
}


@end
