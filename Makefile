DOME_VERSION = v1.4.0

.PHONY: dm dl start record

s start:
	./dome --debug main.wren

r record:
	./dome -r main.wren

c clean:
	rm -f dome-${DOME_VERSION}-linux-x64.zip
	rm -f dome-${DOME_VERSION}-macosx-x64.zip
	rm -f dome

dm dome-macos:
	wget https://github.com/domeengine/dome/releases/download/${DOME_VERSION}/dome-${DOME_VERSION}-macosx-x64.zip
	unzip -o dome-${DOME_VERSION}-macosx-x64.zip
	rm -f dome-${DOME_VERSION}-macosx-x64.zip
	mv dome-macosx-x64/dome .
	rm -rf dome-macosx-x64
	chmod +x ./dome

dl dome-linux:
	wget https://github.com/domeengine/dome/releases/download/${DOME_VERSION}/dome-${DOME_VERSION}-linux-x64.zip
	unzip -o dome-${DOME_VERSION}-linux-x64.zip
	rm -f dome-${DOME_VERSION}-linux-x64.zip
	mv dome-linux-x64/dome .
	rm -rf dome-linux-x64
	chmod +x ./dome
