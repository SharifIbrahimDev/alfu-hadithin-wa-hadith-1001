// 1001 Authentic Hadith Mobile Application Logic
// Author & Compiler: Ibrahim Sharif Abubakar

let hadithsData = [];
let chaptersData = [];
let bookmarks = new Set(JSON.parse(localStorage.getItem('hadith_bookmarks') || '[]'));
let currentHadithIndex = 0;
let currentChapterId = 0;
let currentView = 'home';
let viewHistory = ['home'];

// DOM Elements
const views = {
  home: document.getElementById('view-home'),
  chapter: document.getElementById('view-chapter'),
  reader: document.getElementById('view-reader'),
  search: document.getElementById('view-search'),
  bookmarks: document.getElementById('view-bookmarks'),
  about: document.getElementById('view-about')
};

const btnBack = document.getElementById('btn-back');
const headerMainTitle = document.getElementById('header-main-title');
const headerSubTitle = document.getElementById('header-sub-title');
const navButtons = document.querySelectorAll('.nav-item');
const toastBox = document.getElementById('toast-box');

// Initialize App
async function initApp() {
  if (window.BUNDLED_HADITHS && window.BUNDLED_HADITHS.length > 0) {
    hadithsData = window.BUNDLED_HADITHS;
    chaptersData = (window.BUNDLED_CHAPTERS && window.BUNDLED_CHAPTERS.chapters) ? window.BUNDLED_CHAPTERS.chapters : [];
  } else {
    try {
      const [hRes, cRes] = await Promise.all([
        fetch('./data/hadiths.json'),
        fetch('./data/chapters.json')
      ]);
      hadithsData = await hRes.json();
      const cJson = await cRes.json();
      chaptersData = cJson.chapters || [];
    } catch (err) {
      console.error("Error loading JSON dataset:", err);
    }
  }

  setupEventListeners();
  loadSavedSettings();
  renderChaptersList();
  renderDailyHadith();
  renderBookmarks();
  renderSearchResults('');
}

// Navigation & View Routing
function navigateTo(viewName, addToHistory = true) {
  if (viewName === currentView) return;

  if (addToHistory) {
    viewHistory.push(viewName);
  }

  currentView = viewName;
  Object.keys(views).forEach(v => {
    views[v].classList.toggle('active', v === viewName);
  });

  // Update Header
  btnBack.style.display = viewHistory.length > 1 ? 'flex' : 'none';

  if (viewName === 'home') {
    headerMainTitle.textContent = '1001 Hadith';
    headerSubTitle.textContent = 'Ibrahim Sharif Abubakar';
  } else if (viewName === 'chapter') {
    const chap = chaptersData.find(c => c.id === currentChapterId);
    headerMainTitle.textContent = chap ? `Chapter ${chap.id}` : 'Chapter';
    headerSubTitle.textContent = chap ? chap.english_title : '';
  } else if (viewName === 'reader') {
    const h = hadithsData[currentHadithIndex];
    headerMainTitle.textContent = h ? h.id_str : 'Hadith';
    headerSubTitle.textContent = h ? h.chapter_title_en : '';
  } else if (viewName === 'search') {
    headerMainTitle.textContent = 'Search 1001 Hadiths';
    headerSubTitle.textContent = 'Instant Arabic & English Search';
  } else if (viewName === 'bookmarks') {
    headerMainTitle.textContent = 'Bookmarks';
    headerSubTitle.textContent = `${bookmarks.size} Saved Hadiths`;
  } else if (viewName === 'about') {
    headerMainTitle.textContent = 'About Compendium';
    headerSubTitle.textContent = 'Ibrahim Sharif Abubakar';
  }

  // Update Bottom Nav
  navButtons.forEach(btn => {
    btn.classList.toggle('active', btn.getAttribute('data-view') === viewName);
  });

  window.scrollTo({ top: 0, behavior: 'smooth' });
}

function goBack() {
  if (viewHistory.length > 1) {
    viewHistory.pop();
    const prevView = viewHistory[viewHistory.length - 1];
    navigateTo(prevView, false);
  } else {
    navigateTo('home', false);
  }
}

