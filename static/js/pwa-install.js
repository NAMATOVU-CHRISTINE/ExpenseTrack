// PWA Installation functionality
let deferredPrompt;
let installButton;

// Check if PWA is already installed
function isPWAInstalled() {
  return window.matchMedia('(display-mode: standalone)').matches || 
         window.navigator.standalone === true;
}

// Show install button if PWA can be installed
window.addEventListener('beforeinstallprompt', (e) => {
  console.log('PWA install prompt available');
  e.preventDefault();
  deferredPrompt = e;
  
  // Show install button
  showInstallButton();
});

// Create and show install button
function showInstallButton() {
  if (isPWAInstalled()) {
    return;
  }

  // Create install button if it doesn't exist
  if (!installButton) {
    installButton = document.createElement('button');
    installButton.innerHTML = '<i class="fas fa-download"></i> Install App';
    installButton.className = 'btn btn-primary install-btn';
    installButton.style.cssText = `
      position: fixed;
      bottom: 20px;
      right: 20px;
      z-index: 1000;
      border-radius: 25px;
      padding: 10px 20px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
      animation: pulse 2s infinite;
    `;
    
    installButton.addEventListener('click', installPWA);
    document.body.appendChild(installButton);
  }
}

// Install PWA
async function installPWA() {
  if (!deferredPrompt) {
    return;
  }

  // Show the install prompt
  deferredPrompt.prompt();
  
  // Wait for the user to respond to the prompt
  const { outcome } = await deferredPrompt.userChoice;
  
  if (outcome === 'accepted') {
    console.log('User accepted the install prompt');
    hideInstallButton();
  } else {
    console.log('User dismissed the install prompt');
  }
  
  deferredPrompt = null;
}

// Hide install button
function hideInstallButton() {
  if (installButton) {
    installButton.remove();
    installButton = null;
  }
}

// Register service worker
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/static/js/sw.js')
      .then(registration => {
        console.log('SW registered: ', registration);
      })
      .catch(registrationError => {
        console.log('SW registration failed: ', registrationError);
      });
  });
}

// Hide install button if already installed
window.addEventListener('appinstalled', () => {
  console.log('PWA was installed');
  hideInstallButton();
});

// Check if already installed on load
document.addEventListener('DOMContentLoaded', () => {
  if (isPWAInstalled()) {
    console.log('PWA is already installed');
  }
});