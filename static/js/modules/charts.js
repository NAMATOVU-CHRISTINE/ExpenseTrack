// Chart initialization and configuration
export function initializeCharts(chartData) {
    initializeCategoryChart(chartData);
    initializeTrendChart(chartData);
    initializeBudgetChart(chartData);
}

function initializeCategoryChart(chartData) {
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
}

function initializeTrendChart(chartData) {
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
}

function initializeBudgetChart(chartData) {
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

// Update charts for dark mode
export function updateChartsColorScheme(isDarkMode) {
    Chart.instances.forEach(chart => {
        chart.options.plugins.legend.labels.color = isDarkMode ? '#fff' : '#666';
        chart.options.scales.y.grid.color = isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)';
        chart.options.scales.x.grid.color = isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)';
        chart.update();
    });
}
