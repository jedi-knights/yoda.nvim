# Functions

User functions are custom functions that users can define to extend the 
functionality of the editor. These functions allow users to create their own 
custom commands, mappings, or complex operations to enhance their editing
experience.

Custom functions usually are linked to a keymap or a user command, so that they
can be triggered on demand. However, Neovim has another useful feature called
auto commands, that will allow you to automatically execute custom functions.

Auto commands in Neovim are a powerful feature that allow you to define custom
actions or behavior that automatically trigger in response to specific events
or conditions. Auto commands enable you to automate tasks, customize behavior,
or enhance the editing experience based on various events or states within the
editor.

Auto commands consist of three main components:

- event patterns,
- file patterns,
- commands

## Event Patterns

Event patterns define the events or actions that trigger the auto command.
Neovim provides a wide range of events that you can hook into, such as:

- opening or saving a file,
- entering or leaving a specific mode,
- changing the cursor position,
- and more ...

For example the `BufEnter`, `BufRead`, and `BufWrite` events are commonly used
for actions related to buffer changes.

## File Patterns

File patterns specify the conditions that restrict the auto command to
specific files or types of files. You can use wildcard characters and regular
expressions to define file patterns. For example, you can use `*.txt` to match
all text files or `/path/to/file.txt` to match a specific file.

## Commands

Commands are the actions or scripts that are executed when the auto command is
triggered. Commands can be Lua code, external shell commands, or even calls to
user-defined functions. You can perform a wide range of actions with commands
, such as setting options, modifying the buffer, invoking external tools, or 
defining mappings.


