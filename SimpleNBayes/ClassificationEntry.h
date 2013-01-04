#import <Foundation/Foundation.h>


@interface ClassificationEntry : NSObject

@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, retain, readwrite) NSNumber *probability;

- (id)initWithName:(NSString *)categoryName andProbability:(NSNumber *)guessProbability;
- (NSString *)getPercentage;
- (NSComparisonResult) compare:(ClassificationEntry *)anotherGuess;
- (double)probabilityAsDouble;

@end