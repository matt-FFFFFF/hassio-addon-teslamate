# Local Development

To get the addon to run locally, make these changes but do not commit them to any PR

## Add the `ARCH` arg to the `build.json` file:

```json
{
    "args": {
      "TESLAMATE_TAG": "1.21.2",
      "ARCH": "amd64"
    }
}
```

## Remove the `image` key from `config.json`

This will make Home Assistant build the container every time.
