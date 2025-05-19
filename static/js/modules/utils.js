import { updateChartsColorScheme } from './charts.js';

export function toggleDarkMode() {
    document.body.classList.toggle('dark-mode');
    const isDarkMode = document.body.classList.contains('dark-mode');
    localStorage.setItem('darkMode', isDarkMode);
    
    // Update charts color scheme
    updateChartsColorScheme(isDarkMode);
}

// Format currency values
export function formatCurrency(value) {
    return `UGX ${value.toLocaleString()}`;
}

// Animate number transitions
export function animateValue(element, start, end, duration = 1000) {
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

// Initialize number animations
export function initializeAnimations() {
    document.querySelectorAll('.animate-number').forEach(element => {
        const finalValue = parseFloat(element.getAttribute('data-value'));
        animateValue(element, 0, finalValue);
    });
}

// Load Lottie animations
export function loadLottie(id, url) {
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

// Initialize Lottie animations
export function initializeLottie() {
    const animations = {
        'lottie-quote': 'https://assets3.lottiefiles.com/packages/lf20_xyadoh9h.json',
        'lottie-empty-transactions': 'https://assets8.lottiefiles.com/packages/lf20_ysrn2iwp.json',
        'lottie-empty-categories': 'https://assets9.lottiefiles.com/packages/lf20_yzoqyyqf.json'
    };
    
    Object.entries(animations).forEach(([id, url]) => {
        if (document.getElementById(id)) {
            loadLottie(id, url);
        }
    });
}

// Card hover effect initialization
export function initializeCardEffects() {
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

// Progress bar initialization
export function initializeProgressBars() {
    const bars = document.querySelectorAll('.progress-bar');
    bars.forEach(bar => {
        const width = bar.style.width;
        bar.style.width = '0';
        setTimeout(() => {
            bar.style.width = width;
        }, 100);
    });
}

// Initialize time-based features
export function initializeTimeUpdates() {
    // Update greeting every minute
    setInterval(updateGreeting, 60000);
    
    // Update today's date
    const todaySpan = document.getElementById('today-date');
    if (todaySpan) {
        const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
        todaySpan.textContent = new Date().toLocaleDateString('en-US', options);
    }
}

// Generate greeting based on time of day
export function updateGreeting() {
    const hour = new Date().getHours();
    let greeting = 'Good ';
    if (hour < 12) greeting += 'Morning';
    else if (hour < 17) greeting += 'Afternoon';
    else greeting += 'Evening';
    
    const greetingEl = document.getElementById('greeting');
    if (greetingEl) {
        greetingEl.textContent = greeting;
    }
}
