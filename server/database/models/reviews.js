const db = require('../index.js');

module.exports = {

  getReviews: (productId, page, count) => {
    let start = page * count;
    return db.pool.query(
      `SELECT reviews.id, reviews.rating, reviews.summary, reviews.recommend, reviews.response, reviews.body, reviews.date, reviews.reviewer_name, reviews.helpfulness,
        (SELECT json_agg(
            json_build_object(
              'id', reviews_photos.id,
              'url', reviews_photos.url
            )
          )photos FROM reviews_photos WHERE reviews_photos.review_id=reviews.id
        )
      FROM reviews
      WHERE reviews.product_id = ${productId}
      AND reviews.reported = false
      OFFSET ${start}
      LIMIT ${count}`);
  },

  getMetaData: (productId) => {
    return db.pool.query(`SELECT
      json_build_object(
        '1', (SELECT
          COUNT(reviews.rating)
          FROM reviews
          WHERE reviews.product_id = ${productId} AND reviews.rating = 1),
        '2', (SELECT
          COUNT(reviews.rating)
          FROM reviews
          WHERE reviews.product_id = ${productId} AND reviews.rating = 2),
        '3', (SELECT
          COUNT(reviews.rating)
          FROM reviews
          WHERE reviews.product_id = ${productId} AND reviews.rating = 3),
        '4', (SELECT
          COUNT(reviews.rating)
          FROM reviews
          WHERE reviews.product_id = ${productId} AND reviews.rating = 4),
        '5', (SELECT
          COUNT(reviews.rating)
          FROM reviews
          WHERE reviews.product_id = ${productId} AND reviews.rating = 5)
      )ratings,
      json_build_object(
        'false', (SELECT
          COUNT(reviews.recommend)
          FROM reviews
          WHERE reviews.product_id = ${productId} AND reviews.recommend = false),
        'true', (SELECT
          COUNT(reviews.recommend)
          FROM reviews
          WHERE reviews.product_id = ${productId} AND reviews.recommend = true)
      )recommended,
      json_object_agg(
        characteristics.name,
          json_build_object(
            'id', characteristics.id,
            'value', (SELECT AVG (CAST(characteristics_reviews.value as Float))
                FROM characteristics_reviews
                WHERE characteristics_reviews.characteristic_id = characteristics.id
            )
        )
      )characteristics FROM characteristics WHERE characteristics.product_id = ${productId}`
    );
  },

  addReview: (r) => {
    return db.pool.query(
      `INSERT INTO reviews (product_id, rating, summary, body, recommend, reported, reviewer_name, reviewer_email, helpfulness)
      VALUES (${r.product_id}, ${r.rating}, '${r.summary}', '${r.body}', ${r.recommend}, false, '${r.name}', '${r.email}', 0)
      RETURNING id`
    );
  },

  addPhoto: (photo, id) => {
    return db.pool.query(
      `INSERT INTO reviews_photos (review_id, url)
      VALUES (${id}, '${photo}')
      `
    );
  },

  updateChaRev: (char, val, id) => {
    return db.pool.query(
      `INSERT INTO characteristics_reviews (characteristic_id, review_id, value)
      VALUES(${char}, ${id}, ${val})
      `
    );
  },

  updateHelpfulness: (id) => {
    return db.pool.query(
      `UPDATE reviews
      SET helpfulness = helpfulness + 1
      WHERE id = ${id}`
    );
  },

  reportReview: (id) => {
    return db.pool.query(
      `UPDATE reviews
      SET reported = true
      WHERE id = ${id}`
    );
  }
};




