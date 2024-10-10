#!/bin/sh

help() {
  echo "OPTIONS: branch clean fixup pull push switch" 
}

current_branch() {
  git rev-parse --abbrev-ref HEAD
}

switch() {
  if [ -z "$1" ]; then
    branch=$(git branch --format="%(refname:short)" | gum choose)
  else
    branch=$1
  fi

	if [ -z "${branch}" ]; then
		echo "No branch was selected."		
		exit
	fi

  if [ $branch = $(current_branch) ]; then
    echo "already in $branch"
  else
	  git switch "$branch"
  fi
}

clean() {
  # list of _merged_ branches
  merged=$(
    git branch \
      --format="%(refname:short)" \
      --merged | egrep -v '^(main|master|develop)$'
  )

  if [ -z "$merged" ]; then
    echo "There are no merged branches to be deleted."
    exit
  fi

  branches=$( 
    gum choose \
      --header="Choose branches to delete:" \
      --cursor-prefix="[] " \
      --selected-prefix="[x] " \
      --unselected-prefix="[] " \
      --no-limit \
      $merged
  )

  if [ -z "${branches}" ]; then
    echo "No branch was selected."
    exit 
  fi

  echo $branches | tr " " "\n" | while read branch
  do
    git branch -d "$branch"
  done
}

branch() {
  if [ -z "$1" ]; then
    git branch
    exit
  else
    name=$1
  fi

  branch="$name"

  # check if input is an issue number
  if [ $name -eq $name 2>/dev/null ]; then
    # check if we have the github cli available
    if command -v gh 1>/dev/null; then 
      repo=$(gum spin --title "fetching repo name... " --show-output -- \
        gh repo view --json nameWithOwner -q ".nameWithOwner")
      
      # Confirm repo name
      repo=$(gum input --prompt="repository: " --value=$repo)

      slug=$(gum spin --title "fetching issue... " --show-output -- \
        gh --repo "$repo" issue view "$name" --json title \
        | jq -r .title \
        | iconv -t ascii//IGNORE/TRANSLIT \
        | sed -r 's/[^a-zA-Z0-9]+/-/g' \
        | sed -r 's/^-+\|-+$//g' \
        | tr A-Z a-z \
        | head -c64)

      if [ -z "$slug" ]; then
        echo "Could not find issue $name in $repo"
        exit
      fi

      branch=$(gum input --width=0 --prompt="proposed name: " --value="$name-$slug")
    fi
  fi

  if [ -z $branch ]; then
    echo "A branch name is required."
    exit
  fi

  gum confirm "create branch $branch" || exit

  default_branch=$(gh repo view --json defaultBranchRef -q ".defaultBranchRef.name")
  base=$(gum input --prompt="base branch: " --value=$default_branch)
  if [ -z $base ]; then
  	echo "A base branch is required."
    exit
  fi

  # Should we fetch the base branch?
  # gum spin --title "fetching $base..." -- git fetch origin "$base"
  git branch "$branch" origin/"$base"
  git switch "$branch"
}

pull() {
  if [ -z "$1" ]; then
    # pull current branch
    branch=$(current_branch)
  else
    branch=$1
  fi

  if [ -z $branch ]; then
    echo "A branch is required."
    exit
  fi

  if ! [ $branch = $(current_branch) ]; then
    git switch "$branch"
  fi

  gum spin --title "pulling $branch" --show-output -- \
    git pull origin "$branch"
}

push() {
  if [ -z "$1" ]; then
    # push current branch
    branch=$(current_branch)
  else
    branch=$1
  fi

  if [ -z $branch ]; then
    echo "A branch is required."
    exit
  fi

  if ! [ $branch = $(current_branch) ]; then
    git switch "$branch"
  fi 

  gum spin --title "pushing $branch" --show-output -- \
    git push --force-with-lease origin "$branch"
}

add() {
  if [ $# -eq 0 ]; then
    modified_and_untracked=$(git status -s | awk '{print $2}')
    staged=$(git status -s | grep '^[A-Z]' | awk '{print $2}')
    selected_csv=$(echo $staged | tr ' ' ',' | head -c -1)

    files=$( 
      gum choose \
        --header="Choose files/directories to add:" \
        --cursor-prefix="[] " \
        --selected-prefix="[x] " \
        --unselected-prefix="[] " \
        --item.foreground="210" \
        --header.foreground="" \
        --selected.foreground="114" \
        --no-limit \
        --selected=$selected_csv \
        $modified_and_untracked
    )
  elif [ $# -eq 1] && [ $1 = "-A"]; then
    # add modified and untracked
    files=$(git status -s | awk '{print $2}')
  else
    files=$@
  fi

  if ! [ -z "$staged" ]; then
    git restore --staged $staged
  fi

  if ! [ -z "$files" ]; then
    git add $files
  fi

  git status -s
}

# Chek if current path is a git repo
git rev-parse --is-inside-work-tree 1> /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "There is no git repository in the current path."
  exit
fi

if ! command -v gum 1>/dev/null; then
  echo "gum is not installed. Install it from: https://github.com/charmbracelet/gum"
  exit
fi

if [ -z "$1" ]; then
  help
  exit
else
  case $1 in
    "add")
      shift # remove first argument -> "add"
      add $@
      ;;
    "amend")
      git commit --amend
      ;;
    "branch")
      branch $2
      ;;
    "clean")
      clean
      ;;
    "fixup")
      echo "not implemented"
      ;;
    "help")
      help
      ;;
    "log")
      git log --oneline --no-merges
      ;;
    "pull")
      pull $2
      ;;
    "push")
      push $2
      ;;
    "status")
      git status -s
      ;;
    "switch")
      switch $2
      ;;
    *)
      git $@
      ;;
  esac
fi
