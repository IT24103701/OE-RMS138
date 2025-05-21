<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Create Student</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 min-h-screen">
    <div class="container mx-auto py-8">
        <div class="flex items-center mb-6">
            <button id="backBtn" class="mr-4 px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Back</button>
            <h1 class="text-3xl font-bold text-gray-800">Create Student</h1>
        </div>
        <form id="studentForm" class="bg-white rounded shadow p-8 max-w-lg mx-auto">
            <div class="mb-4">
                <label class="block text-gray-700 font-semibold mb-2">Name</label>
                <input id="name" name="name" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
                <span id="nameError" class="text-red-500 text-xs"></span>
            </div>
            <div class="mb-4">
                <label class="block text-gray-700 font-semibold mb-2">Email</label>
                <input id="email" name="email" type="email" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
                <span id="emailError" class="text-red-500 text-xs"></span>
            </div>
            <div class="mb-4">
                <label class="block text-gray-700 font-semibold mb-2">Contact Number</label>
                <input id="contactNumber" name="contactNumber" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
                <span id="contactError" class="text-red-500 text-xs"></span>
            </div>
            <div class="mb-6">
                <label class="block text-gray-700 font-semibold mb-2">Age</label>
                <input id="age" name="age" type="number" min="1" max="120" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
                <span id="ageError" class="text-red-500 text-xs"></span>
            </div>
            <button id="submitBtn" type="submit" class="w-full px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Create</button>
            <div id="loading" class="text-center text-gray-500 mt-4 hidden">Creating student...</div>
            <div id="successMsg" class="text-center text-green-600 mt-4 hidden"></div>
            <div id="errorMsg" class="text-center text-red-600 mt-4 hidden"></div>
        </form>
    </div>
    <script>
        document.getElementById('backBtn').onclick = function() {
            window.history.back();
        };

        var form = document.getElementById('studentForm');
        var loading = document.getElementById('loading');
        var successMsg = document.getElementById('successMsg');
        var errorMsg = document.getElementById('errorMsg');
        var submitBtn = document.getElementById('submitBtn');

        function validateForm(name, email, contact, age) {
            var valid = true;
            var nameError = document.getElementById('nameError');
            var emailError = document.getElementById('emailError');
            var contactError = document.getElementById('contactError');
            var ageError = document.getElementById('ageError');
            nameError.innerText = '';
            emailError.innerText = '';
            contactError.innerText = '';
            ageError.innerText = '';

            var namePattern = /^[A-Za-z ]{3,50}$/;
            if (!namePattern.test(name)) {
                nameError.innerText = 'Name must be 3-50 letters or spaces.';
                valid = false;
            }
            var emailPattern = /^[^@]+@[^@]+\.[^@]+$/;
            if (!emailPattern.test(email)) {
                emailError.innerText = 'Enter a valid email address.';
                valid = false;
            }
            var contactPattern = /^[0-9\-+() ]{7,20}$/;
            if (!contactPattern.test(contact)) {
                contactError.innerText = 'Enter a valid contact number.';
                valid = false;
            }
            var ageNum = parseInt(age, 10);
            if (isNaN(ageNum) || ageNum < 1 || ageNum > 120) {
                ageError.innerText = 'Enter a valid age (1-120).';
                valid = false;
            }
            return valid;
        }

        form.onsubmit = function(e) {
            e.preventDefault();
            successMsg.classList.add('hidden');
            errorMsg.classList.add('hidden');

            var name = document.getElementById('name').value.trim();
            var email = document.getElementById('email').value.trim();
            var contact = document.getElementById('contactNumber').value.trim();
            var age = document.getElementById('age').value.trim();

            if (!validateForm(name, email, contact, age)) {
                return;
            }

            loading.classList.remove('hidden');
            submitBtn.disabled = true;

            try {
                var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
                var url = contextPath + '/api/students';
                fetch(url, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        name: name,
                        email: email,
                        contactNumber: contact,
                        age: parseInt(age, 10)
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
                            window.location.href = contextPath+"/"
                        },1000)
                        form.reset();
                    } else {
                        errorMsg.innerText = result.error || 'Failed to create student.';
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