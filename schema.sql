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
FROM '/Users/philhuynh/hackreactorProjects/hr-rfe6-system-design-capstone/data/reviews.csv'
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
FROM '/Users/philhuynh/hackreactorProjects/hr-rfe6-system-design-capstone/data/reviews_photos.csv'
DELIMITER ','
CSV HEADER;

DROP TABLE IF EXISTS characteristics CASCADE;

CREATE TABLE IF NOT EXISTS characteristics(
  id SERIAL NOT NULL,
  product_id INTEGER NOT NULL,
  name TEXT,
  PRIMARY KEY (id)
);

COPY characteristics(id, product_id, name)
FROM '/Users/philhuynh/hackreactorProjects/hr-rfe6-system-design-capstone/data/characteristics.csv'
DELIMITER ','
CSV HEADER;

DROP TABLE IF EXISTS characteristics_reviews;

CREATE TABLE IF NOT EXISTS characteristics_reviews(
  id SERIAL NOT NULL,
  characteristic_id INTEGER NOT NULL,
  review_id INTEGER NOT NULL,
  value INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (review_id)
    REFERENCES reviews(id),
  FOREIGN KEY (characteristic_id)
    REFERENCES characteristics(id)
);

COPY characteristics_reviews(id, characteristic_id, review_id, value)
FROM '/Users/philhuynh/hackreactorProjects/hr-rfe6-system-design-capstone/data/characteristic_reviews.csv'
DELIMITER ','
CSV HEADER;

ALTER TABLE reviews
ALTER COLUMN date TYPE timestamptz USING to_timestamp(CAST(date as bigint)/1000);

CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_photos_review_id ON reviews_photos(review_id);
CREATE INDEX idx_characteristics_product_id ON characteristics(product_id);
CREATE INDEX idx_chr_rev_char_id ON characteristics_reviews(characteristic_id);
CREATE INDEX idx_chr_rev_review_id ON characteristics_reviews(review_id);

SELECT setval('reviews_id_seq', COALESCE((SELECT MAX(id)+1 FROM reviews), 1), false)
SELECT setval('reviews_photos_id_seq', COALESCE((SELECT MAX(id)+1 FROM reviews_photos), 1), false)
SELECT setval('characteristics_reviews_id_seq', COALESCE((SELECT MAX(id)+1 FROM characteristics_reviews), 1), false)