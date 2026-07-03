import dataPreferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';

export class PreferencesUtil {
  private static pref: dataPreferences.Preferences | null = null;
  private static context: common.UIAbilityContext | null = null;

  static async init(context: common.UIAbilityContext): Promise<void> {
    PreferencesUtil.context = context;
    try {
      PreferencesUtil.pref = await dataPreferences.getPreferences(context, 'app_pref');
      console.info('Preferences initialized successfully.');
    } catch (err) {
      console.error('Failed to initialize Preferences: ' + JSON.stringify(err));
    }
  }

  static async put(key: string, value: string): Promise<void> {
    if (PreferencesUtil.pref) {
      try {
        await PreferencesUtil.pref.put(key, value);
        await PreferencesUtil.pref.flush();
      } catch (err) {
        console.error(`Failed to put key ${key}: ` + JSON.stringify(err));
      }
    } else {
      console.warn('Preferences not initialized when trying to put key: ' + key);
    }
  }

  static async get(key: string, defaultValue: string = ''): Promise<string> {
    if (PreferencesUtil.pref) {
      try {
        const res = await PreferencesUtil.pref.get(key, defaultValue);
        return res as string;
      } catch (err) {
        console.error(`Failed to get key ${key}: ` + JSON.stringify(err));
        return defaultValue;
      }
    }
    return defaultValue;
  }

  static async delete(key: string): Promise<void> {
    if (PreferencesUtil.pref) {
      try {
        await PreferencesUtil.pref.delete(key);
        await PreferencesUtil.pref.flush();
      } catch (err) {
        console.error(`Failed to delete key ${key}: ` + JSON.stringify(err));
      }
    }
  }
}
