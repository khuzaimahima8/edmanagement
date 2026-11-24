/* ==================================================
   ADMIN ED MANAGEMENT - MODE DEMO
   Tidak menggunakan koneksi Supabase
================================================== */

const DEMO_EMAIL = "admin@edmanagement.test";
const DEMO_PASSWORD = "admin123";

// Elemen HTML
const loginPage = document.getElementById("loginPage");
const adminApp = document.getElementById("adminApp");
const loginForm = document.getElementById("loginForm");
const loginMessage = document.getElementById("loginMessage");
const loginBtn = document.getElementById("loginBtn");
const pageContent = document.getElementById("pageContent");
const pageTitle = document.getElementById("pageTitle");
const pageDescription = document.getElementById("pageDescription");
const breadcrumbTitle = document.getElementById("breadcrumbTitle");
const approvalBadge = document.getElementById("approvalBadge");
const toast = document.getElementById("toast");
const adminName = document.getElementById("adminName");
const adminEmailLabel = document.getElementById("adminEmailLabel");
const sidebar = document.getElementById("sidebar");
const mobileMenu = document.getElementById("mobileMenu");
const logoutBtn = document.getElementById("logoutBtn");
const currentDate = document.getElementById("currentDate");

let currentPage = "dashboard";

// ==================================================
// DATA CONTOH
// ==================================================

let buyers = [
  {
    id: 1,
    name: "Rina Amelia",
    email: "rina@gmail.com",
    phone: "081234567801",
    status: "Aktif",
    date: "20 Oktober 2026"
  },
  {
    id: 2,
    name: "Doni Pratama",
    email: "doni@gmail.com",
    phone: "081234567802",
    status: "Aktif",
    date: "21 Oktober 2026"
  },
  {
    id: 3,
    name: "Nadia Putri",
    email: "nadia@gmail.com",
    phone: "081234567803",
    status: "Aktif",
    date: "22 Oktober 2026"
  }
];

let sellers = [
  {
    id: 1,
    name: "Ayu Craft",
    email: "ayu@gmail.com",
    phone: "081234567811",
    store: "Ayu Craft",
    category: "Kerajinan",
    status: "Menunggu",
    date: "23 Oktober 2026"
  },
  {
    id: 2,
    name: "Rahma",
    email: "rahma@gmail.com",
    phone: "081234567812",
    store: "Keripik Rahma",
    category: "Makanan",
    status: "Disetujui",
    date: "22 Oktober 2026"
  },
  {
    id: 3,
    name: "Budi Santoso",
    email: "budi@gmail.com",
    phone: "081234567813",
    store: "Kopi Budi",
    category: "Minuman",
    status: "Menunggu",
    date: "24 Oktober 2026"
  },
  {
    id: 4,
    name: "Siti Aminah",
    email: "siti@gmail.com",
    phone: "081234567814",
    store: "Buket Siti",
    category: "Kerajinan",
    status: "Ditolak",
    date: "21 Oktober 2026"
  }
];

let products = [
  {
    id: 1,
    name: "Tas Rajut",
    seller: "Ayu Craft",
    category: "Kerajinan",
    price: 17000,
    stock: 20,
    status: "Aktif"
  },
  {
    id: 2,
    name: "Keripik Pisang",
    seller: "Keripik Rahma",
    category: "Makanan",
    price: 10000,
    stock: 50,
    status: "Aktif"
  },
  {
    id: 3,
    name: "Kopi Cendana",
    seller: "Kopi Budi",
    category: "Minuman",
    price: 25000,
    stock: 30,
    status: "Aktif"
  }
];

let orders = [
  {
    id: "ORD-001",
    buyer: "Rina Amelia",
    buyerEmail: "rina@gmail.com",
    buyerPhone: "081234567801",
    address: "Bangil, Pasuruan, Jawa Timur",
    seller: "Ayu Craft",
    product: "Tas Rajut",
    quantity: 1,
    price: 17000,
    total: 17000,
    paymentMethod: "Transfer Bank",
    status: "Diproses",
    date: "25 Oktober 2026"
  },
  {
    id: "ORD-002",
    buyer: "Doni Pratama",
    buyerEmail: "doni@gmail.com",
    buyerPhone: "081234567802",
    address: "Purwosari, Pasuruan, Jawa Timur",
    seller: "Kopi Budi",
    product: "Kopi Cendana",
    quantity: 2,
    price: 25000,
    total: 50000,
    paymentMethod: "COD",
    status: "Selesai",
    date: "24 Oktober 2026"
  },
  {
    id: "ORD-003",
    buyer: "Nadia Putri",
    buyerEmail: "nadia@gmail.com",
    buyerPhone: "081234567803",
    address: "Sukorejo, Pasuruan, Jawa Timur",
    seller: "Keripik Rahma",
    product: "Keripik Pisang",
    quantity: 2,
    price: 10000,
    total: 20000,
    paymentMethod: "Transfer Bank",
    status: "Menunggu",
    date: "25 Oktober 2026"
  }
];


// Riwayat aktivitas dashboard
let activities = [
  {
    title: "Penjual Rahma disetujui",
    detail: "Keripik Rahma • Persetujuan penjual",
    time: "Aktivitas contoh"
  },
  {
    title: "Pesanan ORD-003 diterima",
    detail: "Nadia Putri • Keripik Pisang",
    time: "Aktivitas contoh"
  },
  {
    title: "Produk Kopi Cendana ditambahkan",
    detail: "Kopi Budi • Minuman",
    time: "Aktivitas contoh"
  }
];

let complaints = [
  {
    id: 1,
    name: "Rina Amelia",
    role: "Pembeli",
    subject: "Pesanan belum diterima",
    message: "Saya sudah melakukan pemesanan tetapi barang belum sampai.",
    date: "25 Oktober 2026",
    status: "Menunggu"
  },
  {
    id: 2,
    name: "Ayu Craft",
    role: "Penjual",
    subject: "Kendala produk",
    message: "Produk saya belum muncul di marketplace.",
    date: "24 Oktober 2026",
    status: "Diproses"
  }
];

function addActivity(title, detail) {
  activities.unshift({
    title,
    detail,
    time: "Baru saja"
  });

  activities = activities.slice(0, 8);
}



// ==================================================
// INFORMASI HALAMAN
// ==================================================

const pageInfo = {
  dashboard: {
    title: "Dashboard",
    description: "Pantau aktivitas marketplace ED Management."
  },
  approvals: {
    title: "Persetujuan Penjual",
    description: "Periksa dan tentukan persetujuan pendaftaran penjual."
  },
  buyers: {
    title: "Data Pembeli",
    description: "Kelola informasi akun pembeli."
  },
  sellers: {
    title: "Data Penjual",
    description: "Lihat dan kelola data penjual."
  },
  products: {
    title: "Data Produk",
    description: "Pantau produk yang ditampilkan di marketplace."
  },
  orders: {
    title: "Data Pesanan",
    description: "Pantau transaksi dan status pesanan."
  },
  reports: {
    title: "Laporan Penjualan",
    description: "Lihat ringkasan transaksi marketplace."
  },
  complaints: {
    title: "Pusat Keluhan",
    description: "Kelola laporan dan keluhan pembeli maupun penjual."
  },
  settings: {
    title: "Pengaturan Admin",
    description: "Kelola informasi profil dan pengaturan administrator."
  }
};

// ==================================================
// FUNGSI BANTU
// ==================================================

function escapeHTML(value) {
  return String(value ?? "").replace(/[&<>"']/g, char => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#039;"
  })[char]);
}

function rupiah(number) {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    maximumFractionDigits: 0
  }).format(number);
}

function getPendingCount() {
  return sellers.filter(
    seller => seller.status === "Menunggu"
  ).length;
}

function updateApprovalBadge() {
  if (approvalBadge) {
    approvalBadge.textContent = getPendingCount();
    approvalBadge.hidden = getPendingCount() === 0;
  }
}

function showToast(message) {
  if (!toast) return;

  toast.textContent = message;
  toast.classList.add("show");

  clearTimeout(showToast.timer);

  showToast.timer = setTimeout(() => {
    toast.classList.remove("show");
  }, 3000);
}

function statusBadge(status) {
  let className = "pending";

  if (
    status === "Aktif" ||
    status === "Disetujui" ||
    status === "Selesai"
  ) {
    className = "success";
  } else if (
    status === "Ditolak" ||
    status === "Nonaktif"
  ) {
    className = "danger";
  } else if (status === "Diproses") {
    className = "processing";
  }

  return `
    <span class="status-badge ${className}">
      ${escapeHTML(status)}
    </span>
  `;
}

function formatDateNow() {
  return new Intl.DateTimeFormat("id-ID", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric"
  }).format(new Date());
}

function emptyMessage(message) {
  return `
    <div class="empty-state">
      <p>${escapeHTML(message)}</p>
    </div>
  `;
}

// ==================================================
// LOGIN DEMO
// ==================================================

function showLogin(message = "") {
  if (loginPage) loginPage.hidden = false;
  if (adminApp) adminApp.hidden = true;

  if (loginMessage) {
    loginMessage.textContent = message;
  }
}

function showAdmin() {
  if (loginPage) loginPage.hidden = true;
  if (adminApp) adminApp.hidden = false;

  if (adminName) {
    adminName.textContent = "Administrator";
  }

  if (adminEmailLabel) {
    adminEmailLabel.textContent = DEMO_EMAIL;
  }
}

if (loginForm) {
  loginForm.addEventListener("submit", event => {
    event.preventDefault();

    const email = document
      .getElementById("adminEmail")
      .value.trim();

    const password = document
      .getElementById("adminPassword")
      .value;

    if (loginBtn) {
      loginBtn.disabled = true;
      loginBtn.textContent = "Memeriksa...";
    }

    if (
      email === DEMO_EMAIL &&
      password === DEMO_PASSWORD
    ) {
      showAdmin();
      renderPage("dashboard");
      showToast("Login demo berhasil!");
    } else {
      showLogin(
        "Email atau password salah. Periksa akun demo."
      );
    }

    if (loginBtn) {
      loginBtn.disabled = false;
      loginBtn.textContent = "Masuk";
    }
  });
}

// ==================================================
// KARTU STATISTIK
// ==================================================

