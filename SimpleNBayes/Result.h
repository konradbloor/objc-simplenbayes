#import <Foundation/Foundation.h>


@interface Result : NSObject

@property(nonatomic, retain) NSDictionary * classificationResult;

- (id)initWithClassificationResult:(NSDictionary *)classificationResult;
- (double)probabilityForClass:(NSString *)className;

- (NSString *)highestProbabilityClass;


@end