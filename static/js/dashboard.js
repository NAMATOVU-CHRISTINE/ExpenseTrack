// Main dashboard initialization
import { initializeCharts } from './modules/charts.js';
import {
    toggleDarkMode,
    initializeAnimations,
    initializeLottie,
    initializeCardEffects,
    initializeProgressBars,
    initializeTimeUpdates,
    updateGreeting
} from './modules/utils.js';
import { initDynamicProgress } from './modules/progress.js';

document.addEventListener('DOMContentLoaded', function() {
    // Initialize all dashboard components
    if (window.chartData) {
        initializeCharts(window.chartData);
    }
    
    initializeAnimations();
    initializeLottie();
    initializeCardEffects();
    initializeProgressBars();
    initializeTimeUpdates();
    updateGreeting();
    initDynamicProgress();
    
    // Check for saved dark mode preference
    if (localStorage.getItem('darkMode') === 'true') {
        document.body.classList.add('dark-mode');
        window.updateChartsColorScheme(true);
    }
    
    // Add dark mode toggle listener
    const darkModeToggle = document.getElementById('darkModeToggle');
    if (darkModeToggle) {
        darkModeToggle.addEventListener('click', toggleDarkMode);
    }
    
    // Setup budget progress bar hover effects
    document.querySelectorAll('.budget-progress-item').forEach(item => {
        item.addEventListener('mouseenter', function() {
            this.querySelector('.progress-bar').style.transform = 'scaleY(1.2)';
        });
        
        item.addEventListener('mouseleave', function() {
            this.querySelector('.progress-bar').style.transform = 'scaleY(1)';
        });
    });
});