// plot-exports/capture-plots.cjs
const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

// Get command-line arguments
const scale = process.argv[2] ? parseFloat(process.argv[2]) : 3; // Default to higher scale
const url = process.argv[3] || 'http://127.0.0.1:3000/';

(async () => {
  console.log(`Capturing high-resolution plots from ${url} with scale factor ${scale}`);
  
  // Create output directory
  const outputDir = path.join(__dirname, 'output');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir);
  }
  
  // Launch browser
  const browser = await puppeteer.launch({
    headless: false,
    defaultViewport: {
      width: 2400,  // Larger viewport
      height: 1800, // Larger viewport
      deviceScaleFactor: scale // Higher pixel density
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
    
    // Wait for SVG elements
    await page.waitForSelector('svg', { timeout: 30000 });
    console.log('Found SVG elements');
    
    // Take full page screenshot
    await page.screenshot({ 
      path: path.join(outputDir, 'full-page.png'),
      fullPage: true
    });
    console.log('Saved full page screenshot');
    
    // Find divs containing SVG elements
    const plotContainers = await page.evaluate(() => {
      // Find all divs containing SVGs
      const containers = [];
      document.querySelectorAll('div').forEach((div, index) => {
        if (div.querySelector('svg') && 
            div.getBoundingClientRect().width > 100 && 
            div.getBoundingClientRect().height > 100) {
          
          // Get coordinates and dimensions
          const rect = div.getBoundingClientRect();
          containers.push({
            index,
            x: rect.x,
            y: rect.y,
            width: rect.width,
            height: rect.height,
            // Try to get a meaningful name if possible
            title: div.querySelector('h1, h2, h3, title')?.textContent || 
                   div.getAttribute('id') || 
                   `plot_${index}`
          });
        }
      });
      return containers;
    });
    
    console.log(`Found ${plotContainers.length} plot containers`);
    
    // Capture each plot container
    for (const container of plotContainers) {
      // Generate a clean filename
      const filename = container.title
        .replace(/[^a-z0-9]/gi, '_')
        .toLowerCase()
        .substring(0, 50) + '.png';
      
      // Add padding to ensure legends are included
      const padding = 20;
      
      // Take a screenshot with padding
      await page.screenshot({
        path: path.join(outputDir, filename),
        clip: {
          x: Math.max(0, container.x - padding),
          y: Math.max(0, container.y - padding),
          width: container.width + (padding * 2),
          height: container.height + (padding * 2)
        },
        omitBackground: false
      });
      
      console.log(`Saved ${filename}`);
    }
    
    // Wait for user to review
    console.log('Waiting 15 seconds for you to review the browser...');
    await new Promise(resolve => setTimeout(resolve, 15000));
    
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
  
  console.log(`All high-resolution plots saved to ${outputDir}`);
})();