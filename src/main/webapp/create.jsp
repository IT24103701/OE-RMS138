<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Create Feedback</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 min-h-screen">
    <div class="container mx-auto py-8">
        <div class="flex items-center mb-6">
            <button id="backBtn" class="mr-4 px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Back</button>
            <h1 class="text-3xl font-bold text-gray-800">Create Feedback</h1>
        </div>
        <form id="feedbackForm" class="bg-white rounded shadow p-8 max-w-lg mx-auto">
            <div class="mb-4">
                <label class="block text-gray-700 font-semibold mb-2">Message</label>
                <input id="message" name="message" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
                <span id="messageError" class="text-red-500 text-xs"></span>
            </div>
            <div class="mb-4">
                <label class="block text-gray-700 font-semibold mb-2">Feedback</label>
                <textarea id="feedback" name="feedback" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required></textarea>
                <span id="feedbackError" class="text-red-500 text-xs"></span>
            </div>
            <div class="mb-6">
                <label class="block text-gray-700 font-semibold mb-2">Rating</label>
                <div class="flex items-center">
                    <input type="hidden" id="rating" name="rating" value="0" required>
                    <div class="flex space-x-1">
                        <span class="text-2xl cursor-pointer" onclick="setRating(1)">☆</span>
                        <span class="text-2xl cursor-pointer" onclick="setRating(2)">☆</span>
                        <span class="text-2xl cursor-pointer" onclick="setRating(3)">☆</span>
                        <span class="text-2xl cursor-pointer" onclick="setRating(4)">☆</span>
                        <span class="text-2xl cursor-pointer" onclick="setRating(5)">☆</span>
                    </div>
                    <span id="ratingValue" class="ml-2 text-gray-600">0/5</span>
                </div>
                <span id="ratingError" class="text-red-500 text-xs"></span>
            </div>
                <label class="block text-gray-700 font-semibold mb-2">Feedback Type</label>
                <select id="feedbackType" name="feedbackType" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required>
                    <option value="">Select feedback type</option>
                    <option value="Happy">Happy 😊</option>
                    <option value="Satisfied">Satisfied 🙂</option>
                    <option value="Neutral">Neutral 😐</option>
                    <option value="Disappointed">Disappointed 😕</option>
                    <option value="Frustrated">Frustrated 😠</option>
                    <option value="Other">Other</option>
                </select>
                <span id="feedbackTypeError" class="text-red-500 text-xs"></span>
            </div>
            <button id="submitBtn" type="submit" class="w-full px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Create</button>
            <div id="loading" class="text-center text-gray-500 mt-4 hidden">Creating feedback...</div>
            <div id="successMsg" class="text-center text-green-600 mt-4 hidden"></div>
            <div id="errorMsg" class="text-center text-red-600 mt-4 hidden"></div>
        </form>
    </div>
    <script>
        document.getElementById('backBtn').onclick = function() {
            window.location.href = '${pageContext.request.contextPath}/';
        };

        var form = document.getElementById('feedbackForm');
        var loading = document.getElementById('loading');
        var successMsg = document.getElementById('successMsg');
        var errorMsg = document.getElementById('errorMsg');
        var submitBtn = document.getElementById('submitBtn');

        function validateForm(message, feedback, feedbackType) {
            var valid = true;
            var messageError = document.getElementById('messageError');
            var feedbackError = document.getElementById('feedbackError');
            var feedbackTypeError = document.getElementById('feedbackTypeError');
            messageError.innerText = '';
            feedbackError.innerText = '';
            feedbackTypeError.innerText = '';

            if (!/^.{3,255}$/.test(message)) {
                messageError.innerText = 'Message must be 3-255 characters.';
                valid = false;
            }
            if (!feedback.trim()) {
                feedbackError.innerText = 'Feedback is required.';
                valid = false;
            }
            if (!feedbackType) {
                feedbackTypeError.innerText = 'Feedback type is required.';
                valid = false;
            }
            return valid;
        }

        form.onsubmit = function(e) {
            e.preventDefault();
            successMsg.classList.add('hidden');
            errorMsg.classList.add('hidden');

            var message = document.getElementById('message').value.trim();
            var feedback = document.getElementById('feedback').value.trim();
            var feedbackType = document.getElementById('feedbackType').value;

            if (!validateForm(message, feedback, feedbackType)) {
                return;
            }

            loading.classList.remove('hidden');
            submitBtn.disabled = true;

            try {
                var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
                var url = contextPath + '/api/feedbacks';
                fetch(url, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        message: message,
                        feedback: feedback,
                        feedbackType: feedbackType
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
                        errorMsg.innerText = result.error || 'Failed to create feedback.';
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

<script>
    function setRating(rating) {
        document.getElementById('rating').value = rating;
        const stars = document.querySelectorAll('.flex.space-x-1 span');
        stars.forEach((star, index) => {
            star.textContent = index < rating ? '★' : '☆';
        });
        document.getElementById('ratingValue').textContent = `${rating}/5`;
    }

    function validateForm(message, feedback, feedbackType, rating) {
        var valid = true;
        if (rating < 1 || rating > 5) {
            document.getElementById('ratingError').innerText = 'Please select a rating between 1-5 stars.';
            valid = false;
        }
        return valid;
    }

    form.onsubmit = function(e) {
        e.preventDefault();
        successMsg.classList.add('hidden');
        errorMsg.classList.add('hidden');

        var message = document.getElementById('message').value.trim();
        var feedback = document.getElementById('feedback').value.trim();
        var feedbackType = document.getElementById('feedbackType').value;
        var rating = parseInt(document.getElementById('rating').value);

        if (!validateForm(message, feedback, feedbackType, rating)) {
            return;
        }

        loading.classList.remove('hidden');
        submitBtn.disabled = true;

        try {
            var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
            var url = contextPath + '/api/feedbacks';
            var rating = parseInt(document.getElementById('rating').value);
            fetch(url, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    message: message,
                    feedback: feedback,
                    feedbackType: feedbackType,
                    rating: rating
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
                    errorMsg.innerText = result.error || 'Failed to create feedback.';
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