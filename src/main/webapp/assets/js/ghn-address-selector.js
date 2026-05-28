
const GHNAddressSelector = (function () {

    let cfg = {};

    function loading(el, text) {
        el.innerHTML = '<option value="">' + text + '</option>';
        el.disabled = true;
    }

    function reset(el, placeholder) {
        el.innerHTML = '<option value="">' + placeholder + '</option>';
        el.disabled = true;
        el.value = '';
    }

    async function loadProvinces() {
        const el = cfg.provinceEl;
        loading(el, 'Đang tải...');
        try {
            const res = await fetch(cfg.contextPath + '/api/ghn/provinces');
            const json = await res.json();
            el.innerHTML = '<option value="">-- Chọn Tỉnh / Thành phố --</option>';
            if (json.code === 200 && json.data) {
                json.data.forEach(p => {
                    const opt = document.createElement('option');
                    opt.value = p.NameExtension ? p.NameExtension[0] : p.ProvinceName;
                    opt.dataset.id = p.ProvinceID;
                    opt.textContent = p.ProvinceName;
                    el.appendChild(opt);
                });
            }
        } catch (e) {
            el.innerHTML = '<option value="">Lỗi tải dữ liệu</option>';
            console.error('[GHN] Lỗi load tỉnh:', e);
        }
        el.disabled = false;
    }

    async function loadDistricts(provinceId) {
        const el = cfg.districtEl;
        loading(el, 'Đang tải...');
        reset(cfg.wardEl, '-- Chọn Phường / Xã --');
        if (cfg.districtIdEl) cfg.districtIdEl.value = '';
        if (cfg.wardCodeEl) cfg.wardCodeEl.value = '';
        if (!provinceId) { reset(el, '-- Chọn Quận / Huyện --'); return; }
        try {
            const res = await fetch(cfg.contextPath + '/api/ghn/districts?provinceId=' + provinceId);
            const json = await res.json();
            el.innerHTML = '<option value="">-- Chọn Quận / Huyện --</option>';
            if (json.code === 200 && json.data) {
                json.data.forEach(d => {
                    const opt = document.createElement('option');
                    opt.value = d.DistrictName;
                    opt.dataset.id = d.DistrictID;
                    opt.textContent = d.DistrictName;
                    el.appendChild(opt);
                });
            }
        } catch (e) {
            el.innerHTML = '<option value="">Lỗi tải dữ liệu</option>';
            console.error('[GHN] Lỗi load quận:', e);
        }
        el.disabled = false;
    }

    async function loadWards(districtId) {
        const el = cfg.wardEl;
        loading(el, 'Đang tải...');
        if (cfg.wardCodeEl) cfg.wardCodeEl.value = '';
        if (!districtId) { reset(el, '-- Chọn Phường / Xã --'); return; }
        try {
            const res = await fetch(cfg.contextPath + '/api/ghn/wards?districtId=' + districtId);
            const json = await res.json();
            el.innerHTML = '<option value="">-- Chọn Phường / Xã --</option>';
            if (json.code === 200 && json.data) {
                json.data.forEach(w => {
                    const opt = document.createElement('option');
                    opt.value = w.WardName;
                    opt.dataset.code = w.WardCode;
                    opt.textContent = w.WardName;
                    el.appendChild(opt);
                });
            }
        } catch (e) {
            el.innerHTML = '<option value="">Lỗi tải dữ liệu</option>';
            console.error('[GHN] Lỗi load phường:', e);
        }
        el.disabled = false;
    }

    function init(options) {
        cfg = options;
        loadProvinces();

        cfg.provinceEl.addEventListener('change', function () {
            const selectedOpt = this.options[this.selectedIndex];
            const provinceId = selectedOpt.dataset.id;
            loadDistricts(provinceId);
            if (cfg.onProvinceChange) cfg.onProvinceChange(this.value);
        });

        cfg.districtEl.addEventListener('change', function () {
            const selectedOpt = this.options[this.selectedIndex];
            const districtId = selectedOpt.dataset.id;
            if (cfg.districtIdEl) cfg.districtIdEl.value = districtId || '';
            loadWards(districtId);
        });

        cfg.wardEl.addEventListener('change', function () {
            const selectedOpt = this.options[this.selectedIndex];
            if (cfg.wardCodeEl) cfg.wardCodeEl.value = selectedOpt.dataset.code || '';
        });
    }

    return { init };
})();