// Render Chapters List on Home View
function renderChaptersList() {
  const container = document.getElementById('chapter-list-container');
  if (!container) return;

  container.innerHTML = chaptersData.map(c => `
    <div class="chapter-card" onclick="openChapter(${c.id})">
      <div class="chapter-num-badge">${c.id}</div>
      <div class="chapter-card-content">
        <div class="chapter-arabic-name">${c.arabic_title}</div>
        <div class="chapter-english-name">${c.english_title}</div>
        <div class="chapter-meta">
          <span>${c.hadith_count} Hadiths</span>
          <span>•</span>
          <span>#${String(c.start_id).padStart(4, '0')} – #${String(c.end_id).padStart(4, '0')}</span>
        </div>
      </div>
      <div class="chapter-arrow">›</div>
    </div>
  `).join('');
}

// Render Featured Daily Hadith
function renderDailyHadith() {
  if (!hadithsData.length) return;
  const now = new Date();
  const dayOfYear = Math.floor((now - new Date(now.getFullYear(), 0, 0)) / 1000 / 60 / 60 / 24);
  const dailyIndex = dayOfYear % hadithsData.length;
  const daily = hadithsData[dailyIndex];

  document.getElementById('daily-arabic').textContent = daily.arabic_matn.slice(0, 140) + '...';
  document.getElementById('daily-english').textContent = `"${daily.english_translation.slice(0, 160)}..."`;
  document.getElementById('daily-id-tag').textContent = daily.id_str;

  document.getElementById('daily-hero').onclick = () => openHadithById(daily.id);
}

// Open Specific Chapter
window.openChapter = function(chapterId) {
  currentChapterId = chapterId;
  const chap = chaptersData.find(c => c.id === chapterId);
  if (!chap) return;

  document.getElementById('chapter-view-title-en').textContent = chap.english_title;
  document.getElementById('chapter-view-title-ar').textContent = chap.arabic_title;
  document.getElementById('chapter-view-count').textContent = `${chap.hadith_count} Hadiths`;

  const chapterHadiths = hadithsData.filter(h => h.chapter_id === chapterId);
  const container = document.getElementById('chapter-hadiths-container');

  container.innerHTML = chapterHadiths.map(h => `
    <div class="chapter-card" onclick="openHadithById(${h.id})">
      <div class="chapter-num-badge">${h.id}</div>
      <div class="chapter-card-content">
        <div class="chapter-arabic-name" style="font-size: 1.05rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
          ${h.topic_ar || h.arabic_matn.slice(0, 45)}
        </div>
        <div class="chapter-english-name" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
          ${h.topic_en || h.english_translation.slice(0, 50)}
        </div>
        <div class="chapter-meta">
          <span>${h.narrator_en || h.narrator_ar || 'Companion'}</span>
          <span>•</span>
          <span style="color: #10b981;">${h.grading || 'Sahih'}</span>
        </div>
      </div>
      <div class="chapter-arrow">›</div>
    </div>
  `).join('');

  navigateTo('chapter');
};

// Open Specific Hadith Reader
window.openHadithById = function(hadithId) {
  const idx = hadithsData.findIndex(h => h.id === hadithId);
  if (idx !== -1) {
    currentHadithIndex = idx;
    renderReaderView();
    navigateTo('reader');
  }
};

// Render Reader View
function renderReaderView() {
  const h = hadithsData[currentHadithIndex];
  if (!h) return;

  document.getElementById('reader-hadith-id').textContent = h.id_str;
  
  // 🇸🇦 Arabic Section
  document.getElementById('reader-arabic-topic').textContent = h.topic_ar ? `[الباب: ${h.topic_ar}]` : '';
  document.getElementById('reader-arabic-matn').textContent = h.arabic_matn;
  document.getElementById('reader-arabic-narrator').textContent = h.narrator_ar ? `الراوي: ${h.narrator_ar}` : '';
  document.getElementById('reader-arabic-takhrij').textContent = h.takhrij ? `التخريج: ${h.takhrij}` : '';
  document.getElementById('reader-arabic-benefits').textContent = h.benefits_ar ? `الفوائد: ${h.benefits_ar}` : '';

  // 🇬🇧 English Section
  document.getElementById('reader-english-topic').textContent = h.topic_en || 'AUTHENTIC PROPHETIC TRADITION';
  document.getElementById('reader-english-translation').textContent = `"${h.english_translation}"`;
  document.getElementById('reader-english-narrator').textContent = h.narrator_en || h.narrator_ar || 'Companion Narrator';
  document.getElementById('reader-english-ref').textContent = h.takhrij || 'Canonical Collections';
  document.getElementById('reader-english-grading').textContent = h.grading || 'Sahih (Authentic)';

  const benBox = document.getElementById('reader-english-benefits-box');
  if (h.benefits_en) {
    benBox.style.display = 'flex';
    document.getElementById('reader-english-benefits').textContent = h.benefits_en;
  } else {
    benBox.style.display = 'none';
  }

  // Update Bookmark Icon
  updateBookmarkIcon();

  // Update Nav Buttons
  document.getElementById('btn-prev-hadith').disabled = currentHadithIndex === 0;
  document.getElementById('btn-next-hadith').disabled = currentHadithIndex === hadithsData.length - 1;
}

