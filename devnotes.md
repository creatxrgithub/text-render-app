Development Notes

# Summary

Development notes aim to detail the steps and problems met and its solutions so that someone can start the next project with clear steps.

## Reason of choice with Ionic + Vue + Typescript:

1: cross-platform: write once, run anywhere with same codebase.
2: light: using web browser for debug, it's not required to run the heavy duty "android studio".
3: Vue has nice loose coupling of view-model.
4: Vue has good development documents now.
5: Typescript has more source-to-source compiler (transpiler).


# Setup environment
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
nvm install --lts # using a node version manager to "Resolving Permission Errors​"
npm install -g typescript
npm uninstall -g ionic
npm install -g @ionic/cli
```

## upgrade to ionic 7:
```
npm install vue@latest vue-router@latest
npm install @ionic/core@7 @ionic/vue@7 @ionic/vue-router@7
```
note: something is puzzled with my first try. it asked for java17. but after several days, i started a new project with command "ionic start", then add platform and build. it didn't ask for java17. i checked that it still use gradle ver8. my java version is still 11.

## downgrade to ionic 6:
```
npm i -D -E @vue/cli-service
npm i -E @capacitor/android@4.6.1
npm install @ionic/core@6 @ionic/vue@6 @ionic/vue-router@6
```


# Start project

in projects directory open a terminal window, then run command:
```
ionic start
```
(options with no wizard and React and tabs)
**after finishing, you could package it for next time use with change the config as project's name in "capacitor.config.json"**

go into project's folder, config git:
```
cd "text-render-app"
git remote add origin https://github.com/creatxrgithub/text-render-app.git
git push --set-upstream origin master
```
To display only the name of the current branch you're on:
```
git rev-parse --abbrev-ref HEAD
```
ionic's starter use "master" not "main" as its branch

## set app's id and name
**id should be valid java class style name**
**name could be a string with space etc.**

modify app's name in "capacitor.config.ts"
```
appId: 'creatxr.text_render_app,
appName: 'text-render-app',
```
and "ionic.config.json"
```
"name": "text-render-app",
```
and "package.json" and its "locked"
```
"name": "text-render-app"
```

if forget to change app's name at first time,** the better solution is delete the "android" folder, then re-run command "ionic capacitor build android --no-open" **


## install packages used in project:
```
# https://github.com/jimmywarting/native-file-system-adapter/
# https://github.com/backslash47/native-file-system-adapter # ts
# bug resolved: in packages.json modify "types": "./types/mod.d.ts",
# npm install --save native-file-system-adapter
npm install --save native-file-system-adapter-ts

# https://www.npmjs.com/package/js-base64
npm install --save js-base64
npm install --save adjust-chinese
```

maybe need:
```
npm install @types/node --save-dev
npm i -D @types/web
```

create soft links which are self own packages that may not published or updated to npmjs.org in "src" folder:
```
src/adjust-chinese-ts  ### this a soft link to the folder
src/chinese-text-render.ts
src/gradient.ts
```

## test run project
```
ionic serve -w firefox
```
then visit http://localhost:8100/


# Vuejs Starter Guide
```
"v-bind:attributeName" equals shorthand ":attributeName"
"v-on:eventName" equals shorthand "@eventName"
```
https://pipo.blog/articles/20220714-vue3-v-model-binding
```
<MySearch v-model="someRef" />
<!-- same as -->
<MySearch
    :modelValue="someRef"
    @update:modelValue="someRef = $event"
/>
```

## v-model binding
auto udpate value correct by number type with \<input\> tag
```
<input type="number" v-model="modelValue" />
```
auto udpate value problem by string type with \<ion-input\> tag
```
<ion-input type="number" v-model="modelValue" />
```
reslove: to use .number modifier for v-model
```
<input type="number" v-model.number="modelValue">
```

## ref()
use ref():
to auto render view layer while changing binding data
to auto update binding data while inputing in view layer.

e.g.
```
<script setup>
//let text = 'bad try. not works. e.g. it doesn't auto render html after text is changed.';

const text = ref('test text');
const textChange = (ev) => {
			text.value = ev.target.innerText;
		};
</script>

<template>
	<input @blur="textChange" :value="text" />