function statCard(title, number, icon, note) {
  return `
    <article class="stat-card">
      <div class="stat-top">
        <span class="stat-title">${escapeHTML(title)}</span>
        <span class="stat-icon">${icon}</span>
      </div>

      <div class="stat-number">${number}</div>

      <div class="stat-note">${escapeHTML(note)}</div>
    </article>
  `;
}

// ==================================================
// DASHBOARD
// ==================================================

function renderDashboard() {
  const completedOrders = orders.filter(
    order => order.status === "Selesai"
  );

  const totalRevenue = completedOrders.reduce(
    (sum, order) => sum + order.total,
    0
  );

  const pendingSellers = sellers.filter(
    seller => seller.status === "Menunggu"
  );

  const lowStockProducts = products.filter(
    product => Number(product.stock) <= 10
  );

  const averageOrder = completedOrders.length
    ? totalRevenue / completedOrders.length
    : 0;

  // Data grafik ilustrasi untuk mode demo.
  const chartData = {
    "7": {
      labels: ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"],
      values: [120000, 185000, 150000, 230000, 195000, 280000, 245000]
    },
    "30": {
      labels: ["Minggu 1", "Minggu 2", "Minggu 3", "Minggu 4"],
      values: [620000, 850000, 740000, 1120000]
    },
    "90": {
      labels: ["Bulan 1", "Bulan 2", "Bulan 3"],
      values: [2100000, 2850000, 3340000]
    }
  };

  const selectedRange = window.dashboardChartRange || "7";
  const selectedChart = chartData[selectedRange];
  const maxValue = Math.max(...selectedChart.values, 1);

  const chartWidth = 640;
  const chartHeight = 210;
  const left = 44;
  const right = 16;
  const top = 18;
  const bottom = 34;

  const plotWidth = chartWidth - left - right;
  const plotHeight = chartHeight - top - bottom;

  const points = selectedChart.values.map((value, index) => {
    const x = left + (
      selectedChart.values.length === 1
        ? plotWidth / 2
        : (index / (selectedChart.values.length - 1)) * plotWidth
    );

    const y = top + plotHeight - (value / maxValue) * plotHeight;

    return {
      x,
      y,
      value,
      label: selectedChart.labels[index]
    };
  });

  const linePoints = points
    .map(point => `${point.x},${point.y}`)
    .join(" ");

  const areaPoints = `
    ${left},${top + plotHeight}
    ${linePoints}
    ${left + plotWidth},${top + plotHeight}
  `;

  const chartMarkup = `
    <div class="sales-chart">

      <div class="chart-y-labels">
        <span>${rupiah(maxValue)}</span>
        <span>${rupiah(maxValue * 0.5)}</span>
        <span>Rp0</span>
      </div>

      <svg
        class="chart-svg"
        viewBox="0 0 ${chartWidth} ${chartHeight}"
        role="img"
        aria-label="Grafik penjualan contoh"
      >
        <defs>
          <linearGradient
            id="salesAreaGradient"
            x1="0"
            x2="0"
            y1="0"
            y2="1"
          >
            <stop
              offset="0%"
              stop-color="#008653"
              stop-opacity="0.22"
            />
            <stop
              offset="100%"
              stop-color="#008653"
              stop-opacity="0.01"
            />
          </linearGradient>
        </defs>

        ${[0, 0.5, 1].map(ratio => {
          const y = top + plotHeight * ratio;

          return `
            <line
              x1="${left}"
              y1="${y}"
              x2="${left + plotWidth}"
              y2="${y}"
              class="chart-grid-line"
            />
          `;
        }).join("")}

        <polygon
          points="${areaPoints}"
          fill="url(#salesAreaGradient)"
        />

        <polyline
          points="${linePoints}"
          class="chart-line"
        />

        ${points.map(point => `
          <circle
            cx="${point.x}"
            cy="${point.y}"
            r="4.5"
            class="chart-point"
          >
            <title>
              ${escapeHTML(point.label)}: ${rupiah(point.value)}
            </title>
          </circle>
        `).join("")}

        ${points.map(point => `
          <text
            x="${point.x}"
            y="${chartHeight - 8}"
            text-anchor="middle"
            class="chart-x-label"
          >
            ${escapeHTML(point.label)}
          </text>
        `).join("")}
      </svg>
    </div>
  `;

  const recentOrders = [...orders].reverse().slice(0, 5);
  const recentActivities = activities.slice(0, 5);

  pageContent.innerHTML = `
    <!-- STATISTIK UTAMA -->
    <div class="stats-grid">
      ${statCard(
        "Total Pembeli",
        buyers.length,
        "♙",
        "Akun pembeli demo"
      )}

      ${statCard(
        "Total Penjual",
        sellers.filter(s => s.status === "Disetujui").length,
        "♧",
        "Penjual yang disetujui"
      )}

      ${statCard(
        "Total Produk",
        products.length,
        "▣",
        "Produk contoh"
      )}

      ${statCard(
        "Total Pesanan",
        orders.length,
        "▤",
        "Pesanan contoh"
      )}
    </div>

    <!-- STATISTIK TAMBAHAN -->
    <div class="extra-stats-grid">

      <article class="extra-stat-card">
        <span class="extra-stat-icon">Rp</span>
        <div>
          <p>Total Omzet Selesai</p>
          <strong>${rupiah(totalRevenue)}</strong>
          <small>Dari pesanan berstatus selesai</small>
        </div>
      </article>

      <article class="extra-stat-card">
        <span class="extra-stat-icon warning">!</span>
        <div>
          <p>Menunggu Persetujuan</p>
          <strong>${pendingSellers.length}</strong>
          <small>Pengajuan penjual perlu diperiksa</small>
        </div>
      </article>

      <article class="extra-stat-card">
        <span class="extra-stat-icon blue">✓</span>
        <div>
          <p>Pesanan Selesai</p>
          <strong>${completedOrders.length}</strong>
          <small>Transaksi telah selesai</small>
        </div>
      </article>

      <article class="extra-stat-card">
        <span class="extra-stat-icon orange">▦</span>
        <div>
          <p>Stok Menipis</p>
          <strong>${lowStockProducts.length}</strong>
          <small>Produk dengan stok 10 atau kurang</small>
        </div>
      </article>

    </div>

    <!-- GRAFIK PENJUALAN -->
    <section class="panel chart-panel">

      <div class="panel-header">
        <div>
          <h2>Grafik Penjualan</h2>
          <p>Perkembangan nilai penjualan berdasarkan periode contoh.</p>
        </div>
                <select
          class="filter-select"
          id="chartRange"
          aria-label="Pilih periode grafik"
        >
          <option value="7" ${selectedRange === "7" ? "selected" : ""}>
            7 hari
          </option>

          <option value="30" ${selectedRange === "30" ? "selected" : ""}>
            30 hari
          </option>

          <option value="90" ${selectedRange === "90" ? "selected" : ""}>
            3 bulan
          </option>
        </select>
      </div>

      <div class="chart-summary">
        <div>
          <span>Total omzet dari pesanan selesai</span>
          <strong>${rupiah(totalRevenue)}</strong>
        </div>

        <span class="demo-label">Data grafik ilustrasi / demo</span>
      </div>

      ${chartMarkup}

    </section>

    <!-- PERSETUJUAN DAN RINGKASAN PENJUALAN -->
    <div class="dashboard-two-columns">

      <section class="panel">

        <div class="panel-header">
          <div>
            <h2>Persetujuan Penjual</h2>
            <p>Pendaftaran yang perlu diperiksa.</p>
          </div>

          <button class="btn btn-primary" data-page="approvals">
            Lihat Semua
          </button>
        </div>

        ${pendingSellers.length ? `
          <div class="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>Nama Toko</th>
                  <th>Kategori</th>
                  <th>Status</th>
                  <th>Aksi</th>
                </tr>
              </thead>

              <tbody>
                ${pendingSellers.slice(0, 4).map(seller => `
                  <tr>
                    <td>${escapeHTML(seller.store)}</td>
                    <td>${escapeHTML(seller.category)}</td>
                    <td>${statusBadge(seller.status)}</td>
                    <td>
                      <button
                        class="btn btn-primary"
                        data-action="approve"
                        data-id="${seller.id}"
                      >
                        Setujui
                      </button>
                    </td>
                  </tr>
                `).join("")}
              </tbody>
            </table>
          </div>
        ` : emptyMessage("Tidak ada pendaftaran yang menunggu.")}

      </section>

      <section class="panel">

        <div class="panel-header">
          <div>
            <h2>Ringkasan Penjualan</h2>
            <p>Ikhtisar transaksi yang selesai.</p>
          </div>

          <button class="btn btn-light" data-page="reports">
            Laporan
          </button>
        </div>

        <div class="revenue-summary">
          <span>Total omzet</span>
          <strong>${rupiah(totalRevenue)}</strong>

          <div class="revenue-detail">
            <span>Pesanan selesai</span>
            <b>${completedOrders.length}</b>
          </div>

          <div class="revenue-detail">
            <span>Rata-rata pesanan selesai</span>
            <b>${rupiah(averageOrder)}</b>
          </div>
        </div>

      </section>

    </div>

    <!-- PESANAN TERBARU -->
    <section class="panel">

      <div class="panel-header">
        <div>
          <h2>Pesanan Terbaru</h2>
          <p>Aktivitas transaksi terakhir pada data demo.</p>
        </div>

        <button class="btn btn-light" data-page="orders">
          Lihat Semua Pesanan
        </button>
      </div>

      ${recentOrders.length ? renderTable(
        [
          "No. Pesanan",
          "Pembeli",
          "Produk",
          "Total",
          "Status",
          "Tanggal"
        ],
        recentOrders.map(order => [
          `<strong>${escapeHTML(order.id)}</strong>`,
          escapeHTML(order.buyer),
          escapeHTML(order.product),
          rupiah(order.total),
          statusBadge(order.status),
          escapeHTML(order.date)
        ])
      ) : emptyMessage("Belum ada pesanan.")}

    </section>

    <!-- AKTIVITAS TERBARU -->
    <section class="panel activity-panel">

      <div class="panel-header">
        <div>
          <h2>Aktivitas Terbaru</h2>
          <p>Riwayat aktivitas selama sesi demo ini.</p>
        </div>
      </div>

      ${recentActivities.length ? `
        <div class="activity-list">

          ${recentActivities.map((activity, index) => `
            <div class="activity-item">

              <span class="activity-marker">
                ${index === 0 ? "●" : "○"}
              </span>

              <div class="activity-copy">
                <strong>${escapeHTML(activity.title)}</strong>
                <span>${escapeHTML(activity.detail)}</span>
              </div>

              <small>${escapeHTML(activity.time)}</small>

            </div>
          `).join("")}

        </div>
      ` : emptyMessage("Belum ada aktivitas.")}

    </section>
  `;
}

