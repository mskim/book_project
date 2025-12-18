#!/bin/bash
# Fallback script for building FlipBook when doc_processor is not available
# This script converts markdown files to HTML flipbook format

set -e

STORY_ID=$1
CONTENT_DIR="content/stories"
OUTPUT_DIR="output/flipbook"
TEMPLATE_DIR="templates/flipbook"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to convert markdown to HTML page
convert_md_to_html() {
    local md_file=$1
    local page_num=$2

    # Extract title from first heading
    local title=$(grep -m1 '^#' "$md_file" | sed 's/^#* *//')

    # Convert markdown to HTML (basic conversion)
    local content=$(cat "$md_file" | \
        sed 's/^# \(.*\)/<h2>\1<\/h2>/g' | \
        sed 's/^## \(.*\)/<h3>\1<\/h3>/g' | \
        sed 's/^### \(.*\)/<h4>\1<\/h4>/g' | \
        sed 's/^\*\*\(.*\)\*\*/<strong>\1<\/strong>/g' | \
        sed 's/^\*\(.*\)\*/<em>\1<\/em>/g' | \
        sed '/^$/d' | \
        sed 's/^/<p>/g' | \
        sed 's/$/<\/p>/g' | \
        sed 's/<p><h/<h/g' | \
        sed 's/<\/h.><\/p>/<\/h2>/g')

    echo "<div class=\"page\" data-page=\"$page_num\">"
    echo "  <div class=\"page-content\">"
    echo "    $content"
    echo "  </div>"
    echo "  <div class=\"page-number\">$page_num</div>"
    echo "</div>"
}

# Function to build a single story
build_story() {
    local story_dir=$1
    local story_name=$(basename "$story_dir")
    local story_output="$OUTPUT_DIR/$story_name"

    echo "Building FlipBook for: $story_name"

    mkdir -p "$story_output"

    # Read story metadata
    local title="$story_name"
    local author="Unknown"

    if [ -f "$story_dir/metadata.yml" ]; then
        title=$(grep '^title:' "$story_dir/metadata.yml" | sed 's/title: *//' | tr -d '"')
        author=$(grep '^author:' "$story_dir/metadata.yml" | sed 's/author: *//' | tr -d '"')
    fi

    # Build pages content
    local pages_content=""
    local toc_content=""
    local page_num=1

    # Add cover page
    pages_content="<div class=\"page cover\"><h1>$title</h1><p class=\"author\">by $author</p></div>"

    # Process markdown files in order
    for md_file in "$story_dir"/*.md; do
        if [ -f "$md_file" ]; then
            local chapter_title=$(grep -m1 '^#' "$md_file" | sed 's/^#* *//')
            toc_content="$toc_content<li><a href=\"#\" data-page=\"$page_num\">$chapter_title <span class=\"page-num\">$page_num</span></a></li>"

            pages_content="$pages_content$(convert_md_to_html "$md_file" "$page_num")"
            ((page_num++))
        fi
    done

    # Generate final HTML
    cat "$TEMPLATE_DIR/index.html" | \
        sed "s/{{BOOK_TITLE}}/$title/g" | \
        sed "s/{{AUTHOR_NAME}}/$author/g" | \
        sed "s|{{PAGES_CONTENT}}|$pages_content|g" | \
        sed "s|{{TOC_CONTENT}}|$toc_content|g" \
        > "$story_output/index.html"

    # Copy assets
    cp "$TEMPLATE_DIR/flipbook.css" "$story_output/"
    cp "$TEMPLATE_DIR/flipbook.js" "$story_output/"

    echo "FlipBook generated: $story_output/index.html"
}

# Main logic
if [ -n "$STORY_ID" ]; then
    # Build specific story
    if [ -d "$CONTENT_DIR/$STORY_ID" ]; then
        build_story "$CONTENT_DIR/$STORY_ID"
    else
        echo "Error: Story '$STORY_ID' not found in $CONTENT_DIR"
        exit 1
    fi
else
    # Build all stories
    for story_dir in "$CONTENT_DIR"/*/; do
        if [ -d "$story_dir" ]; then
            build_story "$story_dir"
        fi
    done
fi

echo "Build complete!"
