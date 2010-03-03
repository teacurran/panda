Feature: Notification of appropriate video states

  As an application using the Panda service
  I want to be sure that I get appropriate notifications
  So that I know exactly what's going on with every video
  
  # Notifications Panda should send:
  #   processing => video server notified that it is processing this video
  #   processing_error => video server reported error in processing
  #   complete => video server published encoding information, this video is ready to be made public

  Scenario: Cucumber plays nicely with merb, and the upload action works.
    When I request the login page
    Then I should receive a "200 Ok" response
    When I have uploaded a video file
    Then I should receive a "200 Ok" response

  Scenario: My video file is not a video file type
    When I have uploaded a video file "non-video.jpg"
    Then I should receive a "415" response with message "not a recognized type of video"

  Scenario: My video file has problems encoding
    Given I have uploaded a video file that cannot encode
    When the video file begins encoding
    Then I should receive the "processing" notification
    And I should receive the "processing_error" notification
  
  Scenario: My video file finishes encoding
    Given I have uploaded a video file that will encode
    When the video file begins encoding
    Then I should receive the "processing" notification
    And I should receive the "complete" notification
