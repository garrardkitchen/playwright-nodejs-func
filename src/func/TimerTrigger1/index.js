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

  await page.goto(website); 

  // you can uncomment this if you want to grab a screenshot
  // await page.screenshot({ path: 'example.png' });  

  let body = await page.innerText('body', { timeout: 20000 })

  // we just need confirmation that we've hit the site but don't need to pipe DOM element to logs
  context.log(`body length = ${body.length}`)
  
  await page.getByRole('link', { name: 'Home' }).click();
  await page.getByRole('list').getByRole('link', { name: 'Privacy' }).click();
  await page.getByRole('link', { name: 'Home' }).click();
  
  let locator = await page.getByRole('heading', { name: 'Welcome' })
  let locatorText = await locator.textContent()

  if (locatorText != "Welcome") {
    context.log.warn(`Welcome heading not found`)
  } else {
    context.log(`Welcome heading found`)
  }

  await browser.close();

  context.log('JavaScript timer trigger function ran!', timeStamp);
};