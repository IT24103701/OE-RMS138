<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Create Result</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 min-h-screen">
    <div class="container mx-auto py-8">
        <div class="flex items-center mb-6">
            <button id="backBtn" class="mr-4 px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Back</button>
            <h1 class="text-3xl font-bold text-gray-800">Create Result</h1>
        </div>
        <form id="resultForm" class="bg-white rounded shadow p-8 max-w-lg mx-auto">
            <div class="mb-4">
                <label class="block text-gray-700 font-semibold mb-2">Student Name</label>
                <input id="studentName" name="studentName" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
                <span id="studentNameError" class="text-red-500 text-xs"></span>
            </div>
            <div class="mb-4">
                <label class="block text-gray-700 font-semibold mb-2">Subject</label>
                <input id="subject" name="subject" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
                <span id="subjectError" class="text-red-500 text-xs"></span>
            </div>
            <div class="mb-6">
                <label class="block text-gray-700 font-semibold mb-2">Marks</label>
                <input id="marks" name="marks" type="number" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
                <span id="marksError" class="text-red-500 text-xs"></span>
            </div>
            <button id="submitBtn" type="submit" class="w-full px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Create</button>
            <div id="loading" class="text-center text-gray-500 mt-4 hidden">Creating result...</div>
            <div id="successMsg" class="text-center text-green-600 mt-4 hidden"></div>
            <div id="errorMsg" class="text-center text-red-600 mt-4 hidden"></div>
        </form>
    </div>
    <script>
        document.getElementById('backBtn').onclick = function() {
            window.location.href = '${pageContext.request.contextPath}/';
        };

        var form = document.getElementById('resultForm');
        var loading = document.getElementById('loading');
        var successMsg = document.getElementById('successMsg');
        var errorMsg = document.getElementById('errorMsg');
        var submitBtn = document.getElementById('submitBtn');

        function validateForm(studentName, subject, marks) {
            var valid = true;
            var studentNameError = document.getElementById('studentNameError');
            var subjectError = document.getElementById('subjectError');
            var marksError = document.getElementById('marksError');
            studentNameError.innerText = '';
            subjectError.innerText = '';
            marksError.innerText = '';

            if (!/^.{3,255}$/.test(studentName)) {
                studentNameError.innerText = 'Student name must be 3-255 characters.';
                valid = false;
            }
            if (!/^.{1,255}$/.test(subject)) {
                subjectError.innerText = 'Subject is required (max 255 chars).';
                valid = false;
            }
            if (isNaN(marks) || marks < 0 || marks > 100) {
                marksError.innerText = 'Marks must be between 0 and 100.';
                valid = false;
            }
            return valid;
        }

        form.onsubmit = function(e) {
            e.preventDefault();
            successMsg.classList.add('hidden');
            errorMsg.classList.add('hidden');

            var studentName = document.getElementById('studentName').value.trim();
            var subject = document.getElementById('subject').value.trim();
            var marks = parseInt(document.getElementById('marks').value.trim());

            if (!validateForm(studentName, subject, marks)) {
                return;
            }

            loading.classList.remove('hidden');
            submitBtn.disabled = true;

            try {
                var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
                var url = contextPath + '/api/results';
                fetch(url, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        studentName: studentName,
                        subject: subject,
                        marks: marks
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
                        errorMsg.innerText = result.error || 'Failed to create result.';
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