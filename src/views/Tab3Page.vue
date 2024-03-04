<template>
	<ion-page>
		<ion-header>
			<ion-toolbar>
				<ion-item>
					<ion-button @click="saveGradient">保存</ion-button>
					<ion-button @click="addNewColor">加色</ion-button>
					<ion-button @click="openGradientModal">預設</ion-button>
				</ion-item>
			</ion-toolbar>
		</ion-header>
		<ion-segment :scrollable="true"
			v-model="curGradient">
			<ion-segment-button value="repeating-conic-gradient">conic</ion-segment-button>
			<ion-segment-button value="repeating-linear-gradient">linear</ion-segment-button>
			<ion-segment-button value="repeating-radial-gradient">radial</ion-segment-button>
		</ion-segment>

		<ion-content>
		<ion-list>
			<!--https://vuetifyjs.com/en/components/switches/ -->
			<!--v-switch and v-case are not native -->
			<!--[Vue warn]: Failed to resolve directive: case  -->
				<ion-item v-if="curGradient === 'repeating-conic-gradient'">
					<ion-input label="from Numberdeg:" type="number"
						v-model.number="propFrom"
						/>
					<!--
					<ion-input label="at Numberdeg:" type="number"
						v-for="(item, index) in propAt"
						:value="item"
						/>
					-->

					<ion-input label="at position:" type="text" v-model="mixGradientSyntax.at" placeholder="at 50% 50%" />

				</ion-item>
				<ion-item v-else-if="curGradient === 'repeating-linear-gradient'">
					<ion-input label="Numberdeg:" type="number"
						v-model.number="propAngle"
						/>
				</ion-item>
				<ion-item v-else-if="curGradient === 'repeating-radial-gradient'">
					<ion-input label="size:" type="text" v-model="mixGradientSyntax.size" placeholder="10% 10% or ellipse or circle or closest-corner or closest-side or farthest-corner or farthest-side" />
					<ion-input label="at position:" type="text" v-model="mixGradientSyntax.at" placeholder="at 50% 50%" />
				</ion-item>
			<ion-grid>
				<ion-row v-for="(item, index) in mixGradientSyntax.colorStopList" :key="index">
					<ion-col><ion-input :style="{minWidth: '100px'}" type="text" v-model="item[0]" /></ion-col>
					<ion-col><input v-if="item[0].match(/#/)" type="color" opacity rgba cmyk hsla v-model="item[0]" /></ion-col>
					<ion-col><ion-input v-if="isColor(item[0])" type="text" v-model="item[1]" :style="{minWidth: '35px'}" /></ion-col>
					<ion-col><ion-input v-if="isColor(item[0])" type="text" v-model="item[2]" :style="{minWidth: '35px'}" /></ion-col>
					<ion-col><ion-button :id="`btn${index}`" @click="moveUpColorStop">上移</ion-button></ion-col>
					<ion-col><ion-button :id="`btn${index}`" @click="moveDownColorStop">下移</ion-button></ion-col>
					<ion-col><ion-button :id="`btn${index}`" @click="removeColorStop">刪除</ion-button></ion-col>
					<!-- TypeError: win[(("HTML" + (intermediate value)) + "Element")] is undefined -->
					<!-- cannot use :id="`${index}`" which is a number -->
				</ion-row>
			</ion-grid>
			<ion-item>
				<div :style="gradientEffect"></div>
			</ion-item>
		</ion-list>
		<ion-modal ref="refGradientModal">
			<ion-toolbar>
				<ion-item>
					<ion-button @click="gradientModalCancel">關閉</ion-button>
					<ion-button @click="removeGradient">刪除</ion-button>
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
		</ion-content>
	</ion-page>
</template>

<script setup lang="ts">
import { IonPage, IonSegment, IonSegmentButton, IonList, IonItem, IonInput, IonContent, IonButton, IonCol, IonGrid, IonRow, IonToolbar, IonHeader, IonAccordionGroup, IonAccordion, IonModal } from '@ionic/vue';
import { ref, computed, watch, watchEffect, reactive } from 'vue';
//https://ionicframework.com/docs/native/preferences
import { Preferences } from '@capacitor/preferences';




import type { RepeatingLinearGradient, LinearGradientSyntax, RepeatingConicGradient, ConicGradientSyntax, RepeatingRadialGradient, RadialGradientSyntax, MixGradientSyntax, ColorStop, ColorHint } from '../gradient';
import { RepeatingLinearGradientImpl, RepeatingConicGradientImpl, RepeatingRadialGradientImpl, isColor } from '../gradient';



const refGradientModal = ref();
const gradientModalCancel = () => {
	refGradientModal.value.$el.dismiss(null, 'cancel');
};


const gradientEffect = reactive({
	width: '100%',
	minHeight: '200px',
	backgroundImage: ''
});

const mixGradientSyntax: MixGradientSyntax = reactive({
	angle: undefined,
	to: undefined,
	from: undefined,
	at: undefined,
	shape: undefined,
	size: undefined,
	colorStopList: [['#ff0000', '10%', '20%'], ['50%'], ['#00ff00', '30%'], ['transparent'], ['#0000ff']]
});

const propFrom = computed({
	get(): number {
		if(mixGradientSyntax.from === undefined) return 0;
		return parseInt(mixGradientSyntax.from.replace('from','').replace('deg',''));
	},

	set(value: number) {
		//if(parseInt(value) !== Number.NaN)
		mixGradientSyntax.from = `from ${value || 0}deg`;
	}
});

