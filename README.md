# Extension: Plexamp

The Plexamp extension integrates PlexAmp into HiFiBerryOS. However, due toi the architecture of PlexAmp and the fact that it's closed source, there are some serious limitations:
- HiFiBerryOS is not able to show the status of PlexAmp
- No metadata from PlexAmp will be reported in the UI
- No control is possible from the HiFIBerryOS GUI, you can't start/stop/skip playback
- Enabling the extension requires some command line interactions
- With >200MB RAM usage tha player requires more resources than other players. You will probably like to use a Pi with at least 2GB RAM
- If another player is running, PlexAmp can't stop it. You have to first stop it by yourself.

## Setting up the extension

1. Install the extension using the HiFiBerryOS extension manager
2. Login to the system via SSH
3. Edit the file /etc/plexamp.token and add the claim token that you can retrieve from https://plex.tv/claim (this requires a PlexAmp subscription)
4. Restart the extension: 
```
/opt/hifiberry/bin/extensions stop plexamp
/opt/hifiberry/bin/extensions start plexamp
```
5. If the claim token could be used, you should now see a file /data/extensiondata/plexamp/token_accepted
