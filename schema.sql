DROP TABLE IF EXISTS reviews CASCADE;

CREATE TABLE IF NOT EXISTS reviews(
  id SERIAL NOT NULL,
  product_id INTEGER NOT NULL,
  rating INTEGER NOT NULL,
  date bigint,
  summary VARCHAR(150) DEFAULT NULL,
  body VARCHAR(1000) DEFAULT NULL,
  recommend BOOLEAN,
  reported BOOLEAN,
  reviewer_name VARCHAR(60),
  reviewer_email VARCHAR(60),
  response VARCHAR(250),
  helpfulness INTEGER,
  PRIMARY KEY (id)
);

COPY reviews(id, product_id, rating, date, summary, body, recommend, reported, reviewer_name, reviewer_email, response, helpfulness)
FROM '/home/ubuntu/data/reviews.csv'
DELIMITER ','
CSV HEADER;

DROP TABLE IF EXISTS reviews_photos;

CREATE TABLE IF NOT EXISTS reviews_photos(
  id SERIAL NOT NULL,
  review_id INTEGER NOT NULL,
  url VARCHAR(200),
  PRIMARY KEY (id),
  FOREIGN KEY (review_id)
    REFERENCES reviews(id)
);

COPY reviews_photos(id, review_id, url)
FROM '/home/ubuntu/data/reviews_photos.csv'
DELIMITER ','
CSV HEADER;

DROP TABLE IF EXISTS chars CASCADE;

CREATE TABLE IF NOT EXISTS chars(
  id SERIAL NOT NULL,
  product_id INTEGER NOT NULL,
  name TEXT,
  PRIMARY KEY (id)
);

COPY chars(id, product_id, name)
FROM '/home/ubuntu/data/characteristics.csv'
DELIMITER ','
CSV HEADER;

DROP TABLE IF EXISTS char_revs;

CREATE TABLE IF NOT EXISTS char_revs(
  id SERIAL NOT NULL,
  char_id INTEGER NOT NULL,
  review_id INTEGER NOT NULL,
  value INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (review_id)
    REFERENCES reviews(id),
  FOREIGN KEY (char_id)
    REFERENCES chars(id)
);

COPY char_revs(id, char_id, review_id, value)
FROM '/home/ubuntu/data/characteristic_reviews.csv'
DELIMITER ','
CSV HEADER;

ALTER TABLE reviews
ALTER COLUMN date TYPE timestamptz USING to_timestamp(CAST(date as bigint)/1000);

ALTER TABLE reviews ALTER COLUMN date SET DEFAULT now();

CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_photos_review_id ON reviews_photos(review_id);
CREATE INDEX idx_char_product_id ON chars(product_id);
CREATE INDEX idx_char_rev_char_id ON char_revs(char_id);
CREATE INDEX idx_char_rev_review_id ON char_revs(review_id);

SELECT setval('reviews_id_seq', COALESCE((SELECT MAX(id)+1 FROM reviews), 1), false);
SELECT setval('reviews_photos_id_seq', COALESCE((SELECT MAX(id)+1 FROM reviews_photos), 1), false);
SELECT setval('char_revs_id_seq', COALESCE((SELECT MAX(id)+1 FROM char_revs), 1), false);