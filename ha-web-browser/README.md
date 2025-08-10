# Web Browser Add-on for Home Assistant

A full-featured web browser accessible through Home Assistant using noVNC technology.

## Features

- 🌐 Full Chromium browser with JavaScript support
- 📱 Responsive interface that works on mobile
- 🔒 Optional password protection
- ⚙️ Configurable resolution and performance settings
- 🖼️ Embeddable in Home Assistant dashboards
- 🚀 Hardware-accelerated rendering where available

## Installation

1. Add this repository to your Home Assistant Add-on store
2. Install the "Web Browser (noVNC)" add-on
3. Configure the add-on options
4. Start the add-on
5. Access through the web UI or embed in dashboard

## Configuration

### Options

- **resolution**: Display resolution (1920x1080, 1280x720, etc.)
- **homepage**: Default homepage URL
- **password**: Optional VNC password for security
- **scaling**: Scaling mode (off, local, remote)
- **compression**: VNC compression level (0-9)
- **quality**: VNC quality level (0-9)

### Example Configuration

```yaml
resolution: "1920x1080"
homepage: "https://google.com"
password: "mypassword"
scaling: "remote"
compression: 6
quality: 6
