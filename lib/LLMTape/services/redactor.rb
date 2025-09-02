module LLMTape
  module Redactor
    module_function

    DEFAULT_KEEP_LENGTHS = true
    DEFAULT_BUILTINS     = [:emails, :api_keys].freeze
    DEFAULT_DO_NOT_STORE = [/\bsk-[A-Za-z0-9_-]{20,}\b/].freeze

    EMAIL  = /\b[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}\b/i
    OPENAI = /\bsk-(?:live|test|proj|key)?[A-Za-z0-9_-]{12,}\b/
    ANTHRO = /\banthropic-[A-Za-z0-9_-]{16,}\b/
    GOOGLE = /\bya29\.[A-Za-z0-9._-]{20,}\b/
    AWS_AK = /\bAKIA[0-9A-Z]{16}\b/
    AWS_SK = /\b[A-Za-z0-9\/+=]{40}\b/

    BUILTIN_MAP = {
      emails:   EMAIL,
      api_keys: Regexp.union(OPENAI, ANTHRO, GOOGLE, AWS_AK, AWS_SK)
    }.freeze

    def redact(text,
               keep_lengths: DEFAULT_KEEP_LENGTHS,
               builtins:     DEFAULT_BUILTINS,
               do_not_store: DEFAULT_DO_NOT_STORE)
    input = (text || "").dup

      do_not_store.each { |rx| puts "LLMTape::Redactor: forbidden secret matched #{input}" if input.match?(rx) }

      builtins.each do |name|
        rx = BUILTIN_MAP[name]
        next unless rx
      input = keep_lengths ? keep_len_mask(input, rx, name) : input.gsub(rx, replacement_for(name))
      end

      input
    end

    def replacement_for(name)
      { emails: "[EMAIL_REDACTED]", api_keys: "[API_KEY_REDACTED]" }[name] || "[REDACTED]"
    end
    module_function :replacement_for

    def keep_len_mask(input, rx, name)
      input.gsub(rx) do |m|
        case name
        when :emails
          local, = m.split("@", 2)
          masked_local = (local[0,1] || "") + ("*" * [local.length - 1, 3].max)
          "#{masked_local}@example.com"
        when :api_keys
          prefix = m[0,3] # likely "sk-"
          stars  = [m.length - prefix.length, 8].max
          "#{prefix}#{'*' * stars}"
        else
          "[REDACTED]"
        end
      end
    end

    module_function :keep_len_mask
  end
end
