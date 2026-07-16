/**
 * app.js - Enterprise Employee Management System
 * Client-side JavaScript with jQuery, AJAX, SweetAlert2.
 *
 * Contains:
 * - Page Loader
 * - Sidebar Toggle (responsive)
 * - AJAX Calls (Search, Delete, Status Toggle, Cascading Dropdown)
 * - Form Validation
 * - SweetAlert2 Confirmations
 * - Datepicker Init
 * - Photo Preview
 * - Pagination Helpers
 * - Export Utilities
 * - Activity Time Formatting
 */

// ==========================================
// DOCUMENT READY
// ==========================================
$(document).ready(function () {

    // Initialize tooltips (Bootstrap 5)
    var tooltipEls = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipEls.forEach(function (el) { new bootstrap.Tooltip(el); });

    // Initialize popovers
    var popoverEls = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
    popoverEls.forEach(function (el) { new bootstrap.Popover(el); });

    // Sidebar toggle for mobile
    initSidebar();

    // Auto-dismiss alerts after 5 seconds
    setTimeout(function () {
        $('.alert-dismissible').fadeOut(400);
    }, 5000);

    // Format activity times
    formatActivityTimes();

    // Set active sidebar link
    setActiveSidebarLink();

    // Initialize Flatpickr datepickers (if any)
    initDatepickers();
});

// ==========================================
// PAGE LOADER
// Show/hide a full-screen loading overlay
// ==========================================
var Loader = {
    show: function () {
        $('#pageLoader').fadeIn(200);
    },
    hide: function () {
        $('#pageLoader').fadeOut(200);
    }
};

// ==========================================
// SIDEBAR TOGGLE (Responsive)
// ==========================================
function initSidebar() {
    var $sidebar  = $('.sidebar');
    var $overlay  = $('.sidebar-overlay');
    var $toggle   = $('.sidebar-toggle');

    // Toggle sidebar on mobile
    $toggle.on('click', function () {
        $sidebar.toggleClass('open');
        $overlay.toggleClass('visible');
    });

    // Close sidebar when overlay clicked
    $overlay.on('click', function () {
        $sidebar.removeClass('open');
        $overlay.removeClass('visible');
    });

    // Desktop collapse (optional)
    $(window).on('resize', function () {
        if ($(window).width() > 992) {
            $sidebar.removeClass('open');
            $overlay.removeClass('visible');
        }
    });
}

// ==========================================
// SET ACTIVE SIDEBAR LINK
// Highlights the current page's nav link
// ==========================================
function setActiveSidebarLink() {
    var currentPage = window.location.pathname.toLowerCase();

    $('.sidebar-nav .nav-link').each(function () {
        var href = $(this).attr('href');
        if (href) {
            var hrefLower = href.toLowerCase();
            // Match if current page ends with the link's path
            if (currentPage.indexOf(hrefLower.replace('~/', '')) !== -1
                && hrefLower !== '~/default.aspx') {
                $(this).addClass('active');
            }
        }
    });
}

// ==========================================
// SWEETALERT2 DELETE CONFIRMATION
// Call this from a delete button's onclick
// Usage: confirmDelete('DeleteEmployee.aspx?id=5', 'Delete this employee?')
// ==========================================
function confirmDelete(url, message, callback) {
    Swal.fire({
        title: 'Are you sure?',
        text: message || 'This action cannot be undone!',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#ef4444',
        cancelButtonColor: '#64748b',
        confirmButtonText: '<i class="bi bi-trash3-fill me-1"></i> Yes, Delete!',
        cancelButtonText: 'Cancel',
        reverseButtons: true,
        customClass: { popup: 'swal-custom-popup' }
    }).then(function (result) {
        if (result.isConfirmed) {
            if (typeof callback === 'function') {
                // If a JS callback is provided, call it
                Loader.show();
                callback();
            } else if (url) {
                // Otherwise navigate to the delete URL
                Loader.show();
                window.location.href = url;
            }
        }
    });
}

