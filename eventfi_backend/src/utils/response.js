const success = (data, message = 'Success') => ({
  success: true,
  message,
  data,
});

const error = (message = 'An error occurred', code = null) => ({
  success: false,
  message,
  ...(code && { code }),
});

const successResponse = (res, message, data = {}, statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
};

const errorResponse = (res, message, statusCode = 400) => {
  return res.status(statusCode).json({
    success: false,
    message,
  });
};

module.exports = { success, error, successResponse, errorResponse };