// ==================================================
// PERSIAPAN TABEL
// ==================================================

function renderTable(headers, rows) {
  if (!rows.length) {
    return emptyMessage("Data tidak ditemukan.");
  }

  return `
    <div class="table-wrapper">
      <table>
        <thead>
          <tr>
            ${headers.map(header => `
              <th>${escapeHTML(header)}</th>
            `).join("")}
          </tr>
        </thead>

        <tbody>
          ${rows.map(row => `
            <tr>
              ${row.map(cell => `
                <td>${cell}</td>
              `).join("")}
            </tr>
          `).join("")}
        </tbody>
      </table>
    </div>
  `;
}

function searchBox(placeholder = "Cari data...") {
  return `
    <div class="toolbar">
      <input
        type="search"
        id="tableSearch"
        class="search-input"
        placeholder="${escapeHTML(placeholder)}"
      >
    </div>
  `;
}

// ==================================================
// PERSETUJUAN PENJUAL
// ==================================================

function renderApprovals() {
  const pendingSellers = sellers.filter(
    seller => seller.status === "Menunggu"
  );

  pageContent.innerHTML = `
    <section class="panel">

      <div class="panel-header">
        <div>
          <h2>Daftar Pendaftaran Penjual</h2>
          <p>
            Ada ${pendingSellers.length} pendaftaran yang menunggu.
          </p>
        </div>
      </div>

      ${searchBox("Cari nama atau email penjual...")}

      <div id="tableResult">
        ${renderApprovalTable(pendingSellers)}
      </div>

    </section>
  `;

  const search = document.getElementById("tableSearch");

  search.addEventListener("input", () => {
    const keyword = search.value.toLowerCase();

    const filtered = pendingSellers.filter(seller =>
      seller.name.toLowerCase().includes(keyword) ||
      seller.email.toLowerCase().includes(keyword) ||
      seller.store.toLowerCase().includes(keyword)
    );

    document.getElementById("tableResult").innerHTML =
      renderApprovalTable(filtered);
  });
}

function renderApprovalTable(data) {
  return renderTable(
    [
      "Nama Penjual",
      "Email",
      "Nama Toko",
      "Kategori",
      "Tanggal",
      "Aksi"
    ],
    data.map(seller => [
      escapeHTML(seller.name),
      escapeHTML(seller.email),
      escapeHTML(seller.store),
      escapeHTML(seller.category),
      escapeHTML(seller.date),
      `
        <button
          class="btn btn-primary"
          data-action="approve"
          data-id="${seller.id}"
        >
          Setujui
        </button>

        <button
          class="btn btn-danger"
          data-action="reject"
          data-id="${seller.id}"
        >
          Tolak
        </button>
      `
    ])
  );
}


// ==================================================
// DATA PEMBELI DAN PENJUAL
// TAHAP 2 - MANAJEMEN PENGGUNA
// ==================================================

function showUserModal(role, id, mode = "detail") {
  const isBuyer = role === "buyer";

  const user = isBuyer
    ? buyers.find(item => item.id === id)
    : sellers.find(item => item.id === id);

  if (!user) return;

  const accountStatus = isBuyer
    ? user.status
    : (user.accountStatus || "Aktif");

  const title = mode === "edit"
    ? "Edit Informasi Pengguna"
    : "Detail Pengguna";

  const sellerFields = !isBuyer ? `
    <div class="user-detail-item">
      <span>Nama Toko</span>
      <strong>${escapeHTML(user.store)}</strong>
    </div>
    <div class="user-detail-item">
      <span>Kategori</span>
      <strong>${escapeHTML(user.category)}</strong>
    </div>
    <div class="user-detail-item">
      <span>Status Pendaftaran</span>
      <strong>${escapeHTML(user.status)}</strong>
    </div>
  ` : "";

  const content = mode === "edit" ? `
    <form id="editUserForm" data-role="${role}" data-id="${id}">

      <div class="user-form-field">
        <label>Nama Lengkap</label>
        <input id="editUserName"
          value="${escapeHTML(user.name)}" required>
      </div>

      <div class="user-form-field">
        <label>Email</label>
        <input id="editUserEmail" type="email"
          value="${escapeHTML(user.email)}" required>
      </div>

      <div class="user-form-field">
        <label>Nomor Telepon</label>
        <input id="editUserPhone"
          value="${escapeHTML(user.phone)}" required>
      </div>

      ${!isBuyer ? `
        <div class="user-form-field">
          <label>Nama Toko</label>
          <input id="editUserStore"
            value="${escapeHTML(user.store)}" required>
        </div>

        <div class="user-form-field">
          <label>Kategori Toko</label>
          <select id="editUserCategory">
            ${["Makanan", "Minuman", "Kerajinan", "Fashion", "Lainnya"]
              .map(category => `
                <option value="${category}"
                  ${user.category === category ? "selected" : ""}>
                  ${category}
                </option>
              `).join("")}
          </select>
        </div>
      ` : ""}

      <div class="user-modal-actions">
        <button type="button" class="btn btn-light"
          data-action="close-user-modal">
          Batal
        </button>

        <button type="submit" class="btn btn-primary">
          Simpan Perubahan
        </button>
      </div>

    </form>
  ` : `
    <div class="user-detail-grid">

      <div class="user-detail-item">
        <span>Nama Lengkap</span>
        <strong>${escapeHTML(user.name)}</strong>
      </div>

      <div class="user-detail-item">
        <span>Email</span>
        <strong>${escapeHTML(user.email)}</strong>
      </div>

      <div class="user-detail-item">
        <span>Nomor Telepon</span>
        <strong>${escapeHTML(user.phone)}</strong>
      </div>

      <div class="user-detail-item">
        <span>Tanggal Daftar</span>
        <strong>${escapeHTML(user.date)}</strong>
      </div>

      ${sellerFields}

      <div class="user-detail-item">
        <span>Status Akun</span>
        <strong>${escapeHTML(accountStatus)}</strong>
      </div>

    </div>

    <div class="user-modal-actions">
      <button class="btn btn-light"
        data-action="close-user-modal">
        Tutup
      </button>

      <button class="btn btn-primary"
        data-action="edit-user"
        data-role="${role}"
        data-id="${id}">
        Edit Pengguna
      </button>
    </div>
  `;

  const oldModal = document.getElementById("userModal");
  if (oldModal) oldModal.remove();

  pageContent.insertAdjacentHTML("beforeend", `
    <div class="user-modal-overlay" id="userModal">

      <div class="user-modal">

        <div class="user-modal-header">
          <div>
            <h2>${title}</h2>
            <p>Informasi akun ED Management</p>
          </div>

          <button class="user-modal-close"
            data-action="close-user-modal">
            &times;
          </button>
        </div>

        <div class="user-modal-body">
          ${content}
        </div>

      </div>

    </div>
  `);
}


// ==================================================
// DATA PEMBELI
// ==================================================

function renderBuyers() {
  pageContent.innerHTML = `
    <section class="panel">

      <div class="panel-header">
        <div>
          <h2>Daftar Pembeli</h2>
          <p>Total ${buyers.length} pembeli contoh.</p>
        </div>
      </div>

      ${searchBox("Cari nama, email, atau nomor telepon...")}

      <div id="tableResult">
        ${renderBuyerTable(buyers)}
      </div>

    </section>
  `;

  document.getElementById("tableSearch").addEventListener(
    "input",
    event => {
      const keyword = event.target.value.toLowerCase();

      const filtered = buyers.filter(buyer =>
        buyer.name.toLowerCase().includes(keyword) ||
        buyer.email.toLowerCase().includes(keyword) ||
        buyer.phone.toLowerCase().includes(keyword)
      );

      document.getElementById("tableResult").innerHTML =
        renderBuyerTable(filtered);
    }
  );
}


function renderBuyerTable(data) {
  return renderTable(
    [
      "Nama",
      "Email",
      "Nomor Telepon",
      "Tanggal Daftar",
      "Status",
      "Aksi"
    ],

    data.map(buyer => [
      escapeHTML(buyer.name),
      escapeHTML(buyer.email),
      escapeHTML(buyer.phone),
      escapeHTML(buyer.date),
      statusBadge(buyer.status),

      `
        <div class="user-action-buttons">

          <button class="btn btn-light"
            data-action="view-user"
            data-role="buyer"
            data-id="${buyer.id}">
            Detail
          </button>

          <button class="btn btn-primary"
            data-action="edit-user"
            data-role="buyer"
            data-id="${buyer.id}">
            Edit
          </button>

          <button class="btn ${
            buyer.status === "Aktif"
              ? "btn-danger"
              : "btn-primary"
          }"
            data-action="toggle-user"
            data-role="buyer"
            data-id="${buyer.id}">
            ${buyer.status === "Aktif" ? "Nonaktifkan" : "Aktifkan"}
          </button>

        </div>
      `
    ])
  );
}


// ==================================================
// DATA PENJUAL
// ==================================================

function renderSellers() {
  pageContent.innerHTML = `
    <section class="panel">

      <div class="panel-header">
        <div>
          <h2>Daftar Penjual</h2>
          <p>Total ${sellers.length} penjual contoh.</p>
        </div>
      </div>

      ${searchBox("Cari nama penjual atau nama toko...")}

      <div id="tableResult">
        ${renderSellerTable(sellers)}
      </div>

    </section>
  `;

  document.getElementById("tableSearch").addEventListener(
    "input",
    event => {
      const keyword = event.target.value.toLowerCase();

      const filtered = sellers.filter(seller =>
        seller.name.toLowerCase().includes(keyword) ||
        seller.email.toLowerCase().includes(keyword) ||
        seller.store.toLowerCase().includes(keyword)
      );

      document.getElementById("tableResult").innerHTML =
        renderSellerTable(filtered);
    }
  );
}


