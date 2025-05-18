// Greeting based on time of day
function updateGreeting() {
    const hour = new Date().getHours();
    const greetingSpan = document.getElementById('greeting');
    
    if (hour >= 5 && hour < 12) greetingSpan.textContent = 'Good Morning';
    else if (hour >= 12 && hour < 17) greetingSpan.textContent = 'Good Afternoon';
    else if (hour >= 17 && hour < 22) greetingSpan.textContent = 'Good Evening';
    else greetingSpan.textContent = 'Good Night';
}

// Rotating motivational quotes
const tips = [
    "A budget is telling your money where to go instead of wondering where it went.",
    "Small savings today, big dreams tomorrow.",
    "Track every expense—awareness is the first step to control.",
    "Don't save what is left after spending; spend what is left after saving.",
    "Financial freedom is a journey, not a destination.",
    "Review your goals every week to stay motivated.",
    "Cutting small, unnecessary expenses adds up over time.",
    "Invest in yourself—your best asset.",
    "Every shilling saved is a step toward your goals.",
    "Smart spending today creates wealth tomorrow.",
    "Money grows when managed wisely.",

    "Budgeting turns dreams into reality.",

    "Save first, then spend smart.",

    "Debt-free living is financial freedom.",

    "Invest early, reap the rewards later.",

    "A small cut today prevents a financial wound tomorrow.",

    "Your budget reflects your priorities.",

    "Financial discipline leads to lasting wealth.",

    "Make your money work for you.",

    "A shilling saved is a shilling earned."
];
function updateQuote() {
    const quoteElement = document.getElementById('motivational-quote');
    const randomTip = tips[Math.floor(Math.random() * tips.length)];
    quoteElement.style.opacity = '0';
    setTimeout(() => {
        quoteElement.textContent = randomTip;
        quoteElement.style.opacity = '1';
    }, 400);
}

// Smooth number transitions
function animateValue(element, start, end, duration = 1000) {
    if (!element) return;
    
    const startTimestamp = performance.now();
    const updateNumber = (currentTimestamp) => {
        const elapsed = currentTimestamp - startTimestamp;
        const progress = Math.min(elapsed / duration, 1);
        
        // Easing function for smooth animation
        const easeOutQuart = 1 - Math.pow(1 - progress, 4);
        const current = Math.floor(start + (end - start) * easeOutQuart);
        
        element.textContent = formatCurrency(current);
        
        if (progress < 1) {
            requestAnimationFrame(updateNumber);
        }
    };
    
    requestAnimationFrame(updateNumber);
}

// Format currency with animation
function formatCurrency(value) {
    return `UGX ${value.toLocaleString()}`;
}

// Animate progress bars
function animateProgress(element, targetWidth) {
    if (!element) return;
    
    element.style.width = '0%';
    setTimeout(() => {
        element.style.width = `${targetWidth}%`;
    }, 50);
}

// Handle card hover effects
function initializeCardEffects() {
    const cards = document.querySelectorAll('.dashboard-card');
    cards.forEach(card => {
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            
            const rotateX = (y - centerY) / 20;
            const rotateY = (centerX - x) / 20;
            
            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.02, 1.02, 1.02)`;
        });
        
        card.addEventListener('mouseleave', () => {
            card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) scale3d(1, 1, 1)';
        });
    });
}

// Initialize loading effects
function initializeLoadingEffects() {
    const loadingOverlay = document.createElement('div');
    loadingOverlay.className = 'loading-overlay';
    loadingOverlay.innerHTML = `
        <div class="loading-spinner">
            <div class="spinner-ring"></div>
            <div class="spinner-text">Loading data...</div>
        </div>
    `;
    document.body.appendChild(loadingOverlay);
    
    return {
        show: () => loadingOverlay.classList.add('active'),
        hide: () => loadingOverlay.classList.remove('active')
    };
}

// Lottie Animations
function loadLottie(id, url) {
    if (window.lottie) {
        window.lottie.loadAnimation({
            container: document.getElementById(id),
            renderer: 'svg',
            loop: true,
            autoplay: true,
            path: url
        });
    }
}

// Initialize Lottie Animations
function initLottie() {
    if (document.getElementById('lottie-quote')) {
        lottie.loadAnimation({
            container: document.getElementById('lottie-quote'),
            renderer: 'svg',
            loop: true,
            autoplay: true,
            path: 'https://assets3.lottiefiles.com/packages/lf20_xyadoh9h.json'
        });
    }

    if (document.getElementById('lottie-empty-transactions')) {
        lottie.loadAnimation({
            container: document.getElementById('lottie-empty-transactions'),
            renderer: 'svg',
            loop: true,
            autoplay: true,
            path: 'https://assets8.lottiefiles.com/packages/lf20_ysrn2iwp.json'
        });
    }

    if (document.getElementById('lottie-empty-categories')) {
        lottie.loadAnimation({
            container: document.getElementById('lottie-empty-categories'),
            renderer: 'svg',
            loop: true,
            autoplay: true,
            path: 'https://assets9.lottiefiles.com/packages/lf20_yzoqyyqf.json'
        });
    }
}

// Initialize CountUp animations
function initCountUp() {
    const options = {
        duration: 2.5,
        useEasing: true,
        useGrouping: true,
        separator: ',',
        decimal: '.'
    };

    document.querySelectorAll('.counter-number').forEach(el => {
        const value = parseInt(el.textContent.replace(/[^0-9]/g, ''));
        new CountUp(el, value, options).start();
    });
}

// Handle FAB (Floating Action Button)
function initFAB() {
    const fabContainer = document.querySelector('.fab-container');
    const fabMainBtn = document.getElementById('fab-main-btn');

    if (fabMainBtn) {
        fabMainBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            fabContainer.classList.toggle('open');
        });

        document.addEventListener('click', (e) => {
            if (!fabContainer.contains(e.target)) {
                fabContainer.classList.remove('open');
            }
        });
    }
}

// Progress Bar Animations
function initProgressBars() {
    const bars = document.querySelectorAll('.progress-bar');
    bars.forEach(bar => {
        const width = bar.style.width;
        bar.style.width = '0';
        setTimeout(() => {
            bar.style.width = width;
        }, 100);
    });
}

// Card Hover Effects
function initCardEffects() {
    const cards = document.querySelectorAll('.dashboard-card');
    cards.forEach(card => {
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            
            const rotateX = (y - centerY) / 20;
            const rotateY = (centerX - x) / 20;
            
            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.02, 1.02, 1.02)`;
        });
        
        card.addEventListener('mouseleave', () => {
            card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) scale3d(1, 1, 1)';
        });
    });
}

// Auto-update time-based elements
function initTimeUpdates() {
    // Update greeting every minute
    setInterval(updateGreeting, 60000);
    
    // Update today's date
    const todaySpan = document.getElementById('today-date');
    if (todaySpan) {
        const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
        todaySpan.textContent = new Date().toLocaleDateString('en-US', options);
    }
}

// Initialize all dashboard features
document.addEventListener('DOMContentLoaded', () => {
    updateGreeting();
    initLottie();
    initCountUp();
    initFAB();
    initProgressBars();
    initCardEffects();
    initTimeUpdates();
});