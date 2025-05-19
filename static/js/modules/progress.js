// Initialize dynamic progress bars
export function initDynamicProgress() {
    const dynamicBars = document.querySelectorAll('.progress-dynamic');
    dynamicBars.forEach(bar => {
        const width = bar.dataset.width || '0';
        bar.style.setProperty('--dynamic-width', `${width}%`);
    });
}
