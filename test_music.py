from ytmusicapi import YTMusic

ytmusic = YTMusic("browser.json")
results = ytmusic.search("Tum Hi Ho", filter="songs")

for song in results:
    title = song.get('title', 'Unknown Title')

    # Safe artist extraction
    artist = 'Unknown Artist'
    if 'artist' in song and song['artist']:
        artist = song['artist']
    elif 'artists' in song and song['artists']:
        artist = song['artists'][0].get('name', 'Unknown Artist')

    print(f"{title} - {artist}")