function renderSellerTable(data) {
  return renderTable(
    [
      "Nama Penjual",
      "Email",
      "Nama Toko",
      "Kategori",
      "Pendaftaran",
      "Status Akun",
      "Aksi"
    ],

    data.map(seller => {
      const accountStatus = seller.accountStatus || "Aktif";

      return [
        escapeHTML(seller.name),
        escapeHTML(seller.email),
        escapeHTML(seller.store),
        escapeHTML(seller.category),
        statusBadge(seller.status),
        statusBadge(accountStatus),

        `
          <div class="user-action-buttons">

            <button class="btn btn-light"
              data-action="view-user"
              data-role="seller"
              data-id="${seller.id}">
              Detail
            </button>

            <button class="btn btn-primary"
              data-action="edit-user"
              data-role="seller"
              data-id="${seller.id}">
              Edit
            </button>

            <button class="btn ${
              accountStatus === "Aktif"
                ? "btn-danger"
                : "btn-primary"
            }"
              data-action="toggle-user"
              data-role="seller"
              data-id="${seller.id}">
              ${accountStatus === "Aktif" ? "Nonaktifkan" : "Aktifkan"}
            </button>

          </div>
        `
      ];
    })
  );
}


// ==================================================
// DATA PRODUK - TAHAP 2B
// ==================================================

function renderProducts() {
  const totalStok = products.reduce(
    (total, product) => total + Number(product.stock),
    0
  );

  const produkNonaktif = products.filter(
    product => product.status === "Nonaktif"
  ).length;

  pageContent.innerHTML = `
    <section class="panel">

      <div class="panel-header">
        <div>
          <h2>Daftar Produk</h2>
          <p>Kelola informasi, harga, dan stok produk marketplace.</p>
        </div>
      </div>

      <div class="product-summary">

        <div class="product-summary-card">
          <span>Total Produk</span>
          <strong>${products.length}</strong>
        </div>

        <div class="product-summary-card">
          <span>Total Stok</span>
          <strong>${totalStok}</strong>
        </div>

        <div class="product-summary-card">
          <span>Produk Nonaktif</span>
          <strong>${produkNonaktif}</strong>
        </div>

      </div>

      ${searchBox("Cari nama produk atau penjual...")}

      <div id="tableResult">
        ${renderProductTable(products)}
      </div>

    </section>
  `;

  document.getElementById("tableSearch").addEventListener(
    "input",
    event => {
      const keyword = event.target.value.toLowerCase();

      const filtered = products.filter(product =>
        product.name.toLowerCase().includes(keyword) ||
        product.seller.toLowerCase().includes(keyword) ||
        product.category.toLowerCase().includes(keyword)
      );

      document.getElementById("tableResult").innerHTML =
        renderProductTable(filtered);
    }
  );
}


// ==================================================
// TABEL PRODUK
// ==================================================

function renderProductTable(data) {
  return renderTable(
    [
      "Nama Produk",
      "Penjual",
      "Kategori",
      "Harga",
      "Stok",
      "Status",
      "Aksi"
    ],

    data.map(product => [
      escapeHTML(product.name),
      escapeHTML(product.seller),
      escapeHTML(product.category),
      rupiah(product.price),

      `
        <span class="${
          Number(product.stock) <= 5
            ? "stock-low"
            : "stock-normal"
        }">
          ${Number(product.stock)} unit
        </span>
      `,

      statusBadge(product.status),

      `
        <div class="product-action-buttons">

          <button
            class="btn btn-light"
            data-action="view-product"
            data-id="${product.id}">
            Detail
          </button>

          <button
            class="btn btn-primary"
            data-action="edit-product"
            data-id="${product.id}">
            Edit
          </button>

          <button
            class="btn ${
              product.status === "Aktif"
                ? "btn-danger"
                : "btn-primary"
            }"
            data-action="toggle-product"
            data-id="${product.id}">

            ${
              product.status === "Aktif"
                ? "Nonaktifkan"
                : "Aktifkan"
            }

          </button>

        </div>
      `
    ])
  );
}


// ==================================================
// MODAL DETAIL DAN EDIT PRODUK
// ==================================================

function showProductModal(id, mode = "detail") {
  const product = products.find(
    item => item.id === id
  );

  if (!product) return;

  const isEdit = mode === "edit";

  document.getElementById("productModal")?.remove();

  const detailContent = `
    <div class="product-detail-grid">

      <div class="product-detail-item">
        <span>Nama Produk</span>
        <strong>${escapeHTML(product.name)}</strong>
      </div>

      <div class="product-detail-item">
        <span>Nama Penjual</span>
        <strong>${escapeHTML(product.seller)}</strong>
      </div>

      <div class="product-detail-item">
        <span>Kategori</span>
        <strong>${escapeHTML(product.category)}</strong>
      </div>

      <div class="product-detail-item">
        <span>Harga Produk</span>
        <strong>${rupiah(product.price)}</strong>
      </div>

      <div class="product-detail-item">
        <span>Stok Tersedia</span>
        <strong>${Number(product.stock)} unit</strong>
      </div>

      <div class="product-detail-item">
        <span>Status Produk</span>
        <strong>${escapeHTML(product.status)}</strong>
      </div>

    </div>

    <div class="product-modal-actions">

      <button
        class="btn btn-light"
        data-action="close-product-modal">
        Tutup
      </button>

      <button
        class="btn btn-primary"
        data-action="edit-product"
        data-id="${product.id}">
        Edit Produk
      </button>

    </div>
  `;

  const editContent = `
    <form id="editProductForm" data-id="${product.id}">

      <div class="product-form-field">
        <label>Nama Produk</label>
        <input
          type="text"
          id="editProductName"
          value="${escapeHTML(product.name)}"
          required>
      </div>

      <div class="product-form-field">
        <label>Nama Penjual</label>
        <input
          type="text"
          id="editProductSeller"
          value="${escapeHTML(product.seller)}"
          required>
      </div>

      <div class="product-form-field">
        <label>Kategori Produk</label>

        <select id="editProductCategory">
          ${[
            "Makanan",
            "Minuman",
            "Kerajinan",
            "Fashion",
            "Lainnya"
          ].map(category => `
            <option
              value="${category}"
              ${product.category === category ? "selected" : ""}>
              ${category}
            </option>
          `).join("")}
        </select>
      </div>

      <div class="product-form-field">
        <label>Harga Produk (Rp)</label>
        <input
          type="number"
          id="editProductPrice"
          min="0"
          step="1"
          value="${Number(product.price)}"
          required>
      </div>

      <div class="product-form-field">
        <label>Stok Produk (Unit)</label>
        <input
          type="number"
          id="editProductStock"
          min="0"
          step="1"
          value="${Number(product.stock)}"
          required>
      </div>

      <div class="product-modal-actions">

        <button
          type="button"
          class="btn btn-light"
          data-action="close-product-modal">
          Batal
        </button>

        <button
          type="submit"
          class="btn btn-primary">
          Simpan Perubahan
        </button>

      </div>

    </form>
  `;

  pageContent.insertAdjacentHTML("beforeend", `
    <div class="product-modal-overlay" id="productModal">

      <div class="product-modal">

        <div class="product-modal-header">

          <div>
            <h2>${isEdit ? "Edit Produk" : "Detail Produk"}</h2>
            <p>Manajemen produk ED Management</p>
          </div>

          <button
            class="product-modal-close"
            data-action="close-product-modal">
            &times;
          </button>

        </div>

        <div class="product-modal-body">
          ${isEdit ? editContent : detailContent}
        </div>

      </div>

    </div>
  `);
}


 // ==================================================
 // DATA PESANAN - TAHAP 2C
 // ==================================================

const orderStatuses = [
  "Menunggu",
  "Diproses",
  "Dikirim",
  "Selesai",
  "Dibatalkan"
];

function renderOrders() {
  const waiting = orders.filter(o => o.status === "Menunggu").length;
  const processing = orders.filter(o => o.status === "Diproses").length;
  const shipped = orders.filter(o => o.status === "Dikirim").length;
  const completed = orders.filter(o => o.status === "Selesai").length;

  pageContent.innerHTML = `
    <section class="panel">

      <div class="panel-header">
        <div>
          <h2>Daftar Pesanan</h2>
          <p>Kelola dan pantau seluruh transaksi marketplace.</p>
        </div>
      </div>

      <div class="order-summary">

        <div class="order-summary-card">
          <span>Menunggu</span>
          <strong>${waiting}</strong>
        </div>

        <div class="order-summary-card">
          <span>Diproses</span>
          <strong>${processing}</strong>
        </div>

        <div class="order-summary-card">
          <span>Dikirim</span>
          <strong>${shipped}</strong>
        </div>

        <div class="order-summary-card">
          <span>Selesai</span>
          <strong>${completed}</strong>
        </div>

      </div>

      <div class="order-toolbar">

        ${searchBox("Cari nomor pesanan, pembeli, atau produk...")}

        <select id="orderStatusFilter" class="order-filter">
          <option value="Semua">Semua Status</option>
          ${orderStatuses.map(status => `
            <option value="${status}">${status}</option>
          `).join("")}
        </select>

      </div>

      <div id="tableResult">
        ${renderOrderTable(orders)}
      </div>

    </section>
  `;

  const searchInput = document.getElementById("tableSearch");
  const statusFilter = document.getElementById("orderStatusFilter");

  function applyOrderFilter() {
    const keyword = searchInput.value.toLowerCase().trim();
    const selectedStatus = statusFilter.value;

    const filtered = orders.filter(order => {
      const matchKeyword =
        order.id.toLowerCase().includes(keyword) ||
        order.buyer.toLowerCase().includes(keyword) ||
        order.product.toLowerCase().includes(keyword) ||
        order.seller.toLowerCase().includes(keyword);

      const matchStatus =
        selectedStatus === "Semua" ||
        order.status === selectedStatus;

      return matchKeyword && matchStatus;
    });

    document.getElementById("tableResult").innerHTML =
      renderOrderTable(filtered);
  }

  searchInput.addEventListener("input", applyOrderFilter);
  statusFilter.addEventListener("change", applyOrderFilter);
}


