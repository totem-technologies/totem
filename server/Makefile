build: build-functions

deploy: build
	firebase deploy --force --only storage,firestore,functions

build-functions:
	cd functions && npm i && npm run build

