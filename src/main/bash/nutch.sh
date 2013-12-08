#!/bin/bash

NUTCH_HOME=~/workspaces/nutch/target/apache-nutch-2.2.1/runtime/local
# depth in the web exploration
nbLoop=10
# number of selected urls for fetching
maxUrls=50
nbThread=2
# solr server
solrUrl=http://localhost:8983/solr/nutch

for (( i = 1 ; i <= $nbLoop ; i++ ))
do

  log=$NUTCH_HOME/logs/log

  # Generate
  echo "Generate"
  $NUTCH_HOME/bin/nutch generate -topN $maxUrls > $log

  batchId=`sed -n 's|.*batch id: \(.*\)|\1|p' < $log`
  echo "Batch id is : $batchId"

  # rename log file by appending the batch id
  log2=$log$batchId
  mv $log $log2
  log=$log2

  # Fetch
  echo "Fetch"
  $NUTCH_HOME/bin/nutch fetch $batchId -threads $nbThread >> $log

  # Parse
  echo "Parse"
  $NUTCH_HOME/bin/nutch parse $batchId >> $log

  # Update
  echo "Updatedb"
  $NUTCH_HOME/bin/nutch updatedb >> $log

  # Index
  echo "Solr index"
  $NUTCH_HOME/bin/nutch solrindex $solrUrl $batchId >> $log

done

