#!/bin/bash
# Generate index.html for GitHub Pages listing all available flipbooks

set -e

OUTPUT_DIR="docs"
INDEX_FILE="$OUTPUT_DIR/index.html"

echo "Generating index page..."

# Start HTML
cat > "$INDEX_FILE" << 'HEADER'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Library - FlipBooks</title>
    <style>
        :root {
            --primary: #667eea;
            --secondary: #764ba2;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        header {
            text-align: center;
            color: white;
            margin-bottom: 40px;
        }
        header h1 {
            font-size: 3rem;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        header p {
            font-size: 1.2rem;
            opacity: 0.9;
        }
        .books-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 30px;
        }
        .book-card {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .book-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        .book-cover {
            height: 200px;
            background: linear-gradient(135deg, #8b4513 0%, #654321 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 3rem;
        }
        .book-info {
            padding: 20px;
        }
        .book-info h2 {
            color: #333;
            margin-bottom: 10px;
            font-size: 1.3rem;
        }
        .book-info p {
            color: #666;
            margin-bottom: 15px;
            font-size: 0.9rem;
        }
        .read-btn {
            display: inline-block;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            text-decoration: none;
            padding: 10px 25px;
            border-radius: 25px;
            font-weight: bold;
            transition: opacity 0.3s ease;
        }
        .read-btn:hover {
            opacity: 0.9;
        }
        .empty-state {
            text-align: center;
            color: white;
            padding: 60px;
            background: rgba(255,255,255,0.1);
            border-radius: 15px;
        }
        .empty-state h2 { margin-bottom: 15px; }
        footer {
            text-align: center;
            color: white;
            margin-top: 60px;
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>📚 Book Library</h1>
            <p>Browse and read interactive FlipBooks</p>
        </header>
        <div class="books-grid">
HEADER

# Find all flipbooks and add to index
book_count=0
for book_dir in "$OUTPUT_DIR"/*/; do
    if [ -d "$book_dir" ] && [ -f "$book_dir/index.html" ]; then
        book_name=$(basename "$book_dir")

        # Try to extract metadata
        title="$book_name"
        author="Unknown Author"

        # Check for metadata in content directory
        if [ -f "content/stories/$book_name/metadata.yml" ]; then
            title=$(grep '^title:' "content/stories/$book_name/metadata.yml" | sed 's/title: *//' | tr -d '"' || echo "$book_name")
            author=$(grep '^author:' "content/stories/$book_name/metadata.yml" | sed 's/author: *//' | tr -d '"' || echo "Unknown Author")
        fi

        # Get first letter for cover
        first_letter=$(echo "$title" | head -c 1 | tr '[:lower:]' '[:upper:]')

        cat >> "$INDEX_FILE" << BOOK
            <div class="book-card">
                <div class="book-cover">$first_letter</div>
                <div class="book-info">
                    <h2>$title</h2>
                    <p>by $author</p>
                    <a href="$book_name/" class="read-btn">Read Now →</a>
                </div>
            </div>
BOOK
        ((book_count++))
    fi
done

# If no books found, show empty state
if [ $book_count -eq 0 ]; then
    cat >> "$INDEX_FILE" << 'EMPTY'
        </div>
        <div class="empty-state">
            <h2>📖 No books yet</h2>
            <p>Add markdown content to the content/stories directory and run the build workflow.</p>
        </div>
EMPTY
else
    echo "        </div>" >> "$INDEX_FILE"
fi

# Close HTML
cat >> "$INDEX_FILE" << 'FOOTER'
        <footer>
            <p>Generated by Book Processor • Powered by GitHub Actions</p>
        </footer>
    </div>
</body>
</html>
FOOTER

echo "Index page generated: $INDEX_FILE"
echo "Total books: $book_count"
