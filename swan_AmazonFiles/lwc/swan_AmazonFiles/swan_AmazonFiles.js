import { LightningElement, api, track } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import userId from "@salesforce/user/Id";
import assumeRoleForCurrentUserToUploadFiles from "@salesforce/apex/swan_AmazonFilesController.assumeRoleForCurrentUserToUploadFiles";
import swan_AmazonFiles from "@salesforce/label/c.swan_AmazonFiles";
import swan_AccessDenied from "@salesforce/label/c.swan_AccessDenied";
import swan_DragAndDropYourFiles from "@salesforce/label/c.swan_DragAndDropYourFiles";
import swan_Uploading from "@salesforce/label/c.swan_Uploading";
import swan_NoFiles from "@salesforce/label/c.swan_NoFiles";

import AWS_ICONS from "@salesforce/resourceUrl/swan_amazonIcons";
import AWS_SDK from "@salesforce/resourceUrl/awssdk";

const LWC_SHOW_AMAZON_FILES = "c-swan-_-show-amazon-files";
const LWC_AMAZON_FILES_UPLOADER_MODAL = "c-swan-_-amazon-file-uploader-modal";

export default class Swan_AmazonFiles extends LightningElement {
	@api recordId;
	@api flexipageRegionWidth;
	@api height = "200px";
	@track metadataRecords = [];

	labels = {
		amazonFiles: swan_AmazonFiles,
		accessDenied: swan_AccessDenied,
		dragAndDropYourFiles: swan_DragAndDropYourFiles,
		uploading: swan_Uploading,
		noFiles: swan_NoFiles
	};

	icons = {
		cloudUploadIcon: AWS_ICONS + "/swan_cloudUploadIcon.svg",
		uploadFileIcon: AWS_ICONS + "/swan_uploadFileIcon.svg"
	};

	AWS_SDK_JS = AWS_SDK + "/aws-sdk.min.js";
	credentials;

	isLoading = false;
	isDataLoading = true;
	showUpload = false;
	showBackButton = false;
	showFiles = false;
	userHasPermission = false;

	isEditPermission = false;

	isAWSLoaded = false;

	errorMessage = "";

	stateMachine = {
		setState: (stateNum) => {
			switch (stateNum) {
				case 0:
					this.stateMachine.setStateUpload();
					break;
				case 1:
					this.stateMachine.setStateShowFiles();
					break;
			}
		},

		setStateUpload: () => {
			if (
				this.userHasPermission &&
				this.metadataRecords.length == 0 &&
				!this.isEditPermission
			) {
				this.userHasPermission = false;
				this.errorMessage = this.labels.noFiles;
				return;
			}

			this.showFiles = false;
			this.showUpload = true;

			if (this.metadataRecords && this.metadataRecords.length > 0) {
				this.showBackButton = true;
			}
		},

		setStateShowFiles: () => {
			this.prepareFiles();
			this.showFiles = true;
			this.showUpload = false;
			this.showBackButton = false;
		}
	};

	connectedCallback() {
		Promise.all([this.loadAWS(), this.getCredentials()])
			.then(() => {
				this.initAWS();
				this.isDataLoading = false;
			})
			.catch((error) => {
				console.error(error);
			});
	}

	loadAWS() {
		if (this.isAWSLoaded) {
			return new Promise((resolve, reject) => {
				resolve();
			});
		}

		return new Promise((resolve, reject) => {
			loadScript(this, this.AWS_SDK_JS)
				.then(() => {
					this.isAWSLoaded = true;
					resolve();
				})
				.catch((err) => {
					console.error(err);
				});
		});
	}

	initAWS() {
		AWS.config.update({
			region: this.credentials.region,
			credentials: new AWS.Credentials(
				this.credentials.accessKeyId,
				this.credentials.secretAccessKey,
				this.credentials.sessionToken
			)
		});
	}

	getCredentials() {
		return new Promise((resolve, reject) => {
			assumeRoleForCurrentUserToUploadFiles({
				recordId: this.recordId
			})
				.then((credentials) => {
					this.credentials = credentials;
					this.metadataRecords = this.credentials.amazonFiles;
					this.isEditPermission = this.permissionLevel;
					this.userHasPermission = this.credentials.userHasPermission;

					if (!this.userHasPermission) {
						this.errorMessage = this.labels.accessDenied;
					}

					if (this.metadataRecords.length > 0) {
						this.stateMachine.setState(1);
					} else {
						this.stateMachine.setState(0);
					}

					resolve();
				})
				.catch((error) => {
					console.error(error);
					reject(error);
				});
		});
	}

	enableLoadingMode() {
		this.isLoading = true;
		this.template.querySelector("lightning-spinner").style.display =
			"block";
	}

	disableLoadingMode() {
		this.isLoading = false;
		this.template.querySelector("lightning-spinner").style.display = "none";
	}

	deleteMetadataFile(file) {
		this.metadataRecords = Object.assign(
			[],
			this.metadataRecords.filter((currentFile) => {
				return currentFile.Id != file.Id;
			})
		);

		this.prepareFiles();

		if (this.metadataRecords.length == 0) {
			this.stateMachine.setState(0);
		}

		this.template
			.querySelector(LWC_SHOW_AMAZON_FILES)
			.rerenderColumns(this.metadataRecords);
		this.disableLoadingMode();
	}

	startFilesUploading(files) {
		if (!files.length) return;

		Array.from(files).forEach((file) => {
			file.recordId = this.recordId;
			file.userName = this.credentials.currentUserName;
			file.userId = userId;
			file.bucketName = this.credentials.bucketName;
		});

		this.openModalToUploadFiles(files);
	}

	prepareFiles() {
		this.metadataRecords.forEach((file) => {
			file.Permission = this.credentials.userPermissionLevel;
			file.BucketName = this.credentials.bucketName;
		});
	}

	handleDrop(event) {
		let dt = event.dataTransfer;
		let files = dt.files;

		this.startFilesUploading(files);
	}

	handleFileLoad(event) {
		const files = event.target.files;

		this.startFilesUploading(files);
	}

	handleFileUploadMode(event) {
		this.stateMachine.setState(0);
	}

	handleBackButton(event) {
		this.stateMachine.setState(1);
	}

	handleModalClose(event) {
		let uploadedFiles = event.detail.uploadedFiles;

		this.metadataRecords.push(...uploadedFiles);

		if (this.metadataRecords.length > 0) {
			this.stateMachine.setState(1);
		} else {
			this.stateMachine.setState(0);
		}
	}

	handleDeleteStart(event) {
		this.enableLoadingMode();
	}

	handleFileDelete(event) {
		this.deleteMetadataFile(event.detail.file);
	}

	openModalToUploadFiles(files) {
		this.template
			.querySelector(LWC_AMAZON_FILES_UPLOADER_MODAL)
			.openModal(Array.from(files));
	}

	get componentStyle() {
		return "max-height: " + this.height;
	}

	get dragAnddDropStyle() {
		return "height: " + "180px";
	}

	get permissionLevel() {
		return this.credentials.userPermissionLevel === "EDIT";
	}
}
