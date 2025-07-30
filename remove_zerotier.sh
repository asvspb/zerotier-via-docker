#!/usr/bin/env bash

# This script detects installed ZeroTier components and provides an
# interactive menu for their selective removal.

set -euo pipefail
IFS=$'\n\t'

# --- Output Colors ---
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_CYAN='\033[0;36m'

# --- Global Variables ---
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KNOWN_STACKS=("ztnexitnode" "ztnet" "ztncui")

# --- Detection Functions ---

# Finds stacks for which a docker-compose.yml file exists
detect_stacks() {
  local detected_stacks=()
  for stack in "${KNOWN_STACKS[@]}"; do
    if [[ -f "$REPO_ROOT/$stack/docker-compose.yml" ]]; then
      detected_stacks+=("$stack")
    fi
  done
  printf "%s\n" "${detected_stacks[@]}"
}

# Finds image IDs related to ZeroTier
detect_image_ids() {
  docker images --format '{{.Repository}} {{.ID}}' | awk '/(zerotier|ztn)/{print $2}' | tr '\n' ' '
}

# --- Action Functions ---

remove_stack() {
  local stack_name="$1"
  local compose_dir="$REPO_ROOT/$stack_name"
  
  if [[ ! -d "$compose_dir" ]]; then
    echo -e "${C_YELLOW}Directory for stack '$stack_name' not found. Skipping.${C_RESET}"
    return
  fi

  echo -e "${C_CYAN}==== Stopping & removing stack: $stack_name ====${C_RESET}"
  # The 'down' command removes containers and networks. The -v flag removes volumes.
  (cd "$compose_dir" && docker compose down -v --remove-orphans) || {
    echo -e "${C_RED}Failed to remove stack $stack_name. It might have been already removed.${C_RESET}"
    return 1
  }
  echo -e "${C_GREEN}Stack $stack_name removed successfully.${C_RESET}"
}

remove_images() {
  echo -e "${C_CYAN}==== Removing ZeroTier-related images ====${C_RESET}"
  local image_ids
  image_ids=$(detect_image_ids)
  
  if [[ -z "$image_ids" ]]; then
    echo -e "${C_YELLOW}No ZeroTier images found.${C_RESET}"
    return
  fi
  
  # shellcheck disable=SC2086
  docker rmi -f $image_ids || {
    echo -e "${C_RED}Failed to remove images. Please try running the command manually.${C_RESET}"
    return 1
  }
  echo -e "${C_GREEN}ZeroTier images removed successfully.${C_RESET}"
}

prune_system() {
  echo -e "${C_CYAN}==== Pruning dangling images ====${C_RESET}"
  docker image prune -f
  echo -e "${C_CYAN}==== Pruning unused volumes ====${C_RESET}"
  docker volume prune -f
  echo -e "${C_GREEN}Pruning complete.${C_RESET}"
}

# --- Main Menu Logic ---

main_menu() {
  while true; do
    echo -e "\n${C_CYAN}--- ZeroTier Cleanup Menu ---${C_RESET}"
    
    local available_stacks
    mapfile -t available_stacks < <(detect_stacks)
    local image_ids
    image_ids=$(detect_image_ids)
    
    local options=()
    
    # Build options for stacks
    if [[ ${#available_stacks[@]} -gt 0 ]]; then
      for stack in "${available_stacks[@]}"; do
        options+=("Remove stack: $stack")
      done
    fi
    
    # Build option for images
    if [[ -n "$image_ids" ]]; then
      options+=("Remove all ZeroTier images")
    fi
    
    options+=("Prune unused images and volumes")
    
    # "Remove All" option
    if [[ ${#available_stacks[@]} -gt 0 || -n "$image_ids" ]]; then
      options+=("[!!!] Remove ALL of the above")
    fi
    
    options+=("Exit")

    select opt in "${options[@]}"; do
      case "$opt" in
        "Remove stack: "*)
          local stack_to_remove
          stack_to_remove=$(echo "$opt" | sed 's/Remove stack: //')
          read -p "Are you sure you want to remove the stack '$stack_to_remove'? (y/N): " confirm
          if [[ "${confirm,,}" == "y" ]]; then
            remove_stack "$stack_to_remove"
          fi
          break
          ;;
        "Remove all ZeroTier images")
          read -p "Are you sure you want to remove all ZeroTier images? (y/N): " confirm
          if [[ "${confirm,,}" == "y" ]]; then
            remove_images
          fi
          break
          ;;
        "Prune unused images and volumes")
          prune_system
          break
          ;;
        *"[!!!] Remove ALL"*)
          read -p "$(echo -e "${C_RED}WARNING! This will remove ALL found ZeroTier stacks and images. Continue? (y/N): ${C_RESET}")" confirm
          if [[ "${confirm,,}" == "y" ]]; then
            for stack in "${available_stacks[@]}"; do
              remove_stack "$stack"
            done
            if [[ -n "$image_ids" ]]; then
              remove_images
            fi
            echo -e "${C_GREEN}Full cleanup complete.${C_RESET}"
          fi
          break
          ;;
        "Exit")
          echo -e "${C_GREEN}Exiting.${C_RESET}"
          exit 0
          ;;
        *) 
          echo -e "${C_RED}Invalid choice. Please try again.${C_RESET}"
          break
          ;;
      esac
    done
  done
}

# --- Script Execution ---
if ! command -v docker &> /dev/null; then
    echo -e "${C_RED}Docker not found. Please install Docker and try again.${C_RESET}"
    exit 1
fi

main_menu