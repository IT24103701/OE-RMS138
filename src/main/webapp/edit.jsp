<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Edit Student</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 min-h-screen">
  <div class="container mx-auto py-8" >
    <div class="flex items-center mb-6">
      <button id="backBtn" class="mr-4 px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Back</button>
      <h1 class="text-3xl font-bold text-gray-800">Edit Student</h1>
    </div>
    <form id="studentForm" class="bg-white rounded shadow p-8 max-w-lg mx-auto">
      <div class="mb-4">
        <label class="block text-gray-700 font-semibold mb-2">Name</label>
        <input id="name" name="name" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required pattern="^[A-Za-z ]{3,50}$" />
        <span id="nameError" class="text-red-500 text-xs hidden">Enter a valid name (3-50 letters).</span>
      </div>
      <div class="mb-4">
        <label class="block text-gray-700 font-semibold mb-2">Email</label>
        <input id="email" name="email" type="email" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
        <span id="emailError" class="text-red-500 text-xs hidden">Enter a valid email address.</span>
      </div>
      <div class="mb-4">
        <label class="block text-gray-700 font-semibold mb-2">Contact Number</label>
        <input id="contactNumber" name="contactNumber" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
        <span id="contactError" class="text-red-500 text-xs hidden">Enter a valid contact number.</span>
      </div>
      <div class="mb-6">
        <label class="block text-gray-700 font-semibold mb-2">Age</label>
        <input id="age" name="age" type="number" min="1" max="120" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required />
        <span id="ageError" class="text-red-500 text-xs hidden">Enter a valid age (1-120).</span>
      </div>
      <button id="submitBtn" type="submit" class="w-full px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Update</button>
      <div id="loading" class="text-center text-yellow-600 py-2 hidden">Updating student...</div>
      <div id="successMsg" class="text-center text-green-600 py-2 hidden">Student updated successfully!</div>
      <div id="errorMsg" class="text-center text-red-600 py-2 hidden"></div>
    </form>
  </div>
  <script>
    document.getElementById('backBtn').onclick = function() {
      window.location.href = '${pageContext.request.contextPath}/students.jsp';
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

    let studentId = getIdFromUrl();

    function populateForm(student) {
      document.getElementById('name').value = student.name || '';
      document.getElementById('email').value = student.email || '';
      document.getElementById('contactNumber').value = student.contactNumber || '';
      document.getElementById('age').value = student.age || '';
    }

    function fetchStudent() {
      document.getElementById('loading').classList.remove('hidden');
      var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
      fetch(contextPath + '/api/students?id=' + studentId)
        .then(res => {
          if (!res.ok) throw new Error('Student not found');
          return res.json();
        })
        .then(student => {
          populateForm(student);
          document.getElementById('loading').classList.add('hidden');
        })
        .catch(() => {
          document.getElementById('loading').classList.add('hidden');
          document.getElementById('errorMsg').textContent = 'Failed to load student.';
          document.getElementById('errorMsg').classList.remove('hidden');
        });
    }

    document.getElementById('studentForm').onsubmit = function(e) {
      e.preventDefault();

      // Hide all errors
      showError('nameError', false);
      showError('emailError', false);
      showError('contactError', false);
      showError('ageError', false);
      document.getElementById('successMsg').classList.add('hidden');
      document.getElementById('errorMsg').classList.add('hidden');

      // Validate fields
      let valid = true;
      if (!validateField('name', /^[A-Za-z ]{3,50}$/)) {
        showError('nameError', true); valid = false;
      }
      if (!validateField('email', /^[^@]+@[^@]+\.[^@]+$/)) {
        showError('emailError', true); valid = false;
      }
      if (!validateField('contactNumber', /^[0-9\-+() ]{7,20}$/)) {
        showError('contactError', true); valid = false;
      }
      let ageVal = document.getElementById('age').value.trim();
      let ageNum = parseInt(ageVal, 10);
      if (isNaN(ageNum) || ageNum < 1 || ageNum > 120) {
        showError('ageError', true); valid = false;
      }

      if (!valid) return;

      // Prepare payload
      const payload = {
        name: document.getElementById('name').value.trim(),
        email: document.getElementById('email').value.trim(),
        contactNumber: document.getElementById('contactNumber').value.trim(),
        age: parseInt(document.getElementById('age').value.trim(), 10)
      };

      // Show loading
      document.getElementById('loading').classList.remove('hidden');
      document.getElementById('submitBtn').disabled = true;

      var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
      fetch(contextPath + '/api/students?id=' + studentId, {
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
        document.getElementById('errorMsg').textContent = 'Failed to update student. ' + (err.message || '');
        document.getElementById('errorMsg').classList.remove('hidden');
      });
    };

    // Initial fetch
    fetchStudent();
  </script>
</body>
</html>