Feature: Moonr js runner
  As a js developer
  I want to run a js file
  So i can get the result

  Scenario: Moonr can parse js file
    Moon can parse js file and report error on failure

	Given a js file "test/mjsunit/for.js" is provided
	When i parse it using moonr
	Then i get the result
