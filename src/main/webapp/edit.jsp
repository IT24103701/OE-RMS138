<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <title><%@ page contentType="text/html;charset=UTF-8" language="java" %>
      <!DOCTYPE html>
      <html lang="en">
      <head>
      <meta charset="UTF-8">
      <title>Edit Feedback</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
      .star-rating {
        display: flex;
        gap: 8px;
      }
      .star {
        font-size: 24px;
        cursor: pointer;
        color: #d1d5db;
        transition: color 0.2s;
      }
      .star.active {
        color: #fbbf24;
      }
      .star:hover {
        color: #fbbf24;
      }
    </style>
  </head>
  <body class="bg-gray-100 min-h-screen">
  <div class="container mx-auto py-8">
    <div class="flex items-center mb-6">
      <button id="backBtn" class="mr-4 px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Back</button>
      <h1 class="text-3xl font-bold text-gray-800">Edit Feedback</h1>
    </div>
    <form id="feedbackForm" class="bg-white rounded shadow p-8 max-w-lg mx-auto">
      <div class="mb-4">
        <label class="block text-gray-700 font-semibold mb-2">Message</label>
        <input id="message" name="message" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required pattern=".{3,255}" />
        <span id="messageError" class="text-red-500 text-xs hidden">Enter a valid message (3-255 characters).</span>
      </div>
      <div class="mb-4">
        <label class="block text-gray-700 font-semibold mb-2">Feedback</label>
        <textarea id="feedback" name="feedback" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required></textarea>
        <span id="feedbackError" class="text-red-500 text-xs hidden">Enter a valid feedback.</span>
      </div>
      <div class="mb-6">
        <label class="block text-gray-700 font-semibold mb-2">Feedback Type</label>
        <select id="feedbackType" name="feedbackType" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required>
          <option value="">Select feedback type</option>
          <option value="Happy">Happy 😊</option>
          <option value="Satisfied">Satisfied 🙂</option>
          <option value="Neutral">Neutral 😐</option>
          <option value="Disappointed">Disappointed 😕</option>
          <option value="Frustrated">Frustrated 😠</option>
          <option value="Other">Other</option>
        </select>
        <span id="feedbackTypeError" class="text-red-500 text-xs hidden">Select a valid feedback type.</span>
      </div>
      <div class="mb-6">
        <label class="block text-gray-700 font-semibold mb-2">Rating</label>
        <div class="star-rating">
          <span class="star" data-value="1"><i class="fas fa-star"></i></span>
          <span class="star" data-value="2"><i class="fas fa-star"></i></span>
          <span class="star" data-value="3"><i class="fas fa-star"></i></span>
          <span class="star" data-value="4"><i class="fas fa-star"></i></span>
          <span class="star" data-value="5"><i class="fas fa-star"></i></span>
        </div>
        <input type="hidden" id="rating" name="rating" value="">
        <span id="ratingError" class="text-red-500 text-xs hidden">Please select a rating.</span>
      </div>
      <button id="submitBtn" type="submit" class="w-full px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Update</button>
      <div id="loading" class="text-center text-yellow-600 py-2 hidden">Updating feedback...</div>
      <div id="successMsg" class="text-center text-green-600 py-2 hidden">Feedback updated successfully!</div>
      <div id="errorMsg" class="text-center text-red-600 py-2 hidden"></div>
    </form>
  </div>
  <script>
    document.getElementById('backBtn').onclick = function() {
      window.location.href = '${pageContext.request.contextPath}/';
    };

    function showError(id, show) {
      document.getElementById(id).classList.toggle('hidden', !show);
    }

    function validateField(id, regex) {
      const value = document.getElementById(id).value.trim();
      return regex.test(value);
    }

    function getIdFromUrl() {
      const params = new URLSearchParams(window.location.search);
      return params.get('id');
    }

    let feedbackId = getIdFromUrl();

    // Initialize star rating
    const stars = document.querySelectorAll('.star');
    let currentRating = 0;

    function resetStars() {
      stars.forEach(star => {
        star.classList.remove('active');
      });
    }

    function highlightStars(rating) {
      resetStars();
      for (let i = 0; i < stars.length; i++) {
        if (i < rating) {
          stars[i].classList.add('active');
        }
      }
    }

    stars.forEach(star => {
      star.addEventListener('mouseenter', function() {
        const value = parseInt(this.getAttribute('data-value'));
        highlightStars(value);
      });

      star.addEventListener('mouseleave', function() {
        highlightStars(currentRating);
      });

      star.addEventListener('click', function() {
        const value = parseInt(this.getAttribute('data-value'));
        currentRating = value;
        document.getElementById('rating').value = value;
        highlightStars(value);
        showError('ratingError', false);
      });
    });

    function populateForm(feedback) {
      document.getElementById('message').value = feedback.message || '';
      document.getElementById('feedback').value = feedback.feedback || '';
      document.getElementById('feedbackType').value = feedback.feedbackType || '';

      // Set star rating
      if (feedback.rating) {
        currentRating = parseInt(feedback.rating);
        document.getElementById('rating').value = currentRating;
        highlightStars(currentRating);
      }
    }

    function fetchFeedback() {
      document.getElementById('loading').classList.remove('hidden');
      var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
      fetch(contextPath + '/api/feedbacks?id=' + feedbackId)
              .then(res => {
                if (!res.ok) throw new Error('Feedback not found');
                return res.json();
              })
              .then(feedback => {
                populateForm(feedback);
                document.getElementById('loading').classList.add('hidden');
              })
              .catch(() => {
                document.getElementById('loading').classList.add('hidden');
                document.getElementById('errorMsg').textContent = 'Failed to load feedback.';
                document.getElementById('errorMsg').classList.remove('hidden');
              });
    }

    document.getElementById('feedbackForm').onsubmit = function(e) {
      e.preventDefault();

      // Hide all errors
      showError('messageError', false);
      showError('feedbackError', false);
      showError('feedbackTypeError', false);
      showError('ratingError', false);
      document.getElementById('successMsg').classList.add('hidden');
      document.getElementById('errorMsg').classList.add('hidden');

      // Validate fields
      let valid = true;
      if (!validateField('message', /^.{3,255}$/)) {
        showError('messageError', true); valid = false;
      }
      if (!document.getElementById('feedback').value.trim()) {
        showError('feedbackError', true); valid = false;
      }
      if (!document.getElementById('feedbackType').value) {
        showError('feedbackTypeError', true); valid = false;
      }
      if (!document.getElementById('rating').value) {
        showError('ratingError', true); valid = false;
      }

      if (!valid) return;

      // Prepare payload
      const payload = {
        id: feedbackId,
        message: document.getElementById('message').value.trim(),
        feedback: document.getElementById('feedback').value.trim(),
        feedbackType: document.getElementById('feedbackType').value,
        rating: document.getElementById('rating').value
      };

      // Show loading
      document.getElementById('loading').classList.remove('hidden');
      document.getElementById('submitBtn').disabled = true;

      var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
      fetch(contextPath + '/api/feedbacks?id=' + feedbackId, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      })
              .then(res => {
                document.getElementById('loading').classList.add('hidden');
                document.getElementById('submitBtn').disabled = false;
                if (res.ok) {
                  document.getElementById('successMsg').classList.remove('hidden');
                  setTimeout(function() {
                    window.location.href = contextPath + '/';
                  }, 1200);
                } else {
                  return res.text().then(text => { throw new Error(text); });
                }
              })
              .catch(err => {
                document.getElementById('errorMsg').textContent = 'Failed to update feedback. ' + (err.message || '');
                document.getElementById('errorMsg').classList.remove('hidden');
              });
    };

    fetchFeedback();
  </script>
  </body>
</html></title>
  </head>
  <body>
  
  </body>
</html>
