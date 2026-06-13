const Event = require('../models/Event');
const { success, error } = require('../utils/response');

/// GET /api/events
/// Query: category, district, minPrice, maxPrice, search, page, limit
const getEvents = async (req, res) => {
  try {
    const {
      category,
      district,
      minPrice,
      maxPrice,
      search,
      page  = 1,
      limit = 20,
    } = req.query;

    const filter = { isActive: true };

    if (category && category !== 'all') filter.category = category;
    if (district) filter.district = { $regex: district, $options: 'i' };
    if (search)   filter.$text    = { $search: search };

    if (minPrice || maxPrice) {
      filter.price = {};
      if (minPrice) filter.price.$gte = Number(minPrice);
      if (maxPrice) filter.price.$lte = Number(maxPrice);
    }

    const skip = (Number(page) - 1) * Number(limit);

    const [events, total] = await Promise.all([
      Event.find(filter)
        .sort({ date: 1 })
        .limit(Number(limit))
        .skip(skip)
        .lean(),
      Event.countDocuments(filter),
    ]);

    return res.status(200).json(success({
      events,
      total,
      page:  Number(page),
      pages: Math.ceil(total / Number(limit)),
    }, 'Events fetched'));
  } catch (err) {
    return res.status(500).json(error(err.message));
  }
};

/// GET /api/events/trending  — top 10 by booking count
const getTrending = async (req, res) => {
  try {
    const events = await Event.find({ isActive: true })
      .sort({ bookingCount: -1 })
      .limit(10)
      .lean();
    return res.status(200).json(success({ events }, 'Trending events'));
  } catch (err) {
    return res.status(500).json(error(err.message));
  }
};

/// GET /api/events/districts — unique district list for filter
const getDistricts = async (req, res) => {
  try {
    const districts = await Event.distinct('district', { isActive: true });
    return res.status(200).json(success({ districts: districts.sort() }, 'Districts fetched'));
  } catch (err) {
    return res.status(500).json(error(err.message));
  }
};

/// GET /api/events/:id
const getEventById = async (req, res) => {
  try {
    const event = await Event.findById(req.params.id).lean();
    if (!event) return res.status(404).json(error('Event not found'));
    return res.status(200).json(success({ event }, 'Event fetched'));
  } catch (err) {
    return res.status(500).json(error(err.message));
  }
};

module.exports = { getEvents, getTrending, getDistricts, getEventById };
