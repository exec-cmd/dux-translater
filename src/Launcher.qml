import QtQuick
import Quickshell
import qs.Common
import qs.Services
import "Providers.js" as Providers

// Launcher surface: type the trigger and a text; Enter translates it into the saved target language
// and copies the result. The launcher reads items synchronously and ignores itemsChanged, so the
// translation runs on Enter, not while typing.
Item {
    id: root

    readonly property string pluginId: "duxTranslate"

    property var pluginService: null
    property string trigger: "tr "

    signal itemsChanged

    property var request: null

    Component.onCompleted: {
        if (pluginService)
            Providers.migrateLegacy(pluginService, pluginId);
    }

    function targetCode() {
        return pluginService ? pluginService.loadPluginState(pluginId, "target", "en") : "en";
    }

    function settings() {
        const out = {};
        for (const key of Providers.settingKeys)
            out[key] = pluginService.loadPluginData(pluginId, key, "");
        return out;
    }

    function getItems(query) {
        const text = (query || "").trim();
        return [{
                name: text || I18n.trFor("duxTranslate", "Translate"),
                comment: text ? I18n.trFor("duxTranslate", "Enter: translate to %1 and copy").arg(Providers.languageName(targetCode())) : I18n.trFor("duxTranslate", "Type the text to translate"),
                icon: "material:translate",
                action: text ? "translate" : "none",
                text: text,
                categories: ["Dux Translate"],
                _preScored: 1000
            }];
    }

    function executeItem(item) {
        if (!item || item.action !== "translate" || !item.text)
            return;
        const s = settings();
        const req = Providers.buildRequest(s, item.text, "auto", targetCode(), null);
        if (req.error) {
            ToastService.showError(req.error);
            return;
        }
        cancel();
        const provider = Providers.providerOf(s);
        const xhr = new XMLHttpRequest();
        xhr.onreadystatechange = () => {
            // Ignore aborted or superseded requests.
            if (xhr.readyState !== XMLHttpRequest.DONE || request !== xhr)
                return;
            request = null;
            timeout.stop();
            const res = Providers.parseResponse(provider, xhr.status, xhr.responseText);
            if (res.error) {
                ToastService.showError(res.error);
                return;
            }
            Quickshell.execDetached(["dms", "cl", "copy", res.text]);
            ToastService.showInfo(I18n.trFor("duxTranslate", "Copied translation"), res.text);
        };
        xhr.open("POST", req.url);
        for (const name in req.headers)
            xhr.setRequestHeader(name, req.headers[name]);
        request = xhr;
        xhr.send(req.body);
        timeout.restart();
    }

    function cancel() {
        const old = request;
        request = null;
        timeout.stop();
        if (old)
            old.abort();
    }

    // Qt's XMLHttpRequest has no timeout property.
    Timer {
        id: timeout
        interval: 15000
        onTriggered: {
            root.cancel();
            ToastService.showError(I18n.trFor("duxTranslate", "Request timed out."));
        }
    }
}
