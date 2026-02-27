// js/demo.test.js for inboxcrittersweb
const { JSDOM } = require('jsdom');
describe('Inbox Critters Demo', () => {
  let window, document, section, mindZone, bucketsEl, inputEl, addBtn, summaryEl, toastEl, critterEl;
  beforeEach(() => {
    const dom = new JSDOM(`<!DOCTYPE html><div id="try"><div class="demo-mind-zone"></div><div class="demo-buckets"></div><input class="demo-input"><button class="demo-add-btn"></button><div class="demo-summary"></div><div class="demo-toast"></div><div class="demo-critter"></div><span class="demo-orb-count"></span></div>`);
    window = dom.window;
    document = window.document;
    global.document = document;
    section = document.getElementById('try');
    mindZone = section.querySelector('.demo-mind-zone');
    bucketsEl = section.querySelector('.demo-buckets');
    inputEl = section.querySelector('.demo-input');
    addBtn = section.querySelector('.demo-add-btn');
    summaryEl = section.querySelector('.demo-summary');
    toastEl = section.querySelector('.demo-toast');
    critterEl = section.querySelector('.demo-critter');
  });
  it('renders mind zone and buckets', () => {
    require('./demo.js');
    expect(mindZone).toBeDefined();
    expect(bucketsEl).toBeDefined();
    expect(inputEl).toBeDefined();
    expect(addBtn).toBeDefined();
    expect(summaryEl).toBeDefined();
    expect(toastEl).toBeDefined();
    expect(critterEl).toBeDefined();
  });
  it('add button creates orb', () => {
    require('./demo.js');
    inputEl.value = 'Test Thought';
    addBtn.click();
    expect(mindZone.children.length).toBeGreaterThan(0);
  });
  it('summary shows after completion', () => {
    require('./demo.js');
    summaryEl.classList.add('summary-show');
    expect(summaryEl.innerHTML).toMatch(/Brain dumped!/);
  });
});
