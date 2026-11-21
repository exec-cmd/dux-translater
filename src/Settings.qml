import QtQuick
import qs.Common
import qs.DCommon.Widgets
import qs.Modules.Plugins
import "Providers.js" as Providers

PluginSettings {
    id: root
    pluginId: "duxTranslate"

    SelectionSetting {
        settingKey: "provider"
        label: I18n.trFor("duxTranslate", "Provider")
        options: [
            { label: "Google Cloud Translation", value: "google" },
            { label: "DeepL", value: "deepl" },
            { label: "OpenRouter", value: "openrouter" }
        ]
        defaultValue: Providers.defaultProvider
    }

    KeySetting {
        settings: root
        settingKey: "googleApiKey"
        label: I18n.trFor("duxTranslate", "Google API key")
        description: I18n.trFor("duxTranslate", "Google Cloud Console → Credentials, with the Cloud Translation API enabled.")
    }

    KeySetting {
        settings: root
        settingKey: "deeplApiKey"
        label: I18n.trFor("duxTranslate", "DeepL API key")
        description: I18n.trFor("duxTranslate", "Free keys end in :fx and use the Free endpoint automatically.")
    }

    KeySetting {
        settings: root
        settingKey: "openrouterApiKey"
        label: I18n.trFor("duxTranslate", "OpenRouter API key")
    }

    StringSetting {
        settingKey: "openrouterModel"
        label: I18n.trFor("duxTranslate", "OpenRouter model")
        description: I18n.trFor("duxTranslate", "Any model id from openrouter.ai/models.")
        placeholder: Providers.defaultModel
        defaultValue: Providers.defaultModel
    }

    SelectionSetting {
        settingKey: "openrouterReasoning"
        label: I18n.trFor("duxTranslate", "OpenRouter reasoning")
        description: I18n.trFor("duxTranslate", "How much the model thinks before answering. Off is fastest and cheapest; models that always reason ignore it or reject Off.")
        options: [
            { label: I18n.trFor("duxTranslate", "Model default"), value: "" },
            { label: I18n.trFor("duxTranslate", "Off"), value: "none" },
            { label: I18n.trFor("duxTranslate", "Minimal"), value: "minimal" },
            { label: I18n.trFor("duxTranslate", "Low"), value: "low" },
            { label: I18n.trFor("duxTranslate", "Medium"), value: "medium" },
            { label: I18n.trFor("duxTranslate", "High"), value: "high" },
            { label: I18n.trFor("duxTranslate", "Extra high"), value: "xhigh" }
        ]
        defaultValue: ""
    }

    StringSetting {
        settingKey: "openrouterPrompt"
        label: I18n.trFor("duxTranslate", "OpenRouter system prompt")
        description: I18n.trFor("duxTranslate", "{source} and {target} are replaced with language names.")
        placeholder: Providers.defaultPrompt
        defaultValue: Providers.defaultPrompt
    }
}
