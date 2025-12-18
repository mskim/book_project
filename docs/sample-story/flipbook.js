/**
 * FlipBook with StPageFlip
 * Realistic page-turning effect
 */

document.addEventListener('DOMContentLoaded', () => {
    const flipbookEl = document.getElementById('flipbook');
    const prevBtn = document.getElementById('prev-btn');
    const nextBtn = document.getElementById('next-btn');
    const currentPageEl = document.getElementById('current-page');
    const totalPagesEl = document.getElementById('total-pages');

    // Get all pages
    const pages = flipbookEl.querySelectorAll('.page');
    const totalPages = pages.length;

    // Update total pages display
    totalPagesEl.textContent = totalPages;

    // Calculate page dimensions based on viewport
    const getPageSize = () => {
        const maxWidth = Math.min(window.innerWidth * 0.4, 550);
        const maxHeight = Math.min(window.innerHeight * 0.7, 733);

        // Maintain aspect ratio (A4-ish: 1:1.414)
        const aspectRatio = 1.333;
        let width = maxWidth;
        let height = width * aspectRatio;

        if (height > maxHeight) {
            height = maxHeight;
            width = height / aspectRatio;
        }

        return { width: Math.floor(width), height: Math.floor(height) };
    };

    const pageSize = getPageSize();

    // Initialize StPageFlip
    const pageFlip = new St.PageFlip(flipbookEl, {
        width: pageSize.width,
        height: pageSize.height,
        size: 'stretch',
        minWidth: 300,
        maxWidth: 600,
        minHeight: 400,
        maxHeight: 800,
        maxShadowOpacity: 0.5,
        showCover: true,
        mobileScrollSupport: true,
        clickEventForward: true,
        useMouseEvents: true,
        swipeDistance: 30,
        showPageCorners: true,
        disableFlipByClick: false
    });

    // Load pages
    pageFlip.loadFromHTML(document.querySelectorAll('.page'));

    // Update page indicator on flip
    pageFlip.on('flip', (e) => {
        const currentPage = e.data + 1;
        currentPageEl.textContent = currentPage;
        updateButtons(currentPage);
    });

    // Update button states
    const updateButtons = (currentPage) => {
        prevBtn.disabled = currentPage <= 1;
        nextBtn.disabled = currentPage >= totalPages;
    };

    // Button click handlers
    prevBtn.addEventListener('click', () => {
        pageFlip.flipPrev();
    });

    nextBtn.addEventListener('click', () => {
        pageFlip.flipNext();
    });

    // Keyboard navigation
    document.addEventListener('keydown', (e) => {
        switch (e.key) {
            case 'ArrowRight':
            case 'PageDown':
            case ' ':
                e.preventDefault();
                pageFlip.flipNext();
                break;
            case 'ArrowLeft':
            case 'PageUp':
                e.preventDefault();
                pageFlip.flipPrev();
                break;
            case 'Home':
                e.preventDefault();
                pageFlip.flip(0);
                break;
            case 'End':
                e.preventDefault();
                pageFlip.flip(totalPages - 1);
                break;
            case 'f':
            case 'F':
                toggleFullscreen();
                break;
        }
    });

    // TOC links
    const tocLinks = document.querySelectorAll('.book-toc a[data-page]');
    tocLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const pageIndex = parseInt(link.getAttribute('data-page'), 10);
            pageFlip.flip(pageIndex);
            flipbookEl.scrollIntoView({ behavior: 'smooth' });
        });
    });

    // Fullscreen toggle
    window.toggleFullscreen = () => {
        document.body.classList.toggle('fullscreen');

        if (document.body.classList.contains('fullscreen')) {
            if (document.documentElement.requestFullscreen) {
                document.documentElement.requestFullscreen();
            }
        } else {
            if (document.exitFullscreen) {
                document.exitFullscreen();
            }
        }

        // Update page flip size after fullscreen change
        setTimeout(() => {
            pageFlip.updateFromState();
        }, 100);
    };

    // Handle window resize
    let resizeTimeout;
    window.addEventListener('resize', () => {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(() => {
            const newSize = getPageSize();
            pageFlip.updateFromState();
        }, 250);
    });

    // Initial button state
    updateButtons(1);

    // Expose to global scope for debugging
    window.pageFlip = pageFlip;

    console.log('FlipBook initialized with', totalPages, 'pages');
});
