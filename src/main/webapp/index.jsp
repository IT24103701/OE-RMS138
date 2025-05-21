<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Students List</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
</head>
<body class="bg-gray-100 min-h-screen">
    <div class="container mx-auto py-8">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-3xl font-bold text-gray-800">Students</h1>
            <a href="create" class="px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Create Student</a>
        </div>
        <div class="flex gap-4 mb-4">
            <input id="searchInput" type="text" placeholder="Search students..." class="px-3 py-2 border rounded w-full focus:outline-none focus:ring-2 focus:ring-black" />
            <button id="pdfBtn" class="px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Export PDF</button>
        </div>
        <div class="overflow-x-auto rounded shadow bg-white">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Contact Number</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Age</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                    </tr>
                </thead>
                <tbody id="studentsTable" class="bg-white divide-y divide-gray-200"></tbody>
            </table>
        </div>
    </div>
    <script>
        var students = [];
        var filteredStudents = [];
        var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
        function fetchStudents() {
            fetch(contextPath+'/api/students')
                .then(function(response) { return response.json(); })
                .then(function(data) {
                    students = data;
                    filteredStudents = students;
                    renderTable(filteredStudents);
                });
        }

        function renderTable(data) {
            var table = document.getElementById('studentsTable');
            table.innerHTML = '';
            if (data.length === 0) {
                var row = document.createElement('tr');
                var cell = document.createElement('td');
                cell.colSpan = 6;
                cell.className = 'px-6 py-4 text-center text-gray-500';
                cell.innerText = 'No students found';
                row.appendChild(cell);
                table.appendChild(row);
                return;
            }
            data.forEach(function(student) {
                var row = document.createElement('tr');
                row.className = 'hover:bg-gray-100 transition';

                var idCell = document.createElement('td');
                idCell.className = 'px-6 py-4 whitespace-nowrap';
                idCell.innerText = student.id;
                row.appendChild(idCell);

                var nameCell = document.createElement('td');
                nameCell.className = 'px-6 py-4 whitespace-nowrap';
                nameCell.innerText = student.name;
                row.appendChild(nameCell);

                var emailCell = document.createElement('td');
                emailCell.className = 'px-6 py-4 whitespace-nowrap';
                emailCell.innerText = student.email;
                row.appendChild(emailCell);

                var contactCell = document.createElement('td');
                contactCell.className = 'px-6 py-4 whitespace-nowrap';
                contactCell.innerText = student.contactNumber;
                row.appendChild(contactCell);

                var ageCell = document.createElement('td');
                ageCell.className = 'px-6 py-4 whitespace-nowrap';
                ageCell.innerText = student.age;
                row.appendChild(ageCell);

                var actionsCell = document.createElement('td');
                actionsCell.className = 'px-6 py-4 whitespace-nowrap flex gap-2';
                var editBtn = document.createElement('button');
                editBtn.className = 'px-3 py-1 bg-white border border-black text-black rounded hover:bg-black hover:text-white transition';
                editBtn.innerText = 'Edit';
                editBtn.onclick = function() {
                    window.location.href = contextPath + '/edit?id=' + student.id;
                };
                actionsCell.appendChild(editBtn);

                var deleteBtn = document.createElement('button');
                deleteBtn.className = 'px-3 py-1 bg-red-500 text-white rounded hover:bg-red-700 transition';
                deleteBtn.innerText = 'Delete';
                deleteBtn.onclick = function() {
                    if (confirm('Are you sure you want to delete this student?')) {
                        fetch(contextPath+'/api/students?id=' + student.id, { method: 'DELETE' })
                            .then(function(response) { return response.json(); })
                            .then(function(result) {
                                alert(result.message || result.error);
                                fetchStudents();
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
            filteredStudents = students.filter(function(student) {
                return student.name.toLowerCase().includes(value) ||
                       student.email.toLowerCase().includes(value) ||
                       student.contactNumber.toLowerCase().includes(value) ||
                       (student.age + '').includes(value) ||
                       (student.id + '').includes(value);
            });
            renderTable(filteredStudents);
        });

        document.getElementById('pdfBtn').addEventListener('click', function() {
            var doc = new window.jspdf.jsPDF();
            doc.setFontSize(16);
            doc.text('Students List', 14, 16);
            var startY = 24;
            var rowHeight = 10;
            doc.setFontSize(12);
            doc.text('ID', 14, startY);
            doc.text('Name', 34, startY);
            doc.text('Email', 74, startY);
            doc.text('Contact', 124, startY);
            doc.text('Age', 164, startY);
            filteredStudents.forEach(function(student, idx) {
                var y = startY + rowHeight * (idx + 1);
                doc.text(String(student.id), 14, y);
                doc.text(student.name, 34, y);
                doc.text(student.email, 74, y);
                doc.text(student.contactNumber, 124, y);
                doc.text(String(student.age), 164, y);
            });
            doc.save('students.pdf');
        });

        fetchStudents();
    </script>
</body>
</html>