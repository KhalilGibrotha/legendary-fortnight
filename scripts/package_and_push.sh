#!/bin/bash
# Move to project root
cd "$(dirname "$0")/.."

echo "📦 Packaging environment..."
# We use --ignore-missing-files for those pesky X11 symlinks
/projects/bin/micromamba run -p /projects/rm_env \
    conda-pack -p /projects/rm_env -o rm_env_packed.tar.gz --ignore-missing-files --force

echo "🚀 Pushing to GitHub LFS..."
git add rm_env_packed.tar.gz
git commit -m "Build: Updated environment tarball $(date +'%Y-%m-%d')"
git push origin main