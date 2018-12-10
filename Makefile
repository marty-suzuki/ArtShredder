copy-secret:
	cp -f Resources/Secret_Templete.swift ArtShredder/Common/Secret.swift

carthage-update:
	carthage update --platform ios --no-use-binaries

pod-install:
	pod install

bootstrap: copy-secret pod-install carthage-update