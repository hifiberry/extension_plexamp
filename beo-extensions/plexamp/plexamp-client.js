var plexamp = (function() {
	var plexampEnabled = false;

	const loginButton = document.getElementById("login")
	loginButton.href = `http://${document.location.hostname}:32500`

	$(document).on("plexamp", function(event, data) {
		if (data.header == "plexampSettings") {
			if (data.content.plexampEnabled) {
				plexampEnabled = true;
				$("#plexamp-enabled-toggle").addClass("on");
			} else {
				plexampEnabled = false;
				$("#plexamp-enabled-toggle").removeClass("on");
			}

			beo.notify(false, "plexamp");
		}
	});

	function toggleEnabled() {
		enabled = (!plexampEnabled) ? true : false;

		if (enabled) {
			beo.notify({
				title: "Turning Plexamp on...",
				icon: "attention",
				timeout: false
			});
		} else {
			beo.notify({
				title: "Turning Plexamp off...",
				icon: "attention",
				timeout: false
			});
		}

		beo.send({
			target: "plexamp",
			header: "plexampEnabled",
			content: {
				enabled: enabled
			}
		});
	}

	return {
		toggleEnabled: toggleEnabled,
	};
})();