var exec = require("child_process").exec;
var fs = require("fs");

var debug = beo.debug;
var version = require("./package.json").version;
var sources = null;
var settings = {
	plexampEnabled: false,
}

beo.bus.on('general', function(event) {
	if (event.header == "startup") {
		if (beo.extensions.sources &&
			beo.extensions.sources.setSourceOptions &&
			beo.extensions.sources.sourceDeactivated) {
			sources = beo.extensions.sources;
		}

		if (sources) {
			getPlexampStatus(function(enabled) {
				sources.setSourceOptions("plexamp", {
					enabled: enabled,
					transportControls: false,
					usesHifiberryControl: true
				});
			});
		}

	}

	if (event.header == "activatedExtension") {
		if (event.content.extension == "plexamp") {
			beo.bus.emit("ui", {
				target: "plexamp",
				header: "plexampSettings",
				content: settings
			});
		}
	}
});

beo.bus.on('plexamp', function(event) {
	if (event.header == "plexampEnabled") {
		if (event.content.enabled != undefined) {
			setPlexampStatus(event.content.enabled, function(newStatus, error) {
				beo.bus.emit("ui", {
					target: "plexamp",
					header: "plexampSettings",
					content: settings
				});

				if (sources) sources.setSourceOptions("plexamp", {
					enabled: newStatus
				});

				if (newStatus == false) {
					if (sources) sources.sourceDeactivated("plexamp");
				}

				if (error) {
					beo.bus.emit("ui", {
						target: "plexamp",
						header: "errorTogglingPlexamp",
						content: {}
					});
				}
			});
		}
	}
});


function getPlexampStatus(callback) {
	exec("/opt/hifiberry/bin/extension running plexamp").on('exit', function(code) {
		if (code == 0) {
			settings.plexampEnabled = true;
			callback(true);
		} else {
			settings.plexampEnabled = false;
			callback(false);
		}
	});
}

function setPlexampStatus(enabled, callback) {
	if (enabled) {
		exec("/opt/hifiberry/bin/extension start plexamp").on('exit', function(code) {
			if (code == 0) {
				settings.plexampEnabled = true;
				if (debug) console.log("Plexamp enabled.");
				callback(true);
			} else {
				settings.plexampEnabled = false;
				callback(false, true);
			}
		});
	} else {
		exec("/opt/hifiberry/bin/extension/stop plexamp").on('exit', function(code) {
			if (code == 0) {
				settings.plexampEnabled = false;
				if (debug) console.log("Plexamp disabled.");
				callback(false);
			} else {
				settings.plexampEnabled = true;
				callback(true, true);
			}
		});

	}
}

module.exports = {
	version: version,
	isEnabled: getPlexampStatus
};