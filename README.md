# Salesforce Code Exercise
by [Graham MacRobie](https://macrobie.com)

## Specification

##### Trigger

Create custom objects to model the following relationship: There are Projects to which multiple people can make Payments. Likewise, a person can make payments to multiple projects. Use the standard Contact object for people and custom objects for Payments and Projects. The Project should have a field that shows the total amount of Payments made to it by people. There should be fields on Contact showing the total amount of payments and the most recent payment date that a person has made to projects. There should be a field on Payment to capture payment date. 

Write a trigger to populate these payment date and amount fields on Project and Contact. Use lookup relationships and Apex code instead of roll-up summary fields to compute the amounts. The trigger should handle insert, update and delete of Payments, including modification of payment date.
 
##### Visualforce Page

Using the same data model from above, write a Visualforce page that lists all people that have made at least one payment to any Project. For each person, show the total payment amount and the most recent payment date, and list the individual payments that a person has made underneath the summary line. The date and amount fields for each payment should be editable on the page.

The user can use this page to edit payments and see the rollups of total amount and most recent payment date in action. The internal user can also use this page to add and delete new payments for a given person listed on the page – so there should be add, delete functionality per person, and edit per payment row.

All of these fields should have  a field validation that checks the user's input value for validity (date, number) using Javascript and Visualforce - and displays errors before the user attempts to persist the data when editing or creating a record. 

Styling of the Visualforce page is not important for the purpose of this exercise, but robustness is. Please include tests like you normally would in actual development projects.
 
## Design Assumptions

The following assumptions and clarifications were made:

* Payment Amounts must always be positive.
* Only one type of user (internal) from a security standpoint.
* The specification that there be a delete function “per person” is a little ambiguous.  Accordingly, the decision was made to implement delete “per payment row” instead.

Notwithstanding point number two, and for the sake of completeness, three custom permissions were included in the design (Payment Add, Payment Edit, and Payment Delete), allowing an admin to configure profile-based access with some granularity.

## Design Considerations

The following considerations influenced the design:

* Robustness, first and foremost.  In particular, the trigger was designed to handle the case where there might be millions of Payment, Project, and/or Contact records, while still handling most normal use cases synchronously and within Salesforce’s governor limits.
* Ease of maintenance and testing.  Separation of  concerns is given priority over reducing the number of class files.  Business logic is isolated, to the extent possible, in a “service” layer, and generally not found in VF page controllers.
* Don’t reinvent the wheel.  Popular components (jQuery, DataTables, DataTables Editor) were used instead of hand-coding common elements.
* Try to observe Salesforce best practices.  For instance, there are no hard-coded messages or labels in the app – it’s all in custom labels to ease future translation and maintenance.
* Test-driven, agile methodology.  Several quick tools were built to enhance development testing, in addition to a suite of unit tests, making ongoing testing an integral part of the design and development process.

## Trigger Algorithm

The trigger should meet the following specifications:

* Properly “bulkified”.  Most transactions require only 2 select queries (Project and Contact) and 2 updates (also Project and Contact).  Edge cases require 2 additional select queries (per trigger).  The worst case scenario involves a huge Payment table (tens of thousands of rows), in which case the trigger falls back to calling a batch job to finish the work (which would fail if attempted synchronously).
* Stays within governor limits.
* Business logic not in main trigger class to ease testing and maintenance.
* Aggregate queries are not used because they suffer from the same governor limits that would break the algorithm when the Payment table is huge, except that with aggregate queries those limits are harder to anticipate and divert around.

The algorithm functions as follows:

* For design simplicity, the algorithm calculates TotalPayments and MostRecentPaymentDate for both Project and Contact, even though the spec only mentioned MostRecentPaymentDate for Contact.
* For each of Project and Contact, the algorithm starts by dividing the incoming Payment records (from any trigger event – insert, update, delete, undelete) into buckets, based on object id (project or contact).  See getBucket(...).
* For the objects that will be affected (project or contact), load the current TotalPayments and MostRecentPaymentDate.  See applyAdjustments(...).
* Loop through the Payment records (stored as PaymentDelta object), increasing or decreasing the TotalPayments by each Payment Amount.
* During the loop, if the Payment Date is greater than the current MostRecentPaymentDate, keep track of that as the new maximum.
* If a payment is deleted, and it had a payment date that was equal to the current Most Recent Payment Date, that means the table (project or contact) will need to be rescanned to find the new maximum (since we’re not using rollups).
* If the rescan would exceed governor limits, spin off a batch job to do the task asynchronously.  A flag is set on Project and Contact records that would be affected by this (Recomputing) so that no changes can occur to payments associated with these objects until the batch completes (basically a pessimistic lock).  An email is sent when the batch completes, and the Recomputing flag is reset for affected objects.
* Undeletes are treated as inserts.

A flowchart of this algorithm follows:

![Flowchart](images/flowchart.png?raw=true)

## Visualforce Page (Payments by Payer)

The VF page should meet the following specifications:

* Doesn’t use Lightning.  Since I’m somewhat new to Lightning (November 2017), I didn’t want to add uncertainty to my process during this short coding exercise.  That said, the finished page should at least be compatible with Lightning Experience, which it is.
* Uses AJAX to load and manipulate data.  Tables that are built “traditionally” with standard VF table elements (apex:pageBlockTable) are brittle and don’t scale well.  The current version loads the entire Payment table through AJAX to improve the client-side experience, but a future version could be easily modified to do incremental loads.  The same type of enhancement would be much harder starting from a pageBlockTable design.
* Single page design – I wanted to avoid taking the user to other pages to accomplish Add, Edit, and Delete functionality.
* Project list (for new payment dialog) is loaded with JSON, and currently just loads the entire list.  This approach would have to be rethought if there were any possibility of the number of projects exceeding a few hundred (the drop-down element would be replaced with a lookup facility of some sort).
* None of the labels or system messages are hard-coded – they’re all in custom labels.

The following somewhat arbitrary validation rules were implemented:

* Payment amount is required, must be a number, cannot be negative, and cannot exceed $1B.
* Payment date is required, must be a valid date, cannot be older than January 1 of the previous year, and cannot be in the future.
* Project Id is required for new payments (selected from a drop-down).

Server-side validation rules were implemented as config (to enforce out-of-the-box usage scenarios), and also as Apex code (to provide cleaner error messages).  Client-side validation rules were implemented in JavaScript.

The following test scenarios were implemented to promote a test-driven approach during development:

* There are 2 “Tim Barr” contact (payer) records to test that grouping is handled correctly by contact Id and not just by name.
* The contact “Caralee D’Apostrohpe” is intended to make sure that the apostrophe character doesn’t break any JavaScript.
* The project “Let’s Test Apostrophes!” is there for the same reason.
* The developer tools page was implemented so that there could be hundreds or thousands of test payment records, allowing me to see how the page would scale all along during development.

## Screenshots

### Instant Search

The VF page allows users to search for payments and it instantly filters the table as the user types.  Users can search based on payer name, project name, payment date, or payment amount.

![Screenshot 1](images/screenshot1.png?raw=true)

### New Payment

The VF page allows users to create a new payment.  The payer is already selected when they enter the modal dialog.

![Screenshot 2](images/screenshot2.png?raw=true)

### Client-side and Server-side Input Validation

The VF page performs client-side validation and reports errors underneath each field.  The controller and service classes for the VF page also perform server-side validation of the same rules.

![Screenshot 3](images/screenshot3.png?raw=true)

### Edit Payment

The VF page allows users to edit a payment.  Only the payment date and amount can be modified.

![Screenshot 4](images/screenshot4.png?raw=true)

### Inline Editing of Payments

The VF page allows users to inline edit the payment date and payment amount.  Changes are saved instantly and asynchronously when the user leaves the field.

![Screenshot 5](images/screenshot5.png?raw=true)

### Developer Tools

The developer tools page allows a user to insert random payments, delete random payments, audit the current totals in the database to ensure they are correct, and launch a batch job to reset the totals.  The number of payment records to insert or delete are specified in a field, and the current number of payment records in the database is shown.

![Screenshot 6](images/screenshot6.png?raw=true)

## Areas for Improvement / ToDo List

* Partial / incremental loading of payment table data
* AJAX-based lookup of Projects for New Payment modal (instead of current drop-down select)
* Live updates to payment data like Google Sheets
* Lightning version
* A couple of hard-coded limits could be custom settings
* Thorough analysis of permissions and use cases
* Onscreen help