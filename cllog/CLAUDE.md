# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# CLLOG Amateur Radio Logbook Project

CLLOG is a free, open-source logging program for amateur radio operators, supporting multiple platforms (Windows, Linux, macOS, Android). The project is developed in Harbour language with HwGUI for the graphical interface.

## Project Structure

### Core Directories
- `trunk/` - Main development branch containing all source code
- `trunk/src/` - Harbour source files (.prg) and build scripts
- `trunk/bin/` - Compiled executables and runtime files
- `trunk/doc/` - Documentation in HTML format
- `trunk/include/` - Header files for compilation
- `trunk/lib/` - Library files

### Key Source Files
- `log.prg` - Main console application (Harbour)
- `logw.prg` - Main GUI application (Harbour + HwGUI)
- `log87.prg` - MS-DOS version (Clipper Summer 87)
- `logw.hbp` - Build configuration for hbmk2 utility
- `hwmk.sh` - Linux/macOS build script
- `hwmk.bat` - Windows build script

## Development Commands

### Building the Application

**Linux/macOS:**
```bash
cd trunk/src
./hwmk.sh logw    # Build GUI version with HwGUI
./hwmk.sh log     # Build console version
```

**Windows:**
```cmd
cd trunk\src
hwmk.bat logw     # Build GUI version
hwmk.bat log      # Build console version
```

**Using hbmk2 (cross-platform):**
```bash
cd trunk/src
hbmk2 logw.hbp    # Build using project file
```

### Running Tests
```bash
cd trunk/src
./testen.sh       # Linux test script
testen.bat        # Windows test script
```

### Cleaning Build Files
```bash
cd trunk/src
./clean.sh        # Linux cleanup
clean.bat         # Windows cleanup
```

## Architecture Overview

### Multi-Platform Support
The codebase supports multiple compilation targets:
- **Harbour + HwGUI**: Modern GUI version for Windows/Linux/macOS
- **Harbour Console**: Text-mode version for Linux/Unix
- **Clipper 87**: Legacy MS-DOS version with limited functionality

### Database Architecture
- Uses DBF database format for amateur radio QSO logging
- Main database: `LOGBUCH.DBF` (QSO records)
- Supporting databases: `DOK.DBF`, `DXLAND.DBF`, `RIGS.DBF`
- Work area allocation: Area 1 = main logbook, Area 3 = DOKs, Area 4 = DXCC countries

### GUI Framework (HwGUI)
- Cross-platform windowing system
- GTK+ backend on Linux
- Native Windows controls
- Menu system, dialogs, and form handling
- Resource management for icons and bitmaps

### Key Libraries
- `libcommon.prg` - Common functions and utilities
- `libhwwin.prg` - HwGUI window management
- `libini.prg` - Configuration file handling
- `libqslw.prg` - QSL card management
- `libadifw.prg` - ADIF import/export functionality

### Language Support
- Bilingual: English and German
- Language selection at startup
- Separate language files: `liblangtxt_de.prg`, `liblangtxt_en.prg`

## Important Development Notes

### Variable Scope Conventions
- `LOCAL` - Function-local variables
- `STATIC` - Module-static variables
- `PRIVATE` - Function and sub-function scope
- `PUBLIC` - Global application variables
- Hungarian notation: `oObject`, `cString`, `nNumber`, `lLogical`, `aArray`

### Database Work Areas
The application reserves specific work areas:
- Area 0: Reserved (do not use)
- Area 1: Main logbook (LOGBUCH.DBF)
- Area 3: DOK database (DOK.DBF)
- Area 4: DXCC country list (DXLAND.DBF)

### Build Dependencies
- Harbour compiler with HwGUI support
- GTK+ 2.0 development libraries (Linux)
- PCRE library for regular expressions
- Math library (`-lm`)

### Configuration Management
- INI-style configuration files
- Personal data stored in separate configuration
- Printer and rig control settings
- Language and display preferences