// ==========================================
// SWEETALERT2 STATUS TOGGLE CONFIRMATION
// ==========================================
function confirmStatusToggle(employeeId, currentStatus, callbackFn) {
    var newStatus   = !currentStatus;
    var actionText  = newStatus ? 'Activate' : 'Deactivate';
    var iconType    = newStatus ? 'question' : 'warning';
    var btnColor    = newStatus ? '#10b981' : '#f59e0b';

    Swal.fire({
        title: actionText + ' Employee?',
        text: 'Are you sure you want to ' + actionText.toLowerCase() + ' this employee?',
        icon: iconType,
        showCancelButton: true,
        confirmButtonColor: btnColor,
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Yes, ' + actionText + '!',
        cancelButtonText: 'Cancel'
    }).then(function (result) {
        if (result.isConfirmed && typeof callbackFn === 'function') {
            Loader.show();
            callbackFn(employeeId, newStatus);
        }
    });
}

// ==========================================
// AJAX: LIVE SEARCH (Debounced)
// Fires AJAX after user stops typing (300ms)
// ==========================================
var searchTimer;

function initLiveSearch(inputId, resultContainerId, ajaxUrl) {
    $('#' + inputId).on('input', function () {
        clearTimeout(searchTimer);
        var term = $(this).val().trim();

        searchTimer = setTimeout(function () {
            if (term.length === 0 || term.length >= 2) {
                performSearch(term, resultContainerId, ajaxUrl);
            }
        }, 300);
    });
}

function performSearch(term, containerId, url) {
    Loader.show();
    $.ajax({
        url: url,
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        data: JSON.stringify({ searchTerm: term }),
        success: function (response) {
            // Response is expected as HTML table rows
            if (response && response.d) {
                $('#' + containerId).html(response.d);
            }
        },
        error: function (xhr) {
            showToast('error', 'Search failed. Please try again.');
            console.error('Search AJAX error:', xhr.responseText);
        },
        complete: function () {
            Loader.hide();
        }
    });
}

// ==========================================
// AJAX: CASCADING DROPDOWN
// Load Designations when Department changes
// ==========================================
function loadDesignations(departmentId, designationDropdownId, selectedValue) {
    var $dropdown = $('#' + designationDropdownId);
    $dropdown.prop('disabled', true).html('<option value="">Loading...</option>');

    $.ajax({
        url: '/Handlers/GetDesignations.ashx',
        type: 'GET',
        data: { departmentId: departmentId },
        dataType: 'json',
        success: function (data) {
            $dropdown.html('<option value="">-- Select Designation --</option>');
            if (data && data.length > 0) {
                $.each(data, function (i, item) {
                    var selected = (selectedValue && item.DesignationId == selectedValue) ? 'selected' : '';
                    $dropdown.append(
                        '<option value="' + item.DesignationId + '" ' + selected + '>'
                        + item.DesignationName + '</option>'
                    );
                });
                $dropdown.prop('disabled', false);
            } else {
                $dropdown.html('<option value="">-- No Designations Found --</option>');
            }
        },
        error: function () {
            $dropdown.html('<option value="">-- Error Loading --</option>');
            showToast('error', 'Failed to load designations.');
        }
    });
}

// ==========================================
// AJAX: DUPLICATE EMAIL CHECK
// Called onblur of the Email field
// ==========================================
function checkDuplicateEmail(emailInputId, employeeId) {
    var email = $('#' + emailInputId).val().trim();
    if (!email || !isValidEmail(email)) return;

    $.ajax({
        url: '/Handlers/CheckDuplicate.ashx',
        type: 'GET',
        data: { type: 'email', value: email, id: employeeId || 0 },
        dataType: 'json',
        success: function (data) {
            if (data.isDuplicate) {
                $('#' + emailInputId)
                    .addClass('is-invalid')
                    .removeClass('is-valid');
                showFieldError(emailInputId, 'This email is already registered.');
            } else {
                $('#' + emailInputId)
                    .addClass('is-valid')
                    .removeClass('is-invalid');
                clearFieldError(emailInputId);
            }
        }
    });
}

// ==========================================
// AJAX: DUPLICATE MOBILE CHECK
// ==========================================
function checkDuplicateMobile(mobileInputId, employeeId) {
    var mobile = $('#' + mobileInputId).val().trim();
    if (!mobile || mobile.length < 10) return;

    $.ajax({
        url: '/Handlers/CheckDuplicate.ashx',
        type: 'GET',
        data: { type: 'mobile', value: mobile, id: employeeId || 0 },
        dataType: 'json',
        success: function (data) {
            if (data.isDuplicate) {
                $('#' + mobileInputId)
                    .addClass('is-invalid')
                    .removeClass('is-valid');
                showFieldError(mobileInputId, 'This mobile is already registered.');
            } else {
                $('#' + mobileInputId)
                    .addClass('is-valid')
                    .removeClass('is-invalid');
                clearFieldError(mobileInputId);
            }
        }
    });
}

