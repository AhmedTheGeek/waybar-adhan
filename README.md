# waybar-adhan

A minimalist Waybar module that displays time until the next Muslim prayer (adhan). Simple, lightweight, and easy to configure.

<img width="583" height="58" alt="screenshot-2025-09-01_15-10-21" src="https://github.com/user-attachments/assets/fd596cb9-caaa-4009-a3bc-bc785281c90d" />

## Features

- 🕌 Shows countdown to next prayer time
- 📍 Configurable location coordinates
- 🧮 Multiple calculation methods supported
- 💡 Lightweight - uses only `curl` and `jq`

## Installation

Clone directly into your config directory:

```bash
cd ~/.config
git clone https://github.com/AhmedTheGeek/waybar-adhan.git
```

## Setup

1. **Add to Waybar config** (`~/.config/waybar/config`):

```json
"custom/adhan": {
    "exec": "~/.config/waybar-adhan/waybar-prayer.sh",
    "return-type": "json",
    "interval": 60,
    "format": "{text}",
    "tooltip": true
}
```

2. **Add to your bar modules**:

```json
"modules-right": ["custom/adhan", "clock", "battery"]
```

3. **Reload Waybar** (usually `pkill -SIGUSR2 waybar`)

## Configuration

Edit `~/.config/waybar-adhan/config.json`:

```json
{
  "latitude": 21.4241,
  "longitude": 39.8173,
  "calculation_method": 5
}
```

### Finding Your Coordinates

Visit [latlong.net](https://www.latlong.net/) and search for your city to get coordinates.

### Calculation Methods

| ID | Method |
|----|---------|
| 1  | University of Islamic Sciences, Karachi |
| 2  | Islamic Society of North America (ISNA) |
| 3  | Muslim World League (MWL) |
| 4  | Umm Al-Qura University, Makkah |
| 5  | Egyptian General Authority of Survey |
| 8  | Gulf Region |
| 9  | Kuwait |
| 10 | Qatar |
| 11 | Singapore |
| 13 | Turkey |
| 14 | Russia |

## Styling

Add to `~/.config/waybar/style.css`:

```css
#custom-adhan {
    padding: 0 10px;
    margin: 0 5px;
}

#custom-adhan.error {
    color: #ff6b6b;
}
```

## Troubleshooting

- **No output?** Check internet connection and that `curl` and `jq` are installed
- **Wrong times?** Verify your latitude/longitude and calculation method
- **Error state?** The module will show "No data" if it can't fetch prayer times

## API

Uses the free [Aladhan Prayer Times API](https://aladhan.com/prayer-times-api)

## License

MIT