// ==================================================
// TABEL PESANAN
// ==================================================

function renderOrderTable(data) {
  if (data.length === 0) {
    return emptyMessage("Pesanan tidak ditemukan.");
  }

  return renderTable(
    [
      "Nomor Pesanan",
      "Pembeli",
      "Produk",
      "Total",
      "Tanggal",
      "Status",
      "Aksi"
    ],

    data.map(order => [
      `<strong>${escapeHTML(order.id)}</strong>`,
      escapeHTML(order.buyer),
      escapeHTML(order.product),
      rupiah(order.total),
      escapeHTML(order.date),
      statusBadge(order.status),

      `
        <button
          class="btn btn-primary"
          data-action="view-order"
          data-id="${escapeHTML(order.id)}">
          Detail
        </button>
      `
    ])
  );
}


// ==================================================
// MODAL DETAIL PESANAN
// ==================================================

function showOrderDetail(orderId) {
  const order = orders.find(item => item.id === orderId);

  if (!order) return;

  document.getElementById("orderModal")?.remove();

  const quantity = Number(order.quantity || 1);
  const price = Number(order.price || order.total);
  const subtotal = price * quantity;

  pageContent.insertAdjacentHTML("beforeend", `
    <div class="order-modal-overlay" id="orderModal">

      <div class="order-modal">

        <div class="order-modal-header">
          <div>
            <h2>Detail Pesanan</h2>
            <p>Nomor Pesanan: ${escapeHTML(order.id)}</p>
          </div>

          <button
            class="order-modal-close"
            data-action="close-order-modal">
            &times;
          </button>
        </div>

        <div class="order-modal-body">

          <div class="order-detail-section">
            <h3>Informasi Pembeli</h3>

            <div class="order-detail-grid">

              <div class="order-detail-item">
                <span>Nama Pembeli</span>
                <strong>${escapeHTML(order.buyer)}</strong>
              </div>

              <div class="order-detail-item">
                <span>Email</span>
                <strong>${escapeHTML(order.buyerEmail || "-")}</strong>
              </div>

              <div class="order-detail-item">
                <span>Nomor Telepon</span>
                <strong>${escapeHTML(order.buyerPhone || "-")}</strong>
              </div>

              <div class="order-detail-item">
                <span>Alamat Pengiriman</span>
                <strong>${escapeHTML(order.address || "-")}</strong>
              </div>

            </div>
          </div>

          <div class="order-detail-section">
            <h3>Informasi Produk</h3>

            <div class="order-detail-grid">

              <div class="order-detail-item">
                <span>Nama Produk</span>
                <strong>${escapeHTML(order.product)}</strong>
              </div>

              <div class="order-detail-item">
                <span>Penjual</span>
                <strong>${escapeHTML(order.seller || "-")}</strong>
              </div>

              <div class="order-detail-item">
                <span>Harga Satuan</span>
                <strong>${rupiah(price)}</strong>
              </div>

              <div class="order-detail-item">
                <span>Jumlah</span>
                <strong>${quantity} unit</strong>
              </div>

              <div class="order-detail-item">
                <span>Subtotal Produk</span>
                <strong>${rupiah(subtotal)}</strong>
              </div>

              <div class="order-detail-item">
                <span>Total Pembayaran</span>
                <strong>${rupiah(order.total)}</strong>
              </div>

            </div>
          </div>

          <div class="order-detail-section">
            <h3>Informasi Transaksi</h3>

            <div class="order-detail-grid">

              <div class="order-detail-item">
                <span>Tanggal Pesanan</span>
                <strong>${escapeHTML(order.date)}</strong>
              </div>

              <div class="order-detail-item">
                <span>Metode Pembayaran</span>
                <strong>${escapeHTML(order.paymentMethod || "-")}</strong>
              </div>

              <div class="order-detail-item">
                <span>Status Sekarang</span>
                <strong>${statusBadge(order.status)}</strong>
              </div>

            </div>
          </div>

          <form id="orderStatusForm" data-id="${escapeHTML(order.id)}">

            <div class="order-form-field">
              <label for="newOrderStatus">Ubah Status Pesanan</label>

              <select id="newOrderStatus">
                ${orderStatuses.map(status => `
                  <option
                    value="${status}"
                    ${order.status === status ? "selected" : ""}>
                    ${status}
                  </option>
                `).join("")}
              </select>
            </div>

            <div class="order-modal-actions">

              <button
                type="button"
                class="btn btn-light"
                data-action="close-order-modal">
                Tutup
              </button>

              <button type="submit" class="btn btn-primary">
                Simpan Status
              </button>

            </div>

          </form>

        </div>
      </div>
    </div>
  `);
}


// ==================================================
// LAPORAN PENJUALAN - TAHAP 2D
// ==================================================

function renderReports() {

  const completedOrders = orders.filter(
    order => order.status === "Selesai"
  );

  const pendingOrders = orders.filter(
    order => order.status === "Menunggu"
  );

  const processingOrders = orders.filter(
    order => order.status === "Diproses"
  );

  const shippedOrders = orders.filter(
    order => order.status === "Dikirim"
  );

  const canceledOrders = orders.filter(
    order => order.status === "Dibatalkan"
  );

  const totalRevenue = completedOrders.reduce(
    (sum, order) => sum + Number(order.total || 0),
    0
  );

  const averageOrder = completedOrders.length
    ? totalRevenue / completedOrders.length
    : 0;

  // REKAP PENJUALAN BERDASARKAN PRODUK
  const productSales = {};

  completedOrders.forEach(order => {
    const productName = order.product || "Produk";

    if (!productSales[productName]) {
      productSales[productName] = 0;
    }

    productSales[productName] += Number(order.total || 0);
  });

  const sortedProductSales = Object.entries(productSales)
    .sort((a, b) => b[1] - a[1]);

  const maxProductRevenue = Math.max(
    ...sortedProductSales.map(item => item[1]),
    1
  );

  // GRAFIK PENJUALAN VERTIKAL
  const productChart = sortedProductSales.length
    ? `
      <div class="vertical-chart">

        ${sortedProductSales.map(([name, revenue]) => {
          const percentage = Math.max(
            (revenue / maxProductRevenue) * 100,
            4
          );

          return `
            <div class="vertical-chart-item">

              <div class="vertical-chart-value">
                ${rupiah(revenue)}
              </div>

              <div class="vertical-chart-column">
                <div
                  class="vertical-chart-bar"
                  style="height: ${percentage}%">
                </div>
              </div>

              <div class="vertical-chart-label">
                ${escapeHTML(name)}
              </div>

            </div>
          `;
        }).join("")}

      </div>
    `
    : emptyMessage("Belum ada transaksi yang selesai.");


  // TAMPILAN HALAMAN
  pageContent.innerHTML = `

    <!-- RINGKASAN PENJUALAN -->

    <div class="stats-grid">

      ${statCard(
        "Total Omzet",
        rupiah(totalRevenue),
        "Rp",
        "Dari transaksi yang selesai"
      )}

      ${statCard(
        "Transaksi Selesai",
        completedOrders.length,
        "✓",
        "Pesanan berhasil diselesaikan"
      )}

      ${statCard(
        "Pesanan Menunggu",
        pendingOrders.length,
        "◷",
        "Menunggu konfirmasi"
      )}

      ${statCard(
        "Pesanan Dibatalkan",
        canceledOrders.length,
        "×",
        "Total pesanan dibatalkan"
      )}

    </div>

    <!-- RINGKASAN TAMBAHAN -->

    <div class="report-extra-grid">

      <div class="report-extra-card">
        <span>Total Pesanan</span>
        <strong>${orders.length}</strong>
      </div>

      <div class="report-extra-card">
        <span>Pesanan Diproses</span>
        <strong>${processingOrders.length}</strong>
      </div>

      <div class="report-extra-card">
        <span>Pesanan Dikirim</span>
        <strong>${shippedOrders.length}</strong>
      </div>

      <div class="report-extra-card">
        <span>Rata-rata Transaksi Selesai</span>
        <strong>${rupiah(averageOrder)}</strong>
      </div>

    </div>

    <!-- GRAFIK PENJUALAN -->

    <section class="panel report-chart-panel">

      <div class="panel-header">
        <div>
          <h2>Penjualan Berdasarkan Produk</h2>
          <p>
            Perbandingan omzet setiap produk dari pesanan selesai.
          </p>
        </div>
      </div>

      ${productChart}

    </section>

    <!-- DAFTAR TRANSAKSI -->

    <section class="panel">

      <div class="panel-header">

        <div>
          <h2>Riwayat Transaksi</h2>
          <p>
            Total ${orders.length} transaksi pada data demo.
          </p>
        </div>

        <button
          class="btn btn-primary"
          data-action="export-report">
          Ekspor CSV
        </button>

      </div>

      <div class="report-toolbar">

        <input
          type="search"
          id="reportSearch"
          class="search-input"
          placeholder="Cari nomor pesanan, pembeli, atau produk..."
        >

        <select
          id="reportStatusFilter"
          class="report-filter">

          <option value="Semua">Semua Status</option>
          <option value="Menunggu">Menunggu</option>
          <option value="Diproses">Diproses</option>
          <option value="Dikirim">Dikirim</option>
          <option value="Selesai">Selesai</option>
          <option value="Dibatalkan">Dibatalkan</option>

        </select>

      </div>

      <div id="reportTableResult">
        ${renderReportTable(orders)}
      </div>

    </section>

  `;

  // PENCARIAN DAN FILTER
  const searchInput =
    document.getElementById("reportSearch");

  const statusFilter =
    document.getElementById("reportStatusFilter");

  function applyReportFilter() {

    const keyword =
      searchInput.value.toLowerCase().trim();

    const selectedStatus =
      statusFilter.value;

    const filtered = orders.filter(order => {

      const matchKeyword =
        order.id.toLowerCase().includes(keyword) ||
        order.buyer.toLowerCase().includes(keyword) ||
        order.product.toLowerCase().includes(keyword);

      const matchStatus =
        selectedStatus === "Semua" ||
        order.status === selectedStatus;

      return matchKeyword && matchStatus;

    });

    document.getElementById(
      "reportTableResult"
    ).innerHTML = renderReportTable(filtered);

  }

  searchInput.addEventListener(
    "input",
    applyReportFilter
  );

  statusFilter.addEventListener(
    "change",
    applyReportFilter
  );

}


