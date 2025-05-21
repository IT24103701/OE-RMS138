<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Exam</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 min-h-screen">
<div class="container mx-auto py-8">
    <div class="flex items-center mb-6">
        <button id="backBtn" class="mr-4 px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Back</button>
        <h1 class="text-3xl font-bold text-gray-800">Edit Exam</h1>
    </div>
    <form id="examForm" class="bg-white rounded shadow p-8 max-w-lg mx-auto">
        <div class="mb-4">
            <label class="block text-gray-700 font-semibold mb-2">Name</label>
            <input id="name" name="name" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required pattern="^[A-Za-z ]{3,50}$" />
            <span id="nameError" class="text-red-500 text-xs hidden">Enter a valid name (3-50 letters).</span>
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-semibold mb-2">Date</label>
            <input id="date" name="date" type="date" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
            <span id="dateError" class="text-red-500 text-xs hidden">Enter a valid date.</span>
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-semibold mb-2">Time</label>
            <input id="time" name="time" type="time" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
            <span id="timeError" class="text-red-500 text-xs hidden">Enter a valid time.</span>
        </div>
        <div class="mb-6">
            <label class="block text-gray-700 font-semibold mb-2">Type</label>
            <select id="type" name="type" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required>
                <option value="">Select type</option>
                <option value="Online">Online</option>
                <option value="Physical">Physical</option>
            </select>
            <span id="typeError" class="text-red-500 text-xs hidden">Select a type.</span>
        </div>
        <button id="submitBtn" type="submit" class="w-full px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Update</button>
        <div id="loading" class="text-center text-yellow-600 py-2 hidden">Updating exam...</div>
        <div id="successMsg" class="text-center text-green-600 py-2 hidden">Exam updated successfully!</div>
        <div id="errorMsg" class="text-center text-red-600 py-2 hidden"></div>
    </form>
</div>
<script>
    document.getElementById('backBtn').onclick = function() {
        window.location.href = '${pageContext.request.contextPath}/index.jsp';
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

    let examId = getIdFromUrl();

    function populateForm(exam) {
        document.getElementById('name').value = exam.name || '';
        document.getElementById('date').value = exam.date || '';
        document.getElementById('time').value = exam.time || '';
        document.getElementById('type').value = exam.type || '';
    }

    function fetchExam() {
        document.getElementById('loading').classList.remove('hidden');
        var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
        fetch(contextPath + '/api/exams?id=' + examId)
            .then(res => {
                if (!res.ok) throw new Error('Exam not found');
                return res.json();
            })
            .then(exam => {
                populateForm(exam);
                document.getElementById('loading').classList.add('hidden');
            })
            .catch(() => {
                document.getElementById('loading').classList.add('hidden');
                document.getElementById('errorMsg').textContent = 'Failed to load exam.';
                document.getElementById('errorMsg').classList.remove('hidden');
            });
    }

    document.getElementById('examForm').onsubmit = function(e) {
        e.preventDefault();

        // Hide all errors
        showError('nameError', false);
        showError('dateError', false);
        showError('timeError', false);
        showError('typeError', false);
        document.getElementById('successMsg').classList.add('hidden');
        document.getElementById('errorMsg').classList.add('hidden');

        // Validate fields
        let valid = true;
        if (!validateField('name', /^[A-Za-z ]{3,50}$/)) {
            showError('nameError', true); valid = false;
        }
        if (!validateField('date', /^\d{4}-\d{2}-\d{2}$/)) {
            showError('dateError', true); valid = false;
        }
        if (!validateField('time', /^([01]\d|2[0-3]):([0-5]\d)$/)) {
            showError('timeError', true); valid = false;
        }
        if (!document.getElementById('type').value) {
            showError('typeError', true); valid = false;
        }

        if (!valid) return;

        // Prepare payload
        const payload = {
            name: document.getElementById('name').value.trim(),
            date: document.getElementById('date').value.trim(),
            time: document.getElementById('time').value.trim(),
            type: document.getElementById('type').value.trim()
        };

        // Show loading
        document.getElementById('loading').classList.remove('hidden');
        document.getElementById('submitBtn').disabled = true;

        var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
        fetch(contextPath + '/api/exams?id=' + examId, {
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
                        window.location.href = contextPath + '/index.jsp';
                    }, 1200);
                } else {
                    return res.text().then(text => { throw new Error(text); });
                }
            })
            .catch(err => {
                document.getElementById('errorMsg').textContent = 'Failed to update exam. ' + (err.message || '');
                document.getElementById('errorMsg').classList.remove('hidden');
            });
    };

    // Initial fetch
    fetchExam();
</script>
</body>
</html>