</template>
```

## Vue's Composition API
https://vuejs.org/guide/reusability/composables

In the context of Vue applications, a "composable" is a function that leverages Vue's Composition API to encapsulate and reuse stateful logic.

use setup() better than use data() in
```
<script lang="ts">
export default  defineComponent({
	setup() {
		return {};
	},

	data() {
		return {};
	}
});
</script>
```
recommanded is:
```
<script setup lang="ts"></script>
```


# Add platforms


## install openjdk version 11
```
sudo apt install openjdk-11-jdk
```
puzzled: when I first time start a project of ionic 7, it ask for java17. but after several days, after reboot computer, when I re-run ionic 7 starter project, it runs without asking for java17.

## Setup environment
setup global variable in ~/.bashrc then <b>close and reopen terminal</b>
```
export CAPACITOR_ANDROID_STUDIO_PATH="YOUR_PATH/android-studio/bin/studio.sh"
export ANDROID_HOME="YOUR_PATH/Android/Sdk"
```
local setting (if needed)
in YOUR_PROJECT/android/local.properties (if needed)
```
sdk.dir=YOUR_PATH
```
YOUR_PROJECT/android/gradle.properties  (if needed, for auto sign)
```
RELEASE_STORE_FILE=YOUR_PATH
RELEASE_STORE_PASSWORD=
RELEASE_KEY_ALIAS=
RELEASE_KEY_PASSWORD=
```

## Add platform and build
remove the "android" folder which is in the project and redo this step if it has app id collision
```
ionic capacitor add android ## ios
ionic capacitor sync
ionic capacitor build android --no-open #don't run studio ide
```

## Debug with android device
https://ionicframework.com/docs/cli/commands/capacitor-run
```
ionic capacitor run android --livereload --external
ionic capacitor run android -l --external
```

## Release android apk
```
keytool -genkey -v -keystore my-release-key.keystore -alias alias_name -keyalg RSA -keysize 2048 -validity 10000
```
release shell script
```
#!/usr/bin/env bash
set -e
source ../releaseConfig.cmd

#ionic capacitor build android --no-open #could only run once when add platform　#it may need run once
ionic build
ionic capacitor sync

#ionic capacitor copy
cd android && ./gradlew assembleRelease && cd ..
"${APKSIGNER_DIR}"/apksigner sign --ks-key-alias alias_name --ks "${KEY_STORE}" "${APK_FILE}"
```

## Update resources, e.g. icons
```
#https://github.com/ionic-team/capacitor-assets
npm install @capacitor/assets -g
npx capacitor-assets generate --assetPath public/assets/icon --android
```


# Troubleshooting

## SDK licenses
download command line tools from:
https://developer.android.com/studio
```
./sdkmanager --licenses
```

## unable check typescript type errors in ionic 7
https://vite-plugin-checker.netlify.app/introduction/getting-started
https://vite-plugin-checker.netlify.app/checkers/vue-tsc
https://stackoverflow.com/questions/72545700/vue-3-vite-typescript-dev-build-not-picking-up-ts-errors
```
npm install --save-dev vite-plugin-checker
```
In vite.config.ts
```
import checker from 'vite-plugin-checker';

