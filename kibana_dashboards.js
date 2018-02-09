// Modules
const puppeteer = require('puppeteer');
const mkdirp = require('mkdirp');

// Constants
const urlDashboard = 'http://localhost:5601/app/kibana#/dashboard/'
const type = 'png';

// Take Inputs
const resultsDir = process.argv[2];
const dashboardTitle = process.argv[3];
const dashboardId = process.argv[4];
var dateInit = process.argv[5];

// Set path based on dashboard title and create directory
const dashboardPath = resultsDir + dashboardTitle.replace(/ - /g, "/") + '/';
mkdirp(dashboardPath, function (err) {
    if (err) console.error(err)
});

// Set dateInit and dateEnd based on input dateInit
const dateCurrent = new Date();
dateInit = new Date( dateInit.split('-', 3)[0], dateInit.split('-', 3)[1] -1, dateInit.split('-', 3)[2]);
var dateEnd = new Date(dateInit.getTime());
dateEnd.setDate(dateEnd.getDate() + 6);
dateEnd.setHours(23);
dateEnd.setMinutes(59);
dateEnd.setSeconds(59);
dateEnd.setMilliseconds(999);

// Screen size and clip screenshot
var width = 1973;
var height = 1100;
var cut_x = 53;
var cut_y = 0;
const clip = {x: cut_x, y: cut_y, width: width - cut_x, height: height - cut_y};

// Wait Tiem
var waitTime = 8 * 1000;

url = ( urlDashboard + dashboardId + "?_g=(refreshInterval:(display:Off,pause:!f,value:0),time:(from:'" + dateInit.toISOString() + "',mode:absolute,to:'" + dateEnd.toISOString() + "'))")

// MAIN function
puppeteer.launch({ executablePath: '/opt/chrome/latest/chrome' }).then(async browser => {
  const page = await browser.newPage();
  page.setViewport({width: width, height: height});
  await page.goto( url );
  await page.waitForSelector('[aria-label="Collapse"]');
  await page.click('[aria-label="Collapse"]');
  for(var i = 0; dateInit < dateCurrent;i++){
    await page.waitFor(waitTime);
    await page.screenshot({ path: dashboardPath + dashboardTitle + '_' + dateInit.toISOString().split('T', 1)[0] + '_' + dateEnd.toISOString().split('T', 1)[0] + '.' + type, clip});
    console.log( dateInit.toISOString() + ' -- ' + dateEnd.toISOString() );
    await page.waitForSelector('[aria-label="Move forward in time"]');
    await page.click('[aria-label="Move forward in time"]');
    await page.waitFor(waitTime);
    dateInit.setDate(dateInit.getDate() + 7);
    dateEnd.setDate(dateEnd.getDate() + 7);
  }
  await browser.close();
});
