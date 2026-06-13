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

module.exports = { success, error };
