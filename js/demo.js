/* Inbox Critters — interactive web demo */
(function () {
  'use strict';

  const MAX_ORBS = 8;
  const CRITTER_INTERVAL_MS = 8000;
  const CRITTER_TRAVEL_MS   = 4000;
  const ORB_COLORS = [
    '#fde68a','#bbf7d0','#bfdbfe','#fecaca',
    '#e9d5ff','#fed7aa','#a7f3d0','#fbcfe8'
  ];

  let orbs        = [];
  let nextId      = 0;
  let stolenCount = 0;
  let critterTimer = null;

  // DOM refs (populated in init)
  let section, mindZone, bucketsEl, inputEl, addBtn,
      summaryEl, toastEl, critterEl;

  /* ── bootstrap ─────────────────────────────────────────── */

  function init() {
    section    = document.getElementById('try');
    if (!section) return;
    mindZone   = section.querySelector('.demo-mind-zone');
    bucketsEl  = section.querySelector('.demo-buckets');
    inputEl    = section.querySelector('.demo-input');
    addBtn     = section.querySelector('.demo-add-btn');
    summaryEl  = section.querySelector('.demo-summary');
    toastEl    = section.querySelector('.demo-toast');
    critterEl  = section.querySelector('.demo-critter');

    addBtn.addEventListener('click', handleAdd);
    inputEl.addEventListener('keydown', e => {
      if (e.key === 'Enter') { e.preventDefault(); handleAdd(); }
    });

    startCritterTimer();
    updateStatus();
  }

  function startCritterTimer() {
    clearInterval(critterTimer);
    critterTimer = setInterval(launchCritter, CRITTER_INTERVAL_MS);
  }

  /* ── orb creation ───────────────────────────────────────── */

  function handleAdd() {
    const text = inputEl.value.trim();
    if (!text) return;
    if (orbs.length >= MAX_ORBS) { showToast('Max 8 thoughts!'); return; }
    inputEl.value = '';
    inputEl.focus();
    createOrb(text);
  }

  function createOrb(text) {
    const id  = nextId++;
    const el  = document.createElement('div');
    el.className      = 'demo-orb';
    el.dataset.id     = String(id);
    el.textContent    = text;
    el.style.background     = ORB_COLORS[id % ORB_COLORS.length];
    el.style.left           = (8  + Math.random() * 72).toFixed(1) + '%';
    el.style.top            = (8  + Math.random() * 58).toFixed(1) + '%';
    el.style.animationDelay = (Math.random() * 2).toFixed(2) + 's';
    mindZone.appendChild(el);
    setupDrag(el);
    orbs.push({ id, el, sorted: false, stolen: false });
    updateStatus();
  }

  /* ── drag (Pointer Events API) ──────────────────────────── */

  function setupDrag(el) {
    let dragging = false, offsetX = 0, offsetY = 0;

    el.addEventListener('pointerdown', e => {
      const orb = orbById(parseInt(el.dataset.id, 10));
      if (!orb || orb.sorted || orb.stolen) return;
      e.preventDefault();
      el.setPointerCapture(e.pointerId);
      dragging = true;

      const r = el.getBoundingClientRect();
      offsetX = e.clientX - r.left;
      offsetY = e.clientY - r.top;

      // Switch to fixed so orb can be dragged outside mindZone
      el.style.width    = r.width + 'px';
      el.style.position = 'fixed';
      el.style.left     = r.left + 'px';
      el.style.top      = r.top  + 'px';
      el.style.animation = 'none';
      el.style.zIndex   = '1000';
      el.classList.add('orb-dragging');
    });

    el.addEventListener('pointermove', e => {
      if (!dragging) return;
      el.style.left = (e.clientX - offsetX) + 'px';
      el.style.top  = (e.clientY - offsetY) + 'px';
    });

    el.addEventListener('pointerup', e => {
      if (!dragging) return;
      dragging = false;
      el.classList.remove('orb-dragging');
      el.style.zIndex = '';
      el.style.width  = '';

      const bucket = getBucketAt(e.clientX, e.clientY);
      if (bucket) {
        dropOrbIntoBucket(el, bucket);
      } else {
        // Snap back to absolute position inside mindZone
        const mzRect = mindZone.getBoundingClientRect();
        const elRect = el.getBoundingClientRect();
        el.style.position = 'absolute';
        el.style.left     = (elRect.left - mzRect.left) + 'px';
        el.style.top      = (elRect.top  - mzRect.top)  + 'px';
        el.style.animation = '';
      }
    });
  }

  function orbById(id) {
    return orbs.find(o => o.id === id);
  }

  function getBucketAt(x, y) {
    const buckets = bucketsEl.querySelectorAll('.demo-bucket');
    for (const b of buckets) {
      const r = b.getBoundingClientRect();
      if (x >= r.left && x <= r.right && y >= r.top && y <= r.bottom) return b;
    }
    return null;
  }

  /* ── drop into bucket ───────────────────────────────────── */

  function dropOrbIntoBucket(el, bucket) {
    const orb = orbById(parseInt(el.dataset.id, 10));
    if (!orb || orb.sorted) return;
    orb.sorted = true;

    const badge = bucket.querySelector('.demo-bucket-badge');
    badge.textContent = String(parseInt(badge.textContent, 10) + 1);
    badge.classList.add('bump');
    setTimeout(() => badge.classList.remove('bump'), 300);

    bucket.classList.add('bucket-flash');
    setTimeout(() => bucket.classList.remove('bucket-flash'), 400);

    // Remove positioning overrides, then animate out
    el.style.position  = '';
    el.style.left      = '';
    el.style.top       = '';
    el.style.animation = '';
    el.classList.add('orb-snapping');
    setTimeout(() => el.remove(), 400);

    updateStatus();
    checkComplete();
  }

  /* ── critter ────────────────────────────────────────────── */

  function launchCritter() {
    const unsorted = orbs.filter(o => !o.sorted && !o.stolen);
    if (unsorted.length === 0) return;

    // Force animation restart via reflow
    critterEl.classList.remove('critter-run');
    void critterEl.offsetWidth;
    critterEl.classList.add('critter-run');

    setTimeout(() => {
      critterEl.classList.remove('critter-run');
      const targets = orbs.filter(o => !o.sorted && !o.stolen);
      if (targets.length > 0) {
        stealOrb(targets[Math.floor(Math.random() * targets.length)]);
      }
    }, CRITTER_TRAVEL_MS);
  }

  function stealOrb(orb) {
    orb.stolen = true;
    stolenCount++;
    orb.el.classList.add('orb-vanishing');
    setTimeout(() => orb.el.remove(), 1200);
    showToast('🐛 Critter stole a thought!');
    updateStatus();
    checkComplete();
  }

  /* ── toast ──────────────────────────────────────────────── */

  function showToast(msg) {
    toastEl.textContent = msg;
    toastEl.classList.add('toast-show');
    setTimeout(() => toastEl.classList.remove('toast-show'), 2500);
  }

  /* ── status / completion ────────────────────────────────── */

  function updateStatus() {
    const countEl = section.querySelector('.demo-orb-count');
    if (!countEl) return;
    const n = orbs.filter(o => !o.sorted && !o.stolen).length;
    countEl.textContent = n === 1 ? '1 orb floating' : n + ' orbs floating';
  }

  function checkComplete() {
    if (orbs.length === 0) return;
    const remaining = orbs.filter(o => !o.sorted && !o.stolen);
    if (remaining.length > 0) return;
    clearInterval(critterTimer);
    setTimeout(showSummary, 700);
  }

  function showSummary() {
    const buckets = bucketsEl.querySelectorAll('.demo-bucket');
    const lines = [];
    buckets.forEach(b => {
      const label = b.querySelector('.demo-bucket-label').textContent;
      const count = parseInt(b.querySelector('.demo-bucket-badge').textContent, 10);
      if (count > 0) lines.push(`${label}: ${count}`);
    });

    summaryEl.innerHTML = `
      <div class="demo-summary-inner">
        <div class="demo-summary-emoji">🎉</div>
        <h3>Brain dumped!</h3>
        ${lines.length ? `<p class="summary-counts">${lines.join(' &nbsp;·&nbsp; ')}</p>` : ''}
        ${stolenCount > 0 ? `<p class="stolen-note">🐛 ${stolenCount} thought${stolenCount > 1 ? 's' : ''} stolen by critters</p>` : ''}
        <button class="btn btn-secondary demo-reset-btn" style="margin-top:16px">Try Again</button>
      </div>`;
    summaryEl.classList.add('summary-show');
    summaryEl.querySelector('.demo-reset-btn').addEventListener('click', resetDemo);
  }

  function resetDemo() {
    orbs        = [];
    nextId      = 0;
    stolenCount = 0;

    mindZone.querySelectorAll('.demo-orb').forEach(el => el.remove());
    bucketsEl.querySelectorAll('.demo-bucket-badge').forEach(b => { b.textContent = '0'; });

    summaryEl.classList.remove('summary-show');
    summaryEl.innerHTML = '';

    startCritterTimer();
    updateStatus();
    inputEl.focus();
  }

  document.addEventListener('DOMContentLoaded', init);
}());
