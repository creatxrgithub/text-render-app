import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'creatxr.text_render_app',
  appName: 'text-render-app',
  webDir: 'dist',
  server: {
    androidScheme: 'https'
  }
};

export default config;
