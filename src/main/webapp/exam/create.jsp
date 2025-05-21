<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Create Exam</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 min-h-screen">
<div class="container mx-auto py-8">
    <div class="flex items-center mb-6">
        <button id="backBtn" class="mr-4 px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Back</button>
        <h1 class="text-3xl font-bold text-gray-800">Create Exam</h1>
    </div>
    <form id="examForm" class="bg-white rounded shadow p-8 max-w-lg mx-auto">
        <div class="mb-4">
            <label class="block text-gray-700 font-semibold mb-2">Name</label>
            <input id="name" name="name" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
            <span id="nameError" class="text-red-500 text-xs"></span>
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-semibold mb-2">Date</label>
            <input id="date" name="date" type="date" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
            <span id="dateError" class="text-red-500 text-xs"></span>
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-semibold mb-2">Time</label>
            <input id="time" name="time" type="time" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
            <span id="timeError" class="text-red-500 text-xs"></span>
        </div>
        <div class="mb-6">
            <label class="block text-gray-700 font-semibold mb-2">Type</label>
            <select id="type" name="type" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required>
                <option value="">Select type</option>
                <option value="Online">Online</option>
                <option value="Physical">Physical</option>
            </select>
            <span id="typeError" class="text-red-500 text-xs"></span>
        </div>
        <button id="submitBtn" type="submit" class="w-full px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Create</button>
        <div id="loading" class="text-center text-gray-500 mt-4 hidden">Creating exam...</div>
        <div id="successMsg" class="text-center text-green-600 mt-4 hidden"></div>
        <div id="errorMsg" class="text-center text-red-600 mt-4 hidden"></div>
    </form>
</div>
<script>
    document.getElementById('backBtn').onclick = function() {
        window.history.back();
    };

    // Set min date to today for date input
    var dateInput = document.getElementById('date');
    var today = new Date();
    var yyyy = today.getFullYear();
    var mm = String(today.getMonth() + 1).padStart(2, '0');
    var dd = String(today.getDate()).padStart(2, '0');
    var minDate = yyyy + '-' + mm + '-' + dd;
    dateInput.setAttribute('min', minDate);

    var form = document.getElementById('examForm');
    var loading = document.getElementById('loading');
    var successMsg = document.getElementById('successMsg');
    var errorMsg = document.getElementById('errorMsg');
    var submitBtn = document.getElementById('submitBtn');

    function validateForm(name, date, time, type) {
        var valid = true;
        var nameError = document.getElementById('nameError');
        var dateError = document.getElementById('dateError');
        var timeError = document.getElementById('timeError');
        var typeError = document.getElementById('typeError');
        nameError.innerText = '';
        dateError.innerText = '';
        timeError.innerText = '';
        typeError.innerText = '';

        var namePattern = /^[A-Za-z0-9\s\-]{3,50}$/;
        if (!namePattern.test(name)) {
            nameError.innerText = 'Name must be 3-50 characters, letters, numbers, spaces, or hyphens.';
            valid = false;
        }
        var datePattern = /^\d{4}-\d{2}-\d{2}$/;
        if (!datePattern.test(date)) {
            dateError.innerText = 'Date must be in YYYY-MM-DD format.';
            valid = false;
        } else {
            var selectedDate = new Date(date);
            if (selectedDate < today.setHours(0,0,0,0)) {
                dateError.innerText = 'Date cannot be in the past.';
                valid = false;
            }
        }
        var timePattern = /^\d{2}:\d{2}$/;
        if (!timePattern.test(time)) {
            timeError.innerText = 'Time must be in HH:MM format.';
            valid = false;
        }
        if (type !== 'Online' && type !== 'Physical') {
            typeError.innerText = 'Please select a valid type.';
            valid = false;
        }
        return valid;
    }

    form.onsubmit = function(e) {
        e.preventDefault();
        successMsg.classList.add('hidden');
        errorMsg.classList.add('hidden');

        var name = document.getElementById('name').value.trim();
        var date = document.getElementById('date').value.trim();
        var time = document.getElementById('time').value.trim();
        var type = document.getElementById('type').value.trim();

        if (!validateForm(name, date, time, type)) {
            return;
        }

        loading.classList.remove('hidden');
        submitBtn.disabled = true;

        try {
            var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
            var url = contextPath + '/api/exams';
            fetch(url, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: '{' +
                    '"name":"' + name.replace(/"/g, '\\"') + '",' +
                    '"date":"' + date + '",' +
                    '"time":"' + time + '",' +
                    '"type":"' + type.replace(/"/g, '\\"') + '"' +
                    '}'
            })
                .then(function(response) { return response.json(); })
                .then(function(result) {
                    loading.classList.add('hidden');
                    submitBtn.disabled = false;
                    if (result.message) {
                        successMsg.innerText = result.message;
                        successMsg.classList.remove('hidden');
                        setTimeout(()=>{
                            window.location.href = contextPath+"/"
                        },1000)
                        form.reset();
                    } else {
                        errorMsg.innerText = result.error || 'Failed to create exam.';
                        errorMsg.classList.remove('hidden');
                    }
                })
                .catch(function(error) {
                    loading.classList.add('hidden');
                    submitBtn.disabled = false;
                    errorMsg.innerText = 'Network error. Please try again.';
                    errorMsg.classList.remove('hidden');
                });
        } catch (err) {
            loading.classList.add('hidden');
            submitBtn.disabled = false;
            errorMsg.innerText = 'Unexpected error. Please try again.';
            errorMsg.classList.remove('hidden');
        }
    };
</script>
</body>
</html>