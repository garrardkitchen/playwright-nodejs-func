// example.js
const playwright = require('playwright');

module.exports = async function (context, myTimer) {
    var timeStamp = new Date().toISOString();
    
    if (myTimer.isPastDue)
    {
        context.log('JavaScript is running late!');
    }

    

    const browser = await playwright.firefox.launch({
        
      });
      const ctx = await browser.newContext();
      const page = await ctx.newPage();
      await page.goto('https://www.microsoft.com/edge');
    //   await page.screenshot({ path: 'example.png' });  

    let body = await page.innerText('body', {timeout: 20000})

    context.log(`body length = ${body.length}`)

      await browser.close();

    context.log('JavaScript timer trigger function ran!', timeStamp);   
};



// (async () => {
//   const browser = await playwright.chromium.launch({
//     channel: 'msedge',
//   });
//   const context = await browser.newContext();
//   const page = await context.newPage();
//   await page.goto('https://www.microsoft.com/edge');
//   await page.screenshot({ path: 'example.png' });

//   await browser.close();
// })();