// ==================================================
// TABEL RIWAYAT TRANSAKSI
// ==================================================

function renderReportTable(data) {

  return renderTable(
    [
      "Nomor Pesanan",
      "Pembeli",
      "Produk",
      "Total",
      "Tanggal",
      "Status"
    ],

    data.map(order => [
      `<strong>${escapeHTML(order.id)}</strong>`,
      escapeHTML(order.buyer),
      escapeHTML(order.product),
      rupiah(order.total),
      escapeHTML(order.date),
      statusBadge(order.status)
    ])
  );

}


// ==================================================
// GANTI PERIODE GRAFIK
// ==================================================

document.addEventListener("change", event => {
  if (event.target && event.target.id === "chartRange") {
    window.dashboardChartRange = event.target.value;
    renderDashboard();
  }
});

// ==================================================
// NAVIGASI HALAMAN
// ==================================================

function renderPage(page) {
  if (!pageInfo[page]) return;

  currentPage = page;

  const info = pageInfo[page];

  if (pageTitle) {
    pageTitle.textContent = info.title;
  }

  if (breadcrumbTitle) {
    breadcrumbTitle.textContent = info.title;
  }

  if (pageDescription) {
    pageDescription.textContent = info.description;
  }

  document.querySelectorAll(".nav-item[data-page]").forEach(button => {
    button.classList.toggle(
      "active",
      button.dataset.page === page
    );
  });

  updateApprovalBadge();

  switch (page) {
    case "dashboard":
      renderDashboard();
      break;

    case "approvals":
      renderApprovals();
      break;

    case "buyers":
      renderBuyers();
      break;

    case "sellers":
      renderSellers();
      break;

    case "products":
      renderProducts();
      break;

    case "orders":
      renderOrders();
      break;

    case "reports":
      renderReports();
      break;
    
    case "complaints":
      renderComplaints();
      break;

    case "settings":
      renderSettings();
      break;
  }

  if (sidebar) {
    sidebar.classList.remove("open");
  }
}

// ==================================================
// TOMBOL DAN AKSI
// ==================================================

document.addEventListener("click", event => {
  const pageButton = event.target.closest("[data-page]");

  if (pageButton) {
    const page = pageButton.dataset.page;

    if (pageInfo[page]) {
      renderPage(page);
    }

    return;
  }

  const actionButton = event.target.closest("[data-action]");

  if (!actionButton) return;

  const action = actionButton.dataset.action;
  const id = Number(actionButton.dataset.id);

  // BUKA DETAIL KELUHAN
  if (action === "view-complaint") {
    openComplaintDetail(id);
    return;
  }

  // TUTUP DETAIL KELUHAN
  if (action === "close-complaint") {
    const container = document.getElementById(
      "complaintModalContainer"
    );

    if (container) container.innerHTML = "";
    return;
  }

  // SIMPAN TANGGAPAN DAN STATUS
  if (action === "save-complaint") {

    const item = complaints.find(
      complaint => complaint.id === id
    );

    if (!item) return;

    const newStatus = document.getElementById(
      "complaintStatus"
    ).value;

    const reply = document.getElementById(
      "complaintReply"
    ).value.trim();

    if (!reply) {
      showToast("Silakan isi tanggapan admin terlebih dahulu.");
      return;
    }

    const oldStatus = item.status;

    item.status = newStatus;
    item.reply = reply;

    addActivity(
      `Keluhan ${item.name} diperbarui`,
      `${item.subject} • Status: ${newStatus}`
    );

    renderPage("complaints");

    showToast(
      "Tanggapan dan status keluhan berhasil disimpan."
    );

    return;
  }
  
// DETAIL PESANAN
if (action === "view-order") {
  showOrderDetail(actionButton.dataset.id);
  return;
}

// TUTUP MODAL PESANAN
if (action === "close-order-modal") {
  document.getElementById("orderModal")?.remove();
  return;
}


  
  // DETAIL PENGGUNA
  if (action === "view-user") {
    showUserModal(
      actionButton.dataset.role,
      id,
      "detail"
    );
    return;
  }

  // EDIT PENGGUNA
  if (action === "edit-user") {
    showUserModal(
      actionButton.dataset.role,
      id,
      "edit"
    );
    return;
  }

  // TUTUP MODAL
  if (action === "close-user-modal") {
    document.getElementById("userModal")?.remove();
    return;
  }

  // AKTIF / NONAKTIF PENGGUNA
  if (action === "toggle-user") {
    const role = actionButton.dataset.role;
    const isBuyer = role === "buyer";

    const user = isBuyer
      ? buyers.find(item => item.id === id)
      : sellers.find(item => item.id === id);

    if (!user) return;

    const currentStatus = isBuyer
      ? user.status
      : (user.accountStatus || "Aktif");

    const newStatus = currentStatus === "Aktif"
      ? "Nonaktif"
      : "Aktif";

    const confirmed = confirm(
      `Apakah kamu yakin ingin mengubah status akun ${user.name} menjadi ${newStatus}?`
    );

    if (!confirmed) return;

    if (isBuyer) {
      user.status = newStatus;
    } else {
      user.accountStatus = newStatus;
    }

    addActivity(
      `Status akun ${user.name} diubah`,
      `Status sekarang: ${newStatus}`
    );

    renderPage(currentPage);

    showToast(
      `Status akun ${user.name} berhasil diubah menjadi ${newStatus}.`
    );

    return;
  }


  // SETUJUI PENJUAL
  if (action === "approve") {
    const seller = sellers.find(item => item.id === id);

    if (!seller) return;

    seller.status = "Disetujui";

    addActivity(
      `Penjual ${seller.store} disetujui`,
      `${seller.category} • Persetujuan penjual`
    );

    updateApprovalBadge();
    renderPage(currentPage);

    showToast(
      `Penjual ${seller.store} berhasil disetujui.`
    );
  }

  // TOLAK PENJUAL
  if (action === "reject") {
    const seller = sellers.find(item => item.id === id);

    if (!seller) return;

    const confirmed = confirm(
      `Apakah kamu yakin ingin menolak pendaftaran ${seller.store}?`
    );

    if (!confirmed) return;

    seller.status = "Ditolak";

    addActivity(
      `Pengajuan ${seller.store} ditolak`,
      `${seller.category} • Persetujuan penjual`
    );

    updateApprovalBadge();
    renderPage(currentPage);

    showToast(
      `Pendaftaran ${seller.store} ditolak.`
    );
  }


  // DETAIL PRODUK
  if (action === "view-product") {
    showProductModal(id, "detail");
    return;
  }

  // EDIT PRODUK
  if (action === "edit-product") {
    showProductModal(id, "edit");
    return;
  }

  // TUTUP MODAL PRODUK
  if (action === "close-product-modal") {
    document.getElementById("productModal")?.remove();
    return;
  }


  // AKTIF / NONAKTIF PRODUK
  if (action === "toggle-product") {
    const product = products.find(item => item.id === id);

    if (!product) return;

    product.status =
      product.status === "Aktif"
        ? "Nonaktif"
        : "Aktif";

    addActivity(
      `Status produk ${product.name} diubah`,
      `Status sekarang: ${product.status}`
    );

    renderPage(currentPage);

    showToast(
      `${product.name}: status menjadi ${product.status}.`
    );
  }

  // EKSPOR LAPORAN
  if (action === "export-report") {
    exportReport();
  }
});

document.addEventListener("submit", event => {
  if (event.target.id !== "editUserForm") return;

  event.preventDefault();

  const form = event.target;
  const role = form.dataset.role;
  const id = Number(form.dataset.id);

  const isBuyer = role === "buyer";

  const user = isBuyer
    ? buyers.find(item => item.id === id)
    : sellers.find(item => item.id === id);

  if (!user) return;

  const name = document.getElementById("editUserName").value.trim();
  const email = document.getElementById("editUserEmail").value.trim();
  const phone = document.getElementById("editUserPhone").value.trim();

  if (!name || !email || !phone) {
    showToast("Semua data wajib diisi.");
    return;
  }

  user.name = name;
  user.email = email;
  user.phone = phone;

  if (!isBuyer) {
    user.store = document.getElementById("editUserStore").value.trim();

    user.category = document.getElementById("editUserCategory").value;
  }

  addActivity(
    `Data ${isBuyer ? "pembeli" : "penjual"} ${name} diperbarui`,
    "Informasi akun berhasil diperbarui."
  );

  document.getElementById("userModal")?.remove();

  renderPage(currentPage);

  showToast("Informasi pengguna berhasil diperbarui.");
});


// ==================================================
// SIMPAN PERUBAHAN PRODUK
// ==================================================

document.addEventListener("submit", event => {
  if (event.target.id !== "editProductForm") return;

  event.preventDefault();

  const id = Number(event.target.dataset.id);

  const product = products.find(
    item => item.id === id
  );

  if (!product) return;

  const name = document.getElementById("editProductName").value.trim();

  const seller = document.getElementById("editProductSeller").value.trim();

  const category = document.getElementById("editProductCategory").value;

  const price = Number(document.getElementById("editProductPrice").value);

  const stock = Number(document.getElementById("editProductStock").value);

  if (
    !name ||
    !seller ||
    !category ||
    !Number.isSafeInteger(price) ||
    !Number.isSafeInteger(stock) ||
    price < 0 ||
    stock < 0
  ) {
    showToast("Periksa kembali data produk.");
    return;
  }

  product.name = name;
  product.seller = seller;
  product.category = category;
  product.price = price;
  product.stock = stock;

  addActivity(
    `Produk ${name} diperbarui`,
    `Harga: ${rupiah(price)} • Stok: ${stock} unit`
  );

  document.getElementById("productModal")?.remove();

  renderPage("products");

  showToast("Data produk berhasil diperbarui.");
});


// ==================================================
// SIMPAN STATUS PESANAN
// ==================================================

