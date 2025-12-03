CREATE EXTENSION IF NOT EXISTS pageinspect;

SELECT get_raw_page('employee', 0);

SELECT * FROM page_header(get_raw_page('employee', 0));
