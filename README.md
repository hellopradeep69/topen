## topen.sh

### Introduction

- topen.sh was an idea of opening terminal TUI tool in few keystroke
- but why tho ? : cuz i find myself typing btop and other tool very often
- so i asked myself wouldn't it be great if you get what you want in few keystroke
- instead of making a single script for btop , lf(file manager) and etc
- i made a script that can act for multiple TUI tool within few keystroke
- however the options are limited for now
- and here i brought to you topen.sh
- it opens a tmux session with home directory when used outside tmux

---

### Feature

- Btop - Opens a beautiful btop gui in your terminal
- lf - Opens a file manager in your terminal with regard of your home directory
- gitgo - Opens the currect repo in browser if available
- ytdown - yep as name suggest it download yt video using yt-dlp and provide beautiful ui
- lazygit - opens lazygit for your cwd , only if git repo is present
- twander - passing with directory as argument opens tmux session with cwd
  (if session not exists create new one )
  - **to create a session with your home directory use home argument**
- fdir - Fuzzy find through directory and open a tmux session in that directory
- [code](https://github.com/hellopradeep69/topen?tab=readme-ov-file#code-tool) - It act as Compiler/Interpreter and provide output / errors for your code

### Dependencies

1. Btop
2. yt-dlp
3. lf file manager
4. git
5. gh (optional)
6. lazygit
7. tmux (ofcourse)
8. fzf
9. Language Compiler / Interpreter [for Code tool]

---

### Installation

1. Clone the repo

```bash
git clone https://github.com/hellopradeep69/topen.git
```

2. remove .git and README.md

```bash
rm ~/topen/README.md
rm -rf ~/topen/.git
```

3. move to your local/bin

```bash
mkdir -p ~/.local/bin/
mv ~/topen/* ~/.local/bin/.
```

4. give permission / make it executable

```bash
chmod +x ~/.local/bin/topen.sh
chmod +x ~/.local/bin/ytdown.sh
chmod +x ~/.local/bin/code
```

---

### Usage

- as the name suggest topen it is meant to be used inside tmux
- inside your tmux add the following

1. with tmux

- basic setup in .tmux.conf
  - bind-key {keymap} run-shell "tmux neww -n '{Name}' ~/.local/bin/topen.sh {option}"
  - {Name} is optional
- example setup

```bash
bind-key o run-shell "tmux neww -n 'lf' ~/.local/bin/topen.sh lf"
bind-key b run-shell "tmux neww -n 'Btop' ~/.local/bin/topen.sh btop"
bind-key g run-shell "tmux neww -n 'github' ~/.local/bin/topen.sh gitgo"
bind-key N run-shell "~/.local/bin/topen.sh -d ~/Notes/"
bind-key H run-shell "~/.local/bin/topen.sh -d home"
```

- more option read [Help](https://github.com/hellopradeep69/topen?tab=readme-ov-file#help)

2. without tmux

- just learn using tmux its beautiful and very productive
- it aint that tough !
- '\_'

---

### Code Tool

- code need some Dependencies such as javac for java and python3 for python etc to work

- Language supported
  - Python
  - Java
  - Lua
  - C
  - C++
  - Js
  - Bash / sh

- how to use it
  - You cant normally create a direct keybind in your .tmux.conf
  - i am still working on it
  - it is useless if you bind a key in your .tmux.conf as it need argument
  - and the only way i find it useful is inside neovim [The G.O.A.T editor]
  - inside neovim while writing code you can easily operate the tool
  - Paste the following code in your nvim config
  - It is suggest to paste it in your Keybind config i.e keymap.lua

##### keybinds

- NOTE: 'leader' should be [space] for convenience

1. to open in tmux window (always save before running code)

- RECOMMENDED

```lua
vim.keymap.set("n", "<leader>R", ":sil ! ~/.local/bin/topen.sh code %<CR>", {desc = "Code runner", silent = true})
```

- OR ( it saves your file every time you run it/ still above is recommended)

```lua
vim.keymap.set("n", "<leader>R", function ()
vim.cmd("write")
vim.cmd(":sil ! ~/.local/bin/topen.sh code %")
end, {desc = "Code runner", silent = true})
```

2. to open inside nvim terminal

```lua
vim.keymap.set("n", "<leader>R", function ()
local file = vim.api.nvim_buf_get_name(0)
 vim.cmd("write")
 vim.cmd("silent! ! ~/.local/bin/code " .. file)
 vim.cmd("startinsert")
 end, { desc = "Code Runner" })
```

- NOTE: vim.cmd("startinsert") is optional it is useful exit quickly

#### Known Problem that might occur

1. Problem

- Remember to run the desired code from the directory of the code
- for eg nvim ~/project/java/main.java and running code will not work properly

2. Solution

- recommend steps to use is to cd into the dir using basic cd command or using our tool
- Tmenux or topen fdir tool
- for eg cd ~/project/java/
- nvim main.java
- and then hitting 'leader R' will work
- **_if it doesn't work report the issue_**

---

### Help

- to know more about the topen.sh , simply run the below command :-)

```bash
topen.sh --help
```

or

```bash
~/.local/bin/topen.sh --help
```

### Other Awesome Script / Stuff

- [Tmenux.sh](https://github.com/hellopradeep69/Tmenux.git)
- [Lazyvimed](https://github.com/hellopradeep69/Lazyvimed.git)
- [My .tmux.conf](https://github.com/hellopradeep69/tmux.git)
