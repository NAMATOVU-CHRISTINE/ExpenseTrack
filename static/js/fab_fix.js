/**
 * Floating Action Button (FAB) functionality
 * This script ensures the FAB button works properly
 */

document.addEventListener('DOMContentLoaded', function() {
    console.log('FAB fix script loaded');
    
    // FAB open/close logic
    const fabContainer = document.querySelector('.fab-container');
    const fabMainBtn = document.getElementById('fab-main-btn');
    
    if (fabMainBtn && fabContainer) {
        console.log('FAB elements found, setting up event listeners');
        
        // Handle click/touch events
        const handleInteraction = (e) => {
            e.preventDefault();
            e.stopPropagation();
            console.log('FAB button clicked');
            fabContainer.classList.toggle('open');
        };

        // Add both click and touch events
        fabMainBtn.addEventListener('click', handleInteraction);
        fabMainBtn.addEventListener('touchend', handleInteraction);

        // Close the FAB menu when clicking outside
        const handleOutsideClick = (e) => {
            if (!fabContainer.contains(e.target)) {
                fabContainer.classList.remove('open');
            }
        };

        document.addEventListener('click', handleOutsideClick);
        document.addEventListener('touchend', handleOutsideClick);

        // Handle scroll position
        let lastScrollTop = 0;
        window.addEventListener('scroll', () => {
            const st = window.pageYOffset || document.documentElement.scrollTop;
            if (st > lastScrollTop) {
                // Scrolling down
                fabContainer.style.transform = 'translateY(100px)';
            } else {
                // Scrolling up
                fabContainer.style.transform = 'translateY(0)';
            }
            lastScrollTop = st <= 0 ? 0 : st;
        }, { passive: true });

        // Ensure FAB stays within viewport
        const updateFabPosition = () => {
            const viewportHeight = window.innerHeight;
            const viewportWidth = window.innerWidth;
            const fabHeight = fabContainer.offsetHeight;
            const fabWidth = fabContainer.offsetWidth;
            
            if (fabContainer.offsetTop + fabHeight > viewportHeight) {
                fabContainer.style.bottom = '2rem';
            }
            if (fabContainer.offsetLeft + fabWidth > viewportWidth) {
                fabContainer.style.right = '2rem';
            }
        };

        window.addEventListener('resize', updateFabPosition);
        updateFabPosition();
    } else {
        console.error('FAB elements not found: container=', !!fabContainer, 'button=', !!fabMainBtn);
    }
});