import { LightningElement, api } from "lwc";
import createAmazonFileMetadataRecord from "@salesforce/apex/swan_AmazonFilesController.createAmazonFileMetadataRecord";
import AWS_ICONS from "@salesforce/resourceUrl/swan_amazonIcons";
import Name from "@salesforce/schema/User.Name";
import Id from "@salesforce/schema/User.Id";
import FACTOR from "@salesforce/client/formFactor";
import swan_TypeSomething from "@salesforce/label/c.swan_TypeSomething";

const SUCCESS = "success";
const FAILURE = "failure";

export default class Swan_AmazonFileUploaderModalFile extends LightningElement {
	@api file;
	@api fileContainerStyle = "height: 70px;";
	@api expanderContainerStyle = "height: 100px;";

	@api recordId;

	isExpanded = false;
	fileNote = "";

	userName = Name;
	userId = Id;

	@api startUploading() {
		this.prepareCardForUpload();
		this.uploadFileToS3();
	}

	labels = {
		typeSomething: swan_TypeSomething
	};

	icons = {
		cssIcon: AWS_ICONS + "/swan_cssIcon.svg",
		docIcon: AWS_ICONS + "/swan_docIcon.svg",
		fileIcon: AWS_ICONS + "/swan_fileIcon.svg",
		jpgIcon: AWS_ICONS + "/swan_jpgIcon.svg",
		pdfIcon: AWS_ICONS + "/swan_pdfIcon.svg",
		pngIcon: AWS_ICONS + "/swan_pngIcon.svg",
		txtIcon: AWS_ICONS + "/swan_txtIcon.svg",
		trashIcon: AWS_ICONS + "/swan_trashIcon.svg",
		noteIcon: AWS_ICONS + "/swan_noteIcon.svg"
	};

	uploadFileToS3() {
		let uploadParams = {
			Bucket: this.file.bucketName,
			Key: `${this.file.recordId}/${this.file.id + "-" + this.file.name}`, // Customize your file path
			Body: this.file,
			ContentType: this.file.type,
			Metadata: {
				"uploader-name": this.file.userName,
				"uploader-id": this.file.userId
			}
		};
		const s3 = new AWS.S3();

		s3.upload(uploadParams, (err, data) => {
			if (err) {
				console.error(err.message);
				this.handleUploadFailure();
			} else {
				this.handleUploadSuccess();
			}
		});
	}

	createMetadataRecord(file) {
		return new Promise((resolve, reject) => {
			createAmazonFileMetadataRecord({
				recordId: file.recordId,
				mimeType: file.type,
				key: `${file.recordId}/${file.id + "-" + file.name}`,
				note: this.fileNote,
				size: file.size,
				fileName: file.name
			})
				.then((fileMetadata) => {
					resolve(fileMetadata);
				})
				.catch((err) => {
					reject(err);
				});
		});
	}

	setProgressBarStatus(status) {
		let progressBarElement = this.template.querySelector(
			"c-swan-_-progress-bar"
		);

		switch (status) {
			case SUCCESS:
				progressBarElement.toggleSuccess();
				break;
			case FAILURE:
				progressBarElement.toggleFailure();
		}
	}

	prepareCardForUpload() {
		this.hideExpander();
		this.hideActionButtonsAndShowLoader();
	}

	hideExpander() {
		if (!this.isExpanded) return;

		let expanderElement = this.template.querySelector(
			".file-expander-container"
		);
		expanderElement.classList.add("collapsed");

		setTimeout(() => {
			this.isExpanded = false;
			expanderElement.classList.remove("collapsed");
		}, 500);
	}

	hideActionButtonsAndShowLoader() {
		let actionButtonsWrapperElement = this.template.querySelector(
			".action-buttons-wrapper"
		);
		let progressBarElement = this.template.querySelector(
			"c-swan-_-progress-bar"
		);
		actionButtonsWrapperElement.classList.add("buttons-collapsed");
		setTimeout(() => {
			actionButtonsWrapperElement.style.display = "none";
			progressBarElement.style.display = "block";
		}, 200);
	}

	handleUploadFailure() {
		this.setProgressBarStatus(FAILURE);

		const uploadFailedEvent = new CustomEvent("uploadfailure", {
			detail: { file: this.file }
		});

		this.dispatchEvent(uploadFailedEvent);
	}

	handleUploadSuccess() {
		this.createMetadataRecord(this.file).then((uploadedFile) => {
			this.setProgressBarStatus(SUCCESS);

			const uploadSuccessEvent = new CustomEvent("uploadsuccess", {
				detail: {
					file: this.file,
					uploadedFile: uploadedFile
				}
			});

			this.dispatchEvent(uploadSuccessEvent);
		});
	}

	handleNoteEdit(event) {
		this.fileNote = event.target.value;
	}

	handleRemove(event) {
		const removeEvent = new CustomEvent("remove", {
			detail: { file: this.file }
		});

		this.dispatchEvent(removeEvent);
	}

	handleExpander(event) {
		if (!this.isExpanded) {
			this.isExpanded = true;
			return;
		}

		this.hideExpander();
	}

	get fileSize() {
		if (this.file.size <= 1000000) {
			return Math.ceil(this.file.size / 1000) + "KB";
		} else {
			return Math.ceil(this.file.size / 1000000) + "MB";
		}
	}

	get fileName() {
		let limit = 15;

		if (FACTOR === "Small") {
			limit = 9;
		}

		if (this.file.name.length < limit) {
			return this.file.name;
		} else {
			return this.file.name.substring(0, limit) + "...";
		}
	}

	get fileIcon() {
		switch (this.file.type) {
			case "image/png":
				return this.icons.pngIcon;
			case "image/jpeg":
				return this.icons.jpgIcon;
			case "text/css":
				return this.icons.cssIcon;
			case "application/msword":
				return this.icons.docIcon;
			case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
				return this.icons.docIcon;
			case "text/plain":
				return this.icons.txtIcon;
			case "application/pdf":
				return this.icons.pdfIcon;
			default:
				return this.icons.fileIcon;
		}
	}
}
