// LLMCore/LlamaBridge.mm

#import "LlamaBridge.h"
#import <llama/llama.h>
#include <string>

@implementation LlamaBridge

- (NSString *)runLLMWithPrompt:(NSString *)prompt {
    // gguf 모델 파일 경로
    NSString *modelName = @"phi-3-mini-4k-instruct-q4";  // Resources 폴더에 있어야 함
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:modelName ofType:@"gguf"];
    if (!modelPath) return @"❌ 모델 경로 찾기 실패";

    const char *cModelPath = [modelPath UTF8String];
    const char *cPrompt = [prompt UTF8String];

    // 모델 및 컨텍스트 파라미터 초기화
    struct llama_model_params modelParams = llama_model_default_params();
    struct llama_context_params ctxParams = llama_context_default_params();

    // 모델 로드
    struct llama_model *model = llama_load_model_from_file(cModelPath, modelParams);
    if (!model) return @"❌ 모델 로드 실패";

    // 컨텍스트 생성
    struct llama_context *ctx = llama_new_context_with_model(model, ctxParams);
    if (!ctx) {
        llama_free_model(model);
        return @"❌ 컨텍스트 생성 실패";
    }

    // 입력 프롬프트 토크나이즈
    const int maxTokens = 512;
    llama_token tokens[maxTokens];

    int n_tokens = llama_tokenize_with_model(model, cPrompt, tokens, maxTokens, true, false);
    if (n_tokens <= 0) {
        llama_free(ctx);
        llama_free_model(model);
        return @"❌ 토크나이즈 실패";
    }

    // 토큰 평가
    if (llama_eval(ctx, tokens, n_tokens, 0, 1) != 0) {
        llama_free(ctx);
        llama_free_model(model);
        return @"❌ 평가 실패";
    }

    std::string result;
    for (int i = 0; i < 100; ++i) {
        llama_token token = llama_sample_token(ctx);
        if (token == llama_token_eos(model)) break;

        const char *tokenStr = llama_token_get_text(model, token);
        if (tokenStr) result += tokenStr;

        if (llama_eval(ctx, &token, 1, n_tokens + i, 1) != 0) break;
    }

    llama_free(ctx);
    llama_free_model(model);

    return [NSString stringWithUTF8String:result.c_str()];
}

@end
