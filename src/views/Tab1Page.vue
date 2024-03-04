<template>
	<ion-page>
		<ion-header>
			<ion-toolbar>
				<ion-buttons :collapse="true" slot="start" class="scrollX">
					<ion-toggle slot="start"
						:checked="themeToggle"
						@ionChange="toggleChange($event)"
						justify="space-between"></ion-toggle>
					<ion-button @click="openText">讀文本</ion-button>
					<ion-button id="open-modal-to-set-replacement" expand="block">用繁體</ion-button>
					<ion-button id="open-modal-to-set-writing" expand="block">轉豎行</ion-button>
					<ion-button id="open-modal-to-set-style" expand="block">設渲染</ion-button>
					<ion-button @click="eleToImg">截圖</ion-button>
				</ion-buttons>
			</ion-toolbar>
		</ion-header>
		<ion-content :fullscreen="true">
			<ion-item>
			<div id="textEditor" contenteditable
				@blur="textChange"
				:style="editorStyle"
				v-text="text">
			</div>
			</ion-item>
			<ion-item>
			<img id="divshot" :src="divshotDataUrl"></img>
			</ion-item>
		</ion-content>
		<ion-modal ref="refVerticalModal" trigger="open-modal-to-set-writing">
			<ion-list>
				<ion-item>
					<ion-button @click="renderVerticalWriting">轉豎行</ion-button>
				</ion-item>
				<ion-item>
					<ion-input label="每列幾字："
						type="number" id="maxCharsPerCol"
						min="1" max="80"
						v-model.number="chineseTextStyle.maxCharsPerCol" />
				</ion-item>
				<ion-item>
					<ion-input label="每頁幾列："
						type="number" id="maxColsPerPage"
						min="1" max="80"
						v-model.number="chineseTextStyle.maxColsPerPage" />
				</ion-item>
				<ion-item>
					<ion-toggle label="使用邊框" slot="start" :checked="borderToggle" @ionChange="borderToggleChange($event)">使用邊框</ion-toggle>
				</ion-item>
				<ion-item>
					<ion-select :disabled="!borderToggle"
						label="水平邊框："
						type="text" id="borderHorizontal"
						:value="chineseTextStyle.borderHorizontal"
						@ionChange="event => chineseTextStyle.borderHorizontal = event.target.value">
						<ion-select-option value="═">═</ion-select-option>
						<ion-select-option value="══">══</ion-select-option>
					</ion-select>
				</ion-item>
				<ion-item>
					<ion-select label="標點置換："
						type="text" id="punctuation"
						v-model="chineseTextStyle.replacePunctuation">
						<ion-select-option value="keep">保持標點</ion-select-option>
						<ion-select-option value="space">換空格</ion-select-option>
						<ion-select-option value="newcol">換新列</ion-select-option>
						<ion-select-option value="none">取消標點</ion-select-option>
					</ion-select>
				</ion-item>
			</ion-list>
		</ion-modal>
		<ion-modal ref="refFontModal" trigger="open-modal-to-set-style" class="customModal">
			<ion-toolbar>
				<ion-item>
					<!-- it's not work: Uncaught TypeError: $setup.refFontModal.value is undefined
					<ion-button @click="refFontModal.value.$el.dismiss(null, 'cancel')">保存設置</ion-button>
					-->
					<ion-button @click="fontModalCancel">應用設置</ion-button>
					<ion-button @click="openImage">插入圖片</ion-button>
					<!--
					<ion-button id="open-modal-for-gradient" expand="block">加入彩虹</ion-button>
					-->
					<ion-button @click="openGradientModal">加入彩虹</ion-button>
					<ion-button id="open-modal-for-expert" expand="block">專家模式</ion-button>
				</ion-item>
			</ion-toolbar>
			<ion-content>
				<ion-list>
					<ion-item-divider>前景設置</ion-item-divider>
					<ion-item-group>
						<ion-item>
							<ion-select label="選擇字體："
								:style="{ fontFamily: editorStyle.fontFamily }"
								v-model="editorStyle.fontFamily">
								<ion-select-option
									v-for="(item, index) in fontFamilies" :key="index" :value="item">
									{{ item }}
								</ion-select-option>
							</ion-select>
							<ion-button @click="pickFont">自選字體</ion-button>
						</ion-item>
						<ion-item>
							<ion-input label="字體大小(px)："
								type="number" min="4"
								@ionInput="editorStyle.fontSize = $event.target.value?.toString()+'px'"
								:value="editorStyle.fontSize!.replace('px','')" />
						</ion-item>
						<ion-item>
							<ion-select label="字體樣式："
								type="text" v-model="editorStyle.fontStyle">
								<ion-select-option value="normal">normal</ion-select-option>
								<ion-select-option value="oblique">oblique</ion-select-option>
							</ion-select>
						</ion-item>
						<ion-item>
							<ion-input label="字體顏色："
								type="text"
								placeholder="transparent"
								v-model="editorStyle.WebkitTextFillColor" />
						</ion-item>
						<ion-item>
							<ion-input label="過濾器："
								slot="start"
								type="text"
								placeholder="blur(0px) sepia(1) opacity(0.5)"
								v-model="editorStyle.WebkitFilter" />
							<ion-select
								slot="end"
								@ionChange="ev => editorStyle.WebkitFilter += ' ' + ev.target.value.toString().replace('()', '(0)')">
								<ion-select-option v-for="(item, index) in filterFunctions" :key="index" :value="item">
									{{ item }}
								</ion-select-option>
							</ion-select>
						</ion-item>
						<ion-item>
							<ion-toggle slot="start" label="彩虹文字？" :checked="grandientTextToggle" @ionChange="gradientToggleChange">彩虹文字？</ion-toggle>
						</ion-item>
					</ion-item-group>
					<ion-item-divider>
						背景圖片
					</ion-item-divider>
					<ion-item-group>
						<ion-item
							:style="{
								overflowX: 'scroll important',
								}"
							v-for="(bgImg, index) in backgroundImageArray" :key="index"
							:id="`bgImgId${index}`">

							<ion-input v-if="isImageUrl(bgImg)"
								label=""
								slot="start"
								id="bgImgGroup"
								type="text"
								readonly
								:style="{
									maxWidth: '50%',
									backgroundImage: bgImg,
									backgroundSize: 'contain',
									backgroundRepeat: 'no-repeat' }"
								:value="bgImg" /> <!-- v-model="backgroundImages[index]" -->

							<ion-input v-else-if="isImageGradient(bgImg)"
								label=""
								slot="start"
								id="bgImgGroup"
								type="text"
								:style="{
									maxWidth: '50%',
									backgroundImage: bgImg,
									backgroundSize: 'contain',
									backgroundRepeat: 'no-repeat' }"
								:value="bgImg" />
							<ion-button :id="`relId${index}`" @click="removeImage">delete</ion-button>
							<ion-button :id="`relId${index}`" @click="downImage">down</ion-button>
							<ion-button :id="`relId${index}`" @click="upImage">up</ion-button>
						</ion-item>
					</ion-item-group>
				</ion-list>
			</ion-content>
			<ion-modal ref="refExpertModal" trigger="open-modal-for-expert" class="customModal">
				<ion-toolbar>
					<ion-button @click="expertModalCancel">應用設置</ion-button>
				</ion-toolbar>
				<ion-content>
					<ion-textarea id="styleEditor"
						:autoGrow="true"
						@ionBlur="Object.assign(editorStyle, JSON.parse($event.target.value!))"
						:value="JSON.stringify(editorStyle, null, '\n')">
					</ion-textarea>
					<!-- cannot use this:
						@ionBlur="editorStyle = JSON.parse($event.target.value)"
						it will lose pre-designed computed() backgroundImage.
						it must use Object.assign() to copy key's value.
					-->
				</ion-content>
			</ion-modal>
		</ion-modal>
		<ion-modal ref="refGradientModal">
			<ion-toolbar>
				<ion-item>
					<ion-button @click="gradientModalCancel">關閉</ion-button>
					<ion-button @click="addGradient">加入</ion-button>
					<ion-button routerLink="/tabs/tab3" @click="closeAll">新設</ion-button>
				</ion-item>
			</ion-toolbar>
			<ion-content>
				<ion-accordion-group ref="refAccordionGroup" expand="inset">
				<!-- v-for must to set in the element which is for loop-->
					<ion-accordion v-for="(item, index) in prefs.gradients" :key="index" :value="`${index}`">
						<ion-item slot="header">
							{{ item }}
						</ion-item>
						<ion-item slot="content">
							<div :style="{minHeight: '200px', width: '100%', backgroundImage: item}"></div>
						</ion-item>
					</ion-accordion>
				</ion-accordion-group>
			</ion-content>
		</ion-modal>
		<ion-modal ref="adjustModal" trigger="open-modal-to-set-replacement">
			<ion-toolbar>
				<ion-item>
					<ion-button @click="adjustChinese">轉換</ion-button>
					<ion-button @click="addPattern">增加</ion-button>
				</ion-item>
			</ion-toolbar>
			<ion-content> <!-- 需要使用 ion-content 否則 ion-toolbar 和 ion-list 間會空白一大片 -->
				<ion-list>
					<ion-item>
						例子：{{ customDict }}
					</ion-item>
					<ion-item v-for="(value, index) in tempDict" :key="index">
						<ion-input slot="start" :id="`pattern${index}`" type="text" :value="value"
							@ionBlur="updatePattern"
							placeholder="將用第一個字替換後面的幾個字" />
						<ion-button slot="end" :id="`pattern${index}`" @click="removePattern">刪除</ion-button>
					</ion-item>
				</ion-list>
			</ion-content>
		</ion-modal>
		</ion-page>