document.addEventListener("submit", event => {
  if (event.target.id !== "orderStatusForm") return;

  event.preventDefault();

  const orderId = event.target.dataset.id;

  const order = orders.find(item => item.id === orderId);

  if (!order) return;

  const newStatus =
    document.getElementById("newOrderStatus").value;

  if (!orderStatuses.includes(newStatus)) {
    showToast("Status pesanan tidak valid.");
    return;
  }

  const oldStatus = order.status;

  if (oldStatus === newStatus) {
    showToast("Status pesanan tidak mengalami perubahan.");
    return;
  }

  order.status = newStatus;

  addActivity(
    `Status pesanan ${order.id} diperbarui`,
    `${oldStatus} → ${newStatus}`
  );

  document.getElementById("orderModal")?.remove();

  renderPage("orders");

  showToast(
    `Status pesanan ${order.id} berhasil diubah menjadi ${newStatus}.`
  );
});

// ==================================================
// EKSPOR LAPORAN KE CSV
// ==================================================

function exportReport() {
  const rows = [
    [
      "Nomor Pesanan",
      "Pembeli",
      "Produk",
      "Total",
      "Tanggal",
      "Status"
    ],

    ...orders.map(order => [
      order.id,
      order.buyer,
      order.product,
      order.total,
      order.date,
      order.status
    ])
  ];

  const csv = rows
    .map(row =>
      row.map(value =>
        `"${String(value).replace(/"/g, '""')}"`
      ).join(",")
    )
    .join("\n");

  const blob = new Blob(
    ["\uFEFF" + csv],
    { type: "text/csv;charset=utf-8;" }
  );

  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");

  link.href = url;
  link.download = "laporan-penjualan-demo.csv";

  document.body.appendChild(link);
  link.click();
  link.remove();

  URL.revokeObjectURL(url);

  showToast("Laporan CSV berhasil dibuat.");
}

// ==================================================
// MENU MOBILE
// ==================================================

if (mobileMenu && sidebar) {
  mobileMenu.addEventListener("click", () => {
    sidebar.classList.toggle("open");
  });
}

// ==================================================
// LOGOUT
// ==================================================

if (logoutBtn) {
  logoutBtn.addEventListener("click", () => {
    const confirmed = confirm(
      "Apakah kamu yakin ingin keluar dari panel admin?"
    );

    if (!confirmed) return;

    showLogin();

    const emailInput = document.getElementById("adminEmail");
    const passwordInput = document.getElementById("adminPassword");

    if (emailInput) emailInput.value = "";
    if (passwordInput) passwordInput.value = "";

    showToast("Kamu telah keluar dari panel admin.");
  });
}


// ==================================================
// PUSAT KELUHAN - TAHAP 2E
// ==================================================

function renderComplaints() {

  const waiting = complaints.filter(
    item => item.status === "Menunggu"
  ).length;

  const processing = complaints.filter(
    item => item.status === "Diproses"
  ).length;

  const completed = complaints.filter(
    item => item.status === "Selesai"
  ).length;

  pageContent.innerHTML = `

    <!-- RINGKASAN KELUHAN -->

    <div class="stats-grid">

      ${statCard(
        "Total Keluhan",
        complaints.length,
        "!",
        "Seluruh laporan masuk"
      )}

      ${statCard(
        "Menunggu",
        waiting,
        "◷",
        "Belum ditangani"
      )}

      ${statCard(
        "Diproses",
        processing,
        "↻",
        "Sedang ditangani admin"
      )}

      ${statCard(
        "Selesai",
        completed,
        "✓",
        "Keluhan telah diselesaikan"
      )}

    </div>

    <!-- DAFTAR KELUHAN -->

    <section class="panel">

      <div class="panel-header">
        <div>
          <h2>Daftar Keluhan</h2>
          <p>
            Kelola laporan dari pembeli dan penjual.
          </p>
        </div>
      </div>

      <div class="complaint-toolbar">

        <input
          type="search"
          id="complaintSearch"
          class="search-input"
          placeholder="Cari nama atau jenis keluhan..."
        >

        <select
          id="complaintFilter"
          class="filter-select"
        >
          <option value="Semua">Semua Status</option>
          <option value="Menunggu">Menunggu</option>
          <option value="Diproses">Diproses</option>
          <option value="Selesai">Selesai</option>
        </select>

      </div>

      <div id="complaintTableResult">
        ${renderComplaintTable(complaints)}
      </div>

    </section>

    <div id="complaintModalContainer"></div>

  `;

  const search = document.getElementById(
    "complaintSearch"
  );

  const filter = document.getElementById(
    "complaintFilter"
  );

  function applyComplaintFilter() {

    const keyword = search.value.toLowerCase().trim();
    const selectedStatus = filter.value;

    const filtered = complaints.filter(item => {

      const matchKeyword =
        item.name.toLowerCase().includes(keyword) ||
        item.subject.toLowerCase().includes(keyword) ||
        item.role.toLowerCase().includes(keyword);

      const matchStatus =
        selectedStatus === "Semua" ||
        item.status === selectedStatus;

      return matchKeyword && matchStatus;
    });

    document.getElementById(
      "complaintTableResult"
    ).innerHTML = renderComplaintTable(filtered);
  }

  search.addEventListener("input", applyComplaintFilter);
  filter.addEventListener("change", applyComplaintFilter);

}


// ==================================================
// TABEL KELUHAN
// ==================================================

function renderComplaintTable(data) {

  return renderTable(
    [
      "Nama",
      "Jenis Pengguna",
      "Keluhan",
      "Tanggal",
      "Status",
      "Aksi"
    ],

    data.map(item => [

      escapeHTML(item.name),

      escapeHTML(item.role),

      escapeHTML(item.subject),

      escapeHTML(item.date),

      statusBadge(item.status),

      `
        <button
          class="btn btn-primary"
          data-action="view-complaint"
          data-id="${item.id}"
        >
          Detail
        </button>
      `
    ])
  );
}


// ==================================================
// DETAIL KELUHAN
// ==================================================

function openComplaintDetail(id) {

  const item = complaints.find(
    complaint => complaint.id === id
  );

  if (!item) return;

  const container = document.getElementById(
    "complaintModalContainer"
  );

  if (!container) return;

  container.innerHTML = `

    <div class="complaint-modal-overlay">

      <div class="complaint-modal">

        <div class="complaint-modal-header">

          <div>
            <h2>Detail Keluhan</h2>
            <p>Informasi laporan pengguna ED Management.</p>
          </div>

          <button
            type="button"
            class="complaint-close"
            data-action="close-complaint"
          >
            ×
          </button>

        </div>

        <div class="complaint-modal-body">

          <div class="complaint-detail-grid">

            <div class="complaint-detail-item">
              <span>Nama Pengguna</span>
              <strong>${escapeHTML(item.name)}</strong>
            </div>

            <div class="complaint-detail-item">
              <span>Jenis Pengguna</span>
              <strong>${escapeHTML(item.role)}</strong>
            </div>

            <div class="complaint-detail-item">
              <span>Tanggal Laporan</span>
              <strong>${escapeHTML(item.date)}</strong>
            </div>

            <div class="complaint-detail-item">
              <span>Status Keluhan</span>
              <strong>${statusBadge(item.status)}</strong>
            </div>

          </div>

          <div class="complaint-message-box">

            <span>Judul Keluhan</span>
            <strong>${escapeHTML(item.subject)}</strong>

            <span>Isi Keluhan</span>
            <p>${escapeHTML(item.message)}</p>

          </div>

          <div class="complaint-response">

            <label for="complaintStatus">
              Status Penanganan
            </label>

            <select id="complaintStatus">

              <option value="Menunggu"
                ${item.status === "Menunggu" ? "selected" : ""}>
                Menunggu
              </option>

              <option value="Diproses"
                ${item.status === "Diproses" ? "selected" : ""}>
                Diproses
              </option>

              <option value="Selesai"
                ${item.status === "Selesai" ? "selected" : ""}>
                Selesai
              </option>

            </select>

            <label for="complaintReply">
              Tanggapan Administrator
            </label>

            <textarea
              id="complaintReply"
              rows="4"
              placeholder="Tuliskan tanggapan admin..."
            >${escapeHTML(item.reply || "")}</textarea>

          </div>

        </div>

        <div class="complaint-modal-footer">

          <button
            class="btn btn-light"
            data-action="close-complaint"
          >
            Tutup
          </button>

          <button
            class="btn btn-primary"
            data-action="save-complaint"
            data-id="${item.id}"
          >
            Simpan Perubahan
          </button>

        </div>

      </div>

    </div>

  `;
}


