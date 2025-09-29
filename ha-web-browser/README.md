```markdown
# Web Browser Add-on for Home Assistant (Xpra)

High-performance web browser add-on using Xpra for Home Assistant OS.

## Features

- **Brave Browser** support
- **Opera Browser** support
- High-performance Xpra protocol
- HTML5 web client (no VNC needed!)
- Configurable resolution
- Adjustable compression
- Kiosk mode by default
- Low latency
- Clipboard support

## Installation

1. Add this repository to your Home Assistant add-on store
2. Install the "Web Browser (Xpra)" add-on
3. Configure the add-on (see Configuration below)
4. Start the add-on
5. Access via Home Assistant sidebar

## Configuration

### Options

- **browser** (required): Choose between `brave` or `opera`
- **url** (required): The URL to open in kiosk mode
- **resolution** (optional): Display resolution (default: `1920x1080`)
- **compression** (optional): Compression level 0-9 (default: `5`)

### Example Configuration

```yaml
browser: brave
url: http://homeassistant.local:8123
resolution: 1920x1080
compression: 5
```

## Usage

1. Configure your browser and URL in the add-on configuration
2. Start the add-on
3. Click "Open Web UI" or access from the sidebar
4. The browser will open in full-screen kiosk mode

## Performance Tips

- Lower compression (0-3) for faster local networks
- Higher compression (7-9) for slower connections or remote access
- Reduce resolution for lower-powered devices
- Brave is generally faster than Opera

## Troubleshooting

### Browser not loading
- Check add-on logs for errors
- Verify the URL is accessible
- Try restarting the add-on

### Poor performance
- Increase compression level
- Reduce resolution
- Check network connectivity

### Can't access from mobile
- Ensure you're using Home Assistant's ingress
- Check that the add-on is running
- Try accessing via Home Assistant app

## Technical Details

- Based on Debian Bookworm
- Uses Xpra for application streaming
- HTML5 client (no plugins needed)
- Nginx reverse proxy for ingress
- Supports both ARM and x86 architectures

## License

MIT License
```