<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Create Question</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 min-h-screen">
<div class="container mx-auto py-8">
    <div class="flex items-center mb-6">
        <button id="backBtn" class="mr-4 px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Back</button>
        <h1 class="text-3xl font-bold text-gray-800">Create Question</h1>
    </div>
    <form id="questionForm" class="bg-white rounded shadow p-8 max-w-lg mx-auto">
        <div class="mb-4">
            <label class="block text-gray-700 font-semibold mb-2">Question</label>
            <input id="question" name="question" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
            <span id="questionError" class="text-red-500 text-xs"></span>
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-semibold mb-2">Answer</label>
            <input id="answer" name="answer" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
            <span id="answerError" class="text-red-500 text-xs"></span>
        </div>
        <div class="mb-6">
            <label class="block text-gray-700 font-semibold mb-2">Type</label>
            <select id="type" name="type" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required>
                <option value="">Select type</option>
                <option value="Short Answer">Short Answer</option>
                <option value="Long Answer">Long Answer</option>
            </select>
            <span id="typeError" class="text-red-500 text-xs"></span>
        </div>
        <button id="submitBtn" type="submit" class="w-full px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Create</button>
        <div id="loading" class="text-center text-gray-500 mt-4 hidden">Creating question...</div>
        <div id="successMsg" class="text-center text-green-600 mt-4 hidden"></div>
        <div id="errorMsg" class="text-center text-red-600 mt-4 hidden"></div>
    </form>
</div>
<script>
    document.getElementById('backBtn').onclick = function() {
        window.location.href = '${pageContext.request.contextPath}/';
    };

    var form = document.getElementById('questionForm');
    var loading = document.getElementById('loading');
    var successMsg = document.getElementById('successMsg');
    var errorMsg = document.getElementById('errorMsg');
    var submitBtn = document.getElementById('submitBtn');

    function validateForm(question, answer, type) {
        var valid = true;
        var questionError = document.getElementById('questionError');
        var answerError = document.getElementById('answerError');
        var typeError = document.getElementById('typeError');
        questionError.innerText = '';
        answerError.innerText = '';
        typeError.innerText = '';

        if (!/^.{3,255}$/.test(question)) {
            questionError.innerText = 'Question must be 3-255 characters.';
            valid = false;
        }
        if (!/^.{1,255}$/.test(answer)) {
            answerError.innerText = 'Answer is required (max 255 chars).';
            valid = false;
        }
        if (!/^.{1,50}$/.test(type)) {
            typeError.innerText = 'Type is required (max 50 chars).';
            valid = false;
        }
        return valid;
    }

    form.onsubmit = function(e) {
        e.preventDefault();
        successMsg.classList.add('hidden');
        errorMsg.classList.add('hidden');

        var question = document.getElementById('question').value.trim();
        var answer = document.getElementById('answer').value.trim();
        var type = document.getElementById('type').value.trim();

        if (!validateForm(question, answer, type)) {
            return;
        }

        loading.classList.remove('hidden');
        submitBtn.disabled = true;

        try {
            var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
            var url = contextPath + '/api/questions';
            fetch(url, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    question: question,
                    answer: answer,
                    type: type
                })
            })
                .then(function(response) { return response.json(); })
                .then(function(result) {
                    loading.classList.add('hidden');
                    submitBtn.disabled = false;
                    if (result.message) {
                        successMsg.innerText = result.message;
                        successMsg.classList.remove('hidden');
                        setTimeout(()=>{
                            window.location.href = contextPath + "/";
                        },1000)
                        form.reset();
                    } else {
                        errorMsg.innerText = result.error || 'Failed to create question.';
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