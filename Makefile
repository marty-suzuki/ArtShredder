copy-secret:
	cp -f Resources/Secret_Templete.swift ArtShredder/Common/Secret.swift

install-cocoapods:
	rm -rf vendor
	bundler install --path vendor/bundle

carthage-update:
	carthage update --platform ios --no-use-binaries

pod-install:
	bundle exe pod install

bootstrap: copy-secret install-cocoapods pod-install carthage-update