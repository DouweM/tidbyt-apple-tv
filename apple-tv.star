load("encoding/base64.star", "base64")
load("schema.star", "schema")
load("render.star", "render")
load("http.star", "http")
load("cache.star", "cache")
load("pixlib/file.star", "file")
load("pixlib/const.star", "const")

def main(config):
  DEVICE_NAME = config.get("device_name")
  AIRPLAY_CREDS = config.get("airplay_creds")

  if not AIRPLAY_CREDS or not DEVICE_NAME:
    return render.Root(
        child=render.Box(
            child=render.WrappedText("Apple TV not configured")
        )
    )

  data = file.exec("apple-tv.py", {"airplay_creds": AIRPLAY_CREDS, "device_name": DEVICE_NAME})
  if not data:
    return []

  title = data.get("title")
  artwork = data.get("artwork")

  duration = data.get("duration")
  position = data.get("position")
  remaining = duration - position

  text_width = const.WIDTH - 21 - 1

  return render.Root(
    child=render.Box(
      child=render.Image(
        src=base64.decode(artwork),
        height=const.HEIGHT,
        # width=21
      ),
    )
    # child=render.Row(
    #   expanded=True,
    #   main_align="space_between",
    #   children=[
    #     render.Image(
    #       src=base64.decode(artwork),
    #       height=const.HEIGHT,
    #       # width=21
    #     ),
        # TODO: Show title if artwork is not full-width
        # render.Padding(
        #   pad=(1,0,0,0),
        #   child=render.Column(
        #     expanded=True,
        #     main_align="space_between",
        #     children=[
        #       render.Marquee(width=text_width, child=render.Text(title, font="6x13")),
        #       render.Text("-%d min" % (remaining / 60), font="CG-pixel-3x5-mono")
        #     ]
        #   )
        # )
      # ]
    # )
  )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "device_name",
                name = "Device Name",
                desc = "Acquire using `meltano invoke tap-pixlet--apple-tv:scan`. Example: 'Bedroom Apple TV'",
                icon = "tv"
            ),
            schema.Text(
                id = "airplay_creds",
                name = "AirPlay Creds",
                desc = "Acquire using `meltano invoke tap-pixlet--apple-tv:pair`",
                icon = "key"
            ),
        ],
    )
