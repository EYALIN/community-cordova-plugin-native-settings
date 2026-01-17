[![NPM version](https://img.shields.io/npm/v/community-cordova-plugin-native-settings)](https://www.npmjs.com/package/community-cordova-plugin-native-settings)

# community-cordova-plugin-native-settings 

I dedicate a considerable amount of my free time to developing and maintaining many cordova plugins for the community ([See the list with all my maintained plugins][community_plugins]).
To help ensure this plugin is kept updated,
new features are added and bugfixes are implemented quickly,
please donate a couple of dollars (or a little more if you can stretch) as this will help me to afford to dedicate time to its maintenance.
Please consider donating if you're using this plugin in an app that makes you money,
or if you're asking for new features or priority bug fixes. Thank you!

[![](https://img.shields.io/static/v1?label=Sponsor%20Me&style=for-the-badge&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/eyalin)

---

# Community Cordova Plugin Native Settings

## Overview
This Cordova plugin provides a simple way to open native device settings screens on Android and iOS platforms. It allows your app to deep-link into specific system settings pages (Wi‑Fi, Bluetooth, Location, etc.) with a clean Promise-based API.

## Installation
To install the plugin in your Cordova project, use the following command:
```bash
cordova plugin add community-cordova-plugin-native-settings
```

## Usage
The plugin provides a Promise-based API (also compatible with callbacks) to open various system settings screens.

### Basic JavaScript Usage
```javascript
document.addEventListener('deviceready', onDeviceReady, false);

function onDeviceReady() {
    // Open Wi‑Fi settings
    cordova.plugins.settings.open('wifi')
        .then(() => console.log('Wi‑Fi settings opened'))
        .catch(err => console.error('Failed to open settings:', err));

    // Open settings in a new task (Android only)
    cordova.plugins.settings.open({ setting: 'wifi', newTask: true })
        .then(() => console.log('Settings opened in new task'))
        .catch(err => console.error('Error:', err));
}
```

### TypeScript/Angular Usage
```typescript
import { INativeSettings } from 'community-cordova-plugin-native-settings';

declare const cordova: any;

@Injectable({
    providedIn: 'root'
})
export class SettingsService {
    private settings: INativeSettings;

    constructor() {
        this.settings = cordova.plugins.settings;
    }

    async openWifiSettings(newTask: boolean = false): Promise<void> {
        try {
            await this.settings.open({ setting: 'wifi', newTask });
            console.log('Wi‑Fi settings opened');
        } catch (err) {
            console.error('Failed to open settings:', err);
            throw err;
        }
    }

    async isWifiSettingsAvailable(): Promise<boolean> {
        return await this.settings.isAvailable('wifi');
    }
}
```

## API Reference

### Methods

#### open(options: string | INativeSettingsOptions): Promise<void>
Opens the requested settings page.

Parameters:
- `options`: Either a string (setting name) or an object with:
  - `setting`: The settings page to open
  - `newTask`: (Android only) Whether to open in a new task

#### isAvailable(setting: string): Promise<boolean>
Checks if a specific settings page is available on the current device.

Parameters:
- `setting`: The settings page to check

### Supported Settings

#### Android
- 'wifi' - Wi‑Fi settings
- 'location' - Location settings
- 'bluetooth' - Bluetooth settings
- 'accessibility' - Accessibility settings
- 'add_account' - Add account settings
- 'airplane_mode' - Airplane mode settings
- 'apn' - APN settings
- 'application_details' - App details
- 'application_development' - Development settings
- 'application' - Application settings
- 'battery_optimization' - Battery optimization
- 'device_info' - Device info
- 'display' - Display settings
- 'keyboard' - Keyboard settings
- 'manage_all_applications' - All apps
- 'manage_applications' - App management
- 'memory_card' - Memory card
- 'network' - Network settings
- 'nfc' - NFC settings
- 'notification' - Notification settings
- 'security' - Security settings
- 'sound' - Sound settings
- 'sync' - Sync settings
- 'usage' - Usage settings
- 'user_dictionary' - User dictionary
- 'voice_input' - Voice input settings
- 'vpn' - VPN settings

#### iOS
- 'wifi' - Wi‑Fi settings
- 'bluetooth' - Bluetooth settings
- 'location' - Location settings
- 'settings' - App settings
- 'about' - About settings
- 'accessibility' - Accessibility settings
- 'account' - Account settings
- 'airplane_mode' - Airplane mode
- 'battery' - Battery settings
- 'browser' - Browser settings
- 'date' - Date settings
- 'facetime' - FaceTime settings
- 'keyboard' - Keyboard settings
- 'locale' - Language settings
- 'music' - Music settings
- 'notification' - Notification settings
- 'photos' - Photos settings
- 'profile' - Profile settings
- 'sounds' - Sound settings
- 'storage' - Storage settings
- 'wallpaper' - Wallpaper settings

**Note**: Some iOS URL schemes are unofficial and may not work on all iOS versions. The plugin will fall back to opening the app's settings page in such cases.

## Platform Specifics
- **Android**: Provides comprehensive access to system settings through Android's Settings API
- **iOS**: Uses URL schemes to deep-link into settings; some settings may fall back to the app settings page due to iOS restrictions

## Contributing
Contributions to the plugin are welcome! Please follow the standard fork and pull request workflow.

## License
This project is licensed under the MIT License.

---
[community_plugins]: https://github.com/EYALIN?tab=repositories&q=community&type=&language=&sort=

Android (uses android.provider.Settings actions):

- accessibility, account, airplane_mode, apn, application_details, application_development, application
- battery_optimization, bluetooth, captioning, cast, data_roaming, date, display, dream
- keyboard, keyboard_subtype, storage, locale, location, manage_all_applications, manage_applications
- memory_card, network, nfcsharing, nfc_payment, nfc_settings, print, privacy, quick_launch
- search, security, settings, show_regulatory_info, sound, sync, usage, user_dictionary
- voice_input, wifi_ip, wifi, wireless

iOS (deep-links; availability varies by iOS version):

- about, accessibility, account, airplane_mode, autolock, battery, bluetooth, cellular, date
- facetime, keyboard, language, location, music, notifications (falls back to app settings), photos
- privacy, reset, ringtone, safari, sound, software_update, storage, vpn, wallpaper, wifi

Note: iOS deep-linking uses App-Prefs / UIApplicationOpenSettingsURLString fallbacks. Apple may restrict or change these schemes in new iOS releases.

## Contributing

Contributions are welcome. Please open issues or PRs against the repository.

## License

MIT

[community_plugins]: https://github.com/search?q=topic%3Acordova-plugin+org%3Aeyalin&type=Repositories
