Feature: Uploading/encoding videos

  As an application using the Panda service
  I want to be sure that videos uploaded are handled appropriately
  So that I know exactly what's going on with every video

  Scenario: Cucumber plays nicely with merb, and the upload action works.
    When I request the login page
    Then I should receive a "200 Ok" response
    When I have uploaded a video file
    Then I should receive a "200 Ok" response

  Scenario: My video file is not a video
    When I have uploaded a non-video file
    Then I should receive a "415" response with message "not a recognized type of video"

  Scenario: My video file is not a supported video file type
    When I have uploaded a bad video file
    Then I should receive a "415" response with message "not a recognized type of video"

  Scenario: My video file has problems encoding
    Given I have uploaded a video file that cannot encode
    When the video file encodes
    Then the encoding should fail
    And I should receive the "processing" notification
    And I should receive the "error" notification
  
  Scenario: My video file finishes encoding
    Given I have uploaded a video file that will encode
    When the video file encodes
    Then the encoding should succeed
    And I should receive the "processing" notification
    And I should receive the "success" notification
