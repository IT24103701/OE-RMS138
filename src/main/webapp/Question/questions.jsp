<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>Questions List</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
</head>
<body class="bg-gray-100 min-h-screen">
<div class="container mx-auto py-8">
  <div class="flex justify-between items-center mb-6">
    <h1 class="text-3xl font-bold text-gray-800">Questions</h1>
    <a href="createQuestion.jsp" class="px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Create Question</a>
  </div>
  <div class="flex gap-4 mb-4">
    <input id="searchInput" type="text" placeholder="Search questions..." class="px-3 py-2 border rounded w-full focus:outline-none focus:ring-2 focus:ring-black" />
    <button id="pdfBtn" class="px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Export PDF</button>
  </div>
  <div class="overflow-x-auto rounded shadow bg-white">
    <table class="min-w-full divide-y divide-gray-200">
      <thead class="bg-gray-50">
      <tr>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Question</th>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Answer</th>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
      </tr>
      </thead>
      <tbody id="questionsTable" class="bg-white divide-y divide-gray-200"></tbody>
    </table>
  </div>
</div>
<script>
  var questions = [];
  var filteredQuestions = [];
  var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
  function fetchQuestions() {
    fetch(contextPath+'/api/questions')
            .then(function(response) { return response.json(); })
            .then(function(data) {
              questions = data;
              filteredQuestions = questions;
              renderTable(filteredQuestions);
            });
  }

  function renderTable(data) {
    var table = document.getElementById('questionsTable');
    table.innerHTML = '';
    if (data.length === 0) {
      var row = document.createElement('tr');
      var cell = document.createElement('td');
      cell.colSpan = 5;
      cell.className = 'px-6 py-4 text-center text-gray-500';
      cell.innerText = 'No questions found';
      row.appendChild(cell);
      table.appendChild(row);
      return;
    }
    data.forEach(function(question) {
      var row = document.createElement('tr');
      row.className = 'hover:bg-gray-100 transition';

      var idCell = document.createElement('td');
      idCell.className = 'px-6 py-4 whitespace-nowrap';
      idCell.innerText = question.id;
      row.appendChild(idCell);

      var questionCell = document.createElement('td');
      questionCell.className = 'px-6 py-4 whitespace-nowrap';
      questionCell.innerText = question.question;
      row.appendChild(questionCell);

      var answerCell = document.createElement('td');
      answerCell.className = 'px-6 py-4 whitespace-nowrap';
      answerCell.innerText = question.answer;
      row.appendChild(answerCell);

      var typeCell = document.createElement('td');
      typeCell.className = 'px-6 py-4 whitespace-nowrap';
      typeCell.innerText = question.type;
      row.appendChild(typeCell);

      var actionsCell = document.createElement('td');
      actionsCell.className = 'px-6 py-4 whitespace-nowrap flex gap-2';
      var editBtn = document.createElement('button');
      editBtn.className = 'px-3 py-1 bg-white border border-black text-black rounded hover:bg-black hover:text-white transition';
      editBtn.innerText = 'Edit';
      editBtn.onclick = function() {
        window.location.href = contextPath + '/editQuestion.jsp?id=' + question.id;
      };
      actionsCell.appendChild(editBtn);

      var deleteBtn = document.createElement('button');
      deleteBtn.className = 'px-3 py-1 bg-red-500 text-white rounded hover:bg-red-700 transition';
      deleteBtn.innerText = 'Delete';
      deleteBtn.onclick = function() {
        if (confirm('Are you sure you want to delete this question?')) {
          fetch(contextPath+'/api/questions?id=' + question.id, { method: 'DELETE' })
                  .then(function(response) { return response.json(); })
                  .then(function(result) {
                    alert(result.message || result.error);
                    fetchQuestions();
                  });
        }
      };
      actionsCell.appendChild(deleteBtn);

      row.appendChild(actionsCell);
      table.appendChild(row);
    });
  }

  document.getElementById('searchInput').addEventListener('input', function(e) {
    var value = e.target.value.toLowerCase();
    filteredQuestions = questions.filter(function(question) {
      return (question.question && question.question.toLowerCase().includes(value)) ||
              (question.answer && question.answer.toLowerCase().includes(value)) ||
              (question.type && question.type.toLowerCase().includes(value)) ||
              (question.id + '').includes(value);
    });
    renderTable(filteredQuestions);
  });

  document.getElementById('pdfBtn').addEventListener('click', function() {
    var doc = new window.jspdf.jsPDF();
    doc.setFontSize(16);
    doc.text('Questions List', 14, 16);
    var startY = 24;
    var rowHeight = 10;
    doc.setFontSize(12);
    doc.text('ID', 14, startY);
    doc.text('Question', 34, startY);
    doc.text('Answer', 104, startY);
    doc.text('Type', 164, startY);
    filteredQuestions.forEach(function(question, idx) {
      var y = startY + rowHeight * (idx + 1);
      doc.text(String(question.id), 14, y);
      doc.text(question.question, 34, y);
      doc.text(question.answer, 104, y);
      doc.text(question.type, 164, y);
    });
    doc.save('questions.pdf');
  });

  fetchQuestions();
</script>
</body>
</html>