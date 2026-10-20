# expo-file-opener

Expo module that opens a local file with the system **"Open with"** dialog, so
the user picks which installed app opens it (a PDF reader, Word, Sheets, …).

| Platform | What it shows                                                                                |
| -------- | -------------------------------------------------------------------------------------------- |
| iOS      | `UIDocumentInteractionController`'s "Open in…" menu, anchored at the bottom of the screen    |
| Android  | An `ACTION_VIEW` chooser titled "Abrir com", granting the chosen app read access to the file |

## Installation

Install a tagged version straight from GitHub:

```sh
npm install https://github.com/RaphaPetrereEtapa/expo-file-opener/archive/refs/tags/v1.0.0.tar.gz
```

The HTTPS tarball needs neither git nor an SSH key on the machine. This is a
native module: Expo autolinking picks it up from `node_modules`, so it needs a
new development build (`npx expo run:ios` / `run:android`, or EAS Build) after
installing. It doesn't work in Expo Go.

Requires Expo SDK 58 or newer (iOS 16.4+).

## Usage

```ts
import { File, Paths } from 'expo-file-system';
import { Platform } from 'react-native';
import { openFile } from '@raphapetrereetapa/expo-file-opener';

const file = new File(Paths.cache, 'boletim.pdf');

await openFile(
  // Android needs a content:// URI; iOS takes the file:// URI.
  Platform.OS === 'android' ? file.contentUri : file.uri,
  'application/pdf', // Android: MIME type used to list matching apps
  'com.adobe.pdf', // iOS: Uniform Type Identifier ('' to let iOS infer it)
);
```

### `openFile(uri, mimeType, uti): Promise<void>`

| Argument   | Platform | Description                                                            |
| ---------- | -------- | ---------------------------------------------------------------------- |
| `uri`      | both     | The local file. Android: a `content://` URI; iOS: a `file://` URI.     |
| `mimeType` | Android  | The file's MIME type. An empty string falls back to `*/*`.             |
| `uti`      | iOS      | The file's Uniform Type Identifier. An empty string lets iOS infer it. |

The promise resolves once the dialog is shown. It rejects (with a message in
Portuguese, shown as-is to users of the original app) when:

- iOS: the file can't be read, there's no view to present from, or no app can
  open the file;
- Android: no app can open the file.

## Android package visibility

The module's manifest declares a `<queries>` entry for `ACTION_VIEW` on `*/*`,
which Android 11+ needs to list the apps that can open the file. It's merged
into your app's manifest automatically.

## Releasing a new version

1. Bump `version` in `package.json` (the podspec reads it) and commit.
2. Tag the commit and push the tag:
   ```sh
   git tag v1.1.0
   git push origin main --tags
   ```
3. In each app, install the new tag's tarball URL and make a new native build.

## Development

```sh
npm install
npm run typecheck
npm run format-check
```

## License

MIT
