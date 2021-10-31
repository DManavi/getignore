ARTIFACT_DIR=artifact
PACKAGE_PREFIX=getignore
VERSION_NAME=v$(VERSION)
OUTPUT_DIR=output
NODEJS_FILE_NAME=$(PACKAGE_PREFIX)-nodejs
MACOS_X64_FILE_NAME=$(PACKAGE_PREFIX)-macOS_amd64
LINUX_X64_FILE_NAME=$(PACKAGE_PREFIX)-linux_amd64
LINUX_ARM64_FILE_NAME=$(PACKAGE_PREFIX)-linux_arm64
WINDOWS_X64_FILE_NAME=$(PACKAGE_PREFIX)-windows_amd64

clean:
	rm -rf artifact/ dist/

compile:
	npm run compile

build-native:
	npm run build:native

build-npm:
	npm pack

tag-source:
	git tag "$(VERSION_NAME)"
	git push origin "$(VERSION_NAME)"
########################

publish-npm:
	npm publish --access=public

pack-nodejs:
	mkdir -p $(ARTIFACT_DIR)
	zip $(ARTIFACT_DIR)/$(NODEJS_FILE_NAME)-$(VERSION_NAME).zip -r dist package.json package-lock.json

pack-macos-x64:
	mkdir -p $(ARTIFACT_DIR)
	cp $(OUTPUT_DIR)/getignore-cmd-macos-x64 $(ARTIFACT_DIR)/$(MACOS_X64_FILE_NAME)-$(VERSION_NAME)
	zip $(ARTIFACT_DIR)/$(PACKAGE_PREFIX)-macos_x64-$(VERSION_NAME).zip $(ARTIFACT_DIR)/$(MACOS_X64_FILE_NAME)-$(VERSION_NAME)
	rm $(ARTIFACT_DIR)/$(MACOS_X64_FILE_NAME)-$(VERSION_NAME)

pack-linux-x64:
	mkdir -p $(ARTIFACT_DIR)
	cp $(OUTPUT_DIR)/getignore-cmd-linux-x64 $(ARTIFACT_DIR)/$(LINUX_X64_FILE_NAME)-$(VERSION_NAME)
	zip $(ARTIFACT_DIR)/$(PACKAGE_PREFIX)-linux_x64-$(VERSION_NAME).zip $(ARTIFACT_DIR)/$(LINUX_X64_FILE_NAME)-$(VERSION_NAME)
	rm $(ARTIFACT_DIR)/$(LINUX_X64_FILE_NAME)-$(VERSION_NAME)

pack-linux-arm64:
	mkdir -p $(ARTIFACT_DIR)
	cp $(OUTPUT_DIR)/getignore-cmd-linux-arm64 $(ARTIFACT_DIR)/$(LINUX_ARM64_FILE_NAME)-$(VERSION_NAME)
	zip $(ARTIFACT_DIR)/$(PACKAGE_PREFIX)-linux_arm64-$(VERSION_NAME).zip $(ARTIFACT_DIR)/$(LINUX_ARM64_FILE_NAME)-$(VERSION_NAME)
	rm $(ARTIFACT_DIR)/$(LINUX_ARM64_FILE_NAME)-$(VERSION_NAME)

pack-windows-x64:
	mkdir -p $(ARTIFACT_DIR)
	cp $(OUTPUT_DIR)/getignore-cmd-win-x64.exe $(ARTIFACT_DIR)/$(WINDOWS_X64_FILE_NAME)-$(VERSION_NAME).exe
	zip $(ARTIFACT_DIR)/$(PACKAGE_PREFIX)-windows_x64-$(VERSION_NAME).zip $(ARTIFACT_DIR)/$(WINDOWS_X64_FILE_NAME)-$(VERSION_NAME).exe
	rm $(ARTIFACT_DIR)/$(WINDOWS_X64_FILE_NAME)-$(VERSION_NAME).exe

publish-github: pack-nodejs pack-macos-x64 pack-linux-x64 pack-linux-arm64 pack-windows-x64 tag-source
	gh release create $(VERSION_NAME) --notes "$(VERSION_NAME)"
	gh release upload $(VERSION_NAME) '$(ARTIFACT_DIR)/$(NODEJS_FILE_NAME)-$(VERSION_NAME).zip'
	gh release upload $(VERSION_NAME) '$(ARTIFACT_DIR)/$(PACKAGE_PREFIX)-macos_x64-$(VERSION_NAME).zip'
	gh release upload $(VERSION_NAME) '$(ARTIFACT_DIR)/$(PACKAGE_PREFIX)-linux_x64-$(VERSION_NAME).zip'
	gh release upload $(VERSION_NAME) '$(ARTIFACT_DIR)/$(PACKAGE_PREFIX)-linux_arm64-$(VERSION_NAME).zip'
	gh release upload $(VERSION_NAME) '$(ARTIFACT_DIR)/$(PACKAGE_PREFIX)-windows_x64-$(VERSION_NAME).zip'

publish-all: clean compile build-native publish-github publish-npm
