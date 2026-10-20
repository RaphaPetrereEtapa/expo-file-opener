import { requireNativeModule } from 'expo-modules-core';

type FileOpenerNative = {
  openAsync(uri: string, mimeType: string, uti: string): Promise<void>;
};

/** Presents the system "Open with" menu for a local file. */
export const openFile = (uri: string, mimeType: string, uti: string) => {
  const opener = requireNativeModule<FileOpenerNative>('FileOpener');
  return opener.openAsync(uri, mimeType, uti);
};
