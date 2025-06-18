
#import <Foundation/Foundation.h>

@interface LlamaBridge : NSObject

- (NSString *)runLLMWithPrompt:(NSString *)prompt;

@end