</template>

<script setup lang="ts">
import { IonButtons, IonPage, IonHeader, IonToolbar, IonContent, IonToggle, IonButton, IonItem, IonList, IonModal, IonSelect, IonSelectOption, IonInput, IonTextarea, IonItemGroup, IonItemDivider, ToggleCustomEvent, IonAccordionGroup, IonAccordion } from '@ionic/vue';
import { ref, computed, reactive, watch } from 'vue';
//import { defineProps, defineEmits, defineOptions } from 'vue';
//import { Events } from '@ionic/vue';
import { Preferences } from '@capacitor/preferences';
import { HTMLIonOverlayElement } from '@ionic/core';


//import { Base64 } from 'js-base64';
import { showOpenFilePicker, showSaveFilePicker, getOriginPrivateDirectory } from 'eluve-native-file-system-adapter';
//import { showOpenFilePicker, showSaveFilePicker } from 'native-file-system-adapter';
import { Filesystem, Directory, Encoding } from '@capacitor/filesystem';
import { Capacitor } from '@capacitor/core';

//不須 .ts 後綴，可建立軟連接，與 package 一般導入自己的最新的未發佈的本地的依賴包，比拷到 node_modules 目錄方便。因在 node_modules 下的安裝新包後會丟失軟連接。
import { ChineseAdjustor } from '../adjust-chinese-ts';
import { toVerticalWriting, defaultVerticalWritingStyle, ReplacePunctuation } from '../chinese-text-render';  //ReplacePunctuation,
import type { VerticalWritingStyle } from '../chinese-text-render';

