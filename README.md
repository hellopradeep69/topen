## topen.sh

### Introduction

- topen.sh was an idea of opening terminal api tool in few keystroke
- but why tho ? : cuz i find my self typing btop and other tool very often
- so i asked myself wouldn't it be great if you get what you want in few keystroke
- and here i brought to you topen.sh

---

### Feature

- Btop - Opens a beautiful btop gui in your terminal
- lf - Opens a file manager in your terminal with regard of your home directory
- gitgo - Opens the currect repo in browser if available
- ytdown - yep as name suggest it download yt video using yt-dlp and provide beautiful ui

---

### Dependencies

1. Btop
2. yt-dlp
3. lf file manager
4. git
5. gh (optional)
6. lazygit

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
```

---

### Usage

- as the name suggest topen it is meant to be used inside tmux
- inside your tmux add the following

1. with tmux

```bash
bind-key o run-shell "tmux neww -n 'lf' ~/.local/bin/topen.sh lf"
bind-key b run-shell "tmux neww -n 'Btop' ~/.local/bin/topen.sh btop"
bind-key g run-shell "tmux neww -n 'github' ~/.local/bin/topen.sh gitgo"
```

- more option read [Help]

2. without tmux

- just learn using tmux its beautiful and very productive
- it aint that tough !
- '\_'

---

### Help

- to know more about the topen.sh , simply run the below command :-)

```bash
topen.sh
```

or

```bash
~/.local/bin/topen.sh
```

### Other Awesome Script / Stuff

- [Tmenux.sh](https://github.com/hellopradeep69/Tmenux.git)
- [My tmux conf](https://github.com/hellopradeep69/tmux.git)
