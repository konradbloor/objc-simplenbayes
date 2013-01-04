#import "ClassificationResult.h"
#import "ClassificationEntry.h"
#import "SimpleNBayesTests.h"
#import "SimpleNBayes.h"

@implementation SimpleNBayesTests

- (void)setUp
{
    [super setUp];
    self.nbayes = [[SimpleNBayes alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testShouldAssignEqualProbabilityToEachClass
{
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", nil] forCategory:@"classA"];
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", nil] forCategory:@"classB"];
    ClassificationResult *result = [self.nbayes classify:[[NSArray alloc] initWithObjects:@"a", @"b", @"c", nil]];
    STAssertEquals((double)0.5, [result probabilityForClass:@"classA"], nil);
}

- (void)testShouldHandleMoreThan2Classes
{
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"a", @"a", @"a", @"a", nil] forCategory:@"classA"];
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"b", @"b", @"b", @"b", nil] forCategory:@"classB"];
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"c", @"c", nil] forCategory:@"classC"];
    ClassificationResult *result = [self.nbayes classify:[[NSArray alloc] initWithObjects:@"a", @"a", @"a", @"a", @"b", @"c", nil]];
    STAssertTrue(([result probabilityForClass:@"classA"] >= (double)0.4), nil);
    STAssertTrue(([result probabilityForClass:@"classB"] <= (double)0.3), nil);
    STAssertTrue(([result probabilityForClass:@"classC"] <= (double)0.3), nil);

}

- (void)testShouldUseSmoothingByDefaultToEliminateErrorsWithDivisionByZero
{
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"a", @"a", @"a", @"a", nil] forCategory:@"classA"];
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"b", @"b", @"b", @"b", nil] forCategory:@"classB"];
    ClassificationResult *result = [self.nbayes classify:[[NSArray alloc] initWithObjects:@"x", @"y", @"z", nil]];
    STAssertTrue(([result probabilityForClass:@"classA"] >= (double)0.0), nil);
    STAssertTrue(([result probabilityForClass:@"classB"] >= (double)0.0), nil);
}

- (void)testShouldOptionallyPurgeLowFrequencyData
{
    for (int i=0; i<100; i++) {
        [self.nbayes train:[[NSArray alloc] initWithObjects:@"a", @"a", @"a", @"a", nil] forCategory:@"classA"];
        [self.nbayes train:[[NSArray alloc] initWithObjects:@"b", @"b", @"b", @"b", nil] forCategory:@"classB"];
    }
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"a", nil] forCategory:@"classA"];
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"c", @"b", nil] forCategory:@"classB"];
    ClassificationResult *result = [self.nbayes classify:[[NSArray alloc] initWithObjects:@"c", nil]];
    STAssertEqualObjects(@"classB", [result highestProbabilityClass], nil);
    STAssertTrue(([result probabilityForClass:@"classB"] >= (double)0.5), nil);
    STAssertEqualObjects([[NSNumber alloc] initWithInt:1], [self.nbayes countForToken:@"c" inCategory:@"classB"], nil);

    [self.nbayes purgeLessThan:2];  //removes entry for 'c' in 'classB' because it has a frequency of 1, not decrementing example count
    result = [self.nbayes classify:[[NSArray alloc] initWithObjects:@"c", nil]];
    STAssertEqualObjects([[NSNumber alloc] initWithInt:0], [self.nbayes countForToken:@"c" inCategory:@"classB"], nil);
    STAssertTrue(([result probabilityForClass:@"classA"] == (double)0.5), nil);
    STAssertTrue(([result probabilityForClass:@"classB"] == (double)0.5), nil);


}

- (void)testWorksOnAllTokensNotJustStrings
{
    [self.nbayes train:[[NSArray alloc] initWithObjects: [[NSNumber alloc] initWithInt:1],
                                                         [[NSNumber alloc] initWithInt:2],
                                                         [[NSNumber alloc] initWithInt:3], nil] forCategory:@"low"];
    [self.nbayes train:[[NSArray alloc] initWithObjects: [[NSNumber alloc] initWithInt:5],
                                                         [[NSNumber alloc] initWithInt:6],
                                                         [[NSNumber alloc] initWithInt:7], nil] forCategory:@"high"];
    ClassificationResult *result = [self.nbayes classify:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:2], nil]];
    STAssertEqualObjects(@"low", [result highestProbabilityClass], nil);

    result = [self.nbayes classify:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:6], nil]];
    STAssertEqualObjects(@"high", [result highestProbabilityClass], nil);

}

