const playwright = require('playwright');

module.exports = async function (context, myTimer) {
  var timeStamp = new Date().toISOString();

  if (myTimer.isPastDue) {
    context.log('JavaScript is running late!');
  }

  const browser = await playwright.firefox.launch({
    headless: true,
    browserName: 'firefox',
    ignoreHTTPSErrors: true,
    timeout: this._timeout,
    args: ["--disable-gpu"]
  });

  const ctx = await browser.newContext();
  const page = await ctx.newPage();
  const website = process.env["WEBAPP_URI"]

  context.log(`website = ${website}`)

  await page.goto(website); //'https://www.microsoft.com/edge');

  //   await page.screenshot({ path: 'example.png' });  

  let body = await page.innerText('body', { timeout: 20000 })

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