# g
Aliases and scripts for daily git operations

## Required Dependencies

 * [charm_ gum tool](https://github.com/charmbracelet/gum)

 Optional for `branch` command:
 * [github cli tool](https://cli.github.com/)

## Usage

Available commands are:
 * [`add`](#add)
 * [`amend`](#amend)
 * [`branch`](#branch)
 * [`clean`](#clean)
 * [`fixup`](#fixup)
 * [`help`](#help)
 * [`log`](#log)
 * [`pull`](#pull)
 * [`push`](#push)
 * [`status`](#status)
 * [`switch`](#switch)

If the command is not recognized, it will be forwarded to `git`:
For example if you want to restore a staged file:
```
$ g restore --staged file.txt

# all the arguments will be forwarded to `git`:
$ git restore --staged file.txt
```

add
---
Add file contents to the git index.

ref: https://git-scm.com/docs/git-add

If no arguments are given, a list of modified and untracked files will be presented to select which ones you want to add to the index. 

If the -A argument is given, all modified and untracked files will be staged to be added to the git index.

You can add individual files by passing their names as arguments: 
```
g add file_a file_b
```

You can also restore staged file contents by calling `g add` again and unselect the staged files, which is the same as calling 
```
git restore --staged file_a file_b
```

amend
-----
Amend commits

ref: https://git-scm.com/docs/git-commit

This is just an alias for `git commit --amend`

branch
------
Create branches 

ref: https://git-scm.com/docs/git-branch

Create a branch passing the desired name as an argument:
```
g branch my-new-branch
```

Create a branch passing an issue number.  If you have the [github cli tool](https://cli.github.com/) installed, the issue title will be fetched and used along with the number as the new branch's name. 
```
g branch 1000
```

If no arguments are given, a prompt will ask you for the new branch name or issue number to fetch.

clean
-----
Delete merged branches

ref: https://git-scm.com/docs/git-branch

```
g clean
```
Will prompt you with a selected list of merged branches to delete.

fixup
-----
Not Implemented yet.

help
----
Not Implemented yet.

log
---
Show commit logs

ref: https://git-scm.com/docs/git-log

This is just an alias for `git log --online --no-merges`

pull
----
Fetch from and integrate with another repository or a local branch

ref: https://git-scm.com/docs/git-pull

With no arguments, it will update the current local branch with the remote `origin` refs 
```
g pull
```

If an argument is given, it will be used as the target branch
```
g pull branch-name
```

push
----
Update remote refs along with associated objects

ref: https://git-scm.com/docs/git-push

With no arguments, it will update remote `origin` refs with your current branch refs using the `--force-with_lease` option.
```
g push
```

If an argument is given, it will be used as the target branch
```
g push branch-name
```

status
------
Show the working tree status

ref: https://git-scm.com/docs/git-status

This is just an alias for `git status -s`

switch
------
Switch branches

ref: https://git-scm.com/docs/git-switch

With no arguments, it will present you a list of branches to choose one to switch to.
```
g switch
```

If an argument is given, it will be used as the target branch to switch to.
```
g switch to-branch
```
