// plot-exports/capture-plots.cjs
const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

// Get command-line arguments
const scale = process.argv[2] ? parseFloat(process.argv[2]) : 1.5;
const url = process.argv[3] || 'http://127.0.0.1:3000/'; // Changed to 127.0.0.1

(async () => {
  console.log(`Capturing plots from ${url} with scale factor ${scale}`);
  
  // Create output directory
  const outputDir = path.join(__dirname, 'output');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir);
  }
  
  // Launch browser with non-headless mode to see what's happening
  const browser = await puppeteer.launch({
    headless: false, // Change to false to see the browser
    defaultViewport: {
      width: 1600,
      height: 1200,
      deviceScaleFactor: scale
    }
  });
  
  const page = await browser.newPage();
  
  try {
    // Navigate to the page
    console.log(`Navigating to ${url}`);
    await page.goto(url, { waitUntil: 'networkidle0', timeout: 60000 });
    console.log('Page loaded');
    
    // Debug: Print page title
    const title = await page.title();
    console.log(`Page title: ${title}`);
    
    // Debug: Check what selectors exist
    const hasCards = await page.evaluate(() => {
      const cards = document.querySelectorAll('.card');
      console.log(`Found ${cards.length} .card elements`);
      return cards.length;
    });
    console.log(`Found ${hasCards} .card elements via JS evaluation`);
    
    // Wait for a more general selector first
    await page.waitForSelector('svg', { timeout: 30000 });
    console.log('Found some SVG elements');
    
    // Take a screenshot of the entire page for debugging
    await page.screenshot({ path: path.join(outputDir, 'full-page.png') });
    console.log('Saved full page screenshot for debugging');
    
    // Try to find any visible cards on the page
    const elements = await page.$$('div');
    console.log(`Found ${elements.length} div elements`);
    
    // Capture each visible div that might contain plots
    for (let i = 0; i < elements.length; i++) {
      const element = elements[i];
      
      // Check if element is visible
      const isVisible = await page.evaluate(el => {
        const style = window.getComputedStyle(el);
        const rect = el.getBoundingClientRect();
        return style.display !== 'none' && 
               style.visibility !== 'hidden' && 
               rect.width > 100 && 
               rect.height > 100;
      }, element);
      
      if (!isVisible) continue;
      
      // Check if element contains an SVG
      const hasSvg = await page.evaluate(el => {
        return el.querySelector('svg') !== null;
      }, element);
      
      if (!hasSvg) continue;
      
      // Get bounding box
      const box = await element.boundingBox();
      if (!box) continue;
      
      // Take a screenshot
      const filename = `element_${i}.png`;
      await page.screenshot({
        path: path.join(outputDir, filename),
        clip: {
          x: box.x,
          y: box.y,
          width: box.width,
          height: box.height
        }
      });
      
      console.log(`Saved ${filename}`);
    }
    
    // Wait for user to review (when using headless: false)
    console.log('Waiting 10 seconds for you to review the browser...');
    await new Promise(resolve => setTimeout(resolve, 10000));
    
  } catch (error) {
    console.error('Error capturing plots:', error);
    
    // Still try to take a full page screenshot for debugging
    try {
      await page.screenshot({ path: path.join(outputDir, 'error-page.png') });
      console.log('Saved error page screenshot for debugging');
    } catch (screenshotError) {
      console.error('Failed to take error screenshot:', screenshotError);
    }
  } finally {
    // Close browser
    await browser.close();
    console.log('Browser closed');
  }
  
  console.log(`All outputs saved to ${outputDir}`);
})();