// Next & Previous Hadith
function nextHadith() {
  if (currentHadithIndex < hadithsData.length - 1) {
    currentHadithIndex++;
    renderReaderView();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
}

function prevHadith() {
  if (currentHadithIndex > 0) {
    currentHadithIndex--;
    renderReaderView();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
}

// Arabic Text Normalizer for accurate instant search
function normalizeArabic(text) {
  if (!text) return '';
  return text
    .replace(/[\u064B-\u065F\u0670]/g, '') // Remove Tashkeel diacritics
    .replace(/[أإآ]/g, 'ا')
    .replace(/ة/g, 'ه')
    .replace(/ى/g, 'ي')
    .toLowerCase();
}

// Search Engine across all 1001 Hadiths
function renderSearchResults(query) {
  const container = document.getElementById('search-results-container');
  const countEl = document.getElementById('search-result-count');
  const titleEl = document.getElementById('search-status-title');
  if (!container) return;

  const rawQ = query.trim();
  const normQ = normalizeArabic(rawQ);

  let results = hadithsData;
  if (rawQ) {
    results = hadithsData.filter(h => {
      const matchId = String(h.id) === rawQ || h.id_str.toLowerCase().includes(rawQ.toLowerCase());
      const matchEng = (h.english_translation && h.english_translation.toLowerCase().includes(rawQ.toLowerCase())) ||
                       (h.topic_en && h.topic_en.toLowerCase().includes(rawQ.toLowerCase())) ||
                       (h.narrator_en && h.narrator_en.toLowerCase().includes(rawQ.toLowerCase()));
      const normMatn = normalizeArabic(h.arabic_matn);
      const normTopicAr = normalizeArabic(h.topic_ar);
      const matchAr = normMatn.includes(normQ) || normTopicAr.includes(normQ);

      return matchId || matchEng || matchAr;
    });
    titleEl.textContent = `Search: "${rawQ}"`;
  } else {
    titleEl.textContent = "Browse 1001 Hadiths";
  }

  countEl.textContent = `${results.length} Found`;

  container.innerHTML = results.slice(0, 100).map(h => `
    <div class="chapter-card" onclick="openHadithById(${h.id})">
      <div class="chapter-num-badge">${h.id}</div>
      <div class="chapter-card-content">
        <div class="chapter-arabic-name" style="font-size: 1.05rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
          ${h.topic_ar || h.arabic_matn.slice(0, 45)}
        </div>
        <div class="chapter-english-name" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
          ${h.topic_en || h.english_translation.slice(0, 50)}
        </div>
        <div class="chapter-meta">
          <span>${h.chapter_title_en}</span>
          <span>•</span>
          <span style="color: #10b981;">${h.grading || 'Sahih'}</span>
        </div>
      </div>
      <div class="chapter-arrow">›</div>
    </div>
  `).join('');
}

// Bookmarking System
function toggleBookmark() {
  const h = hadithsData[currentHadithIndex];
  if (!h) return;

  if (bookmarks.has(h.id)) {
    bookmarks.delete(h.id);
    showToast("Removed from bookmarks");
  } else {
    bookmarks.add(h.id);
    showToast("Saved to bookmarks ⭐");
  }

  localStorage.setItem('hadith_bookmarks', JSON.stringify(Array.from(bookmarks)));
  updateBookmarkIcon();
  renderBookmarks();
}

function updateBookmarkIcon() {
  const h = hadithsData[currentHadithIndex];
  const icon = document.getElementById('bookmark-icon');
  if (h && bookmarks.has(h.id)) {
    icon.setAttribute('fill', 'var(--gold-accent)');
    icon.setAttribute('stroke', 'var(--gold-accent)');
  } else {
    icon.setAttribute('fill', 'none');
    icon.setAttribute('stroke', 'currentColor');
  }
}

function renderBookmarks() {
  const container = document.getElementById('bookmarks-container');
  const countEl = document.getElementById('bookmarks-count');
  if (!container) return;

  const savedList = hadithsData.filter(h => bookmarks.has(h.id));
  countEl.textContent = `${savedList.length} Saved`;

  if (savedList.length === 0) {
    container.innerHTML = `
      <div style="text-align: center; padding: 40px 20px; color: var(--text-muted);">
        <div style="font-size: 2.5rem; margin-bottom: 8px;">📑</div>
        <div style="font-size: 1.05rem; font-weight: 700; color: var(--text-secondary);">No Bookmarks Yet</div>
        <p style="font-size: 0.85rem; margin-top: 4px;">Tap the bookmark icon on any Hadith while reading to save it here.</p>
      </div>
    `;
    return;
  }

  container.innerHTML = savedList.map(h => `
    <div class="chapter-card" onclick="openHadithById(${h.id})">
      <div class="chapter-num-badge" style="border-color: var(--gold-accent); color: var(--gold-accent);">${h.id}</div>
      <div class="chapter-card-content">
        <div class="chapter-arabic-name" style="font-size: 1.05rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
          ${h.topic_ar || h.arabic_matn.slice(0, 45)}
        </div>
        <div class="chapter-english-name" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
          ${h.topic_en || h.english_translation.slice(0, 50)}
        </div>
        <div class="chapter-meta">
          <span>${h.chapter_title_en}</span>
        </div>
      </div>
      <div class="chapter-arrow">›</div>
    </div>
  `).join('');
}

// Copy Hadith Card
function copyHadith() {
  const h = hadithsData[currentHadithIndex];
  if (!h) return;

  const text = `✨ 1001 Authentic Hadith — ${h.id_str}\nAuthor & Compiler: Ibrahim Sharif Abubakar\n\n🇸🇦 [الباب: ${h.topic_ar || ''}]\n${h.arabic_matn}\nالراوي: ${h.narrator_ar || ''}\n\n🇬🇧 [${h.topic_en || ''}]\n"${h.english_translation}"\nCompanion Narrator: ${h.narrator_en || h.narrator_ar || ''}\nReference: ${h.takhrij || ''}\nGrading: ${h.grading || 'Sahih'}\n\n📖 Read more: https://github.com/SharifIbrahimDev/alfu-hadithin-wa-hadith-1001`;

  if (navigator.clipboard) {
    navigator.clipboard.writeText(text).then(() => showToast("Hadith copied to clipboard! 📋"));
  } else {
    showToast("Hadith copied!");
  }
}

// Share Hadith
function shareHadith() {
  const h = hadithsData[currentHadithIndex];
  if (!h) return;

  const shareData = {
    title: `1001 Hadith ${h.id_str} — Ibrahim Sharif Abubakar`,
    text: `"${h.english_translation}"\n\n${h.arabic_matn}\n\n— 1001 Authentic Hadith (${h.takhrij})`,
    url: window.location.href
  };

  if (navigator.share) {
    navigator.share(shareData).catch(() => {});
  } else {
    copyHadith();
  }
}

// Text-to-Speech (Read Aloud)
let isSpeaking = false;
function toggleSpeak() {
  if (!('speechSynthesis' in window)) {
    showToast("Audio synthesis not supported in this browser");
    return;
  }

  if (isSpeaking) {
    window.speechSynthesis.cancel();
    isSpeaking = false;
    document.getElementById('btn-audio-speak').style.background = 'var(--bg-card)';
    showToast("Audio stopped");
    return;
  }

  const h = hadithsData[currentHadithIndex];
  if (!h) return;

  const utter = new SpeechSynthesisUtterance(h.english_translation);
  utter.rate = 0.9;
  utter.onend = () => {
    isSpeaking = false;
    document.getElementById('btn-audio-speak').style.background = 'var(--bg-card)';
  };

  window.speechSynthesis.speak(utter);
  isSpeaking = true;
  document.getElementById('btn-audio-speak').style.background = 'var(--accent-glow)';
  showToast("Reading English translation... 🔊");
}

// Toast Alert Helper
function showToast(msg) {
  toastBox.textContent = msg;
  toastBox.style.display = 'block';
  setTimeout(() => { toastBox.style.display = 'none'; }, 2200);
}

// Settings & Modal Controls
function setupEventListeners() {
  btnBack.addEventListener('click', goBack);

  navButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const view = btn.getAttribute('data-view');
      navigateTo(view);
    });
  });

  document.getElementById('btn-prev-hadith').addEventListener('click', prevHadith);
  document.getElementById('btn-next-hadith').addEventListener('click', nextHadith);
  document.getElementById('btn-bookmark-hadith').addEventListener('click', toggleBookmark);
  document.getElementById('btn-copy-hadith').addEventListener('click', copyHadith);
  document.getElementById('btn-share-hadith').addEventListener('click', shareHadith);
  document.getElementById('btn-audio-speak').addEventListener('click', toggleSpeak);

  // Search Input listener
  const searchInput = document.getElementById('search-input');
  searchInput.addEventListener('input', (e) => {
    renderSearchResults(e.target.value);
  });

  // Modal Settings Toggle
  const modal = document.getElementById('modal-settings');
  document.getElementById('btn-font-modal').addEventListener('click', () => {
    modal.classList.add('open');
  });
  document.getElementById('btn-close-modal').addEventListener('click', () => {
    modal.classList.remove('open');
  });
  modal.addEventListener('click', (e) => {
    if (e.target === modal) modal.classList.remove('open');
  });

  // Theme Toggle Button
  document.getElementById('btn-theme-toggle').addEventListener('click', () => {
    const currentTheme = document.documentElement.getAttribute('data-theme') || 'dark';
    const nextTheme = currentTheme === 'dark' ? 'sepia' : currentTheme === 'sepia' ? 'light' : 'dark';
    setTheme(nextTheme);
  });

  // Theme Pill Buttons
  document.querySelectorAll('[data-theme-btn]').forEach(btn => {
    btn.addEventListener('click', () => {
      setTheme(btn.getAttribute('data-theme-btn'));
    });
  });

  // Font Sliders
  const sliderAr = document.getElementById('slider-arabic-font');
  const sliderEn = document.getElementById('slider-english-font');

  sliderAr.addEventListener('input', (e) => {
    const val = e.target.value;
    document.documentElement.style.setProperty('--arabic-size', `${val}px`);
    document.getElementById('arabic-size-val').textContent = `${val}px`;
    localStorage.setItem('hadith_arabic_font_size', val);
  });

  sliderEn.addEventListener('input', (e) => {
    const val = e.target.value;
    document.documentElement.style.setProperty('--english-size', `${val}px`);
    document.getElementById('english-size-val').textContent = `${val}px`;
    localStorage.setItem('hadith_english_font_size', val);
  });

  // Touch Swipe for Next / Previous Hadith
  let touchStartX = 0;
  let touchEndX = 0;
  views.reader.addEventListener('touchstart', (e) => {
    touchStartX = e.changedTouches[0].screenX;
  }, false);

  views.reader.addEventListener('touchend', (e) => {
    touchEndX = e.changedTouches[0].screenX;
    handleSwipe();
  }, false);

  function handleSwipe() {
    if (currentView !== 'reader') return;
    const diff = touchEndX - touchStartX;
    if (diff > 60) prevHadith();
    else if (diff < -60) nextHadith();
  }
}

function setTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem('hadith_theme', theme);

  document.querySelectorAll('[data-theme-btn]').forEach(b => {
    b.classList.toggle('active', b.getAttribute('data-theme-btn') === theme);
  });

  const themeIcon = document.getElementById('theme-icon');
  if (theme === 'dark') {
    themeIcon.innerHTML = '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>';
  } else if (theme === 'sepia') {
    themeIcon.innerHTML = '<circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line>';
  } else {
    themeIcon.innerHTML = '<circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>';
  }
}

function loadSavedSettings() {
  const savedTheme = localStorage.getItem('hadith_theme') || 'dark';
  setTheme(savedTheme);

  const savedArSize = localStorage.getItem('hadith_arabic_font_size') || '22';
  document.documentElement.style.setProperty('--arabic-size', `${savedArSize}px`);
  document.getElementById('slider-arabic-font').value = savedArSize;
  document.getElementById('arabic-size-val').textContent = `${savedArSize}px`;

  const savedEnSize = localStorage.getItem('hadith_english_font_size') || '15';
  document.documentElement.style.setProperty('--english-size', `${savedEnSize}px`);
  document.getElementById('slider-english-font').value = savedEnSize;
  document.getElementById('english-size-val').textContent = `${savedEnSize}px`;
}

// Start on DOM Ready
document.addEventListener('DOMContentLoaded', initApp);
