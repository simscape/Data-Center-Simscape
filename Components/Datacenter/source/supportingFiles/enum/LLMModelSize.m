classdef LLMModelSize < int32
    % LLMModelSize  Enumeration for LLM model size presets.
    %   Used by computeProfileSource to derive training cycle timing.

    % Copyright 2026 The MathWorks, Inc.

    enumeration
        Llama_7B   (1)
        Llama_13B  (2)
        Llama_70B  (3)
        GPT_175B   (4)
        Llama_405B (5)
        Custom     (6)
    end

    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('Llama_7B')   = 'Llama 7B';
            map('Llama_13B')  = 'Llama 13B';
            map('Llama_70B')  = 'Llama 70B';
            map('GPT_175B')   = 'GPT 175B';
            map('Llama_405B') = 'Llama 405B';
            map('Custom')     = 'Custom';
        end
    end
end