- (void)testShouldOptionallyAllowClassDistributionToBeAssumedUniform
{
    //before uniform distribution
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"a", @"a", @"a", @"a", @"b", nil] forCategory:@"classA"];
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"a", @"a", @"a", @"a", nil] forCategory:@"classA"];
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"a", @"a", @"a", @"a", nil] forCategory:@"classB"];

    ClassificationResult *result = [self.nbayes classify:[[NSArray alloc] initWithObjects:@"a", nil]];
    STAssertEqualObjects(@"classA", [result highestProbabilityClass], nil);

    //after uniform distribution
    self.nbayes.assumeUniform = YES;
    result = [self.nbayes classify:[[NSArray alloc] initWithObjects:@"a", nil]];
    STAssertEqualObjects(@"classB", [result highestProbabilityClass], nil);
    STAssertTrue(([result probabilityForClass:@"classB"] > (double)0.5), nil);
}

- (void)trainForBinarizedTest:(SimpleNBayes *)bayes
{
    [bayes train:[[NSArray alloc] initWithObjects:@"a", @"a", @"a", @"a", @"a", @"a", @"a", @"a", @"a", @"a", @"a",nil] forCategory:@"classA"];
    [bayes train:[[NSArray alloc] initWithObjects:@"b", @"b", nil] forCategory:@"classA"];
    [bayes train:[[NSArray alloc] initWithObjects:@"a", @"c", nil] forCategory:@"classB"];
    [bayes train:[[NSArray alloc] initWithObjects:@"a", @"c", nil] forCategory:@"classB"];
    [bayes train:[[NSArray alloc] initWithObjects:@"a", @"c", nil] forCategory:@"classB"];

}

- (void)testShouldAllowBinarizedMode
{
    [self trainForBinarizedTest:self.nbayes];
    ClassificationResult *result = [self.nbayes classify:[[NSArray alloc] initWithObjects:@"a", nil]];
    STAssertEqualObjects(@"classA", [result highestProbabilityClass], nil);
    STAssertTrue(([result probabilityForClass:@"classA"] > (double)0.5), nil);

    self.nbayes = [[SimpleNBayes alloc] initWithBinarized:YES debug:NO logVocab:NO assumeUniform:NO];
    [self trainForBinarizedTest:self.nbayes];

    result = [self.nbayes classify:[[NSArray alloc] initWithObjects:@"a", nil]];
    STAssertEqualObjects(@"classB", [result highestProbabilityClass], nil);
    STAssertTrue(([result probabilityForClass:@"classB"] > (double)0.5), nil);

}

- (void)testAllowsSmoothingConstantKToBeSetToAnyValue
{
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"a", @"a", @"a", @"c",  nil] forCategory:@"classA"];
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"b", @"b", @"b", @"d", nil] forCategory:@"classB"];

    STAssertEquals((double)1, [self.nbayes.k doubleValue], nil);
    ClassificationResult *result = [self.nbayes classify:[[NSArray alloc] initWithObjects:@"c", nil]];
    double probK1 = [result probabilityForClass:@"classA"];

    self.nbayes.k = [[NSNumber alloc] initWithDouble:5];
    result = [self.nbayes classify:[[NSArray alloc] initWithObjects:@"c", nil]];
    double probK5 = [result probabilityForClass:@"classA"];

    STAssertTrue((probK1  > probK5), nil);
}

- (void)testShouldGiveSortedClassificationEntriesFromResult
{
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"a", nil] forCategory:@"classA"];
    [self.nbayes train:[[NSArray alloc] initWithObjects:@"b", nil] forCategory:@"classB"];

    ClassificationResult *result = [self.nbayes classify:[[NSArray alloc] initWithObjects:@"b", nil]];
    NSArray *entries = [result sortedClassificationEntries];

    ClassificationEntry *highestEntry = [entries objectAtIndex:0];
    STAssertEqualObjects(@"classB", [highestEntry name], nil);
    STAssertTrue(([highestEntry probabilityAsDouble] > (double)0.5), nil);

    ClassificationEntry *lowerEntry = [entries objectAtIndex:1];
    STAssertEqualObjects(@"classA", [lowerEntry name], nil);
    STAssertTrue(([lowerEntry probabilityAsDouble] < (double)0.5), nil);

}

@end
