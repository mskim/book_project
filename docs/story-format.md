# Story.md Format Guide

This document describes the markdown format used by `doc_processor` to generate professional PDF books.

## Overview

The `story.md` format combines:
- YAML frontmatter for book configuration
- Section headers with document types
- Per-document metadata
- Markdown content

## Basic Structure

```markdown
---
# Book Configuration (YAML)
title: Book Title
author: Author Name
...
---

# [document_type]
---
title: Document Title
---

Content here...

## [chapter]
---
title: Chapter Title
---

Chapter content...
```

## Book Configuration (YAML Frontmatter)

The file starts with YAML configuration between `---` markers:

```yaml
---
title: My Life Story
subtitle: A Journey Through Time
author: John Doe
publisher: BookcheeGo Publishing
book_type: novel
size: 148mmx210mm
has_part: false
part_count: 0
dedication: true
thanks: true
foreword: true
prologue: false
front_blank_page: false
copyright_at_end: false
chapter_count: 6
---
```

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Book title |
| `book_type` | enum | One of: novel, essay, poetry, textbook, manual, children |
| `size` | string | Page dimensions (e.g., "148mmx210mm", "125mmx188mm") |

### Optional Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `subtitle` | string | - | Book subtitle |
| `author` | string | - | Author name |
| `publisher` | string | - | Publisher name |
| `has_part` | boolean | false | Book has parts/sections |
| `part_count` | integer | 0 | Number of parts |
| `dedication` | boolean | false | Include dedication page |
| `thanks` | boolean | false | Include acknowledgments |
| `foreword` | boolean | false | Include foreword |
| `prologue` | boolean | false | Include prologue |
| `front_blank_page` | boolean | false | Blank page after title |
| `copyright_at_end` | boolean | false | Copyright at end of book |
| `chapter_count` | integer | 0 | Number of chapters |

### Common Page Sizes

| Size | Dimensions | Use Case |
|------|------------|----------|
| A5 | 148mmx210mm | Standard paperback |
| B6 | 125mmx188mm | Compact book |
| A4 | 210mmx297mm | Large format |
| Letter | 216mmx279mm | US standard |

## Document Types

### Front Matter (use `#`)

| Type | Description |
|------|-------------|
| `title_page` | Book cover/title page |
| `inside_cover` | Inside cover page |
| `blank_page` | Empty page |
| `copyright` | Copyright information |
| `toc` | Table of contents |
| `dedication` | Dedication page |
| `thanks` | Acknowledgments |
| `foreword` | Foreword/preface |
| `information` | Additional info |
| `prologue` | Story prologue |

### Body Matter (use `##`)

| Type | Description |
|------|-------------|
| `chapter` | Regular chapter |
| `poem` | Poetry (preserves line breaks) |
| `part_cover` | Part divider page |

### Rear Matter (use `#`)

| Type | Description |
|------|-------------|
| `epilogue` | Story epilogue |
| `appendix` | Supplementary material |
| `glossary` | Term definitions |
| `back_copyright` | End copyright page |

## Section Format

### Basic Section

```markdown
# [document_type]
---
title: Section Title
---

Section content here...
```

### Chapter with Part Number

```markdown
## [chapter]
---
title: Chapter 1: The Beginning
part_number: 1
---

Chapter content here...
```

## Content Formatting

### Headings (within sections)

```markdown
### Subheading (h3)

#### Sub-subheading (h4)
```

### Paragraphs

```markdown
This is a paragraph. Leave blank lines between paragraphs.

This is another paragraph with more content.
```

### Block Quotes

```markdown
> "This is a quotation," she said.
> It can span multiple lines.
```

### Lists

```markdown
Unordered list:
- Item one
- Item two
- Item three

Ordered list:
1. First item
2. Second item
3. Third item
```

### Emphasis

```markdown
*italic text*
**bold text**
***bold italic***
```

## Complete Example

```markdown
---
title: A Simple Story
author: Jane Writer
book_type: novel
size: 148mmx210mm
dedication: true
chapter_count: 2
---

# [title_page]
---
title: A Simple Story
---

A SIMPLE STORY

by Jane Writer

# [copyright]
---
title: Copyright
---

Copyright 2025 by Jane Writer. All rights reserved.

# [dedication]
---
title: Dedication
---

For everyone who dreams.

## [chapter]
---
title: Chapter 1: Beginnings
---

The story begins on an ordinary day.

### The Morning

She woke to sunlight streaming through the window.

> "Today will be different," she thought.

And it was.

## [chapter]
---
title: Chapter 2: Discoveries
---

What she found changed everything:

1. A letter from the past
2. A key to somewhere new
3. Courage she didn't know she had

# [epilogue]
---
title: Epilogue
---

Years later, she understood.
```

## Processing Commands

### Parse and Generate PDF

```bash
# Parse story.md and create book structure
doc_processor book-parse \
  --input story.md \
  --book ./output/my-book \
  --generate-pdf

# Generate PDF from book database
doc_processor db-generate \
  ./output/my-book/book_info.db \
  --output my-book.pdf \
  --images
```

### Export Back to Markdown

```bash
doc_processor book-export \
  --book ./output/my-book \
  --output exported-story.md
```

## Tips

1. **Document Order**: Documents appear in the PDF in the order they appear in the file
2. **Auto-generated Pages**: title_page, copyright, toc, inside_cover are auto-generated if not specified
3. **Parts**: Use `part_number` in chapter metadata when `has_part: true`
4. **Line Breaks**: Use `poem` type to preserve exact line breaks
5. **Images**: Place images in an `images/` folder alongside story.md