// ==========================================
// FORM VALIDATION
// Client-side validation before form submit
// Returns false to prevent submission if invalid
// ==========================================
function validateEmployeeForm() {
    var isValid = true;
    var errors  = [];

    // First Name
    var firstName = $('#txtFirstName').val().trim();
    if (!firstName) {
        setFieldError('txtFirstName', 'First name is required.');
        isValid = false;
    } else {
        clearFieldError('txtFirstName');
    }

    // Last Name
    var lastName = $('#txtLastName').val().trim();
    if (!lastName) {
        setFieldError('txtLastName', 'Last name is required.');
        isValid = false;
    } else {
        clearFieldError('txtLastName');
    }

    // Email
    var email = $('#txtEmail').val().trim();
    if (!email) {
        setFieldError('txtEmail', 'Email is required.');
        isValid = false;
    } else if (!isValidEmail(email)) {
        setFieldError('txtEmail', 'Please enter a valid email address.');
        isValid = false;
    } else {
        clearFieldError('txtEmail');
    }

    // Mobile
    var mobile = $('#txtMobile').val().trim();
    if (!mobile) {
        setFieldError('txtMobile', 'Mobile number is required.');
        isValid = false;
    } else if (!isValidPhone(mobile)) {
        setFieldError('txtMobile', 'Enter a valid mobile (10-15 digits).');
        isValid = false;
    } else {
        clearFieldError('txtMobile');
    }

    // Department
    if (!$('#ddlDepartment').val()) {
        setFieldError('ddlDepartment', 'Please select a department.');
        isValid = false;
    } else {
        clearFieldError('ddlDepartment');
    }

    // Designation
    if (!$('#ddlDesignation').val()) {
        setFieldError('ddlDesignation', 'Please select a designation.');
        isValid = false;
    } else {
        clearFieldError('ddlDesignation');
    }

    // Salary
    var salary = parseFloat($('#txtSalary').val());
    if (isNaN(salary) || salary < 0) {
        setFieldError('txtSalary', 'Enter a valid salary (must be >= 0).');
        isValid = false;
    } else {
        clearFieldError('txtSalary');
    }

    // Joining Date
    if (!$('#txtJoiningDate').val()) {
        setFieldError('txtJoiningDate', 'Joining date is required.');
        isValid = false;
    } else {
        clearFieldError('txtJoiningDate');
    }

    if (!isValid) {
        Swal.fire({
            icon: 'warning',
            title: 'Validation Error',
            text: 'Please fix the highlighted errors before submitting.',
            confirmButtonColor: '#4f46e5'
        });
    }

    return isValid;
}

function validateDepartmentForm() {
    var isValid = true;
    var name    = $('#txtDepartmentName').val().trim();

    if (!name) {
        setFieldError('txtDepartmentName', 'Department name is required.');
        isValid = false;
    } else if (name.length > 100) {
        setFieldError('txtDepartmentName', 'Department name cannot exceed 100 characters.');
        isValid = false;
    } else {
        clearFieldError('txtDepartmentName');
    }

    return isValid;
}

function validateDesignationForm() {
    var isValid = true;

    var name = $('#txtDesignationName').val().trim();
    if (!name) {
        setFieldError('txtDesignationName', 'Designation name is required.');
        isValid = false;
    } else {
        clearFieldError('txtDesignationName');
    }

    var dept = $('#ddlDepartmentDesig').val();
    if (!dept) {
        setFieldError('ddlDepartmentDesig', 'Please select a department.');
        isValid = false;
    } else {
        clearFieldError('ddlDepartmentDesig');
    }

    return isValid;
}

// ==========================================
// FIELD ERROR HELPERS
// ==========================================
function setFieldError(inputId, message) {
    var $input = $('#' + inputId);
    $input.addClass('is-invalid').removeClass('is-valid');

    var $feedback = $input.siblings('.invalid-feedback');
    if ($feedback.length === 0) {
        $input.after('<div class="invalid-feedback"><i class="bi bi-exclamation-circle"></i> ' + message + '</div>');
    } else {
        $feedback.html('<i class="bi bi-exclamation-circle"></i> ' + message);
    }
}

function clearFieldError(inputId) {
    var $input = $('#' + inputId);
    $input.removeClass('is-invalid');
    $input.siblings('.invalid-feedback').remove();
}

