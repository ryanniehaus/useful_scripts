/* run this with casperjs */
/* usage:
casperjs navigateAndDumpPaystubs.js <rcbenefitsUsername> <rcbenefitsPassword>
*/

var links = [];
var casper = require('casper').create({
	verbose: true,
	logLevel: "debug"
});
var fs = require('fs');
var x = casper.selectXPath
var username = casper.cli.get(0);
var password = casper.cli.get(1);
var listCounter = 0;
var screenshotCounter = 0;
var pageTimeoutMS=60000;
var yearOfHiring=2005;
var date = new Date();
var numOfYears=(date.getYear()+1990+1)-yearOfHiring;
var numberOfLoops=numOfYears*26;

casper.start('https://benefits.rockwellcollins.com/');

casper.waitForSelector('input[value="Login"]', function(){}, function(){}, pageTimeoutMS);


casper.then(function() {
    console.log('filling and submitting form at ' + this.getCurrentUrl());
	
	this.fillSelectors('form[name="frmLogin"]', {
        'input[name="j_username"]':    username,
        'input[name="j_password"]':    password
	}, false);
    this.capture('screenshot' + (screenshotCounter++) + '.png');
	
    this.click('input[value="Login"]');
    console.log('Login Button clicked at ' + this.getCurrentUrl());
});

casper.waitForSelector('frame[name="bottom"]', function(){}, function(){}, pageTimeoutMS);

casper.thenOpen("https://benefits.rockwellcollins.com/Webchecks/WC_Check_List.cfm", function() {
    console.log('clicked Login, new location is ' + this.getCurrentUrl());
	
    this.capture('screenshot' + (screenshotCounter++) + '.png');

});

casper.waitForSelector('td.GenTextBlueB', function(){}, function(){}, pageTimeoutMS);

casper.then(function() {
    console.log('loaded check list, new location is ' + this.getCurrentUrl());
	
    this.capture('screenshot' + (screenshotCounter++) + '.png');
		
    this.click('tr.ePayText:nth-child(2)');
		this.wait(10000);
		
    console.log('Looping ' + numberOfLoops + ' times');
    
  	this.repeat(numberOfLoops, function() {
				this.waitForSelector('img[alt="Create Excel file"]', function(){}, function(){}, pageTimeoutMS);
				
				this.capture('screenshot' + (screenshotCounter++) + '.png');
				fs.write('stub' + (listCounter++) + '.html', this.getHTML('body'), 'w');
		
    		this.click('a[href^="WC_Check_Detail.cfm"]');
				this.wait(10000);
		});
});

/*
casper.waitForSelector('a#linkToSeeAllClaims', function(){}, function(){}, 60000);

casper.then(function() {
    console.log('We are in! ' + this.getCurrentUrl());
    this.capture('screenshot3.png');
	
    this.click('a#linkToSeeAllClaims');
});

casper.waitForSelector('a#ctl00_ContentRight_ctl00_searchInternal_LinkButton1', function(){}, function(){}, 60000);

casper.then(function() {
    console.log('filling and submitting form at ' + this.getCurrentUrl());
	
	this.fillSelectors('form#aspnetForm', {
        'input[id="ctl00_ContentRight_ctl00_searchInternal_FromDate"]':  '01/01/' + desiredYear,
        'input[id="ctl00_ContentRight_ctl00_searchInternal_ToDate"]':    '12/31/' + desiredYear
	}, false);
    this.capture('screenshot4.png');
	
    this.click('a#ctl00_ContentRight_ctl00_searchInternal_LinkButton1');
    console.log('Submit Button clicked at ' + this.getCurrentUrl());
});

casper.waitForUrl(/searchresults\.aspx$/, function(){}, function(){}, 60000);

casper.then(function() {
    console.log('selecting printer view' + this.getCurrentUrl());
    this.capture('screenshot5.png');
	
    this.click('a#ctl00_ContentLeft_DisplayGrid_PrinterLink');
    console.log('Clicked printer view link' + this.getCurrentUrl());
});

// this will wait for the popup to be opened and loaded
casper.waitForPopup(/PrintClaims\.aspx$/, function() {
});

casper.withPopup(/PrintClaims\.aspx$/, function() {
	this.waitForSelector('table#ctl00_ContentMain_GridView1', function(){}, function(){}, 70000);

	this.then(function() {
		console.log('Entered Printer View' + this.getCurrentUrl());
		this.capture('screenshot6.png');
		
		// dump table contents
		this.echo(this.getHTML('table#ctl00_ContentMain_GridView1'));
		fs.write('part1.html', this.getHTML('table#ctl00_ContentMain_GridView1'), 'w');
		this.click('a[title="View details regarding this claim."]');
	});
});

casper.waitForSelector('a#ctl00_ContentLeft_DisplayGrid_AllClaimsGrid_ctl103_NextPage', function(){}, function(){}, 70000);

casper.then(function() {
	this.click('a#ctl00_ContentLeft_DisplayGrid_AllClaimsGrid_ctl103_NextPage');
    this.capture('screenshot7.png');
});

casper.waitWhileSelector('a#ctl00_ContentLeft_DisplayGrid_PrinterLink', function(){}, function(){}, 70000);
casper.wait(5000);
casper.waitForSelector('a#ctl00_ContentLeft_DisplayGrid_PrinterLink', function(){}, function(){}, 70000);

casper.then(function() {
    console.log('selecting printer view' + this.getCurrentUrl());
    this.capture('screenshot8.png');
	
    this.click('a#ctl00_ContentLeft_DisplayGrid_PrinterLink');
    console.log('Clicked printer view link' + this.getCurrentUrl());
});

casper.waitWhileSelector('table#ctl00_ContentMain_GridView1', function(){}, function(){}, 70000);
casper.wait(5000);
// this will wait for the popup to be opened and loaded
casper.waitForPopup(/PrintClaims\.aspx$/, function() {
});

casper.withPopup(/PrintClaims\.aspx$/, function() {
	this.waitForSelector('table#ctl00_ContentMain_GridView1', function(){}, function(){}, 70000);

	this.then(function() {
		console.log('Entered Printer View' + this.getCurrentUrl());
		this.capture('screenshot9.png');
		
		// dump table contents
		this.echo(this.getHTML('table#ctl00_ContentMain_GridView1'));
		fs.write('part2.html', this.getHTML('table#ctl00_ContentMain_GridView1'), 'w');
		this.click('a[title="View details regarding this claim."]');
	});
});

casper.waitForSelector('a#ctl00_ContentLeft_DisplayGrid_AllClaimsGrid_ctl103_NextPage', function(){}, function(){}, 70000);

casper.then(function() {
	this.click('a#ctl00_ContentLeft_DisplayGrid_AllClaimsGrid_ctl103_NextPage');
    this.capture('screenshot10.png');
});
*/

casper.run();
