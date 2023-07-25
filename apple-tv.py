#!/usr/bin/env python3
import base64
import os
import sys
import json
import asyncio
from pyatv import scan, connect
from pyatv.const import Protocol

async def get_metadata(loop, config):
    device_name = config["device_name"]
    airplay_creds = config["airplay_creds"]

    atvs = await scan(loop, protocol=Protocol.AirPlay)
    try:
        atv = next(atv for atv in atvs if atv.name == device_name)
    except StopIteration:
        raise Exception("Could not find Apple TV with name '%s'" % device_name)

    atv.set_credentials(Protocol.AirPlay, airplay_creds)

    atv = await connect(atv, loop)

    playing = await atv.metadata.playing()
    artwork = await atv.metadata.artwork(width=64, height=32)

    # TODO: Skip if idle
    metadata = {}
    if playing and playing.title:
        metadata["title"] = playing.title
        metadata["duration"] = playing.total_time
        metadata["position"] = playing.position

    if artwork:
        metadata["artwork"] = base64.b64encode(artwork.bytes).decode("utf-8")

    await asyncio.gather(*atv.close())

    return metadata

async def main():
    loop = asyncio.get_event_loop()

    if len(sys.argv) == 1:
        config = {
            "device_name": os.getenv("APPLE_TV_DEVICE_NAME"),
            "airplay_creds": os.getenv("APPLE_TV_AIRPLAY_CREDS"),
        }
    else:
        config = json.loads(sys.argv[1])
    metadata = await get_metadata(loop, config)

    print(json.dumps(metadata))

asyncio.run(main())