export default defineConfig({
  plugins: [
    // your plugins
    checker({
      vueTsc: true,
    }),
  ],
  // your config
})
```

## Could not find a declaration file for module 'native-file-system-adapter'
resolved: in "node_modules/native-file-system-adapter" edit "packages.json" modify "types"
```
"types": "./types/mod.d.ts",
```

## Module not found: Error: Can't resolve 'fs' in
in the **module's** package.json (not the project's), e.g. use "filer-browserify" for "fs" module in browser
```
{
  "dependencies": {
    "filer-browserify": "*"
  },
  "browser": {
    "fs": "filer-browserify"
  }
}
```
What I did in module "adjust-chinese" is
```
{
  "browser": {
    "fs": "./updown-instead-fsapi.js"
  }
}
```

## retain newline in a contenteditable \<div\> tag
e.g.
```
aaa
bbb
```
when the div tag got focused then blured, it will render to one line:
```
aaa bbb
```
solution: add style to auto wrap text and maintain white-space:
```
pre {
	white-space: pre-wrap;
}
```
or use \<pre\> tag

## exception in phase 'semantic analysis' in source unit '_BuildScript_' Unsupported class file major version 65

According to the official grade docs: Java 17 and later versions are not yet supported.

use Java11


## style for horizontal scroll
```
{ overflowX: 'scroll!important;' }
```
must with "!important;". otherwise it will get display issue in browsers except firefox.
must with ";" at the end.

## with [Vue warn]: Unexpected semicolon at the end of 'overflowX' style value: 'scroll!important;'
use unicode "U+0003B" instead of the semi ";"
```
{ overflowX: 'scroll!importantU+0003B' }
```

## dark mode
read: https://ionicframework.com/docs/theming/dark-mode
need copy and paste the theme to replace the default start-app theme in **project_dir/src/theme/variables.css**


## SyntaxError: ambiguous indirect export:

### with ionic 7

it's cause ionic 7 use vite. vite does not support commonjs.

commonjs module vs es module (esm)

modify "module.exports = {}" to "export {}"

### with ionic 6

it's because import module ( which isn't installed in folder "node_modules". cause it's developed by self and still not publish to npmjs.com ) from local folder which has typescript and its compiled javascript file.

#### solution: import the "main" typescript file like "index.ts" not the module's folder.


#### solution: use symbolic link in folder "node_modules"
run command in node_modules to create a soft link
```
ln -s target_folder
```
note: if npm i package to install new module, it needs to re-create the links.

### solution: Ship ESM & CJS in one Package
https://antfu.me/posts/publish-esm-and-cjs
https://github.com/egoist/tsup
https://nodejs.org/api/packages.html#packages_type
https://nodejs.org/api/packages.html#packages_subpath_imports
https://nodejs.org/api/packages.html#packages_conditional_exports
https://nodejs.org/api/packages.html
```
npm i tsup -D
npm i typescript -D
```
config in package.json
```
{
  "main": "./dist/adjust_chinese2tc.js",
  "module": "./dist/adjust_chinese2tc.mjs",
  "types": "./dist/adjust_chinese2tc.d.ts",
  "exports": {
    ".": {
      "require": "./dist/adjust_chinese2tc.js",
      "import": "./dist/adjust_chinese2tc.mjs",
      "types": "./dist/adjust_chinese2tc.d.ts"
    }
  },
  "scripts": {
    "build": "tsup src/adjust_chinese2tc.ts src/updown-instead-fsapi.ts --format cjs,esm --dts --clean",
    "watch": "npm run build -- --watch src",
    "prepublishOnly": "npm run build",
    "test": "echo \"Error: no test specified\" && exit 1"
  }
}
```

## a little style problem with ionic 6 and ionic 7

in a editable div with enough long text, if the div focused to edit state, then click at its middle position (or maybe it's the text's middle position), the div will over-cover the header. it seems that it's only problem of ionic 6.

with ionic 7, the input field (e.g. toggle) will try to have 100% width or display in newline.

solution: set toggle's slot="start"

## open modal "AAA" in modal "BBB"
the modal "AAA" must place in the modal "BBB". let modal "AAA" could "see" modal "BBB". otherwise it will not work:
```
[Ionic Warning]: A trigger element with the ID "open-modal-for-expert" was not found in the DOM. The trigger element must be in the DOM when the "trigger" property is set on an overlay component.
```

## 'get' does not exist in type 'ComputedGetter \<unknown\>'
The computed's getter has its type inferred from the setter's argument
```
const computedProp = computed({
  get: () => { return retObj; },
  set: (newValue: Object) => {}  //setter's type
});
```

## convert encoding
do not use "iconv-lite" cause it uses "Buffer". it's not work in browser.
use TextDecoder: https://developer.mozilla.org/en-US/docs/Web/API/TextDecoder
```
return new TextDecoder(encoding).decode(buf) || '';
```

## webpack : Uncaught ReferenceError: require is not defined
require commonjs's module in es6 module: https://nodejs.org/api/module.html#modulecreaterequirefilename
```
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const commonjsModule = require('./commonjs-module');
```

## detect and convert encoding of uploaded non-utf8 text
https://developer.mozilla.org/en-US/docs/Web/API/FileReaderSync/readAsArrayBuffer
upload file with **"readAsArrayBuffer()"**, do not use "readAsText()".
```
const openText = async() => {
	async function readFileAsync(file:any) {
		return new Promise((resolve, reject) => {
			let reader = new FileReader();
			reader.onload = () => {
			resolve(reader.result);
		};
			reader.onerror = reject;
//reader.readAsText(file);  //unable detect text encoding, it will be garbled characters with non utf8. e.g. big5.
			//reader.readAsDataURL(file);  //to use in url()
			reader.readAsArrayBuffer(file);  //to get raw data
		})
	}
	const [fileHandle] = await showOpenFilePicker({
			types: [
			],
			multiple: false, // default
			excludeAcceptAllOption: false, // default
			_preferPolyfill: false // default
		});
	const file = await fileHandle.getFile();
	let upFileContent = await readFileAsync(file);
	let buf = new Uint8Array(upFileContent as ArrayBufferLike);  //must be Uint8Array
	let encoding = chardet.detect(buf);
	console.log(encoding);
	if(/\.txt$/i.test(fileHandle.name)) {
		text.value = new TextDecoder(encoding).decode(buf);
	}
};
```

## error TS1203: Export assignment cannot be used when targeting ECMAScript modules. Consider using 'export default' or another module format instead.
https://www.darraghoriordan.com/2021/06/26/publishing-package-using-esm-esmodules
https://www.typescriptlang.org/docs/handbook/modules/reference.html
https://www.typescriptlang.org/tsconfig/moduleResolution.html

To load an ES module, set "type": "module" in the package.json or use the .mjs extension.

Directory import '/path/to/folder' is not supported resolving ES modules imported.
must use '/path/to/folder/file'

cannot as:
```
export = ChineseAdjustor;
```
must be:
```
export default ChineseAdjustor;
//or
export { ChineseAdjustor }; //it's better. cause it's easier to expand.
```
with 'export default', to import in commonjs:
```
export default ChineseAdjustor;

