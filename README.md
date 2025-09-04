# MTracks - LFG History Tracker

MTracks is a World of Warcraft addon that tracks your Mythic+ and Looking for Group (LFG) application history, providing detailed statistics and insights into your dungeon and raid group-finding experience.

## Features

### 📊 **Comprehensive Tracking**

- **Application History** - Track all your LFG applications
- **Success Rates** - Monitor your acceptance and decline rates
- **Character Statistics** - Per-character and account-wide stats
- **Activity Timeline** - See when you last applied for groups
- **Status Tracking** - Applied, Invited, Declined, Cancelled, and more

### 🎨 **Modern UI**

- **Clean Interface** - Minimal, professional design
- **Styled Logo** - Beautiful gradient text logo system
- **Statistical Cards** - Easy-to-read stat displays
- **Color-coded Data** - Visual indicators for performance
- **Responsive Layout** - Adapts to different screen sizes

### 🔧 **Technical Features**

- **Database Management** - Persistent data storage with AceDB
- **Performance Optimized** - Efficient event handling
- **Minimap Integration** - LibDBIcon support
- **Configuration System** - AceConfig integration
- **Console Commands** - AceConsole command support

## Installation

### From GitHub

1. **Download** the latest release from [https://github.com/Medalink/mtracks](https://github.com/Medalink/mtracks)
2. **Extract** to your `Interface\AddOns\MTracks` folder
3. **Restart** World of Warcraft or `/reload` if in-game
4. **Access** via minimap icon or `/mtracks` command

### Manual Installation

1. Clone or download the repository
2. Copy the MTracks folder to your WoW AddOns directory
3. Ensure the folder structure matches: `Interface\AddOns\MTracks\`

## Usage

### Opening MTracks

- **Minimap Icon** - Click the MTracks minimap button
- **Slash Command** - Type `/mtracks` in chat
- **Key Binding** - Set up a keybind in WoW's key binding menu

### Understanding the Interface

#### **Account Statistics** (Top Section)

- **Applied** - Total applications across all characters
- **Success** - Number of successful applications
- **Decline** - Applications that were declined
- **Delisted** - Groups that were delisted/cancelled
- **Removed** - Applications you cancelled
- **Last Activity** - When you last applied for a group

#### **Character Statistics** (Left Panel)

- Same stats as account, but for current character only
- **Class-colored** character name and realm

#### **Character Table** (Main Area)

- **Per-character breakdown** of all tracked data
- **Sortable columns** for easy analysis
- **Success/Decline/Cancel rates** as percentages
- **Last activity timestamps**

### Managing Data

- Data is **automatically saved** per character and account
- **Persistent across** game sessions and character switches
- **Backed up** in your WoW SavedVariables folder

## Logo System

MTracks includes a powerful logo creation system that generates beautiful styled text with gradients and effects.

### Basic Usage

```lua
-- Super simple - just text! Uses beautiful gold gradient by default
local logo = MTracks.Logo:CreateStyledLogo(parentFrame, "Your Text Here")

-- With positioning
local logo = MTracks.Logo:CreateStyledLogo(parentFrame, "Your Text Here", {
    position = {x = 0, y = 10}
})
```

### Advanced Examples

#### **Custom Colors**

```lua
local logo = MTracks.Logo:CreateStyledLogo(parentFrame, "Fire Ice", {
    startColor = {r = 1, g = 0, b = 0},  -- Red
    endColor = {r = 0, g = 0, b = 1}     -- Blue
})
```

#### **Vertical Gradient**

```lua
local logo = MTracks.Logo:CreateStyledLogo(parentFrame, "Epic Adventures", {
    firstLetterFont = "Fonts\\SKURRI.TTF",
    firstLetterSize = 72,
    restSize = 36,
    startColor = {r = 1, g = 1, b = 0},    -- Yellow
    endColor = {r = 1, g = 0.5, b = 0},    -- Orange
    gradientDirection = "vertical"
})
```

#### **Custom Styling & Outlines**

```lua
local logo = MTracks.Logo:CreateStyledLogo(parentFrame, "Epic Quest", {
    startColor = {r = 0.8, g = 0, b = 1},    -- Purple
    endColor = {r = 0.4, g = 0, b = 0.8},    -- Dark purple
    gradientDirection = "vertical",          -- Top-down gradient
    letterSpacing = 12,
    wordSpacing = 20,
    outlineStyle = "THICKOUTLINE"           -- Bold black outlines
})
```

#### **Dynamic Color Updates**

```lua
-- Create logo with defaults
local logo = MTracks.Logo:CreateStyledLogo(parentFrame, "Dynamic Colors")

-- Update colors later
MTracks.Logo:UpdateLogoColors(logo,
    {r = 1, g = 0, b = 1},  -- Magenta
    {r = 0, g = 1, b = 1}   -- Cyan
)
```

### Logo Options Reference

**Function Signature:** `MTracks.Logo:CreateStyledLogo(parentFrame, text, options)`

- `parentFrame` - The WoW frame to attach the logo to
- `text` - The text to display (**required**)
- `options` - Table of optional settings (all have great defaults!)

| Option              | Type    | Default                   | Description                         |
| ------------------- | ------- | ------------------------- | ----------------------------------- |
| `position`          | table   | `{x=0, y=0}`              | Position offset                     |
| `anchor`            | string  | `"CENTER"`                | WoW anchor point                    |
| `anchorTo`          | string  | `"CENTER"`                | WoW anchor point to attach to       |
| `firstLetterFont`   | string  | `"Fonts\\SKURRI.TTF"`     | Font for first letters (angular)    |
| `firstLetterSize`   | number  | `72`                      | Size of first letters               |
| `restFont`          | string  | `"Fonts\\MORPHEUS.TTF"`   | Font for rest of text (fantasy)     |
| `restSize`          | number  | `52`                      | Size of rest of text                |
| `startColor`        | table   | `{r=1, g=0.9, b=0.3}`     | RGB start color (metallic gold)     |
| `endColor`          | table   | `{r=0.8, g=0.5, b=0.1}`   | RGB end color (bronze gold)         |
| `gradientDirection` | string  | `"vertical"`              | "horizontal" or "vertical"          |
| `outlineEnabled`    | boolean | `true`                    | Enable/disable text outlines        |
| `outlineStyle`      | string  | `"THICKOUTLINE"`          | OUTLINE, THICKOUTLINE, MONOCHROME   |
| `letterSpacing`     | number  | `8`                       | Space between first letter and rest |
| `wordSpacing`       | number  | `15`                      | Space between words                 |
| `containerSize`     | table   | `{width=400, height=100}` | Container dimensions                |

## Commands

- `/mtracks` - Opens the main MTracks interface
- `/mtracks show` - Shows the main window
- `/mtracks hide` - Hides the main window
- `/mtracks config` - Opens configuration (if available)

## Dependencies

MTracks uses the following libraries (included):

- **Ace3** - Core addon framework
  - AceAddon-3.0 - Addon management
  - AceDB-3.0 - Database handling
  - AceEvent-3.0 - Event management
  - AceConsole-3.0 - Console commands
  - AceConfig-3.0 - Configuration system
  - AceGUI-3.0 - UI components
- **LibDataBroker-1.1** - Data broker support
- **LibDBIcon-1.0** - Minimap icon support
- **CallbackHandler-1.0** - Event callbacks
- **LibStub** - Library management

## File Structure

```
MTracks/
├── Core.lua              # Main addon logic
├── Logo.lua              # Logo creation system
├── embeds.xml            # Library includes
├── MTracks.toc           # Addon metadata
├── README.md             # This file
└── Libs/                 # Dependencies
    ├── Ace3/             # Ace3 framework
    ├── LibDataBroker-1.1/
    ├── LibDBIcon-1.0/
    ├── CallbackHandler-1.0/
    └── LibStub/
```

## Development

### Building

MTracks uses standard WoW addon structure. No build process required.

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly in-game
5. Submit a pull request

### Code Style

- Use **4-space indentation**
- Follow **Lua naming conventions**
- Add **comments for complex logic**
- Keep **functions focused and small**
- Use **meaningful variable names**

## License

This addon is released under the MIT License. See LICENSE file for details.

## Support

- **GitHub**: Report bugs and feature requests at [https://github.com/Medalink/mtracks](https://github.com/Medalink/mtracks)
- **Issues**: Use the GitHub issue tracker for bug reports and feature requests

## Version History

### v1.0.0

- Initial release
- LFG application tracking
- Character and account statistics
- Modern UI with styled logo
- Minimap integration

---

**Made with ❤️ for the World of Warcraft community**
