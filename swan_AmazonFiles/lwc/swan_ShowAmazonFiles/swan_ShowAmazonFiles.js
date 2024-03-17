import { LightningElement, api, track } from "lwc";
import FACTOR from "@salesforce/client/formFactor";

const SMALL = "Small";
const MEDIUM = "MEDIUM";
const LARGE = "LARGE";

const FACTOR_SMALL = "Small";

export default class Swan_ShowAmazonFiles extends LightningElement {
	@api metadataRecords = [];
	@api flexipageRegionWidth;

	@track columns = {
		first: [],
		second: [],
		third: [],
		fourth: [],
		fifth: []
	};

	keyMappings = {
		0: "first",
		1: "second",
		2: "third",
		3: "fourth",
		4: "fifth"
	};

	numberOfColumns = 1;

	connectedCallback() {
		this.calculateData();
	}

	@api
	rerenderColumns(metadataRecords) {
		this.metadataRecords = metadataRecords;
		this.calculateData();
	}

	calculateData() {
		this.defineRegionWidth();
		this.clearData();
		this.defineNumberOfColumns();
		this.buildColumns();
	}

	defineNumberOfColumns() {
		switch (this.flexipageRegionWidth) {
			case MEDIUM:
				this.numberOfColumns = 3;
				break;
			case LARGE:
				this.numberOfColumns = 4;
				break;
			default:
				this.numberOfColumns = 1;
				break;
		}
	}

	defineRegionWidth() {
		if (this.flexipageRegionWidth) {
			return;
		}

		if (FACTOR === FACTOR_SMALL) {
			this.flexipageRegionWidth = SMALL;
		} else {
			this.flexipageRegionWidth = MEDIUM;
		}
	}

	buildColumns() {
		this.metadataRecords.forEach((record, index) => {
			this.columns[this.keyMappings[index % this.numberOfColumns]].push(
				record
			);
		});
	}

	clearData() {
		for (let i = 0; i < 5; i++) {
			this.columns[this.keyMappings[i]] = [];
		}
	}

	get isSizeMedium() {
		return this.flexipageRegionWidth === MEDIUM;
	}

	get isSizeSmall() {
		return this.flexipageRegionWidth === SMALL;
	}

	get firstColumn() {
		return this.columns.first.length;
	}
}
