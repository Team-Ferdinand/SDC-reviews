const express = require('express');
const app = express();
const db = require('./database');
const models = require('./database/models');

const port = 3000;

app.use(express.json());

app.listen(port, () => {
  console.log(`Reviews API server listening at port: ${port}`);
});
app.get('/', (req,res) => {
  console.log('connected');
  res.send('server is connected');
});

app.get('/loaderio-6d3dc3a5b535d2a9d9a1104c463c9de0', (req, res) => {
  res.send('loaderio-6d3dc3a5b535d2a9d9a1104c463c9de0');
});

app.get('/reviews', (req, res) => {
  const productId = req.query.product_id || undefined;
  const page = req.query.page - 1 || 0;
  const count = req.query.count || 5;
  let response = { product_id: productId, page: page, count: count, results: []};

  models.reviews.getReviews(productId, page, count)
    .then(({rows}) => {
      response.results = rows;
      delete response.rows;
      res.json(response);
    })
    .catch((err) => {
      console.log("🚀 ~ file: index.js ~ line 31 ~ app.get ~ err", err);
    });
});

app.get('/reviews/meta', (req, res) => {
  const productId = req.query.product_id || undefined;
  models.reviews.getMetaData(productId)
    .then(({rows}) => {
      console.log("🚀 ~ file: index.js ~ line 42 ~ .then ~ rows", rows)
      let response = {
        product_id: productId,
        ratings: rows[0].ratings,
        recommended: rows[0].recommended,
        characteristics: rows[0].random,
      };
      res.json(response);
    })
    .catch((err) => {
      console.log("🚀 ~ file: index.js ~ line 49 ~ app.get ~ err", err);
    });
});

app.post('/reviews', (req, res) => {
  const { photos, characteristics } = req.body;
  var id;
  models.reviews.addReview(req.body)
    .then(({rows}) => {
      id = rows[0].id;
      var promises = photos.map((photo) => {
        return models.reviews.addPhoto(photo, id);
      });
      return Promise.all(promises);
    })
    .then(() => {
      var chArray = Object.keys(characteristics);
      var charPromises = chArray.map((char) => {
        var val = characteristics[char];
        return models.reviews.updateChaRev(char, val, id);
      });
      return Promise.all(charPromises);
    })
    .then(() => {
      res.sendStatus(201);
    })
    .catch((err) => {
      console.log("🚀 ~ file: index.js ~ line 75 ~ app.post ~ err", err);
    });
});

app.put('/reviews/:review_id/helpful', (req, res) => {
  var id = req.params.review_id;
  models.reviews.updateHelpfulness(id)
    .then(() => {
      res.sendStatus(200);
    })
    .catch((err) => {
      console.log("🚀 ~ file: index.js ~ line 87 ~ app.put ~ err", err);
    });
});

app.put('/reviews/:review_id/report', (req, res) => {
  var id = req.params.review_id;
  models.reviews.reportReview(id)
    .then(() => {
      res.sendStatus(200);
    })
    .catch((err) => {
      console.log("🚀 ~ file: index.js ~ line 98 ~ app.put ~ err", err);
    });
});
