import { LightningElement, api, track } from "lwc";
import AWS_ICONS from "@salesforce/resourceUrl/swan_amazonIcons";
import swan_AmazonFiles from "@salesforce/label/c.swan_AmazonFiles";
import swan_Cancel from "@salesforce/label/c.swan_Cancel";
import swan_Finish from "@salesforce/label/c.swan_Finish";
import swan_Upload from "@salesforce/label/c.swan_Upload";

const LWC_AMAZON_FILES_UPLOADER_MODAL =
	"c-swan-_-amazon-file-uploader-modal-file";

export default class Swan_AmazonFileUploaderModal extends LightningElement {
	isOpen = false; // Use to show/hide the modal

	@api flexipageRegionWidth;
	@track filesToUpload = [];
	@track successfullyUploadedFilesMetadata = [];

	filesLength = 0;
	numberOfRemovedFiles = 0;

	isActionButtonsDisabled = false;

	numberOfSuccessfullyUploadedFiles = 0;
	numberOfFailedUploadedFiles = 0;

	labels = {
		amazonFiles: swan_AmazonFiles,
		cancel: swan_Cancel,
		finish: swan_Finish,
		upload: swan_Upload
	};

	icons = {
		uploadIcon: AWS_ICONS + "/swan_uploadIcon.svg"
	};

	@api
	openModal(filesToUpload) {
		this.clearData();

		this.derevo = "kek";
		this.filesToUpload = Object.assign(
			[],
			this.prepareFilesForUploading(filesToUpload)
		);
		this.filesLength = this.filesToUpload.length;

		this.isOpen = true;
	}

	@api
	closeModal() {
		const modal = this.template.querySelector(".slds-modal");
		const backdrop = this.template.querySelector(".slds-backdrop");
		if (modal) {
			modal.classList.add("fade-scale-out");
			backdrop.classList.add("fade-out");
			// Optional: Use a timeout to remove or hide the modal from the DOM after the animation completes
			setTimeout(() => {
				const closeEvent = new CustomEvent("close", {
					detail: {
						uploadedFiles: this.successfullyUploadedFilesMetadata
					}
				});

				this.dispatchEvent(closeEvent);
				this.isOpen = false;
			}, 200); // Match the animation duration
		}
	}

	startUploading() {
		this.isActionButtonsDisabled = true;

		let fileElements = this.template.querySelectorAll(
			LWC_AMAZON_FILES_UPLOADER_MODAL
		);

		const visibleFiles = Array.from(fileElements).filter((el) => {
			return el.parentNode.style.display !== "none";
		});

		visibleFiles.forEach((fileElement) => {
			fileElement.startUploading();
		});
	}

	hideFooter() {
		let footerElement = this.template.querySelector(".slds-modal__footer");

		footerElement.classList.add("collapsed");
	}

	fileUploaderMediator() {
		let totalFilesFinished =
			this.numberOfSuccessfullyUploadedFiles +
			this.numberOfFailedUploadedFiles;
		if (
			totalFilesFinished !=
			this.filesLength - this.numberOfRemovedFiles
		) {
			return;
		}

		if (!this.numberOfFailedUploadedFiles) {
			setTimeout(() => {
				this.closeModal();
			}, 300);
		} else {
			setTimeout(() => {
				this.showButtonFinish();
			}, 300);
		}
	}

	showButtonFinish() {
		let footerElement = this.template.querySelector(".slds-modal__footer");

		if (footerElement) {
			footerElement.classList.remove("collapsed");
			footerElement.classList.add("collapsed-reverse");
		}

		let customButtons = this.template.querySelectorAll(".custom-button");

		customButtons.forEach((button) => {
			if (!button.classList.contains("slds-hide")) {
				button.classList.add("slds-hide");
			} else {
				button.classList.remove("slds-hide");
			}
		});
	}

	removeFile(file) {
		file.isRemoved = true;

		if (this.numberOfRemovedFiles === 0) {
			this.setHardcodedHeightToFilesContainer();
		}

		let fileElement = this.template.querySelector(
			`lightning-layout-item[data-key="${file.id}"]`
		);

		fileElement.classList.add("fade-out");
		setTimeout(() => {
			fileElement.style.display = "none";
		}, 500);

		this.numberOfRemovedFiles++;

		if (this.numberOfRemovedFiles == this.filesLength) {
			this.closeModal();
		}
	}

	setHardcodedHeightToFilesContainer() {
		let filesContainerElement = this.template.querySelector(
			".slds-modal__content"
		);

		filesContainerElement.style.height =
			filesContainerElement.getBoundingClientRect().height + "px";
	}

	prepareFilesForUploading(filesToUpload) {
		filesToUpload.forEach((file) => {
			file.id = this.generateRandomKey(15);
			file.isRemoved = false;
			//file.size = file.size / 10
		});

		return filesToUpload;
	}

	generateRandomKey(length) {
		const possibleCharacters =
			"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
		let key = "";
		for (let i = 0; i < length; i++) {
			const randomIndex = Math.floor(
				Math.random() * possibleCharacters.length
			);
			key += possibleCharacters.charAt(randomIndex);
		}
		return key;
	}

	clearData() {
		this.filesLength = 0;
		this.numberOfRemovedFiles = 0;
		this.numberOfFailedUploadedFiles = 0;
		this.numberOfSuccessfullyUploadedFiles = 0;
		this.isActionButtonsDisabled = false;
		this.filesToUpload = [];
		this.successfullyUploadedFilesMetadata = [];

		let footerElement = this.template.querySelector(".slds-modal__footer");

		if (footerElement) {
			footerElement.classList.remove("collapsed");
		}
	}

	handleUploadSuccess(event) {
		this.numberOfSuccessfullyUploadedFiles++;

		this.successfullyUploadedFilesMetadata.push(event.detail.uploadedFile);

		this.fileUploaderMediator();
	}

	handleUploadFailure(event) {
		this.numberOfFailedUploadedFiles++;

		this.fileUploaderMediator();
	}

	handleRemove(event) {
		this.removeFile(event.detail.file);
	}

	handleSave() {
		this.closeModal(); // Close the modal after the action
	}

	handleCancel(event) {
		this.closeModal();
	}

	handleUpload(event) {
		this.hideFooter();
		this.startUploading();
	}

	handleFinish(event) {
		this.closeModal();
	}

	get isSizeSmall() {
		return this.flexipageRegionWidth === "SMALL";
	}
}
