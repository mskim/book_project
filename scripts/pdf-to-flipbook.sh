#!/bin/bash
# Convert PDF pages to FlipBook HTML format

set -e

STORY_NAME=$1
PDF_FILE="output/pdf/${STORY_NAME}.pdf"
IMAGES_DIR="output/images/${STORY_NAME}"
OUTPUT_DIR="output/flipbook/${STORY_NAME}"
TEMPLATE_DIR="templates/flipbook"

echo "Converting PDF to FlipBook: $STORY_NAME"

# Create output directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$IMAGES_DIR"

# Check if PDF exists
if [ ! -f "$PDF_FILE" ]; then
    echo "Error: PDF not found at $PDF_FILE"
    exit 1
fi

# Convert PDF to images
echo "Converting PDF pages to images..."

# Clear existing images
rm -f "$IMAGES_DIR"/*.png "$IMAGES_DIR"/*.jpg 2>/dev/null || true

# Use pdftoppm (poppler) if available - best quality
if command -v pdftoppm &> /dev/null; then
    echo "Using pdftoppm for conversion..."
    pdftoppm -png -r 150 "$PDF_FILE" "$IMAGES_DIR/page"

    # Rename files to consistent format (page-1.png -> page_001.png)
    for f in "$IMAGES_DIR"/page-*.png; do
        if [ -f "$f" ]; then
            num=$(basename "$f" | sed 's/page-\([0-9]*\)\.png/\1/')
            # Remove leading zeros to avoid octal interpretation
            num=$((10#$num))
            new_name=$(printf "page_%03d.png" "$num")
            mv "$f" "$IMAGES_DIR/$new_name"
        fi
    done

# Use ImageMagick convert if available
elif command -v convert &> /dev/null; then
    echo "Using ImageMagick for conversion..."
    convert -density 150 "$PDF_FILE" -quality 90 "$IMAGES_DIR/page_%03d.png"

# Use Ghostscript if available
elif command -v gs &> /dev/null; then
    echo "Using Ghostscript for conversion..."
    gs -dNOPAUSE -dBATCH -sDEVICE=png16m -r150 \
       -sOutputFile="$IMAGES_DIR/page_%03d.png" "$PDF_FILE"

# Fallback: use qlmanage for single thumbnail
else
    echo "Using Quick Look for preview (single page only)..."
    qlmanage -t -s 1200 -o "$IMAGES_DIR" "$PDF_FILE" 2>/dev/null || true
    for f in "$IMAGES_DIR"/*.png; do
        if [ -f "$f" ]; then
            mv "$f" "$IMAGES_DIR/page_001.png"
            break
        fi
    done
fi

echo "Image conversion complete."
ls -la "$IMAGES_DIR"/ 2>/dev/null || true

# Extract metadata from content.md if available
TITLE="$STORY_NAME"
AUTHOR="Unknown"

if [ -f "content/stories/${STORY_NAME}/metadata.yml" ]; then
    TITLE=$(grep '^title:' "content/stories/${STORY_NAME}/metadata.yml" | sed 's/title: *//' | tr -d '"' || echo "$STORY_NAME")
    AUTHOR=$(grep '^author:' "content/stories/${STORY_NAME}/metadata.yml" | sed 's/author: *//' | tr -d '"' || echo "Unknown")
fi

echo "Title: $TITLE"
echo "Author: $AUTHOR"

# Build pages content from images
PAGES_CONTENT=""
PAGE_NUM=0

# Process page images
shopt -s nullglob
for img in "$IMAGES_DIR"/page_*.png "$IMAGES_DIR"/page_*.jpg; do
    if [ -f "$img" ]; then
        ((PAGE_NUM++))
        img_name=$(basename "$img")

        # Copy image to output
        cp "$img" "$OUTPUT_DIR/"

        PAGES_CONTENT="${PAGES_CONTENT}
            <div class=\"page\" data-page=\"${PAGE_NUM}\">
                <div class=\"page-content page-image\">
                    <img src=\"${img_name}\" alt=\"Page ${PAGE_NUM}\" loading=\"lazy\">
                </div>
                <div class=\"page-number\">${PAGE_NUM}</div>
            </div>"
    fi
done

# If no images, create placeholder with PDF download
if [ $PAGE_NUM -eq 0 ]; then
    echo "No page images found, creating download placeholder..."

    # Copy PDF to output for download
    cp "$PDF_FILE" "$OUTPUT_DIR/"
    PDF_NAME=$(basename "$PDF_FILE")

    PAGES_CONTENT="
        <div class=\"page cover\" data-page=\"1\">
            <div class=\"page-content\">
                <h1>$TITLE</h1>
                <p class=\"author\">by $AUTHOR</p>
                <p class=\"placeholder\">
                    <a href=\"$PDF_NAME\" class=\"download-btn\" download>Download PDF</a>
                </p>
            </div>
        </div>"
    PAGE_NUM=1
fi

echo "Creating FlipBook HTML with $PAGE_NUM pages (using StPageFlip)..."

# Generate FlipBook HTML with StPageFlip
cat > "$OUTPUT_DIR/index.html" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${TITLE}</title>
    <link rel="stylesheet" href="flipbook.css">
    <style>
        .page-content {
            padding: 0 !important;
        }
        .page-content img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }
    </style>
</head>
<body>
    <div class="book-container">
        <header class="book-header">
            <h1>${TITLE}</h1>
            <p class="author">by ${AUTHOR}</p>
        </header>

        <div class="flipbook-wrapper">
            <div class="flipbook" id="flipbook">
                ${PAGES_CONTENT}
            </div>
        </div>

        <nav class="book-controls">
            <button id="prev-btn" class="nav-btn" aria-label="Previous page">
                <span>←</span> Previous
            </button>
            <span class="page-indicator">
                Page <span id="current-page">1</span> of <span id="total-pages">${PAGE_NUM}</span>
            </span>
            <button id="next-btn" class="nav-btn" aria-label="Next page">
                Next <span>→</span>
            </button>
        </nav>

        <div class="book-toc" id="toc">
            <h2>Options</h2>
            <ul>
                <li><a href="$(basename "$PDF_FILE")" download>📥 Download PDF</a></li>
                <li><a href="#" onclick="toggleFullscreen(); return false;">🔲 Fullscreen (F)</a></li>
                <li><a href="../">← Back to Library</a></li>
            </ul>
        </div>
    </div>

    <script src="page-flip.min.js"></script>
    <script src="flipbook.js"></script>
</body>
</html>
HTMLEOF

# Copy CSS, JS and StPageFlip library from templates
cp "$TEMPLATE_DIR/flipbook.css" "$OUTPUT_DIR/"
cp "$TEMPLATE_DIR/flipbook.js" "$OUTPUT_DIR/"
cp "$TEMPLATE_DIR/page-flip.min.js" "$OUTPUT_DIR/"

# Copy PDF for download
cp "$PDF_FILE" "$OUTPUT_DIR/"

echo "=========================================="
echo "FlipBook generated: $OUTPUT_DIR/index.html"
echo "Total pages: $PAGE_NUM"
echo "=========================================="
