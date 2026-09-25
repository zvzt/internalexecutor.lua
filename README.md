# Internal Executor UI

A Roblox Luau script-editor interface with line numbers, scrolling, clipboard support, and file export controls.

> **Current status:** the editor UI is functional, but the **Execute** button is currently a placeholder and does not run the text inside the editor. That behavior is being kept documented until the execution logic is updated and tested.

## Preview

<img width="566" height="380" alt="Internal Executor UI" src="https://github.com/user-attachments/assets/771bbaeb-a408-4956-b948-9db2e81046ad" />

<img width="529" height="37" alt="Internal Executor controls" src="https://github.com/user-attachments/assets/865d3a16-1f5b-483f-9751-19c3fc651327" />

## Usage

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/zvzt/internalexecutor.lua/refs/heads/main/internalexec.lua"))()
```

## Features

- Draggable editor window
- Line-number gutter
- Horizontal and vertical scrolling
- Clear button
- Clipboard copy when `setclipboard` is available
- File export when `writefile` is available
- Compact status messages

## Compatibility

Some controls depend on executor-specific functions. The UI handles unavailable clipboard and file-writing functions without requiring them to exist.

## Files

- `internalexec.lua` — main script
- `README.md` — documentation

## License

MIT — see [LICENSE](LICENSE).
