<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Question</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 min-h-screen">
<div class="container mx-auto py-8">
    <div class="flex items-center mb-6">
        <button id="backBtn" class="mr-4 px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Back</button>
        <h1 class="text-3xl font-bold text-gray-800">Edit Question</h1>
    </div>
    <form id="questionForm" class="bg-white rounded shadow p-8 max-w-lg mx-auto">
        <div class="mb-4">
            <label class="block text-gray-700 font-semibold mb-2">Question</label>
            <input id="question" name="question" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required pattern=".{3,255}" />
            <span id="questionError" class="text-red-500 text-xs hidden">Enter a valid question (3-255 characters).</span>
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-semibold mb-2">Answer</label>
            <input id="answer" name="answer" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required pattern=".{1,255}" />
            <span id="answerError" class="text-red-500 text-xs hidden">Enter a valid answer.</span>
        </div>
        <div class="mb-6">
            <label class="block text-gray-700 font-semibold mb-2">Type</label>
            <select id="type" name="type" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required>
                <option value="">Select type</option>
                <option value="Short Answer">Short Answer</option>
                <option value="Long Answer">Long Answer</option>
            </select>
            <span id="typeError" class="text-red-500 text-xs hidden">Enter a valid type.</span>
        </div>
        <button id="submitBtn" type="submit" class="w-full px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Update</button>
        <div id="loading" class="text-center text-yellow-600 py-2 hidden">Updating question...</div>
        <div id="successMsg" class="text-center text-green-600 py-2 hidden">Question updated successfully!</div>
        <div id="errorMsg" class="text-center text-red-600 py-2 hidden"></div>
    </form>
</div>
<script>
    document.getElementById('backBtn').onclick = function() {
        window.location.href = '${pageContext.request.contextPath}/questions.jsp';
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

    let questionId = getIdFromUrl();

    function populateForm(question) {
        document.getElementById('question').value = question.question || '';
        document.getElementById('answer').value = question.answer || '';
        // Set the dropdown value for type
        document.getElementById('type').value = question.type || '';
    }

    function fetchQuestion() {
        document.getElementById('loading').classList.remove('hidden');
        var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
        fetch(contextPath + '/api/questions?id=' + questionId)
            .then(res => {
                if (!res.ok) throw new Error('Question not found');
                return res.json();
            })
            .then(question => {
                populateForm(question);
                document.getElementById('loading').classList.add('hidden');
            })
            .catch(() => {
                document.getElementById('loading').classList.add('hidden');
                document.getElementById('errorMsg').textContent = 'Failed to load question.';
                document.getElementById('errorMsg').classList.remove('hidden');
            });
    }

    document.getElementById('questionForm').onsubmit = function(e) {
        e.preventDefault();

        // Hide all errors
        showError('questionError', false);
        showError('answerError', false);
        showError('typeError', false);
        document.getElementById('successMsg').classList.add('hidden');
        document.getElementById('errorMsg').classList.add('hidden');

        // Validate fields
        let valid = true;
        if (!validateField('question', /^.{3,255}$/)) {
            showError('questionError', true); valid = false;
        }
        if (!validateField('answer', /^.{1,255}$/)) {
            showError('answerError', true); valid = false;
        }
        if (!document.getElementById('type').value) {
            showError('typeError', true); valid = false;
        }

        if (!valid) return;

        // Prepare payload
        const payload = {
            question: document.getElementById('question').value.trim(),
            answer: document.getElementById('answer').value.trim(),
            type: document.getElementById('type').value.trim()
        };

        // Show loading
        document.getElementById('loading').classList.remove('hidden');
        document.getElementById('submitBtn').disabled = true;

        var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
        fetch(contextPath + '/api/questions?id=' + questionId, {
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
                document.getElementById('errorMsg').textContent = 'Failed to update question. ' + (err.message || '');
                document.getElementById('errorMsg').classList.remove('hidden');
            });
    };

    // Initial fetch
    fetchQuestion();
</script>
</body>
</html>