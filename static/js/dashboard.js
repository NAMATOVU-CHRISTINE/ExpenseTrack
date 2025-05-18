// Dashboard JavaScript

document.addEventListener('DOMContentLoaded', function() {
    // Initialize all charts
    initializeDashboardCharts();
    
    // Initialize animations
    initializeAnimations();
    
    // Setup event listeners
    setupEventListeners();
});

function initializeDashboardCharts() {
    // Spending by Category Donut Chart
    const categoryChartCtx = document.getElementById('categoryDonutChart');
    if (categoryChartCtx) {
        new Chart(categoryChartCtx, {
            type: 'doughnut',
            data: {
                labels: chartData.categories,
                datasets: [{
                    data: chartData.amounts,
                    backgroundColor: chartData.colors,
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const value = context.raw;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((value / total) * 100).toFixed(1);
                                return `${context.label}: UGX ${value.toLocaleString()} (${percentage}%)`;
                            }
                        }
                    }
                },
                cutout: '70%'
            }
        });
    }

    // Monthly Trend Line Chart
    const trendChartCtx = document.getElementById('trendChart');
    if (trendChartCtx) {
        new Chart(trendChartCtx, {
            type: 'line',
            data: {
                labels: chartData.months,
                datasets: [{
                    label: 'Monthly Spending',
                    data: chartData.spending_trend,
                    borderColor: '#667eea',
                    backgroundColor: 'rgba(102, 126, 234, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return `UGX ${context.raw.toLocaleString()}`;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return 'UGX ' + value.toLocaleString();
                            }
                        }
                    }
                }
            }
        });
    }

    // Budget vs Actual Bar Chart
    const budgetChartCtx = document.getElementById('budgetComparisonChart');
    if (budgetChartCtx) {
        new Chart(budgetChartCtx, {
            type: 'bar',
            data: {
                labels: chartData.categories,
                datasets: [
                    {
                        label: 'Budget',
                        data: chartData.budget_amounts,
                        backgroundColor: 'rgba(102, 126, 234, 0.6)',
                        borderRadius: 4
                    },
                    {
                        label: 'Actual',
                        data: chartData.amounts,
                        backgroundColor: 'rgba(237, 137, 54, 0.6)',
                        borderRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return `${context.dataset.label}: UGX ${context.raw.toLocaleString()}`;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return 'UGX ' + value.toLocaleString();
                            }
                        }
                    }
                }
            }
        });
    }
}

function initializeAnimations() {
    // Animate numbers in summary cards
    document.querySelectorAll('.animate-number').forEach(element => {
        const finalValue = parseFloat(element.getAttribute('data-value'));
        animateNumber(element, finalValue);
    });
}

function animateNumber(element, finalValue) {
    const duration = 1500;
    const steps = 60;
    const stepValue = finalValue / steps;
    let currentValue = 0;
    let currentStep = 0;

    const interval = setInterval(() => {
        currentStep++;
        currentValue += stepValue;
        
        if (currentStep === steps) {
            currentValue = finalValue;
            clearInterval(interval);
        }
        
        element.textContent = formatCurrency(currentValue);
    }, duration / steps);
}

function formatCurrency(value) {
    return 'UGX ' + value.toLocaleString('en-US', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    });
}

function setupEventListeners() {
    // FAB menu toggle
    const fabButton = document.querySelector('.fab-main-btn');
    if (fabButton) {
        fabButton.addEventListener('click', function() {
            const fabContainer = this.closest('.fab-container');
            fabContainer.classList.toggle('open');
        });
    }

    // Hide FAB menu when clicking outside
    document.addEventListener('click', function(event) {
        const fabContainer = document.querySelector('.fab-container');
        if (fabContainer && !fabContainer.contains(event.target)) {
            fabContainer.classList.remove('open');
        }
    });

    // Budget progress bar hover effects
    document.querySelectorAll('.budget-progress-item').forEach(item => {
        item.addEventListener('mouseenter', function() {
            this.querySelector('.progress-bar').style.transform = 'scaleY(1.2)';
        });
        
        item.addEventListener('mouseleave', function() {
            this.querySelector('.progress-bar').style.transform = 'scaleY(1)';
        });
    });
}

// Toast notification system
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast-notification toast-${type}`;
    toast.innerHTML = `
        <div class="toast-content">
            <i class="fas ${type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle'}"></i>
            <span>${message}</span>
        </div>
    `;
    document.body.appendChild(toast);
    
    // Animate in
    setTimeout(() => toast.classList.add('show'), 10);
    
    // Animate out and remove
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Handle dark mode toggle
function toggleDarkMode() {
    document.body.classList.toggle('dark-mode');
    const isDarkMode = document.body.classList.contains('dark-mode');
    localStorage.setItem('darkMode', isDarkMode);
    
    // Update charts color scheme
    updateChartsColorScheme(isDarkMode);
}

// Update charts for dark mode
function updateChartsColorScheme(isDarkMode) {
    Chart.instances.forEach(chart => {
        chart.options.plugins.legend.labels.color = isDarkMode ? '#fff' : '#666';
        chart.options.scales.y.grid.color = isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)';
        chart.options.scales.x.grid.color = isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)';
        chart.update();
    });
}

// Check for saved dark mode preference
if (localStorage.getItem('darkMode') === 'true') {
    document.body.classList.add('dark-mode');
    updateChartsColorScheme(true);
}