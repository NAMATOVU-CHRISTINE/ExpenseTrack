// Handle dark mode and sidebar functionality
import { updateChartsColorScheme } from './charts.js';

document.addEventListener('DOMContentLoaded', function() {
    initializeDarkMode();
    initializeSidebar();
});

function initializeDarkMode() {
    // Initialize dark mode from localStorage
    const isDarkMode = localStorage.getItem('darkMode') === 'true';
    if (isDarkMode) {
        document.body.classList.add('dark-mode');
        updateChartsColorScheme(true);
    }
    
    // Add dark mode toggle listener
    const darkModeToggle = document.getElementById('darkModeToggle');
    if (darkModeToggle) {
        darkModeToggle.addEventListener('click', function() {
            document.body.classList.toggle('dark-mode');
            const newDarkMode = document.body.classList.contains('dark-mode');
            localStorage.setItem('darkMode', newDarkMode);
            updateChartsColorScheme(newDarkMode);
        });
    }
}

function initializeSidebar() {
    const sidebar = document.getElementById('sidebar');
    const sidebarToggle = document.getElementById('sidebarToggle');
    
    if (sidebarToggle && sidebar) {
        // Handle sidebar toggle click
        sidebarToggle.addEventListener('click', function() {
            sidebar.classList.toggle('show');
        });
        
        // Close sidebar when clicking outside on mobile
        document.addEventListener('click', function(e) {
            if (window.innerWidth <= 768) {
                if (!sidebar.contains(e.target) && !sidebarToggle.contains(e.target)) {
                    sidebar.classList.remove('show');
                }
            }
        });
    }
}

function updateChartsColorScheme(isDarkMode) {
    // Update Chart.js charts if they exist
    if (window.Chart && Chart.instances) {
        Chart.instances.forEach(chart => {
            chart.options.plugins.legend.labels.color = isDarkMode ? '#fff' : '#666';
            chart.options.scales.y.grid.color = isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)';
            chart.options.scales.x.grid.color = isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)';
            chart.update();
        });
    }
}
