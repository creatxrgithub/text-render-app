<template>
	<ion-page>
		<ion-header>
			<ion-toolbar>
				<ion-item>

				</ion-item>
			</ion-toolbar>
		</ion-header>

		<ion-content>
			<svg ref="svgRef">
				<ellipse cx="50" cy="50" rx="45" ry="75" fill="#111100" />
			</svg>
		</ion-content>
	</ion-page>
</template>

<script setup lang="ts">
import { IonPage, IonHeader, IonToolbar, IonContent, IonItem, IonInput, IonList, IonButton, IonSelect, IonSelectOption } from '@ionic/vue';
//import { Events } from '@ionic/vue';
//import { ref, computed } from 'vue';
//import { defineProps, defineEmits, defineOptions, defineExpose } from 'vue';
//import { defineExpose } from 'vue';
//import { useEventListener } from '@vueuse/core';
import { ref, computed, reactive, watch } from 'vue';


const svgRef = ref();

//const svg = document.getElementsByTagName("svg")[0];
//const svg = document.querySelector("#svg");
//const bbox = svg.getBBox();
console.log(svgRef);
/*
svg.setAttribute("width", bbox.width + "px");
svg.setAttribute("height", bbox.height + "px");
svg.setAttribute("viewBox", `${bbox.x} ${bbox.y} ${bbox.width} ${bbox.height}`);
*/


</script>


