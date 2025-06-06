// Bill Management
document.addEventListener('DOMContentLoaded', function() {
    // Handle mark as paid functionality
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
                    
                    // Show success message
                    showToast('success', 'Bill marked as paid successfully!');
                    
                    // Refresh financial health score
                    updateFinancialHealth();
                }
            } catch (error) {
                showToast('error', 'Failed to mark bill as paid. Please try again.');
            }
        });
    });

    // Handle adding new bill
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
                    // Close modal
                    const modal = document.getElementById('addBillModal');
                    const bsModal = bootstrap.Modal.getInstance(modal);
                    bsModal.hide();
                    
                    // Show success message
                    showToast('success', 'New bill added successfully!');
                    
                    // Refresh the bills list
                    location.reload();
                }
            } catch (error) {
                showToast('error', 'Failed to add bill. Please try again.');
            }
        });
    }
});

// Savings Goals Management
document.addEventListener('DOMContentLoaded', function() {
    // Handle adding new savings goal
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
                    // Close modal
                    const modal = document.getElementById('addSavingsGoalModal');
                    const bsModal = bootstrap.Modal.getInstance(modal);
                    bsModal.hide();
                    
                    // Show success message
                    showToast('success', 'New savings goal created successfully!');
                    
                    // Refresh the page to show new goal
                    location.reload();
                }
            } catch (error) {
                showToast('error', 'Failed to create savings goal. Please try again.');
            }
        });
    }    // Handle updating savings amount
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

    // Handle adjusting savings goal
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
                    // Update modal title
                    modal.querySelector('.modal-title').textContent = 'Edit Savings Goal';
                    
                    // Populate form fields
                    form.elements['name'].value = goal.name;
                    form.elements['target_amount'].value = goal.target_amount;
                    form.elements['current_savings'].value = goal.current_savings;
                    form.elements['target_date'].value = goal.target_date;
                    
                    // Update form action URL
                    form.action = `/users/savings/goal/${goalId}/update/`;
                    
                    // Show modal
                    const bsModal = new bootstrap.Modal(modal);
                    bsModal.show();
                }
            } catch (error) {
                showToast('error', 'Failed to load goal details. Please try again.');
            }
        });
    });
    
    // Reset add goal modal title when creating new goal
    const addGoalBtn = document.querySelector('[data-bs-target="#addSavingsGoalModal"]');
    if (addGoalBtn) {
        addGoalBtn.addEventListener('click', function() {
            const modal = document.getElementById('addSavingsGoalModal');
            modal.querySelector('.modal-title').textContent = 'Create Savings Goal';
            modal.querySelector('form').reset();
            modal.querySelector('form').action = "{% url 'add_savings_goal' %}";
        });
    }

    // Toast notification function
    window.showToast = function(type, message) {
        const toastContainer = document.getElementById('toastContainer');
        if (!toastContainer) {
            const container = document.createElement('div');
            container.id = 'toastContainer';
            container.style.position = 'fixed';
            container.style.top = '20px';
            container.style.right = '20px';
            container.style.zIndex = '1050';
            document.body.appendChild(container);
        }
        
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
        
        // Remove toast after it's hidden
        toast.addEventListener('hidden.bs.toast', function() {
            toast.remove();
        });
    };
});