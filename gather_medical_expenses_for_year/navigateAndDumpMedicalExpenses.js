/* run this with casperjs */
/* usage:
casperjs navigateAndDumpMedicalExpenses.js <wellmarkUsername> <wellmarkPassword> <YearToDownload>
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
var desiredYear = casper.cli.get(2);

casper.start('https://member.wellmark.com/modules/claims/');

casper.waitForSelector('#ctl00_body_btnOk', function() {
});

casper.then(function() {
    console.log('filling and submitting form at ' + this.getCurrentUrl());
	
	this.fillSelectors('form#aspnetForm', {
        'input[id="ctl00_body_userid"]':    username,
        'input[id="ctl00_body_password"]':    password
	}, false);
    this.capture('screenshot1.png');
	
    this.click('form#aspnetForm input[type="submit"]');
    console.log('OK Button clicked at ' + this.getCurrentUrl());
});

casper.waitForSelector('input.wm_button', function(){}, function(){}, 7000);

casper.then(function() {
    console.log('clicked ok, new location is ' + this.getCurrentUrl());
	
    this.capture('screenshot2.png');
	
    this.click('input.wm_button');
});

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

casper.run();
