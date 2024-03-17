import { LightningElement, api } from "lwc";

const CLASS_CIRCLE_LOADER_SELECTOR = ".circle-loader";
const CLASS_CHECKMARK_SELECTOR = ".checkmark";
const CLASS_LOAD_COMPLETE = "load-complete";
const CLASS_LOAD_FAILURE = "load-failure";
const CLASS_LOAD_SUCCESS = "load-success";

export default class Swan_ProgressBar extends LightningElement {
	@api
	toggleFailure() {
		let circleLoaderElement = this.template.querySelector(
			CLASS_CIRCLE_LOADER_SELECTOR
		);

		circleLoaderElement.classList.add(CLASS_LOAD_COMPLETE);
		circleLoaderElement.classList.add(CLASS_LOAD_FAILURE);
	}

	@api
	toggleSuccess() {
		let circleLoaderElement = this.template.querySelector(
			CLASS_CIRCLE_LOADER_SELECTOR
		);

		circleLoaderElement.classList.remove(CLASS_LOAD_FAILURE);
		circleLoaderElement.classList.add(CLASS_LOAD_COMPLETE);
		circleLoaderElement.classList.add(CLASS_LOAD_SUCCESS);

		let checkmarkElement = this.template.querySelector(
			CLASS_CHECKMARK_SELECTOR
		);

		checkmarkElement.style.display = "block";
	}
}
