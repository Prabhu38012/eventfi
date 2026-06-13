const express    = require('express');
const router     = express.Router();
const { getEvents, getTrending, getDistricts, getEventById } = require('../controllers/event.controller');

// NOTE: /trending and /districts must be BEFORE /:id  (otherwise "trending" is treated as an id)
router.get('/trending',  getTrending);
router.get('/districts', getDistricts);
router.get('/',          getEvents);
router.get('/:id',       getEventById);

module.exports = router;
