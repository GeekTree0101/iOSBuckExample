
.PHONY : log install_buck build targets pods audit debug test xcode_tests clean project audit

log:
	echo "Make"

update_cocoapods:
	pod repo update
	pod install

build:
	buck build app

debug:
	buck install app --run

targets:
	buck targets //...

test:
	echo "Under construction"
	# buck test //App/Tests:Tests --all --exclude ui --test-runner-env FOO=BAR

ui_test:
	echo "Under construction"
	# buck test //App/UITests:UITests

pods:
	$(pod) install

clean:
	killall Xcode || true
	killall Simulator || true
	rm -rf **/*.xcworkspace
	rm -rf **/*.xcodeproj
	buck clean

xcode_tests: project
	xcodebuild build test -workspace iOSBuckExample/iOSBuckExample.xcworkspace -scheme iOSBuckExample -destination 'platform=iOS Simulator,name=iPhone 8,OS=latest' | xcpretty && exit ${PIPESTATUS[0]}

project: clean
	buck project //iOSBuckExample:workspace
	open iOSBuckExample/iOSBuckExample.xcworkspace