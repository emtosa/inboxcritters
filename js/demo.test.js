// js/demo.test.js for inboxcrittersweb
const { JSDOM } = require('jsdom');
describe('Inbox Critters Demo', () => {
  let window, document, section, mindZone, bucketsEl, inputEl, addBtn, summaryEl, toastEl, critterEl;
  beforeEach(() => {
    jest.resetModules();
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
    document.dispatchEvent(new window.Event('DOMContentLoaded'));
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
    document.dispatchEvent(new window.Event('DOMContentLoaded'));
    inputEl.value = 'Test Thought';
    addBtn.click();
    expect(mindZone.children.length).toBeGreaterThan(0);
  });
  it('mind zone accepts multiple orbs', () => {
    require('./demo.js');
    document.dispatchEvent(new window.Event('DOMContentLoaded'));
    inputEl.value = 'Thought 1';
    addBtn.click();
    inputEl.value = 'Thought 2';
    addBtn.click();
    expect(mindZone.children.length).toBe(2);
  });
});
