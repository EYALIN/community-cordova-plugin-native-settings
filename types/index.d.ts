export interface INativeSettingsOptions {
  setting: string;
  /**
   * On Android, open the settings screen in a new task (so it appears as a separate app in Recents)
   */
  newTask?: boolean;
}

export declare class SettingsManager {
  /**
   * Open device settings screen
   * @param options Settings options or setting string
   */
  open(options: INativeSettingsOptions | string): Promise<void>;

  /**
   * Check if specific settings page is available
   * @param setting The settings page to check
   */
  isAvailable(setting: string): Promise<boolean>;
}

// For global access
declare global {
  const SettingsPlugin: SettingsManager;
}