//==================================================
// PENGATURAN ADMIN
//==================================================
function renderSettings() {
  const adminNameValue =
    localStorage.getItem("adminName") || "Administrator";

  const adminEmailValue =
    localStorage.getItem("adminEmail") || DEMO_EMAIL;

  const notifications = {
    orders: localStorage.getItem("adminNotifyOrders") !== "false",
    sellers: localStorage.getItem("adminNotifySellers") !== "false",
    products: localStorage.getItem("adminNotifyProducts") !== "false",
    complaints: localStorage.getItem("adminNotifyComplaints") !== "false"
  };

  pageContent.innerHTML = `
    <div class="settings-container">

      <!-- PROFIL ADMINISTRATOR -->
      <section class="panel settings-section">

        <div class="panel-header">
          <div>
            <h2>Profil Administrator</h2>
            <p>Informasi akun administrator ED Management.</p>
          </div>
        </div>

        <form id="adminSettingsForm" class="settings-form">

          <div class="settings-field">
            <label for="settingsName">Nama Administrator</label>
            <input
              type="text"
              id="settingsName"
              value="${escapeHTML(adminNameValue)}"
              required
            >
          </div>

          <div class="settings-field">
            <label for="settingsEmail">Email Administrator</label>
            <input
              type="email"
              id="settingsEmail"
              value="${escapeHTML(adminEmailValue)}"
              required
            >
          </div>

          <button class="btn btn-primary" type="submit">
            Simpan Perubahan
          </button>

        </form>
      </section>


      <!-- KEAMANAN AKUN -->
      <section class="panel settings-section">

        <div class="panel-header">
          <div>
            <h2>Keamanan Akun</h2>
            <p>Kelola keamanan akun administrator.</p>
          </div>
        </div>

        <form id="adminPasswordForm" class="settings-form">

          <div class="settings-field">
            <label for="newAdminPassword">Password Baru</label>
            <input
              type="password"
              id="newAdminPassword"
              placeholder="Masukkan password baru"
              minlength="8"
              required
            >
          </div>

          <div class="settings-field">
            <label for="confirmAdminPassword">
              Konfirmasi Password Baru
            </label>
            <input
              type="password"
              id="confirmAdminPassword"
              placeholder="Ulangi password baru"
              minlength="8"
              required
            >
          </div>

          <button class="btn btn-primary" type="submit">
            Ubah Password
          </button>

          <p class="settings-info">
            Password minimal terdiri dari 8 karakter.
          </p>

        </form>
      </section>


      <!-- PENGATURAN NOTIFIKASI -->
      <section class="panel settings-section">

        <div class="panel-header">
          <div>
            <h2>Pengaturan Notifikasi</h2>
            <p>Atur pemberitahuan yang diterima administrator.</p>
          </div>
        </div>

        <div class="notification-settings">

          <div class="notification-item">
            <div>
              <strong>Notifikasi Pesanan</strong>
              <p>Pemberitahuan ketika terdapat pesanan baru.</p>
            </div>

            <label class="settings-switch">
              <input
                type="checkbox"
                id="notifyOrders"
                ${notifications.orders ? "checked" : ""}
              >
              <span class="settings-slider"></span>
            </label>
          </div>

          <div class="notification-item">
            <div>
              <strong>Notifikasi Penjual</strong>
              <p>Pemberitahuan pendaftaran penjual baru.</p>
            </div>

            <label class="settings-switch">
              <input
                type="checkbox"
                id="notifySellers"
                ${notifications.sellers ? "checked" : ""}
              >
              <span class="settings-slider"></span>
            </label>
          </div>

          <div class="notification-item">
            <div>
              <strong>Notifikasi Produk</strong>
              <p>Pemberitahuan perubahan dan penambahan produk.</p>
            </div>

            <label class="settings-switch">
              <input
                type="checkbox"
                id="notifyProducts"
                ${notifications.products ? "checked" : ""}
              >
              <span class="settings-slider"></span>
            </label>
          </div>

          <div class="notification-item">
            <div>
              <strong>Notifikasi Keluhan</strong>
              <p>Pemberitahuan laporan dan keluhan pengguna.</p>
            </div>

            <label class="settings-switch">
              <input
                type="checkbox"
                id="notifyComplaints"
                ${notifications.complaints ? "checked" : ""}
              >
              <span class="settings-slider"></span>
            </label>
          </div>

        </div>

        <div class="settings-save">
          <button
            class="btn btn-primary"
            type="button"
            id="saveNotifications"
          >
            Simpan Pengaturan
          </button>
        </div>

      </section>

    </div>
  `;


  // SIMPAN PROFIL ADMIN
  document.getElementById("adminSettingsForm")
    .addEventListener("submit", function(event) {

      event.preventDefault();

      const name = document.getElementById("settingsName")
        .value.trim();

      const email = document.getElementById("settingsEmail")
        .value.trim();

      if (!name || !email) {
        showToast("Nama dan email wajib diisi.");
        return;
      }

      localStorage.setItem("adminName", name);
      localStorage.setItem("adminEmail", email);

      if (adminName) {
        adminName.textContent = name;
      }

      if (adminEmailLabel) {
        adminEmailLabel.textContent = email;
      }

      showToast("Profil administrator berhasil diperbarui.");
    });


  // UBAH PASSWORD ADMIN (MODE DEMO)
  document.getElementById("adminPasswordForm")
    .addEventListener("submit", function(event) {

      event.preventDefault();

      const password = document.getElementById("newAdminPassword")
        .value;

      const confirmPassword = document.getElementById("confirmAdminPassword")
        .value;

      if (password.length < 8) {
        showToast("Password minimal 8 karakter.");
        return;
      }

      if (password !== confirmPassword) {
        showToast("Konfirmasi password tidak sesuai.");
        return;
      }

      // Penyimpanan khusus prototipe frontend.
      localStorage.setItem("adminDemoPassword", password);

      document.getElementById("adminPasswordForm").reset();

      showToast("Password demo berhasil diperbarui.");
    });


  // SIMPAN NOTIFIKASI
  document.getElementById("saveNotifications")
    .addEventListener("click", function() {

      localStorage.setItem(
        "adminNotifyOrders",
        document.getElementById("notifyOrders").checked
      );

      localStorage.setItem(
        "adminNotifySellers",
        document.getElementById("notifySellers").checked
      );

      localStorage.setItem(
        "adminNotifyProducts",
        document.getElementById("notifyProducts").checked
      );

      localStorage.setItem(
        "adminNotifyComplaints",
        document.getElementById("notifyComplaints").checked
      );

      showToast("Pengaturan notifikasi berhasil disimpan.");
    });

}


// ==================================================
// INISIALISASI
// ==================================================

if (currentDate) {
  currentDate.textContent = formatDateNow();
}

updateApprovalBadge();
showLogin();

console.log("Admin ED Management berjalan dalam mode demo.");

// =========================================
// PUSAT NOTIFIKASI ADMIN - DATA DEMO
// =========================================

const adminNotifications = [
  {
    id: 1,
    type: "seller",
    avatar: "KB",
    title: "Pendaftaran Penjual Baru",
    message: "Toko Kopi Budi sedang menunggu persetujuan admin.",
    time: "Baru saja",
    read: false
  },
  {
    id: 2,
    type: "order",
    avatar: "RA",
    title: "Pesanan Baru",
    message: "Rina Amelia melakukan pemesanan produk marketplace.",
    time: "10 menit lalu",
    read: false
  },
  {
    id: 3,
    type: "product",
    avatar: "KR",
    title: "Produk Baru Ditambahkan",
    message: "Keripik Rahma menambahkan produk baru.",
    time: "30 menit lalu",
    read: false
  }
];

const notificationButton =
  document.getElementById("notificationButton");

const notificationPanel =
  document.getElementById("notificationPanel");

const notificationCount =
  document.getElementById("notificationCount");

const notificationList =
  document.getElementById("notificationList");

const markAllReadButton =
  document.getElementById("markAllRead");

const notificationTabs =
  document.querySelectorAll(".notification-tab");

const notificationTabCount =
  document.getElementById("notificationTabCount");

let activeNotificationFilter = "all";

// =========================================
// MENGHITUNG NOTIFIKASI BELUM DIBACA
// =========================================

function updateNotificationCount() {
  const unreadCount = adminNotifications.filter(
    notification => !notification.read
  ).length;

  if (notificationCount) {
    notificationCount.textContent =
      unreadCount > 0 ? unreadCount : "";

    notificationCount.classList.toggle(
      "zero",
      unreadCount === 0
    );
  }

  if (notificationTabCount) {
    notificationTabCount.textContent = unreadCount;
    notificationTabCount.style.display =
      unreadCount > 0 ? "inline-flex" : "none";
  }
}

// =========================================
// MENAMPILKAN NOTIFIKASI
// =========================================

function renderNotifications() {
  if (!notificationList) return;

  const filteredNotifications =
    activeNotificationFilter === "all"
      ? adminNotifications
      : adminNotifications.filter(
          notification =>
            notification.type === activeNotificationFilter
        );

  notificationList.innerHTML = "";

  if (filteredNotifications.length === 0) {
    notificationList.innerHTML = `
      <div class="notification-empty">
        Belum ada notifikasi pada kategori ini.
      </div>
    `;

    updateNotificationCount();
    return;
  }

  filteredNotifications.forEach(notification => {
    const item = document.createElement("div");

    item.className =
      `notification-item ${notification.read ? "" : "unread"}`;

    item.dataset.notificationId = notification.id;

    item.innerHTML = `
      <div class="notification-avatar ${notification.type}">
        ${escapeHTML(notification.avatar)}
      </div>

      <div class="notification-content">
        <strong>${escapeHTML(notification.title)}</strong>
        <p>${escapeHTML(notification.message)}</p>
        <small>${escapeHTML(notification.time)}</small>
      </div>

      ${
        notification.read
          ? ""
          : '<span class="notification-unread-dot"></span>'
      }
    `;

    notificationList.appendChild(item);
  });

  updateNotificationCount();
}

// =========================================
// FILTER TAB NOTIFIKASI
// =========================================

notificationTabs.forEach(tab => {
  tab.addEventListener("click", function () {
    activeNotificationFilter = this.dataset.filter;

    notificationTabs.forEach(item => {
      item.classList.remove("active");
    });

    this.classList.add("active");

    renderNotifications();
  });
});

// =========================================
// BUKA DAN TUTUP PANEL
// =========================================

if (notificationButton && notificationPanel) {
  notificationButton.addEventListener("click", function (event) {
    event.stopPropagation();

    notificationPanel.hidden = !notificationPanel.hidden;

    notificationButton.setAttribute(
      "aria-expanded",
      String(!notificationPanel.hidden)
    );
  });

  notificationPanel.addEventListener("click", function (event) {
    event.stopPropagation();
  });

  document.addEventListener("click", function () {
    notificationPanel.hidden = true;

    notificationButton.setAttribute(
      "aria-expanded",
      "false"
    );
  });
}

// =========================================
// MENANDAI SATU NOTIFIKASI SUDAH DIBACA
// =========================================

if (notificationList) {
  notificationList.addEventListener("click", function (event) {
    const item = event.target.closest(".notification-item");

    if (!item) return;

    const id = Number(item.dataset.notificationId);

    const selectedNotification = adminNotifications.find(
      notification => notification.id === id
    );

    if (selectedNotification) {
      selectedNotification.read = true;
      renderNotifications();
    }
  });
}

// =========================================
// MENANDAI SEMUA NOTIFIKASI SUDAH DIBACA
// =========================================

if (markAllReadButton) {
  markAllReadButton.addEventListener("click", function () {
    adminNotifications.forEach(notification => {
      notification.read = true;
    });

    renderNotifications();

    if (typeof showToast === "function") {
      showToast("Semua notifikasi sudah dibaca.");
    }
  });
}

// =========================================
// TAMPILKAN NOTIFIKASI PERTAMA KALI
// =========================================

renderNotifications();