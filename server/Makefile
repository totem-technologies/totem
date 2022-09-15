PROJECT_ID ?= totem-dev-184f1 # totem-dev-184f1 or totem-26659

build: build-functions

deploy: build
	firebase deploy --project ${PROJECT_ID} --force --only storage,firestore,functions

build-functions:
	cd functions && npm i && npm run build

