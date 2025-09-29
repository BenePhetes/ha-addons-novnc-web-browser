
```markdown
# Web Browser Add-on Documentation

## What is this add-on?

This add-on provides a full web browser (Brave or Opera) that runs inside Home Assistant and can be accessed through your Home Assistant interface. It's perfect for:

- Displaying your Home Assistant dashboard on a dedicated screen
- Running web-based applications within Home Assistant
- Kiosk displays
- Accessing web services that need a full browser

## How it works

The add-on uses **Xpra**, a high-performance application streaming protocol that's much faster than traditional VNC. The browser runs inside the add-on container and streams to your device via HTML5 (no plugins required!).

## Configuration Options

### browser
Choose which browser to use:
- `brave` - Fast, privacy-focused browser (recommended)
- `opera` - Feature-rich browser

### url
The website to open automatically in kiosk mode. Examples:
- `http://homeassistant.local:8123` - Your Home Assistant dashboard
- `https://www.home-assistant.io` - Any external website
- `http://192.168.1.100:3000` - Local service

### resolution
Display resolution in format `WIDTHxHEIGHT`. Examples:
- `1920x1080` - Full HD (default)
- `1280x720` - HD
- `3840x2160` - 4K (requires powerful hardware)

### compression
Compression level from 0-9:
- `0` - No compression (best quality, most bandwidth)
- `5` - Balanced (default)
- `9` - Maximum compression (lower quality, least bandwidth)

Higher compression is better for:
- Remote access over internet
- Slow network connections
- Mobile data usage

Lower compression is better for:
- Local network access
- High-quality displays
- Powerful devices

## Examples

### Example 1: Home Assistant Dashboard
```yaml
browser: brave
url: http://homeassistant.local:8123
resolution: 1920x1080
compression: 3
```

### Example 2: Remote Access
```yaml
browser: brave
url: https://grafana.example.com
resolution: 1280x720
compression: 8
```

### Example 3: Low-Power Device
```yaml
browser: opera
url: http://homeassistant.local:8123
resolution: 1280x720
compression: 7
```