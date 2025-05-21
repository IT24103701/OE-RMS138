<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Results List</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
</head>
<body class="bg-gray-100 min-h-screen">
    <div class="container mx-auto py-8">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-3xl font-bold text-gray-800">Results</h1>
            <a href="create" class="px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Create Result</a>
        </div>
        <div class="flex gap-4 mb-4">
            <input id="searchInput" type="text" placeholder="Search results..." class="px-3 py-2 border rounded w-full focus:outline-none focus:ring-2 focus:ring-black" />
            <button id="pdfBtn" class="px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Export PDF</button>
        </div>
        <div class="overflow-x-auto rounded shadow bg-white">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Student Name</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Subject</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Marks</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                    </tr>
                </thead>
                <tbody id="resultsTable" class="bg-white divide-y divide-gray-200"></tbody>
            </table>
        </div>
    </div>
    <script>
        var results = [];
        var filteredResults = [];
        var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));

        function fetchResults() {
            fetch(contextPath+'/api/results?sort=marks ')
                .then(function(response) { return response.json(); })
                .then(function(data) {
                    results = data;
                    filteredResults = results;
                    renderTable(filteredResults);
                });
        }

        function renderTable(data) {
            var table = document.getElementById('resultsTable');
            table.innerHTML = '';
            if (data.length === 0) {
                var row = document.createElement('tr');
                var cell = document.createElement('td');
                cell.colSpan = 5;
                cell.className = 'px-6 py-4 text-center text-gray-500';
                cell.innerText = 'No results found';
                row.appendChild(cell);
                table.appendChild(row);
                return;
            }
            data.forEach(function(result) {
                var row = document.createElement('tr');
                row.className = 'hover:bg-gray-100 transition';

                var idCell = document.createElement('td');
                idCell.className = 'px-6 py-4 whitespace-nowrap';
                idCell.innerText = result.id;
                row.appendChild(idCell);

                var studentNameCell = document.createElement('td');
                studentNameCell.className = 'px-6 py-4 whitespace-nowrap';
                studentNameCell.innerText = result.studentName;
                row.appendChild(studentNameCell);

                var subjectCell = document.createElement('td');
                subjectCell.className = 'px-6 py-4 whitespace-nowrap';
                subjectCell.innerText = result.subject;
                row.appendChild(subjectCell);

                var marksCell = document.createElement('td');
                marksCell.className = 'px-6 py-4 whitespace-nowrap';
                marksCell.innerText = result.marks;
                // Conditional formatting for marks
                if (result.marks < 40) {
                    marksCell.classList.add('text-red-500', 'font-bold');
                } else if (result.marks >= 40 && result.marks < 75) {
                    marksCell.classList.add('text-yellow-500');
                } else {
                    marksCell.classList.add('text-green-500', 'font-bold');
                }
                row.appendChild(marksCell);

                var actionsCell = document.createElement('td');
                actionsCell.className = 'px-6 py-4 whitespace-nowrap flex gap-2';
                var editBtn = document.createElement('button');
                editBtn.className = 'px-3 py-1 bg-white border border-black text-black rounded hover:bg-black hover:text-white transition';
                editBtn.innerText = 'Edit';
                editBtn.onclick = function() {
                    window.location.href = contextPath + '/edit?id=' + result.id;
                };
                actionsCell.appendChild(editBtn);

                var deleteBtn = document.createElement('button');
                deleteBtn.className = 'px-3 py-1 bg-red-500 text-white rounded hover:bg-red-700 transition';
                deleteBtn.innerText = 'Delete';
                deleteBtn.onclick = function() {
                    if (confirm('Are you sure you want to delete this result?')) {
                        fetch(contextPath+'/api/results?id=' + result.id, { method: 'DELETE' })
                            .then(function(response) { return response.json(); })
                            .then(function(result) {
                                alert(result.message || result.error);
                                fetchResults();
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
            filteredResults = results.filter(function(result) {
                return (result.studentName && result.studentName.toLowerCase().includes(value)) ||
                       (result.subject && result.subject.toLowerCase().includes(value)) ||
                       (result.marks + '').includes(value) ||
                       (result.id + '').includes(value);
            });
            renderTable(filteredResults);
        });

        document.getElementById('pdfBtn').addEventListener('click', function() {
            var doc = new window.jspdf.jsPDF();
            doc.setFontSize(16);
            doc.text('Results List', 14, 16);
            var startY = 24;
            var rowHeight = 10;
            doc.setFontSize(12);
            doc.text('ID', 14, startY);
            doc.text('Student Name', 34, startY);
            doc.text('Subject', 104, startY);
            doc.text('Marks', 164, startY);
            filteredResults.forEach(function(result, idx) {
                var y = startY + rowHeight * (idx + 1);
                doc.text(String(result.id), 14, y);
                doc.text(result.studentName, 34, y);
                doc.text(result.subject, 104, y);
                doc.text(result.marks.toString(), 164, y);
            });
            doc.save('results.pdf');
        });

        fetchResults();
    </script>
</body>
</html>