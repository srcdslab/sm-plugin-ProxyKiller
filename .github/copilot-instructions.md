# Copilot Instructions for ProxyKiller SourceMod Plugin

## Repository Overview

This repository contains **ProxyKiller**, a SourceMod plugin designed to detect and handle proxy/VPN users on Source engine game servers. The plugin provides extensive API integration, configurable punishments, caching mechanisms, and rule-based whitelisting/blacklisting.

**Key Features:**
- Proxy/VPN detection via configurable HTTP services
- MySQL/SQLite caching support
- Extensive native API for third-party plugins
- Configurable punishments (kick, ban, log)
- Admin flags and Steam app whitelisting
- Real-time rule management

## Technical Environment

### Language & Platform
- **Primary Language**: SourcePawn (.sp files)
- **Include Files**: SourcePawn headers (.inc files)
- **Platform**: SourceMod 1.11+ (minimum version)
- **Target**: Source engine game servers

### Dependencies
- **SourceMod**: 1.11.0-git6934 (auto-downloaded by build system)
- **SteamWorks Extension**: Required for HTTP requests
- **sm-json**: JSON parsing library
- **Database**: MySQL or SQLite (optional, for caching)

### Build System
- **Primary Tool**: SourceKnight (sourceknight.yaml configuration)
- **Compiler**: SourcePawn compiler (spcomp) - bundled with SourceMod
- **CI/CD**: GitHub Actions (.github/workflows/ci.yml)
- **Output**: Compiled .smx files in `/addons/sourcemod/plugins/`

## Project Structure

```
/addons/sourcemod/
├── scripting/
│   ├── ProxyKiller.sp              # Main plugin file
│   ├── include/
│   │   ├── ProxyKiller.inc         # Main include file
│   │   ├── StringMapEx.inc         # Extended StringMap utilities
│   │   └── ProxyKiller/            # Plugin-specific includes
│   └── ProxyKiller/                # Plugin modules
│       ├── api/                    # Native functions and forwards
│       ├── cache/                  # Caching implementations
│       ├── http/                   # HTTP service integration
│       ├── rules/                  # Rule management
│       └── migrations/             # Database migrations
└── configs/
    ├── proxykiller.cfg             # Main configuration
    ├── proxykiller.example.cfg     # Example configuration
    ├── proxykiller_whitelist.ini   # SteamID whitelist
    └── proxykiller_blacklist.ini   # SteamID blacklist
```

## Development Workflow

### Building the Plugin

```bash
# Using SourceKnight (recommended)
sourceknight build

# Manual compilation (if needed)
spcomp -i addons/sourcemod/scripting/include addons/sourcemod/scripting/ProxyKiller.sp
```

### Key Build Files
- `sourceknight.yaml`: Build configuration and dependencies
- `.github/workflows/ci.yml`: Automated building and releases
- `ProxyKiller.sp`: Main plugin entry point

### Testing Changes
1. Build the plugin locally
2. Deploy to development server
3. Test with various proxy detection scenarios
4. Verify database operations (if using caching)
5. Check logs for proper functionality

## Code Patterns & Best Practices

### SourcePawn Conventions
```sourcepawn
#pragma newdecls required           // Always use new declaration syntax
#pragma semicolon 1                 // Require semicolons
#pragma dynamic 131072              // Increase memory for large plugins

// Global variable naming
bool g_bVariable = false;           // Prefix globals with g_
ProxyCache g_Cache = null;          // Use descriptive names

// Function naming
public void OnPluginStart()         // PascalCase for public functions
static void DoSomething()           // PascalCase for functions
```

### Plugin Architecture Patterns
- **Methodmaps**: Used extensively for object-oriented design
- **Modules**: Functionality split into include files
- **Forwards**: Event system for third-party integration
- **Natives**: API functions for external plugins

### Database Operations
```sourcepawn
// Always use asynchronous database operations
g_Database.Query(OnQueryComplete, "SELECT * FROM table WHERE id = %d", clientId);

// Use transactions for multiple operations
Transaction txn = new Transaction();
txn.AddQuery("INSERT INTO...");
txn.AddQuery("UPDATE...");
g_Database.Execute(txn, OnTransactionSuccess, OnTransactionFailure);
```

