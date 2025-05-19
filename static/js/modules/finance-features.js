// Finance features module - Handles bills and savings goals
export function initializeFinanceFeatures() {
    initializeMarkPaidButtons();
    initializeBillForm();
    
    // Handle savings goals
    initializeSavingsGoalForm();
    initializeAddSavingsButtons();
    initializeAdjustGoalButtons();
    
    // Setup FAB actions
    initializeFAB();
});

function initializeMarkPaidButtons() {
    const markPaidButtons = document.querySelectorAll('.mark-paid-btn');
    markPaidButtons.forEach(button => {
        button.addEventListener('click', async function() {
            const billId = this.dataset.billId;
            try {
                const response = await fetch(`/users/bill/${billId}/mark-paid/`, {
                    method: 'POST',
                    headers: {
                        'X-CSRFToken': document.querySelector('[name=csrfmiddlewaretoken]').value,
                    },
                });
                
                if (response.ok) {
                    // Remove or update the bill item from the list
                    const billItem = this.closest('.bill-item');
                    billItem.classList.add('fade-out');
                    setTimeout(() => billItem.remove(), 300);
                    
                    showToast('success', 'Bill marked as paid successfully!');
                    updateFinancialHealth();
                }
            } catch (error) {
                showToast('error', 'Failed to mark bill as paid. Please try again.');
            }
        });
    });
}

function initializeBillForm() {
    const addBillForm = document.getElementById('addBillForm');
    if (addBillForm) {
        addBillForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            
            try {
                const response = await fetch('/users/bill/add/', {
                    method: 'POST',
                    body: formData,
                });
                
                if (response.ok) {
                    const modal = document.getElementById('addBillModal');
                    const bsModal = bootstrap.Modal.getInstance(modal);
                    bsModal.hide();
                    
                    showToast('success', 'New bill added successfully!');
                    location.reload();
                }
            } catch (error) {
                showToast('error', 'Failed to add bill. Please try again.');
            }
        });
    }
}

function initializeSavingsGoalForm() {
    const addGoalForm = document.getElementById('savingsGoalForm');
    if (addGoalForm) {
        addGoalForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            
            try {
                const response = await fetch('/users/savings/goal/add/', {
                    method: 'POST',
                    body: formData,
                });
                
                if (response.ok) {
                    const modal = document.getElementById('addSavingsGoalModal');
                    const bsModal = bootstrap.Modal.getInstance(modal);
                    bsModal.hide();
                    
                    showToast('success', 'New savings goal created successfully!');
                    location.reload();
                }
            } catch (error) {
                showToast('error', 'Failed to create savings goal. Please try again.');
            }
        });
    }
}

function initializeAddSavingsButtons() {
    const addSavingsButtons = document.querySelectorAll('.add-savings-btn');
    addSavingsButtons.forEach(button => {
        button.addEventListener('click', async function() {
            const goalId = this.dataset.goalId;
            const amount = prompt('Enter amount to add to savings:');
            
            if (amount && !isNaN(amount)) {
                const formData = new FormData();
                formData.append('amount', amount);
                const csrfToken = document.querySelector('[name=csrfmiddlewaretoken]').value;
                
                try {
                    const response = await fetch(`/users/savings/goal/${goalId}/update/`, {
                        method: 'POST',
                        headers: {
                            'X-CSRFToken': csrfToken
                        },
                        body: formData,
                    });
                    
                    if (response.ok) {
                        showToast('success', `Added UGX ${Number(amount).toLocaleString()} to your savings!`);
                        location.reload();
                    } else {
                        showToast('error', 'Failed to update savings. Please try again.');
                    }
                } catch (error) {
                    showToast('error', 'Failed to update savings. Please try again.');
                }
            }
        });
    });
}

function initializeAdjustGoalButtons() {
    const adjustGoalButtons = document.querySelectorAll('.adjust-goal-btn');
    adjustGoalButtons.forEach(button => {
        button.addEventListener('click', async function() {
            const goalId = this.dataset.goalId;
            const modal = document.getElementById('addSavingsGoalModal');
            const form = modal.querySelector('form');
            
            try {
                const response = await fetch(`/users/savings/goal/${goalId}/`, {
                    method: 'GET',
                    headers: {
                        'X-CSRFToken': document.querySelector('[name=csrfmiddlewaretoken]').value
                    }
                });
                
                if (response.ok) {
                    const goal = await response.json();
                    modal.querySelector('.modal-title').textContent = 'Edit Savings Goal';
                    
                    // Populate form fields
                    form.elements['name'].value = goal.name;
                    form.elements['target_amount'].value = goal.target_amount;
                    form.elements['current_savings'].value = goal.current_savings;
                    form.elements['target_date'].value = goal.target_date;
                    
                    form.action = `/users/savings/goal/${goalId}/update/`;
                    
                    const bsModal = new bootstrap.Modal(modal);
                    bsModal.show();
                }
            } catch (error) {
                showToast('error', 'Failed to load goal details. Please try again.');
            }
        });
    });
}

function initializeFAB() {
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

export function showToast(type, message) {
    const toastContainer = document.getElementById('toastContainer') || createToastContainer();
    
    const toast = document.createElement('div');
    toast.className = `toast align-items-center text-white bg-${type === 'error' ? 'danger' : type}`;
    toast.setAttribute('role', 'alert');
    toast.setAttribute('aria-live', 'assertive');
    toast.setAttribute('aria-atomic', 'true');
    
    toast.innerHTML = `
        <div class="d-flex">
            <div class="toast-body">
                ${message}
            </div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
    `;
    
    toastContainer.appendChild(toast);
    const bsToast = new bootstrap.Toast(toast);
    bsToast.show();
    
    toast.addEventListener('hidden.bs.toast', function() {
        toast.remove();
    });
}

function createToastContainer() {
    const container = document.createElement('div');
    container.id = 'toastContainer';
    container.style.position = 'fixed';
    container.style.top = '20px';
    container.style.right = '20px';
    container.style.zIndex = '1050';
    document.body.appendChild(container);
    return container;
}

function updateFinancialHealth() {
    // Implementation for updating financial health score
    // This would typically involve an API call and UI updates
}
