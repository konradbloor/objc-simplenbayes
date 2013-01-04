#import <Foundation/Foundation.h>


@interface ClassificationResult : NSObject

@property(nonatomic, retain) NSDictionary * classificationResult;

- (id)initWithClassificationResult:(NSDictionary *)classificationResult;
- (double)probabilityForClass:(NSString *)className;
- (NSString *)highestProbabilityClass;
- (NSArray *)sortedClassificationEntries;

@end