function showFieldError(inputId, message) {
    setFieldError(inputId, message);
}

// ==========================================
// VALIDATION HELPERS
// ==========================================
function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function isValidPhone(phone) {
    return /^\+?[0-9]{10,15}$/.test(phone);
}

// ==========================================
// TOAST NOTIFICATION (SweetAlert2 Toast)
// ==========================================
function showToast(type, message) {
    var Toast = Swal.mixin({
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 3500,
        timerProgressBar: true,
        didOpen: function (toast) {
            toast.addEventListener('mouseenter', Swal.stopTimer);
            toast.addEventListener('mouseleave', Swal.resumeTimer);
        }
    });

    Toast.fire({
        icon: type,     // 'success', 'error', 'warning', 'info'
        title: message
    });
}

// ==========================================
// PHOTO PREVIEW
// Shows a preview of the selected image
// before upload (on the employee form)
// ==========================================
function previewPhoto(inputId, previewId) {
    var file = document.getElementById(inputId).files[0];
    if (!file) return;

    // Validate file type
    var allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (!allowedTypes.includes(file.type)) {
        showToast('error', 'Please select a valid image (JPG, PNG, GIF, WEBP).');
        return;
    }

    // Validate size (max 2MB)
    if (file.size > 2 * 1024 * 1024) {
        showToast('error', 'Image size must be less than 2MB.');
        document.getElementById(inputId).value = '';
        return;
    }

    var reader = new FileReader();
    reader.onload = function (e) {
        $('#' + previewId).attr('src', e.target.result);
    };
    reader.readAsDataURL(file);
}

// ==========================================
// DATEPICKER INITIALIZATION (Flatpickr)
// ==========================================
function initDatepickers() {
    if (typeof flatpickr !== 'undefined') {
        // Date of Birth: max today, min 100 years ago
        flatpickr('.datepicker-dob', {
            dateFormat: 'Y-m-d',
            maxDate: 'today',
            allowInput: true,
            disableMobile: true
        });

        // Joining Date: max today
        flatpickr('.datepicker-joining', {
            dateFormat: 'Y-m-d',
            maxDate: 'today',
            allowInput: true,
            disableMobile: true
        });

        // Date range pickers (for report filters)
        flatpickr('.datepicker-range', {
            dateFormat: 'Y-m-d',
            allowInput: true,
            disableMobile: true
        });
    }
}

// ==========================================
// PAGINATION HELPER
// Calls a page-specific function to navigate
// ==========================================
function goToPage(pageNumber, containerId) {
    if (typeof window['loadPage'] === 'function') {
        window['loadPage'](pageNumber);
    } else {
        // If using server-side postback, update hidden field and submit
        var $hiddenPage = $('#hfCurrentPage');
        if ($hiddenPage.length) {
            $hiddenPage.val(pageNumber);
            // Trigger ASP.NET LinkButton or update panel
            var $lbPage = $('#lbGoToPage');
            if ($lbPage.length) { $lbPage.trigger('click'); }
        }
    }
}

// ==========================================
// SORT TABLE COLUMN
// Updates hidden fields for sort and postback
// ==========================================
function sortByColumn(column) {
    var $hfSort      = $('#hfSortColumn');
    var $hfOrder     = $('#hfSortOrder');
    var currentCol   = $hfSort.val();
    var currentOrder = $hfOrder.val();

    if (currentCol === column) {
        // Toggle direction
        $hfOrder.val(currentOrder === 'ASC' ? 'DESC' : 'ASC');
    } else {
        $hfSort.val(column);
        $hfOrder.val('ASC');
    }

    // Trigger postback via a hidden button
    $('#lbSort').trigger('click');
}

