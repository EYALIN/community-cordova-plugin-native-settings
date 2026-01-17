var exec = require('cordova/exec');

class SettingsManager {
    open(options) {
        return new Promise((resolve, reject) => {
            const setting = typeof options === 'string' ? options : options.setting;
            const newTask = typeof options === 'object' ? !!options.newTask : false;
            
            exec(function() {
                resolve();
            }, function(error) {
                reject(error);
            }, "NativeSettings", "open", [setting, newTask]);
        });
    }

    isAvailable(setting) {
        return new Promise((resolve, reject) => {
            exec(function(result) {
                resolve(!!result);
            }, function(error) {
                reject(error);
            }, "NativeSettings", "isAvailable", [setting]);
        });
    }
}

// Create and export a singleton instance as SettingsPlugin
module.exports = new SettingsManager();