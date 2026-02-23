## Metadata
Question Type : Text Input

## Question
One of the configured data sources is usually excluded from Active Devices queries. Which one and why? :

## Answers
^ServiceNow$ : 1

## Correct Answer Feedback
ServiceNow is often excluded because its "last updated" timestamp changes whenever the record is modified, not necessarily when the device was actually active. This can lead to false positives for device activity.

## Incorrect Answer Feedback
Correct answer is **ServiceNow**
