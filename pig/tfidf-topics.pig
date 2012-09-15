/*
 * Wikipedia Statistics for Named Entity Recognition and Disambiguation
 *      - use Pig/hadoop to generate a tfidf index for categories
 * @params $OUTPUT_DIR - the directory where the files should be stored
 *         $STOPLIST_PATH - the location of the stoplist in HDFS                
 *         $STOPLIST_NAME - the filename of the stoplist
 *         $INPUT - the wikipedia XML dump
 *         $MIN_COUNT - the minumum count for a token to be included in the index
 *         $PIGNLPROC_JAR - the location of the pignlproc jar
 *         $LANG - the language of the Wikidump 
 *         $MAX_SPAN_LENGTH - the maximum length for a paragraph span
 *         $NUM_DOCS - the number of documents in this wikipedia dump
 *         $N - the number of tokens to keep
 *         - use the file 'indexer.pig.params' to supply a default configuration
 */

-- TEST: set parallelism level for reducers
SET default_parallel 15;

SET job.name 'Wikipedia-Token-Counts-per-URI for $LANG';
--SET mapred.compress.map.output 'true';
--SET mapred.map.output.compression.codec 'org.apache.hadoop.io.compress.GzipCodec';
-- Register the project jar to use the custom loaders and UDFs
REGISTER $PIGNLPROC_JAR;

-- Define aliases
DEFINE getTokens pignlproc.index.LuceneTokenizer('$STOPLIST_PATH', '$STOPLIST_NAME', '$LANG', '$ANALYZER_NAME');
--Comment above and uncomment below to use default stoplist for the analyzer
--DEFINE getTokens pignlproc.index.LuceneTokenizer('$LANG', '$ANALYZER_NAME');
DEFINE textWithLink pignlproc.evaluation.ParagraphsWithLink('$MAX_SPAN_LENGTH');
DEFINE JsonCompressedStorage pignlproc.storage.JsonCompressedStorage();
DEFINE keepTopN pignlproc.helpers.FirstNtuples('$N');

--No fields: 4 (what is the second field??)
categories = LOAD '$INPUT' 
	USING PigStorage('\t')
	AS (name: chararray, count: long, categoryList: chararray, text: chararray);

--DUMP categories;
--DESCRIBE categories;

topic_context = FOREACH categories GENERATE
	name AS name, 
	FLATTEN(getTokens(text)) AS token;

--category_and_token = FOREACH topic_context GENERATE
--	name,
--	FLATTEN(context) as token;

--DUMP topic_context;
--DESCRIBE topic_context;

unique = DISTINCT topic_context;

categories_by_tokens = GROUP unique BY token;

doc_freq = FOREACH categories_by_tokens GENERATE
	group as token,
	COUNT(unique) as df; 
 
--DUMP doc_freq;
--DESCRIBE doc_freq;

--NUM_DOCS should be the number of categories (i.e. do line count on input and add constant in params)
idf = foreach doc_freq GENERATE
        token,
        LOG((double)$NUM_DOCS/(double)df) AS idf: double;


term_freq = GROUP topic_context BY (name, token);
term_counts = FOREACH term_freq GENERATE
	group.name AS name,
	group.token AS token,
	COUNT(topic_context) AS tf;

token_instances = JOIN term_counts BY token, idf by token;

--(5) calculate tfidf using $NUM_DOCS - note that the user must know how many RESOURCES there are, not how many docs
tfidf = FOREACH token_instances {
        tf_idf = (double)term_counts::tf*(double)idf::idf;
                GENERATE
                        term_counts::name as name,
                        term_counts::token as token,
                        tf_idf as weight;
        };

by_docs = GROUP tfidf BY name;
docs_with_weights = FOREACH by_docs GENERATE
	group AS name,
	tfidf.(token,weight) AS tokens;

--DUMP docs_with_weights;
--DESCRIBE docs_with_weights;

ordered = FOREACH docs_with_weights {
        sorted = ORDER tokens by weight desc;
        GENERATE
        name, sorted;
};
--DUMP ordered;
--DESCRIBE ordered;


STORE ordered INTO '$OUTPUT_DIR/topics_tfidf.tsv.bz2' USING PigStorage();