import chardet from 'chardet';
import { Base64 } from 'js-base64';


import { domToPng } from 'modern-screenshot';



//https://capawesome.io/plugins/file-picker/
//import { FilePicker } from '@capawesome/capacitor-file-picker';


const reg1 = /(?:url\((['"]).+?\1\))/g;
const reg2 = /(?:(?:repeating-)?linear-gradient\(.+?\))/g;
const reg3 = /(?:(?:repeating-)?conic-gradient\(.+?\))/g;
const reg4 = /(?:(?:repeating-)?radial-gradient\(.+?\))/g;

const filterFunctions = ['blur()','brightness()','contrast()','drop-shadow()','grayscale()','hue-rotate()','invert()','opacity()','sepia()','saturate()'];

const fontFamilies = reactive(['CREATXR_BLACK_MONO','CREATXR_BLACK_MONO_STRETCH','CREATXR_XIAOZUAN_MONO', 'HanaMinA','HanaMinB','sans-serif','sans-serif-thin','sans-serif-light','sans-serif-medium','sans-serif-black','arial','helvetica','tahoma','verdana','sans-serif-condensed','sans-serif-condensed-light','sans-serif-condensed-medium','serif','serif-bold','times','times new roman','palatino','georgia','baskerville','goudy','fantasy','ITC Stone Serif','monospace','sans-serif-monospace','monaco','serif-monospace','courier','courier new','casual','cursive','sans-serif-smallcaps','source-sans-pro','source-sans-pro-semi-bold','roboto-flex']);

const chineseTextStyle: VerticalWritingStyle = reactive({
	SPACE: '　',
	spliterNewLine: '\n\|',
	punctuations: '。﹐﹑﹔﹕﹖﹗' + '，、；：？！' + ' \|\t' + '\'\"\`‘’“”「」『』《》〈〉«»‹›',
	maxCharsPerCol: 8,
	maxColsPerPage: 10,
	cornerTopLeft: '╔',
	cornertopRight: '╗',
	cornerBottomLeft: '╚',
	cornerBottomRight: '╝',
	spliterVerticalTop: '╤',
	spliterVertical: '╎',
	spliterVerticalBottom: '╧',
	borderVertical: '║',
	borderHorizontal: '═',
	//replacePunctuation: 'space'
	replacePunctuation: ReplacePunctuation.none,
	newLineReplacement: '\n'
});

const text = ref('let temp = {`("...[\'《隨筆》：冷胙告初祖，渝期沒吟毀。\']")`}; 文本顏色綜合測試 color test color test '.repeat(10));  //use ref() to auto render to html with binding
text.value = '道﹐可道也﹐非恆道也。名﹐可名也﹐非恆名也。「無」﹐名天地之始﹔「有」﹐名萬物之母。故﹐常「無」﹐欲以觀其妙﹔常「有」﹐欲以觀其徼。此兩者﹐同出而異名﹐同謂之玄。玄之又玄﹐眾妙之門。';


const closeAll = () => {
	// adjust selector to fit your needs
	const overlays = document.querySelectorAll('ion-alert, ion-action-sheet, ion-loading, ion-modal, ion-picker, ion-popover, ion-toast');
	const overlaysArr = Array.from(overlays) as HTMLIonOverlayElement[];
	overlaysArr.forEach(o => o.dismiss());
};

/*
const events = Events;
events.subscribe('gradient:created', async(data) => {
	console.log(data);
});
//*/


//in ionic 7 starter, it only has "favicon.png" in root folder "/", not "assets", and it has not "shapes.svg".
const backgroundImageArray = ref([
	'url("/favicon.png")',
	'url("/shapes.svg")',
	"repeating-linear-gradient(135deg,red,orange,yellow,green,blue,indigo,violet)",
]);

const cssBgImg = computed({
	get: () => { return backgroundImageArray.value.join(',') },
	set: (value) => {
		const reg = new RegExp(reg1.source
			+ '|' + reg2.source
			+ '|' + reg3.source
			+ '|' + reg4.source, 'g');
		backgroundImageArray.value = value.match(reg) || [];
	}
});


const editorStyle = ref({
	whiteSpace: 'pre-wrap',
	minWidth: '100',
	fontFamily: 'monospace',
	fontSize: '16px',
	fontWeight: 'normal',
	fontStyle: 'normal',
	color: "",
	backgroundColor: "transparent",
//	mixBlendMode: "difference",
	WebkitBackgroundClip: 'text',
	WebkitTextFillColor: 'transparent',  //transparent
	WebkitFilter: '',
	backgroundImage: cssBgImg,
	backgroundSize: 'contain', //cover, contain
	backgroundRepeat: 'repeat', //no-repeat
});


const pickFont = async () => {
	/*
	const result = await FilePicker.pickFiles({
		types: ['font/ttf'],
		multiple: false,
	});

	console.log(result.files[0]);
	if(result.files[0] !== undefined) {
		const font = new FontFace(`${result.files[0].name}`, `url("${result.files[0].path}")`);
		document.fonts.add(font);
		console.log(`${result.files[0].name}`);
		fontFamilies.push(`${result.files[0].name}`);
		//text.value = result.files[0].name;
		//text.value = result.files[0].path || '';
	}
	*/
	async function readFileAsync(file:any) {
		return new Promise((resolve, reject) => {
			let reader = new FileReader();
			reader.onload = () => {
			resolve(reader.result);
		};
			reader.onerror = reject;
			reader.readAsDataURL(file);
		})
	}
	const [fileHandle] = await showOpenFilePicker({
			/*
			types: [
				{ accept: { 'font/ttf': ['.ttf'] } }
			],
			*/
			excludeAcceptAllOption: true, // default
			multiple: false, // default
			//_preferPolyfill: false // default
		});
	const file = await fileHandle.getFile();
	let upFileContent = await readFileAsync(file);
	const faceName = new String(fileHandle.name).replaceAll(/[\.\s]+/g, '_');
	const font = new FontFace(faceName, `url('${upFileContent}')`);
	document.fonts.add(font);
	fontFamilies.unshift(faceName);
	editorStyle.value.fontFamily = faceName;
};

const openText = async() => {
	async function readFileAsync(file:any) {
		return new Promise((resolve, reject) => {
			let reader = new FileReader();
			reader.onload = () => {
			resolve(reader.result);
		};
			reader.onerror = reject;
			//https://developer.mozilla.org/en-US/docs/Web/API/FileReaderSync/readAsDataURL
			//reader.readAsText(file);  //非 utf8 的會亂碼，且無法徵測正確的編碼。
			//reader.readAsDataURL(file);
			reader.readAsArrayBuffer(file);
		})
	}
	const [fileHandle] = await showOpenFilePicker({
			//startIn: "documents",
			/*
			types: [
				{
					description: 'text',
					accept: { "text/*": [ ".txt" ] }
				}
			],
			*/
			multiple: false, // default
			excludeAcceptAllOption: true, // default
			//_preferPolyfill: false // default
		});
	const file = await fileHandle.getFile();
	let upFileContent = await readFileAsync(file);
	let buf = new Uint8Array(upFileContent as ArrayBufferLike);  //必須轉成 Uint8Array
	let encoding = chardet.detect(buf) || '';
	//console.log(encoding);
	if(/\.txt$/i.test(fileHandle.name)) {
		//text.value = ChineseAdjustor.encodingToUtf8(buf);
		text.value = new TextDecoder(encoding).decode(buf);
	}
};

const openImage = async() => {
	async function readFileAsync(file:any) {
		return new Promise((resolve, reject) => {
			let reader = new FileReader();
			reader.onload = () => {
			resolve(reader.result);
		};
			reader.onerror = reject;
			reader.readAsDataURL(file);
		})
	}
	const [fileHandle] = await showOpenFilePicker({
			multiple: false, // default
			excludeAcceptAllOption: false, // default
			//_preferPolyfill: false // default
		});
	const file = await fileHandle.getFile();
	let upFileContent = await readFileAsync(file);
	backgroundImageArray.value.unshift(`url('${upFileContent}')`);
};

const textChange = (ev: any) => {
	text.value = ev.target.innerText;
};

const removeImage = (ev: any) => {
	//console.log(ev.target.id.replace('relId',''));
	let index = parseInt(ev.target.id.replace('relId',''));
	backgroundImageArray.value.splice(index, 1);
	//console.log(backgroundImageArray.value);
};

const upImage = (ev: any) => {
	let index = parseInt(ev.target.id.replace('relId',''));
	if (index > 0) {
		[backgroundImageArray.value[index-1], backgroundImageArray.value[index]]
			= [backgroundImageArray.value[index], backgroundImageArray.value[index-1]];
	}
};

const downImage = (ev: any) => {
	let index = parseInt(ev.target.id.replace('relId',''));
	if (index < backgroundImageArray.value.length-1) {
		[backgroundImageArray.value[index], backgroundImageArray.value[index+1]]
			= [backgroundImageArray.value[index+1], backgroundImageArray.value[index]];
	}
};


const adjustModal = ref();
const customDict = reactive(['雖𨿽', '個个', '網网']);  //「𨿽」字在網頁上通常不能顯示，繁體通常用「個網」字。
const tempDict = reactive(['', '']);
const dicts = reactive(['traAdjustT','standardT','contextT','symbolT', customDict, tempDict]);

const adjustChinese = () => {
	const adjustor = new ChineseAdjustor(dicts);
	text.value = adjustor.adjust(text.value);
	adjustModal.value.$el.dismiss(null, 'cancel');
};

const addPattern = () => {
	tempDict.push('');
}

const removePattern = (ev: Event) => {
	const target = ev.target as HTMLButtonElement;
	let index = parseInt(target.id.replace('pattern',''));
	tempDict.splice(index, 1);
}

const updatePattern = (ev: Event) => {
	const target = ev.target as HTMLInputElement;
	let index = parseInt(target.id.replace('pattern',''));
	tempDict[index] = target.value;
	//console.log(tempDict);
}


const refVerticalModal = ref();
const renderVerticalWriting = () => {
	//console.log(chineseTextStyle);
	text.value = toVerticalWriting(text.value, chineseTextStyle);
	//console.log(text.value);
	refVerticalModal.value.$el.dismiss(null, 'cancel');
};

const refFontModal = ref();
const fontModalCancel = () => {
	refFontModal.value.$el.dismiss(null, 'cancel');
};

const refExpertModal = ref();
const expertModalCancel = () => {
	refExpertModal.value.$el.dismiss(null, 'cancel');
};

const prefs = reactive({
	gradients: []
});


//*
const refGradientModal = ref();
const gradientModalCancel = () => {
	refGradientModal.value.$el.dismiss(null, 'cancel');
};
//*/

const openGradientModal = async() => {
	const keyName = 'gradients';
	const preRes: any = await Preferences.get({ key: keyName });
	const res = JSON.parse(preRes.value) || [];
	//if(res === null) res = [];
	prefs.gradients = res;
	refGradientModal.value.$el.present();
}

const refAccordionGroup = ref();

const addGradient = () => {
	const el = refAccordionGroup.value.$el;
	if(el.value === undefined) return;
	//console.log(prefs.gradients[el.value]);
	backgroundImageArray.value.unshift(prefs.gradients[el.value]);
	refGradientModal.value.$el.dismiss();
};



const borderToggle = ref(true);

const borderToggleChange = (ev: any) => {
	if(ev.detail.checked) {
		//borderToggle.value = true;
		//忘了之前爲什麼雖然 toggle 的 :checked="borderToggle" 卻不會自動同步，要在 ionChange 事件中更改。或是忘了加冒號綁定，或是沒刷新頁面。
		chineseTextStyle.cornerTopLeft =  '╔';
		chineseTextStyle.cornertopRight =  '╗';
		chineseTextStyle.cornerBottomLeft =  '╚';
		chineseTextStyle.cornerBottomRight =  '╝';
		chineseTextStyle.spliterVerticalTop =  '╤';
		chineseTextStyle.spliterVertical =  '╎';
		chineseTextStyle.spliterVerticalBottom =  '╧';
		chineseTextStyle.borderVertical =  '║';
		chineseTextStyle.borderHorizontal =  '═';
	} else {
		//borderToggle.value = false;
		chineseTextStyle.cornerTopLeft = '';
		chineseTextStyle.cornertopRight = '';
		chineseTextStyle.cornerBottomLeft = '';
		chineseTextStyle.cornerBottomRight = '';
		chineseTextStyle.spliterVerticalTop = '';
		chineseTextStyle.spliterVertical = '';
		chineseTextStyle.spliterVerticalBottom = '';
		chineseTextStyle.borderVertical = '';
		chineseTextStyle.borderHorizontal = '';
	}
};



/** https://ionicframework.com/docs/theming/dark-mode */
const themeToggle = ref(false);
// Use matchMedia to check the user preference
const prefersDark = window.matchMedia('(prefers-color-scheme: dark)');
// Add or remove the "dark" class on the document body
const toggleDarkTheme = (shouldAdd: boolean) => {
	document.body.classList.toggle('dark', shouldAdd);
};
// Check/uncheck the toggle and update the theme based on isDark
const initializeDarkTheme = (isDark: boolean) => {
	themeToggle.value = isDark;
	toggleDarkTheme(isDark);
};
// Initialize the dark theme based on the initial
// value of the prefers-color-scheme media query
initializeDarkTheme(prefersDark.matches);
// Listen for changes to the prefers-color-scheme media query
prefersDark.addEventListener('change', (mediaQuery) => initializeDarkTheme(mediaQuery.matches));
// Listen for the toggle check/uncheck to toggle the dark theme
const toggleChange = (ev: ToggleCustomEvent) => {
	toggleDarkTheme(ev.detail.checked);
};


const isImageUrl = (str: string): boolean => {
	const reg = new RegExp(reg1.source, 'g');
	return reg.test(str);
};

const isImageGradient = (str: string): boolean => {
	const reg = new RegExp(reg2.source
			+ '|' + reg3.source
			+ '|' + reg4.source, 'g');
	return reg.test(str);
};


const gradientToggleChange = (ev: ToggleCustomEvent) => {
	if(ev.detail.checked) {
		editorStyle.value.backgroundColor = 'transparent';
		editorStyle.value.WebkitBackgroundClip = 'text';
		editorStyle.value.WebkitTextFillColor = 'transparent';
	} else {
		editorStyle.value.backgroundColor = '';
		editorStyle.value.WebkitBackgroundClip = '';
		editorStyle.value.WebkitTextFillColor = '';
	}
};


const isGradientTextChecked = () => {
	if((editorStyle.value.backgroundColor === 'transparent')
		&& (editorStyle.value.WebkitBackgroundClip === 'text')
		&& (editorStyle.value.WebkitTextFillColor === 'transparent')) {
			return true;
		}
	return false;
};


const grandientTextToggle = ref(true);

watch([editorStyle], async(newVal, oldVal) => {
	if(isGradientTextChecked()) {
		grandientTextToggle.value = true;
	} else {
		grandientTextToggle.value = false;
	}
}, { deep: true });



const divshotDataUrl = ref('');
const eleToImg = async() => {
	const dataUrl = await domToPng(document.getElementById('textEditor') as HTMLElement);
	//console.log(dataUrl);
	divshotDataUrl.value = dataUrl;
	if(Capacitor.getPlatform() === 'web') {
		const fileHandle = await showSaveFilePicker({
			_preferPolyfill: false,
			suggestedName: 'Untitled.png',
			excludeAcceptAllOption: false // default
		});
		const blob = await (await fetch(dataUrl)).blob();  //in morden browser
		//console.log(blob);
		const writer = await fileHandle.createWritable();
		await writer.write(blob);
		await writer.close();
	} else {
		const base64Data = dataUrl.replace(/^data:image\/png;base64\,/, '');
		const fileName = Date.now() + '.png';
		const savedFile = await Filesystem.writeFile({
				path: fileName,
				data: base64Data,
				directory: Directory.Documents
			});
	}

/*
	domToPng(document.getElementById('textEditor') as HTMLElement).then(dataUrl => {
		const link = document.createElement('a')
		link.download = 'screenshot.png'
		link.href = dataUrl
		link.click()
	})
//*/

//console.log(document.getElementsByTagName('ion-button')[0].getBoundingClientRect());
}



/*
{
	"alert_radio_label_sc_ion_alert_md": {
		"whiteSpace": "normal !important"
	},
	"alert_radio_label_sc_ion_alert_ios": {
		"whiteSpace": "normal !important"
	}
}
*/

/*//https://blog.logrocket.com/reactivity-vue-3-composition-api-ref-reactive/
ref() vs. reactive(): Which should you use?

The significant difference between ref() and reactive() is that the ref()function allows us to declare reactive state for primitives and objects, while reactive() only declares reactive state for objects.

We also have to access the value of ref() by using the .value property on the returned object, but we don’t have to do that for reactive() objects. Therefore, in real-world scenarios, you’ll find more Vue code that uses ref() than reactive(), but reactive() is perfect because it can easily accept state as it was defined before the Composition API. Both effectively track reactivity, so which one to use is a matter of preference and coding style.
*/
</script>

<style>
/* https://css-tricks.com/almanac/properties/f/font-stretch/ */



@font-face {
  font-family: 'CREATXR_BLACK_MONO';
  src: url('/fonts/CREATXR_BLACK_MONO.ttf');
}

@font-face {
  font-family: 'CREATXR_BLACK_MONO_STRETCH';
  src: url('/fonts/CREATXR_BLACK_MONO_STRETCH.ttf');
}

@font-face {
  font-family: 'CREATXR_XIAOZUAN_MONO';
  src: url('/fonts/CREATXR_XIAOZUAN_MONO.ttf');
}

@font-face {
  font-family: 'HanaMinA';
  src: url('/fonts/HanaMinA.ttf');
}

@font-face {
  font-family: 'HanaMinB';
  src: url('/fonts/HanaMinB.ttf');
}


/* <ion-select multiple="true" ... */
.alert-checkbox-label.sc-ion-alert-md,
.alert-checkbox-label.sc-ion-alert-ios {
  white-space: normal !important;
}

/* <ion-select multiple="false" ... */
.alert-radio-label.sc-ion-alert-md,
.alert-radio-label.sc-ion-alert-ios {
  white-space: normal !important;
}
/*
ion-modal {
  --ion-background-color: rgba(0,0,0,0.1) !important;
}
*/

.scrollX {
  overflow-x: scroll !important;
}




.customModal {

}
</style>



<style scoped>
ion-toggle {
	touch-action: auto;
}
</style>