// ==========================================
// EXPORT TO EXCEL (Client-side)
// Exports the visible table to CSV/Excel
// ==========================================
function exportToExcel(tableId, filename) {
    var table = document.getElementById(tableId);
    if (!table) { showToast('warning', 'No data to export.'); return; }

    var rows = table.querySelectorAll('tr');
    var csv  = [];

    rows.forEach(function (row) {
        var cols = row.querySelectorAll('td, th');
        var rowData = [];
        cols.forEach(function (col) {
            // Remove HTML tags and trim
            var text = col.innerText.replace(/"/g, '""').trim();
            rowData.push('"' + text + '"');
        });
        csv.push(rowData.join(','));
    });

    var csvContent = csv.join('\n');
    var blob       = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    var link       = document.createElement('a');
    link.href      = URL.createObjectURL(blob);
    link.download  = (filename || 'export') + '_' + formatDate(new Date()) + '.csv';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    showToast('success', 'Export successful!');
}

// ==========================================
// PRINT TABLE
// ==========================================
function printTable(tableId, title) {
    var printContents = document.getElementById(tableId).outerHTML;
    var win = window.open('', '', 'height=700,width=900');
    win.document.write('<html><head><title>' + (title || 'Print') + '</title>');
    win.document.write('<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">');
    win.document.write('<style>body{font-family:Inter,sans-serif;padding:20px;} table{width:100%;font-size:13px;}</style>');
    win.document.write('</head><body>');
    win.document.write('<h4>' + (title || 'Report') + '</h4>');
    win.document.write(printContents);
    win.document.write('</body></html>');
    win.document.close();
    setTimeout(function () { win.print(); }, 500);
}

// ==========================================
// ACTIVITY TIME FORMATTER
// Formats "2024-01-15 14:30:00" -> "2 hours ago"
// ==========================================
function formatActivityTimes() {
    $('.activity-time[data-datetime]').each(function () {
        var dt  = new Date($(this).data('datetime'));
        var now = new Date();
        var diff = Math.floor((now - dt) / 1000); // seconds

        var text;
        if      (diff < 60)      text = 'Just now';
        else if (diff < 3600)    text = Math.floor(diff / 60)   + 'm ago';
        else if (diff < 86400)   text = Math.floor(diff / 3600) + 'h ago';
        else if (diff < 604800)  text = Math.floor(diff / 86400) + 'd ago';
        else                     text = dt.toLocaleDateString();

        $(this).text(text);
    });
}

// ==========================================
// DATE FORMAT HELPER
// ==========================================
function formatDate(date) {
    var d   = new Date(date);
    var day = String(d.getDate()).padStart(2, '0');
    var mon = String(d.getMonth() + 1).padStart(2, '0');
    return d.getFullYear() + '-' + mon + '-' + day;
}

// ==========================================
// SEARCH INPUT CLEAR BUTTON
// Shows an X button to clear search input
// ==========================================
$(document).on('input', '.search-input-wrapper .form-control', function () {
    var $wrapper = $(this).closest('.search-input-wrapper');
    var $clear   = $wrapper.find('.search-clear-btn');

    if ($(this).val().length > 0) {
        if ($clear.length === 0) {
            $wrapper.append('<button type="button" class="search-clear-btn btn btn-sm" style="position:absolute;right:8px;top:50%;transform:translateY(-50%);border:none;background:none;color:#64748b;"><i class="bi bi-x-circle-fill"></i></button>');
        }
    } else {
        $clear.remove();
    }
});

$(document).on('click', '.search-clear-btn', function () {
    var $input = $(this).closest('.search-input-wrapper').find('.form-control');
    $input.val('').trigger('input').focus();
    $(this).remove();
});

// ==========================================
// STATUS TOGGLE SWITCH HANDLER
// For the toggle switch in employee list
// ==========================================
$(document).on('change', '.status-toggle-switch', function () {
    var employeeId  = $(this).data('employee-id');
    var isChecked   = $(this).is(':checked');
    var $switch     = $(this);

    confirmStatusToggle(employeeId, !isChecked, function (id, newStatus) {
        // AJAX call to update status
        $.ajax({
            url: '/Handlers/UpdateStatus.ashx',
            type: 'POST',
            data: JSON.stringify({ employeeId: id, isActive: newStatus }),
            contentType: 'application/json',
            success: function (data) {
                Loader.hide();
                if (data.success) {
                    showToast('success', 'Status updated successfully.');

                    // Update badge text
                    var badgeId = 'badge_' + id;
                    if (newStatus) {
                        $('#' + badgeId).text('Active').removeClass('badge-inactive').addClass('badge-active');
                    } else {
                        $('#' + badgeId).text('Inactive').removeClass('badge-active').addClass('badge-inactive');
                    }
                } else {
                    showToast('error', data.message || 'Failed to update status.');
                    $switch.prop('checked', !isChecked); // Revert
                }
            },
            error: function () {
                Loader.hide();
                showToast('error', 'Connection error. Please try again.');
                $switch.prop('checked', !isChecked); // Revert
            }
        });
    });
});
