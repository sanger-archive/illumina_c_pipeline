Generic LIMS Pipeline Application
=================================

This is a web-based front-end for generic sequencing pipelines based on the Sequencescape public JSON API.

To test it
==========

1. Download and install Sequencescape

2. Create a new empty testing database for Sequencescape:
 
  rake db:drop db:create db:schema:load db:seed working:setup

3. Go to Illumina-C app and generate the configuration

  rake config:generaate

4. Copy the configuration file to test:

  cp config/settings/development.yml config/settings/test.yml

5. Start sequencescape server

  ./script/server

6. Start the tests in Illumina-C

  cucumber
