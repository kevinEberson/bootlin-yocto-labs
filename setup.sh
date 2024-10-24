#!/usr/bin/env bash

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "git is not installed. Please install git to proceed."
    exit 1
fi

# Set the base directory for the yocto project
if [ -z "$1" ]; then
    YOCTO_BASE_DIR=$PWD
else
    YOCTO_BASE_DIR="$1"
fi

REPO_ROOT_DIR=$PWD

# Create the base directory if it doesn't exist
mkdir -p "$YOCTO_BASE_DIR"
cd "$YOCTO_BASE_DIR" || exit

# Define the repositories to clone

YOCTO_MIRROR="https://git.yoctoproject.org/git"
GITHUB_MIRROR="https://github.com/kevinEberson"

declare -A REPOS=(
    ["poky"]="$YOCTO_MIRROR/poky.git kirkstone-4.0.5 kirkstone-4.0.5"
    ["meta-arm"]="$YOCTO_MIRROR/meta-arm.git yocto-4.0.1 yocto-4.0.1"
    ["meta-ti"]="$YOCTO_MIRROR/meta-ti.git kirkstone-labs 2a5a0339d5bd28d6f6aedaf02a6aaa9b73a248e4"
    ["meta-bootlinlabs"]="$GITHUB_MIRROR/meta-bootlinlabs.git kirkstone-4.0.0 main"
)

# Clone the repositories
for REPO in "${!REPOS[@]}"; do
    IFS=' ' read -r URL BRANCH REVISION <<< "${REPOS[$REPO]}"

    if [ ! -d "$YOCTO_BASE_DIR/$REPO" ]; then
        echo "Cloning $REPO from $URL..."
        git clone "$URL" "$REPO"
	cd "$REPO" || exit
       	git checkout -b $BRANCH $REVISION
	cd ..
    fi
done

# Apply the patch if it exists
PATCH_PATH="$REPO_ROOT_DIR/bootlin-lab-data/0001-Simplify-linux-ti-staging-recipe-for-the-Bootlin-lab.patch"

if [ -f "$PATCH_PATH" ]; then
    echo "Applying patch $PATCH_PATH..."
    cd "$YOCTO_BASE_DIR/meta-ti" || exit
    git am $PATCH_PATH
    echo "Patch applied successfully."
else
    echo "Patch file not found: $PATCH_PATH"
    exit 1
fi

# If the setup is done out-of-tree, copy the default configs to the build directory
if [ "$YOCTO_BASE_DIR" != "$REPO_ROOT_DIR" ]; then   
    cp -r $REPO_ROOT_DIR/build $YOCTO_BASE_DIR
fi

echo "All operations completed, check if any errors occured. Run \"source poky/oe-init-build-env\" in $YOCTO_BASE_DIR"
