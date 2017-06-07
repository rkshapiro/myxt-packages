This scrub function will remove leading/trailing spaces, new lines, and tabs from selected text fields. The fields are defined in a scrub list table.

Instructions to setup the scrub text function
1. use the scublist.xlsx template to generate a list of fields to scrub
2. save that list as a CSV and import it into the scrublist table using the csvimp_map.
3. use xtconnect to schedule the metasql to run nightly.
4. the process returns the number of updates made and the number of xTuple errors encountered by the update.