### Memory Management
```sourcepawn
// Proper cleanup
delete someStringMap;               // Don't check for null first
someStringMap = new StringMap();    // Create new instance

// Handle cleanup in OnPluginEnd if needed
public void OnPluginEnd()
{
    delete g_Cache;
    delete g_Rules;
}
```

## API Integration

### Native Functions
The plugin provides extensive natives in `addons/sourcemod/scripting/include/ProxyKiller.inc`:
- User checking: `ProxyKiller_CheckUser()`
- Configuration: `ProxyKiller_Config_*()`
- Caching: `ProxyKiller_Cache_*()`
- Rules: `ProxyKiller_Rules_*()`

### Forwards
Event callbacks for third-party plugins:
- `ProxyKiller_OnUserChecked()`: When user check completes
- `ProxyKiller_OnUserPunished()`: When user receives punishment

## Configuration Management

### Main Configuration (`proxykiller.cfg`)
- Service settings (URL, response format, etc.)
- Punishment configuration
- Caching settings
- Logging preferences

### Runtime Variables
The plugin supports dynamic variables in configurations:
- `{STEAM_ID}`: Client's Steam ID
- `{IP}`: Client's IP address
- `{USER_ID}`: Client's user ID

## Common Development Tasks

### Adding New Features
1. Create module file in `ProxyKiller/` directory
2. Add include statement in main `ProxyKiller.sp`
3. Update `ProxyKiller.inc` if adding API functions
4. Test with development server

### Modifying HTTP Service Integration
- Edit files in `ProxyKiller/http/service/`
- Update response parsing in `response.sp`
- Test with various proxy detection services

### Database Schema Changes
1. Add migration in `ProxyKiller/migrations/`
2. Update cache/rules implementations
3. Test migration process

### Adding Configuration Options
1. Add ConVar in `api/convars.sp`
2. Update config parsing in `config.sp`
3. Document in example configuration

## Debugging & Troubleshooting

### Log Levels
```sourcepawn
#define PROXYKILLER_SPEWLEVEL (SPEWLEVEL_ERROR | SPEWLEVEL_INFO)
```

### Common Issues
- **Build failures**: Check SourceMod version compatibility
- **HTTP errors**: Verify SteamWorks extension installation
- **Database issues**: Check connection string and permissions
- **JSON parsing**: Ensure valid JSON response format

### Debug Information
- Plugin logs to SourceMod error logs
- Enable verbose logging in configuration
- Use `sm plugins info ProxyKiller` for runtime status

## Performance Considerations

### Optimization Guidelines
- Cache proxy check results when possible
- Use asynchronous database operations
- Minimize string operations in frequently called functions
- Consider rate limiting for HTTP requests

### Memory Usage
- Plugin uses `#pragma dynamic 131072` for increased memory
- Monitor StringMap/ArrayList usage
- Clean up handles properly with `delete`

## Release Process

### Version Management
- Update version in `ProxyKiller.sp` plugin info
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Tag releases in GitHub for automated builds

### Automated Builds
- Push to main branch triggers CI build
- Tags trigger versioned releases
- Artifacts include compiled plugin and configs

## Integration Examples

### Third-party Plugin Integration
```sourcepawn
// Check if ProxyKiller is loaded
if (!LibraryExists("ProxyKiller"))
    return;

// Use native functions
bool isProxy = ProxyKiller_IsUserProxy(client);
```

### Custom Service Integration
```sourcepawn
// Implement custom HTTP response parsing
// Modify ProxyKiller/http/service/response.sp
```

## File Modification Guidelines

### When Editing Core Files
- **ProxyKiller.sp**: Main plugin logic, includes, initialization
- **ProxyKiller.inc**: Public API definitions, constants, typedefs
- **Module files**: Specific functionality (cache, rules, HTTP, etc.)

### Configuration Files
- **proxykiller.cfg**: Runtime plugin configuration
- **sourceknight.yaml**: Build system and dependencies
- **ci.yml**: Build automation and releases

### Testing Changes
1. Build locally with SourceKnight
2. Deploy to test server
3. Verify functionality with different scenarios
4. Check error logs for issues
5. Test API compatibility if modifying includes

This plugin follows SourceMod's event-driven architecture and emphasizes modularity, proper memory management, and extensive API integration for maximum flexibility and performance.