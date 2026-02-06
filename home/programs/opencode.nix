{ config, pkgs, lib, ... }:

{
  # Generate opencode.json configuration
  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    model = "anthropic/claude-sonnet-4-5";
    autoupdate = true;
    theme = "cyberdream";
    plugin = [
      "oh-my-opencode@latest"
      "opencode-antigravity-auth@latest"
    ];
    provider = {
      google = {
        name = "Google";
        models = {
          antigravity-gemini-3-pro = {
            name = "Antigravity Gemini 3 Pro";
            contextWindow = 2000000;
            maxTokens = 65536;
          };
          antigravity-gemini-3-flash = {
            name = "Antigravity Gemini 3 Flash";
            contextWindow = 1000000;
            maxTokens = 8192;
          };
        };
      };
    };
  };

  # Generate oh-my-opencode.json configuration
  xdg.configFile."opencode/oh-my-opencode.json".text = builtins.toJSON {
    "$schema" = "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json";
    agents = {
      sisyphus = {
        model = "anthropic/claude-opus-4-5";
        variant = "max";
      };
      oracle = {
        model = "openai/gpt-5.2";
        variant = "high";
      };
      librarian = {
        model = "opencode/kimi-k2.5-free";
      };
      explore = {
        model = "anthropic/claude-haiku-4-5";
      };
      prometheus = {
        model = "anthropic/claude-opus-4-5";
        variant = "max";
      };
    };
    categories = {
      visual-engineering = {
        model = "google/antigravity-gemini-3-pro";
      };
      quick = {
        model = "anthropic/claude-haiku-4-5";
      };
    };
  };

  # Copy cyberdream theme to themes directory
  xdg.configFile."opencode/themes/cyberdream.json".source = ./opencode/cyberdream.json;
}
