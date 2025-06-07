# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that manages macOS system configuration using Nix, nix-darwin, and home-manager. The configuration is organized as a Nix flake that supports multiple machines with different hostnames.

## Architecture

### Core Structure
- **flake.nix**: Main flake definition with inputs and machine configurations
- **home.nix**: Home-manager configuration entry point with imports
- **darwin.nix**: nix-darwin system-level configuration
- **home-manager/**: Modular configuration files for individual programs and services

### Configuration Management
The repository uses a modular approach where each program/service has its own configuration file in `home-manager/`. The main `home.nix` imports all these modules, allowing for organized and maintainable configuration.

### Multi-Machine Support
Configurations are defined for multiple machines in `flake.nix`:
- `louischan-m4`: Personal M4 Mac
- `louischan-work`: Work Mac  
- `nixd`: Special configuration for nixd LSP

## Key Configuration Areas

### Shells
Multiple shells are configured with consistent theming:
- bash, zsh, fish, nushell, elvish
- Starship prompt, shell completion, direnv, atuin

### Terminals
Multiple terminal emulators supported:
- kitty, alacritty, wezterm, ghostty
- tmux configuration with catppuccin theme

### Development Tools
- Neovim with extensive configuration
- Language servers and development languages
- Git configuration with GPG signing
- Database tools and cloud CLI tools

### macOS Integration
- Karabiner-Elements for keyboard customization
- Hammerspoon for window management
- Replaces stock macOS programs with modern alternatives

## Important Notes

- Configuration files are symlinked to the Nix store, so edit the source files in this repository
- Do not run `home-manager switch` without explicit grant
- The configuration supports both system-level (nix-darwin) and user-level (home-manager) settings
- NIX_PATH is configured to support legacy nix commands and nixd LSP