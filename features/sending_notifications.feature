Feature: Sending notifications

  As an application using the Panda service
  I want to be notified of things in Panda
  So that I know exactly what's going on with my videos
  
  Scenario: Running the notifier
    Given the following notifications have been queued:
      | mode  | state    | body                 | uri                   |
      | email | error    | There was an error   | bill@tedadventure.com |  
      | email | fooey    | It was fooey         | daniel@coolguy.com |  
      | email | whatever | This can be anything | zach@niftyguy.com |
    When the notifier runs
    Then "bill@tedadventure.com" should receive the email:
      | subject contains | error |
      | body contains    | There was an error |
    And "daniel@coolguy.com" should receive the email:
      | subject contains | fooey |
      | body contains    | It was fooey |
    And "zach@niftyguy.com" should receive the email:
      | subject contains | whatever |
      | body contains    | This can be anything |

