import { LightningElement, api } from "lwc";
import AWS_ICONS from "@salesforce/resourceUrl/swan_amazonIcons";
import deleteAmazonFile from "@salesforce/apex/swan_AmazonFilesController.deleteAmazonFile";
import swan_Name from "@salesforce/label/c.swan_Name";
import swan_Note from "@salesforce/label/c.swan_Note";
import swan_UploadedBy from "@salesforce/label/c.swan_UploadedBy";

export default class Swan_AmazonFileCard extends LightningElement {
	@api file;

	isExpanded = false;
	isDeleting = false;

	labels = {
		name: swan_Name,
		note: swan_Note,
		uploadedBy: swan_UploadedBy
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

	hideExpander() {
		if (!this.isExpanded) return;

		let expanderElement = this.template.querySelector(".file-description");
		expanderElement.classList.add("collapsed");

		setTimeout(() => {
			this.isExpanded = false;
			expanderElement.classList.remove("collapsed");
		}, 500);
	}

	fireDeletedEvent() {
		const fileDeletedEvent = new CustomEvent("delete", {
			detail: {
				file: this.file
			},
			bubbles: true,
			composed: true
		});

		this.dispatchEvent(fileDeletedEvent);
	}

	deleteMetadataRecord(file) {
		return new Promise((resolve, reject) => {
			deleteAmazonFile({
				recordId: this.fileRecordId(file),
				metadataRecordId: file.Id
			})
				.then(() => {
					resolve();
				})
				.catch((err) => {
					reject(err);
				});
		});
	}

	setDeleteStyles() {
		let elementsToDisable = this.template.querySelectorAll(
			".file-container, .file-expander-button, .action-buttons-container"
		);

		elementsToDisable.forEach((element) => {
			element.classList.add("cursor-wait");
		});
	}

	fileRecordId(file) {
		return file.Key__c.split("/")[0];
	}

	handleExpander(event) {
		if (!this.isExpanded) {
			this.isExpanded = true;
			return;
		}

		this.hideExpander();
	}

	handleDelete(event) {
		const deleteStarted = new CustomEvent("deletestart", {
			composed: true,
			bubbles: true
		});

		this.dispatchEvent(deleteStarted);

		this.isDeleting = true;

		this.setDeleteStyles();

		let deleteParams = {
			Bucket: this.file.BucketName,
			Key: `${this.file.Key__c}` // Customize your file path based on how it was uploaded
		};

		const s3 = new AWS.S3();
		s3.deleteObject(deleteParams, (err, data) => {
			if (err) {
				console.error(err.message);
			} else {
				this.isDeleting = true;
				this.handleDeleteSuccess(); // Define this method to handle successful deletions
			}
		});
	}

	handleDeleteSuccess() {
		this.deleteMetadataRecord(this.file).then(() => {
			this.fireDeletedEvent();
		});
	}

	handleFileView(event) {
		if (this.isDeleting) {
			return;
		}

		const s3 = new AWS.S3();

		// Parameters for the pre-signed URL
		const uploadParams = {
			Bucket: this.file.BucketName,
			Key: `${this.file.Key__c}`, // Customize your file path
			Expires: 60 * 5 // The URL expires in 5 minutes
		};

		// Create a pre-signed PUT URL for file uploads
		s3.getSignedUrl("getObject", uploadParams, (err, url) => {
			if (err) {
				console.error(err.message);
			} else {
				window.open(url);
			}
		});
	}

	get fileIcon() {
		switch (this.file.MIME__c) {
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

	get fileSize() {
		if (this.file.Size__c <= 1000000) {
			return Math.ceil(this.file.Size__c / 1000) + "KB";
		} else {
			return Math.ceil(this.file.Size__c / 1000000) + "MB";
		}
	}

	get fileName() {
		if (this.file.FileName__c.length < 15) {
			return this.file.FileName__c;
		} else {
			return this.file.FileName__c.substring(0, 18) + "...";
		}
	}

	get fileHasNote() {
		return this.file.Note__c && this.file.Note__c.length > 0;
	}

	get isEditPermission() {
		return this.file.Permission === "EDIT";
	}
}
