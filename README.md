⚠️ This is a work in progress

### GigBase

Flutter app for editing a database of songs and when they were performed. Currently supports
the specific use case of selecting songs and adding them to a gig. There are lots
of other things it should do that haven't been implemented yet.

This is the fourth incarnation of GigBase. The first was a React/GraphQL app using Hasura to
host the database. Performance on Hasura's free tier wasn't great so that lead to a second
incarnation, with a REST backend implemented in PHP. However, the spot where I usually play
didn't have good network connectivity, so that lead to the third incarnation, an Android app
reading from a local SQLite database, written using MIT's App Inventor. That was clunky but 
it worked. There were some problems that I think were due to bugs in the SQLite implementation
for App Inventor, and lots of limitations and minor bugs. 

I used that for several years, then I got a new phone where it wouldn't work, because of changes
to Android's policies as far as writing files. App Inventor is good for getting a quick
version of something running but hard to modify and debug. Hence this version was started, implemented in Flutter. It
looks much nicer, has some features I always wanted, but could never add, in the App Inventor
version (like an indexed scrolling list), and is more solid. Thoughout the same database has been
used, starting with PostgreSQL in the original web app then SQLite in the Android apps.

This is probably not useful to anyone but me, except as an example of editing an SQLite database
in Flutter. It does what I need it to do so it's unlikely I'll be adding any new features.