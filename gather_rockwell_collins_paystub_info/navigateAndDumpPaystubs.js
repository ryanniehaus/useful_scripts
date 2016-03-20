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

casper.run();
