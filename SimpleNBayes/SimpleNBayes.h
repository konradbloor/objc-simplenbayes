#import <Foundation/Foundation.h>
#import "ClassificationResult.h"

@class BayesCategory;

@interface SimpleNBayes : NSObject

@property(nonatomic) BOOL debug;
@property(nonatomic,retain) NSNumber *k; //some bayesian math thing?
@property(nonatomic) BOOL binarized;
@property(nonatomic) BOOL logVocab; //for smoothing, use log of vocab size, rather than vocab size
@property(nonatomic) BOOL assumeUniform;
@property(nonatomic,retain) NSMutableDictionary *vocab; //used to calculate vocab size
@property(nonatomic,retain) NSMutableDictionary *data;


- (id)initWithBinarized:(BOOL)ifBinarized debug:(BOOL)ifDebug logVocab:(BOOL)ifLogVocab assumeUniform:(BOOL)ifAssumeUniform;
- (void)purgeLessThan:(int)x;
- (BayesCategory *)getCategoryForName:(NSString *)categoryName;
- (void)train:(NSArray *)tokens forCategory:(NSString *)category;
- (ClassificationResult *)classify:(NSArray *)tokens;
- (NSNumber *)totalExamples;
- (NSUInteger)totalCategories;
- (NSNumber *)vocabSize;
- (NSDictionary *)calculateProbabilities:(NSArray *)tokens;
- (NSNumber *)countForToken:(NSString *)token inCategory:(NSString *)categoryName;

@end