const propAngle = computed({
	get(): number {
		if(mixGradientSyntax.angle === undefined) return 0;
		return parseInt(mixGradientSyntax.angle.replace('deg',''));
	},

	set(value: number) {
		//if(parseInt(value) !== Number.NaN)
		mixGradientSyntax.angle = `${value || 0}deg`;
	}
});

const propAt = computed({
	//pos: [50, 50],

	get(): number[] {
		console.log('propat......get()');
		console.log('propat......', mixGradientSyntax.at);
		const retObj = [50, 50];

		if(mixGradientSyntax.at === undefined) return retObj;
		console.log('propat......', mixGradientSyntax.at );
		return retObj;
	},

	set(value: number[]) {
		//mixGradientSyntax.at = `at ${value[0] || 50}% ${value[1] || 50}% `;
		console.log('propAt......set()', value);
		//mixGradientSyntax.at = 'at 50% 50%';
	}
});

const moveUpColorStop = (ev: any) => {
	//console.log(ev.target.id);
	const index = parseInt(ev.target.id.match(/\d+/));
	if(index > 0)
		[mixGradientSyntax.colorStopList[index-1], mixGradientSyntax.colorStopList[index]]
			= [mixGradientSyntax.colorStopList[index], mixGradientSyntax.colorStopList[index-1]];
}

const moveDownColorStop = (ev: any) => {
	//console.log(ev.target.id);
	const index = parseInt(ev.target.id.match(/\d+/));
	if(index < mixGradientSyntax.colorStopList.length-1)
		[mixGradientSyntax.colorStopList[index], mixGradientSyntax.colorStopList[index+1]]
			= [mixGradientSyntax.colorStopList[index+1], mixGradientSyntax.colorStopList[index]];
}

const removeColorStop = (ev: any) => {
	//console.log(ev.target.id);
	const index = parseInt(ev.target.id.match(/\d+/));
	mixGradientSyntax.colorStopList.splice(index, 1);
}

const curGradient = ref('');

watch([curGradient, mixGradientSyntax], async(newVal, oldVal) => {
	//console.log(newVal, oldVal);
	switch(curGradient.value) {
		case 'repeating-conic-gradient':
			const conic = new RepeatingConicGradientImpl();
			conic.syntax = mixGradientSyntax;
			gradientEffect.backgroundImage = conic.toString();
			//console.log('conic......', conic.toString());
			break;
		case 'repeating-linear-gradient':
			const linear = new RepeatingLinearGradientImpl();
			linear.syntax = mixGradientSyntax;
			gradientEffect.backgroundImage = linear.toString();
			//console.log('linear......', linear.toString());
			break;
		case 'repeating-radial-gradient':
			const radial = new RepeatingRadialGradientImpl();
			radial.syntax = mixGradientSyntax;
			gradientEffect.backgroundImage = radial.toString();
			//console.log('radial......', radial.toString());
			break;
	}
}, { deep: true });


const addNewColor = (ev: any) => {
	mixGradientSyntax.colorStopList.push(['#aabbcc']);
}


const saveGradient = async () => {
	const keyName = 'gradients';
	//let preRes: any = await Preferences.get({ key: keyName });
	const preRes: any = await Preferences.get({ key: keyName });
	const res = JSON.parse(preRes.value) || [];
	//let res = JSON.parse(preRes.value);
	//console.log(111111, typeof res, res);
	//if(res === null) res = [];
	//console.log('saveGradient......preset count: ', res.length);
	///console.log(gradientEffect.backgroundImage);
	if(gradientEffect.backgroundImage.length > 0) if(!res.includes(gradientEffect.backgroundImage)) res.push(gradientEffect.backgroundImage);
	await Preferences.set({
		key: keyName,
		value: JSON.stringify(res),
	});
	//console.dir(await Preferences.get({ key: keyName }), { depth: null });
	//await Preferences.remove({ key: keyName });
};


const prefs = reactive({
	gradients: []
});

const openGradientModal = async() => {
	const keyName = 'gradients';
	const preRes: any = await Preferences.get({ key: keyName });
	const res = JSON.parse(preRes.value) || [];
	//if(res === null) res = [];
	prefs.gradients = res;
	refGradientModal.value.$el.present();
}


const refAccordionGroup = ref();

const removeGradient = async() => {
	const el = refAccordionGroup.value.$el;
	if(el.value === undefined) return;
	const keyName = 'gradients';
	prefs.gradients.splice(el.value, 1);
	const preRes: any = await Preferences.get({ key: keyName });
	await Preferences.set({
		key: keyName,
		value: JSON.stringify(prefs.gradients),
	});
}

</script>


<style>

.ion-item {
	overflow-x: scroll !important;
	--border-color: red;
	margin: auto 1;
}

.has-focus {
	border: solid 1px orange !important;
}


/* css comments */

/* https://stackoverflow.com/questions/67547564/how-to-make-a-scrollable-ion-cols-in-a-single-ion-row */
ion-row {
	justify-content: flex-start;
	flex-wrap: nowrap;
	overflow-x: scroll !important;
	overflow-y: hidden;
	white-space: nowrap;
}

ion-row ion-col {
	display: flex;
	flex-wrap: nowrap;
}


</style>



