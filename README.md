# Internal Executor UI

A Roblox Luau script-editor interface with line numbers, scrolling, execution, clipboard support, file export controls, and Onyx-style window behavior.

## Preview

<img width="566" height="380" alt="Internal Executor UI" src="https://github.com/user-attachments/assets/771bbaeb-a408-4956-b948-9db2e81046ad" />

<img width="529" height="37" alt="Internal Executor controls" src="https://github.com/user-attachments/assets/865d3a16-1f5b-483f-9751-19c3fc651327" />

## Usage

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/zvzt/internalexecutor.lua/refs/heads/main/internalexec.lua"))()
```

## Features

- Onyx-style draggable editor window
- Header-only minimize/restore behavior
- Screen-edge drag clamping with `-57 / 57` vertical offsets
- Line-number gutter
- Horizontal and vertical editor scrolling
- Execute button using `loadstring` when available
- Compile errors and runtime errors are caught and reported
- Clear button
- Clipboard copy when `setclipboard` is available
- File export when `writefile` is available
- Compact status messages
- Rerun cleanup prevents duplicate UI and input connections

## Execution behavior

The Execute button now runs the editor contents when the current environment exposes `loadstring`.

- Compile failures are reported as **Compile error - check console**
- Runtime failures are reported as **Runtime error - check console**
- Successful runs report **Executed successfully**

## Compatibility

Several controls depend on executor-specific functions. The UI handles unavailable execution, clipboard, and file-writing functions without assuming they exist.

A synchronized deployment copy is maintained in `zxt.lol/public/internalexecutor.lua`.

## Files

- `internalexec.lua` — main script
- `README.md` — documentation

## License

MIT — see [LICENSE](LICENSE).
