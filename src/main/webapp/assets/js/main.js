/* assets/js/main.js */
// Cuộn mượt
document.querySelectorAll('.subnav a[href^="#"]').forEach(a => {
    a.addEventListener('click', e => {
        e.preventDefault();
        const id = a.getAttribute('href');
        const el = document.querySelector(id);
        if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
});


document.addEventListener('DOMContentLoaded', function () {
    const inputs = document.querySelectorAll('.otp-input');
    const hiddenInput = document.getElementById('otpHiddenInput');

    function updateHiddenInput() {
        let code = '';
        inputs.forEach(i => code += (i.value || ''));
        hiddenInput.value = code;
    }
    // xử lý input verify
    inputs.forEach((input, index) => {
        // Khi nhập
        input.addEventListener('input', (e) => {
            // Chỉ cho số
            input.value = input.value.replace(/[^0-9]/g, '');

            // Nếu dán nhiều số vào 1 ô -> tự tách ra
            if (e.inputType === 'insertFromPaste' && input.value.length > 1) {
                const chars = input.value.split('');
                input.value = chars[0];
                let nextIndex = index + 1;
                for (let i = 1; i < chars.length && nextIndex < inputs.length; i++, nextIndex++) {
                    inputs[nextIndex].value = chars[i].replace(/[^0-9]/g, '');
                }
            }

            // Nếu có ký tự & chưa phải ô cuối -> nhảy qua ô tiếp theo
            if (input.value && index < inputs.length - 1) {
                inputs[index + 1].focus();
                inputs[index + 1].select();
            }

            updateHiddenInput();
        });

        // Bắt phím để xử lý Backspace
        input.addEventListener('keydown', (e) => {
            if (e.key === 'Backspace') {
                if (input.value === '' && index > 0) {
                    inputs[index - 1].focus();
                    inputs[index - 1].value = '';
                    e.preventDefault();
                    updateHiddenInput();
                }
            }

            // Di chuyển bằng phím mũi tên trái/phải (optional cho tiện)
            if (e.key === 'ArrowLeft' && index > 0) {
                inputs[index - 1].focus();
            }
            if (e.key === 'ArrowRight' && index < inputs.length - 1) {
                inputs[index + 1].focus();
            }
        });
    });
});
//tính năng hiện mật khẩu
document.addEventListener('DOMContentLoaded', function() {
    const togglePasswordIcons = document.querySelectorAll('.toggle-password');

    togglePasswordIcons.forEach(function(icon) {
        icon.addEventListener('click', function() {
            const targetSelector = this.getAttribute('toggle');
            const passwordInput = document.querySelector(targetSelector);
            if (passwordInput) {
                if (passwordInput.getAttribute('type') === 'password') {
                    passwordInput.setAttribute('type', 'text');
                    this.classList.remove('fa-eye');
                    this.classList.add('fa-eye-slash');
                } else {
                    passwordInput.setAttribute('type', 'password');
                    this.classList.remove('fa-eye-slash');
                    this.classList.add('fa-eye');
                }
            }
        });
    });
});

const otpForm = document.getElementById('otpForm');
if (otpForm) {
    otpForm.addEventListener('submit', function (e) {
        const inputs = document.querySelectorAll('.otp-input');
        let code = '';

        inputs.forEach(i => code += (i.value || ''));

        if (code.length !== 6) {
            alert('Vui lòng nhập đủ 6 số OTP');
            e.preventDefault();
            return;
        }

        document.getElementById('otpHiddenInput').value = code;
    });
}



