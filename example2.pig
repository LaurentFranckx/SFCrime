register s3n://uw-cse-344-oregon.aws.amazon.com/myudfs.jar

-- load the test file into Pig
--raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/cse344-test-file' USING TextLoader as (line:chararray);
-- later you will load to other files, example:
raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-000' USING TextLoader as (line:chararray); 

-- parse each line into ntriples
ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);
DESCRIBE ntriples;

--group the n-triples by object column
subjects = group ntriples by (subject) PARALLEL 50;
DESCRIBE subjects;

-- flatten the objects out (because group by produces a tuple of each object
-- in the first column, and we want each object ot be a string, not a tuple),
-- and count the number of tuples associated with each object
count_by_subject = foreach subjects generate flatten($0), COUNT($1) as x PARALLEL 50;
DESCRIBE count_by_subject;

group_by_count = group count_by_subject by (x) PARALLEL 50;
DESCRIBE group_by_count;

count_by_count = foreach group_by_count generate flatten($0), COUNT($1) as y PARALLEL 50;
DESCRIBE count_by_count;

--store count_by_count into 's3n://laurentfranckx/example-results';

records_count = FOREACH (GROUP count_by_count ALL) GENERATE COUNT(count_by_count);
DUMP records_count;


