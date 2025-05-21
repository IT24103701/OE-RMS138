<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Edit Result</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 min-h-screen">
  <div class="container mx-auto py-8">
    <div class="flex items-center mb-6">
      <button id="backBtn" class="mr-4 px-4 py-2 bg-white border border-black text-black rounded shadow hover:bg-black hover:text-white transition">Back</button>
      <h1 class="text-3xl font-bold text-gray-800">Edit Result</h1>
    </div>
    <form id="resultForm" class="bg-white rounded shadow p-8 max-w-lg mx-auto">
      <div class="mb-4">
        <label class="block text-gray-700 font-semibold mb-2">Student Name</label>
        <input id="studentName" name="studentName" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required pattern=".{3,255}" />
        <span id="studentNameError" class="text-red-500 text-xs hidden">Enter a valid student name (3-255 characters).</span>
      </div>
      <div class="mb-4">
        <label class="block text-gray-700 font-semibold mb-2">Subject</label>
        <input id="subject" name="subject" type="text" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required pattern=".{1,255}" />
        <span id="subjectError" class="text-red-500 text-xs hidden">Enter a valid subject.</span>
      </div>
      <div class="mb-6">
        <label class="block text-gray-700 font-semibold mb-2">Marks</label>
        <input id="marks" name="marks" type="number" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-black" required min="0" max="100" />
        <span id="marksError" class="text-red-500 text-xs hidden">Enter valid marks (0-100).</span>
      </div>
      <button id="submitBtn" type="submit" class="w-full px-4 py-2 bg-black text-white rounded shadow hover:bg-gray-800 transition">Update</button>
      <div id="loading" class="text-center text-yellow-600 py-2 hidden">Updating result...</div>
      <div id="successMsg" class="text-center text-green-600 py-2 hidden">Result updated successfully!</div>
      <div id="errorMsg" class="text-center text-red-600 py-2 hidden"></div>
    </form>
  </div>
  <script>
    document.getElementById('backBtn').onclick = function() {
      window.location.href = '${pageContext.request.contextPath}/';
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

    let resultId = getIdFromUrl();

    function populateForm(result) {
      document.getElementById('studentName').value = result.studentName || '';
      document.getElementById('subject').value = result.subject || '';
      document.getElementById('marks').value = result.marks || '';
    }

    function fetchResult() {
      document.getElementById('loading').classList.remove('hidden');
      var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
      fetch(contextPath + '/api/results?id=' + resultId)
        .then(res => {
          if (!res.ok) throw new Error('Result not found');
          return res.json();
        })
        .then(result => {
          populateForm(result);
          document.getElementById('loading').classList.add('hidden');
        })
        .catch(() => {
          document.getElementById('loading').classList.add('hidden');
          document.getElementById('errorMsg').textContent = 'Failed to load result.';
          document.getElementById('errorMsg').classList.remove('hidden');
        });
    }

    document.getElementById('resultForm').onsubmit = function(e) {
      e.preventDefault();

      // Hide all errors
      showError('studentNameError', false);
      showError('subjectError', false);
      showError('marksError', false);
      document.getElementById('successMsg').classList.add('hidden');
      document.getElementById('errorMsg').classList.add('hidden');

      // Validate fields
      let valid = true;
      if (!validateField('studentName', /^.{3,255}$/)) {
        showError('studentNameError', true); valid = false;
      }
      if (!validateField('subject', /^.{1,255}$/)) {
        showError('subjectError', true); valid = false;
      }
      const marks = parseInt(document.getElementById('marks').value.trim());
      if (isNaN(marks) || marks < 0 || marks > 100) {
        showError('marksError', true); valid = false;
      }

      if (!valid) return;

      // Prepare payload
      const payload = {
        studentName: document.getElementById('studentName').value.trim(),
        subject: document.getElementById('subject').value.trim(),
        marks: marks
      };

      // Show loading
      document.getElementById('loading').classList.remove('hidden');
      document.getElementById('submitBtn').disabled = true;

      var contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
      fetch(contextPath + '/api/results?id=' + resultId, {
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
        document.getElementById('errorMsg').textContent = 'Failed to update result. ' + (err.message || '');
        document.getElementById('errorMsg').classList.remove('hidden');
      });
    };

    // Initial fetch
    fetchResult();
  </script>
</body>
</html>