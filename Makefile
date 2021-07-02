.PHONY: new
new:
	@rm -rf modes/new
	@cp -R template modes/new

.PHONY: upload
upload:
	@scp -r modes/$$MODE music@eyesy.local:/sdcard/Modes/oFLua
	@curl -d 'name="..."' http://eyesy.local:8080/reload_mode
