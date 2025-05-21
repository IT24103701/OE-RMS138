<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>Exams List</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
</head>
<body class="bg-gray-100 min-h-screen">
<div class="container mx-auto py-8">
  <div class="flex justify-between items-center mb-6">
    <h1 class="text-3xl font-bold text-gray-800">Exams</h1>
    <a href="create" class="px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Create Exam</a>
  </div>
  <div class="flex gap-4 mb-4">
    <input id="searchInput" type="text" placeholder="Search exams..." class="px-3 py-2 border rounded w-full focus:outline-none focus:ring-2 focus:ring-black" />
    <button id="pdfBtn" class="px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Export PDF</button>
  </div>
  <div class="overflow-x-auto rounded shadow bg-white">
    <table class="min-w-full divide-y divide-gray-200">
      <thead class="bg-gray-50">
      <tr>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Time</th>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
      </tr>
      </thead>
      <tbody id="examsTable" class="bg-white divide-y divide-gray-200"></tbody>
    </table>
  </div>
</div>
<script>
  var exams = [];
  var filteredExams = [];
  var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
  function fetchExams() {
    fetch(contextPath+'/api/exams')
            .then(function(response) { return response.json(); })
            .then(function(data) {
              exams = data;
              filteredExams = exams;
              renderTable(filteredExams);
            });
  }

  function renderTable(data) {
    var table = document.getElementById('examsTable');
    table.innerHTML = '';
    if (data.length === 0) {
      var row = document.createElement('tr');
      var cell = document.createElement('td');
      cell.colSpan = 6;
      cell.className = 'px-6 py-4 text-center text-gray-500';
      cell.innerText = 'No exams found';
      row.appendChild(cell);
      table.appendChild(row);
      return;
    }
    data.forEach(function(exam) {
      var row = document.createElement('tr');
      row.className = 'hover:bg-gray-100 transition';

      var idCell = document.createElement('td');
      idCell.className = 'px-6 py-4 whitespace-nowrap';
      idCell.innerText = exam.id;
      row.appendChild(idCell);

      var nameCell = document.createElement('td');
      nameCell.className = 'px-6 py-4 whitespace-nowrap';
      nameCell.innerText = exam.name;
      row.appendChild(nameCell);

      var dateCell = document.createElement('td');
      dateCell.className = 'px-6 py-4 whitespace-nowrap';
      dateCell.innerText = exam.date;
      row.appendChild(dateCell);

      var timeCell = document.createElement('td');
      timeCell.className = 'px-6 py-4 whitespace-nowrap';
      timeCell.innerText = exam.time;
      row.appendChild(timeCell);

      var typeCell = document.createElement('td');
      typeCell.className = 'px-6 py-4 whitespace-nowrap';
      typeCell.innerText = exam.type;
      row.appendChild(typeCell);

      var actionsCell = document.createElement('td');
      actionsCell.className = 'px-6 py-4 whitespace-nowrap flex gap-2';
      var editBtn = document.createElement('button');
      editBtn.className = 'px-3 py-1 bg-white border border-black text-black rounded hover:bg-black hover:text-white transition';
      editBtn.innerText = 'Edit';
      editBtn.onclick = function() {
        window.location.href =contextPath+ '/edit?id=' + exam.id;
      };
      actionsCell.appendChild(editBtn);

      var deleteBtn = document.createElement('button');
      deleteBtn.className = 'px-3 py-1 bg-red-500 text-white rounded hover:bg-red-700 transition';
      deleteBtn.innerText = 'Delete';
      deleteBtn.onclick = function() {
        if (confirm('Are you sure you want to delete this exam?')) {
          fetch(contextPath+'/api/exams?id=' + exam.id, { method: 'DELETE' })
                  .then(function(response) { return response.json(); })
                  .then(function(result) {
                    alert(result.message || result.error);
                    fetchExams();
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
    filteredExams = exams.filter(function(exam) {
      return exam.name.toLowerCase().includes(value) ||
              exam.date.toLowerCase().includes(value) ||
              exam.time.toLowerCase().includes(value) ||
              exam.type.toLowerCase().includes(value) ||
              (exam.id + '').includes(value);
    });
    renderTable(filteredExams);
  });

  document.getElementById('pdfBtn').addEventListener('click', function() {
    var doc = new window.jspdf.jsPDF();
    doc.setFontSize(16);
    doc.text('Exams List', 14, 16);
    var startY = 24;
    var rowHeight = 10;
    doc.setFontSize(12);
    doc.text('ID', 14, startY);
    doc.text('Name', 34, startY);
    doc.text('Date', 94, startY);
    doc.text('Time', 124, startY);
    doc.text('Type', 154, startY);
    filteredExams.forEach(function(exam, idx) {
      var y = startY + rowHeight * (idx + 1);
      doc.text(String(exam.id), 14, y);
      doc.text(exam.name, 34, y);
      doc.text(exam.date, 94, y);
      doc.text(exam.time, 124, y);
      doc.text(exam.type, 154, y);
    });
    doc.save('exams.pdf');
  });

  fetchExams();
</script>
</body>
</html>