require ChineseAdjustor from require('path/to/file').default;
//require ChineseAdjustor from require('path/to/file'); //error
```

## [vue-tsc] Type 'NodeListOf \<Element\>' must have a '[Symbol.iterator]()' method that returns an iterator.
add "lib":["dom.iterable"] in tsconfig.json
```
{
  "compilerOptions": {
    "lib": ["ESNext", "DOM", "dom.iterable"],
  }
}
```

## [vue-tsc] Property 'value' does not exist on type 'Element'.
https://stackoverflow.com/questions/12989741/the-property-value-does-not-exist-on-value-of-type-htmlelement
```
(document.getElementById(elementId) as HTMLInputElement).value
var inputValue = (<HTMLInputElement>document.getElementById(elementId)).value;
```

## [vue-tsc] Property 'value' does not exist on type 'Element'.
```
const addColor = (ev: any) => {
  //console.log(ev.target.value);
  let color = (document.querySelector('[id=colorPicker]') as HTMLInputElement).value;
  gradientUtil.value.colors.push(color);
};
```

##  [vue-tsc] 'ev.target' is possibly 'null'.
https://freshman.tech/snippets/typescript/fix-value-not-exist-eventtarget/

if set event's type with "Event" not "any" ("any" type means to ignore type check).
it needs keyword "as"
```
function handleClick(event: Event) {
  const target = event.target as HTMLElement; //HTMLButtonElement, HTMLInputELement etc.
  if (target) console.log(target.id);
}
```

## import { performance } from 'node:perf_hooks'
that's error message from ionic ver7 starter
```
npm i --save-dev @types/node
```

## error TS2792: Cannot find module 'native-file-system-adapter'. Did you mean to set the 'moduleResolution' option to 'nodenext', or to add aliases to the 'paths' option?

in tsconfig.json
```
"moduleResolution": "node"
```

## generate declare files .d.ts
```
# tsc -m commonjs -t esnext --outDir cjs --strict --sourceMap
# tsc -m esnext -t esnext --outDir mjs --strict --sourceMap
tsc --declaration --allowJs --emitDeclarationOnly --outDir types
```
https://itnext.io/mastering-declaration-files-the-key-to-typescripts-type-magic-fe4483a86645
https://github.com/josdejong/mathjs/issues/2919


# references
https://www.w3docs.com/
https://www.w3schools.com/
https://developer.mozilla.org/en-US/docs/Web
https://learnvue.co/articles
https://github.com/foxbenjaminfox/vue-async-computed
https://developer.mozilla.org/en-US/docs/Glossary/Base64
https://rxjs.dev/guide/overview
https://stackoverflow.com/questions/34278474/module-exports-and-es6-import
https://stackoverflow.com/questions/48708410/typescript-error-an-export-assignment-cannot-be-used-in-a-module-with-other-exp
https://vitejs.dev/guide/troubleshooting.html#module-externalized-for-browser-compatibility for more details.
https://github.com/jimmywarting/native-file-system-adapter/
https://www.npmjs.com/package/eluve-native-file-system-adapter
https://capawesome.io/plugins/file-picker/
https://github.com/capacitor-community/sqlite/blob/master/docs/Ionic-Vue-Usage.md
https://ionicframework.com/docs/native/filesystem
