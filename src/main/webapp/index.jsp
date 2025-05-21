<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <title><%@ page contentType="text/html;charset=UTF-8" language="java" %>
      <html>
      <head>
      <title>Feedbacks List</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
  </head>
  <body class="bg-gray-100 min-h-screen">
  <div class="container mx-auto py-8">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold text-gray-800">Feedbacks</h1>
      <a href="create" class="px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Create Feedback</a>
    </div>
    <div class="flex gap-4 mb-4">
      <input id="searchInput" type="text" placeholder="Search feedbacks..." class="px-3 py-2 border rounded w-full focus:outline-none focus:ring-2 focus:ring-black" />
      <button id="pdfBtn" class="px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Export PDF</button>
    </div>
    <div id="feedbacksContainer" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
    </div>
  </div>
  <script>
    var feedbacks = [];
    var filteredFeedbacks = [];
    var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));

    function fetchFeedbacks() {
      fetch(contextPath+'/api/feedbacks?sortByRating=true')
              .then(function(response) { return response.json(); })
              .then(function(data) {
                feedbacks = data;
                filteredFeedbacks = feedbacks;
                renderCards(filteredFeedbacks);
              });
    }

    function renderCards(data) {
      var container = document.getElementById('feedbacksContainer');
      container.innerHTML = '';

      if (data.length === 0) {
        var emptyMsg = document.createElement('div');
        emptyMsg.className = 'col-span-3 text-center text-gray-500 py-8';
        emptyMsg.innerText = 'No feedbacks found';
        container.appendChild(emptyMsg);
        return;
      }

      data.forEach(function(feedback) {
        var card = document.createElement('div');
        card.className = 'bg-white rounded-lg shadow p-6 hover:shadow-lg transition';

        var idDiv = document.createElement('div');
        idDiv.className = 'text-sm text-gray-500 mb-2';
        idDiv.innerText = 'ID: ' + feedback.id;
        card.appendChild(idDiv);

        var messageDiv = document.createElement('div');
        messageDiv.className = 'text-lg font-semibold mb-2';
        messageDiv.innerText = feedback.message;
        card.appendChild(messageDiv);

        var feedbackDiv = document.createElement('div');
        feedbackDiv.className = 'text-gray-600 mb-4';
        feedbackDiv.innerText = feedback.feedback;
        card.appendChild(feedbackDiv);

        var ratingDiv = document.createElement('div');
        ratingDiv.className = 'flex items-center';

        for (let i = 1; i <= 5; i++) {
          var star = document.createElement('span');
          star.className = i <= feedback.rating ? 'text-yellow-500' : 'text-gray-300';
          star.innerHTML = '★';
          ratingDiv.appendChild(star);
        }

        var ratingText = document.createElement('span');
        ratingText.className = 'ml-2 text-sm text-gray-500';
        ratingText.innerText = feedback.rating + '/5';
        ratingDiv.appendChild(ratingText);
        card.appendChild(ratingDiv);

        var actionsDiv = document.createElement('div');
        actionsDiv.className = 'flex gap-2 mt-4';

        var editBtn = document.createElement('button');
        editBtn.className = 'px-3 py-1 bg-white border border-black text-black rounded hover:bg-black hover:text-white transition';
        editBtn.innerText = 'Edit';
        editBtn.onclick = function() {
          window.location.href = contextPath + '/edit?id=' + feedback.id;
        };
        actionsDiv.appendChild(editBtn);

        var deleteBtn = document.createElement('button');
        deleteBtn.className = 'px-3 py-1 bg-red-500 text-white rounded hover:bg-red-700 transition';
        deleteBtn.innerText = 'Delete';
        deleteBtn.onclick = function() {
          if (confirm('Are you sure you want to delete this feedback?')) {
            fetch(contextPath+'/api/feedbacks?id=' + feedback.id, { method: 'DELETE' })
                    .then(function(response) { return response.json(); })
                    .then(function(result) {
                      alert(result.message || result.error);
                      fetchFeedbacks();
                    });
          }
        };
        actionsDiv.appendChild(deleteBtn);

        card.appendChild(actionsDiv);
        container.appendChild(card);
      });
    }

    document.getElementById('searchInput').addEventListener('input', function(e) {
      var value = e.target.value.toLowerCase();
      filteredFeedbacks = feedbacks.filter(function(feedback) {
        return (feedback.message && feedback.message.toLowerCase().includes(value)) ||
                (feedback.feedback && feedback.feedback.toLowerCase().includes(value)) ||
                (feedback.rating + '').includes(value) ||
                (feedback.id + '').includes(value);
      });
      renderCards(filteredFeedbacks);
    });

    document.getElementById('pdfBtn').addEventListener('click', function() {
      var doc = new window.jspdf.jsPDF();
      doc.setFontSize(16);
      doc.text('Feedbacks List', 14, 16);
      var startY = 24;
      var rowHeight = 10;
      doc.setFontSize(12);
      doc.text('ID', 14, startY);
      doc.text('Message', 34, startY);
      doc.text('Feedback', 104, startY);
      doc.text('Rating', 164, startY);
      filteredFeedbacks.forEach(function(feedback, idx) {
        var y = startY + rowHeight * (idx + 1);
        doc.text(String(feedback.id), 14, y);
        doc.text(feedback.message, 34, y);
        doc.text(feedback.feedback, 104, y);
        doc.text(feedback.rating.toString(), 164, y);
      });
      doc.save('feedbacks.pdf');
    });

    fetchFeedbacks();
  </script>
  </body>
</html></title>
  </head>
  <body>
  
  </body>
</html>
