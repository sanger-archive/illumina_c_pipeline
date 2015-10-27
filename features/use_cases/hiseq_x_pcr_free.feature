@javascript
Feature: ss342 - Illumina-C PCR free library creation for X10 sequencing
  In order to process customer samples for phase 3 validation of that process
  As Scientific Manager
  I would like a No-PCR XTen Library type in Generic LIMS

  Scenario: Processing a No-PCR XTen Library plate
    Given I am on the homepage
    When I enter a valid user barcode
    And I enter with a "ILC Stock" plate
    Then I should be in a plate page

    And I should see a "ILC Stock" plate
    And I should see that the plate is in "passed" state
    And I should be able to create a "ILC AL Libs Tagged" plate

    When I create the next plate

    Then I should be in the tag selection page
    When I select "Netflex-96 barcoded adapters" from Tags selection
    And I click on "Create Plate"

    Then I should be in a plate page
    And I should see a "ILC AL Libs Tagged" plate
    And I should see that the plate is in "pending" state

    When I move to the next state
    And I change state to started
    And I click on "Change State"

    Then I should be in the homepage
    And I should see a plate has been changed to "started" state

    When I enter a valid user barcode
    And I enter with the last plate shown

    Then I should be in a plate page
    And I should see a "ILC AL Libs Tagged" plate
    And I should see that the plate is in started state

    When I move to the next state
    And I change state to "passed" state
    And I click on "Change State"

    Then I should be in the homepage
    And I should see a plate has been changed to "passed" state

    When I enter a valid user barcode
    And I enter with the last plate shown

    Then I should be in a plate page
    And I should see a "ILC AL Libs Tagged" plate
    And I should see that the plate is in passed state

    When I click on "Create the next tube"
    Then I should be able to create a "ILC QC Pool" tube
    When I create the next tube

    Then I should be in the tube page

