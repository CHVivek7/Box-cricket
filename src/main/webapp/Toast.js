/**
 * Styles for custom toast notifications
 */
const styles = `
.custom-toast {
    border-radius: 10px;
    font-size: 16px;
    width: 300px;
    background: white;
    transition: transform 0.5s ease-in-out, opacity 0.5s ease-in-out;
    position: fixed;
    top: 100px;
    right: -350px;
    opacity: 0;
    z-index: 9999;
    display: flex;
    flex-direction: column;
    padding: 15px;
    font-family: 'Calibri', sans-serif; /* Apply Calibri (Body) font */
    font-weight: 500;
    color: black;
    text-shadow: none; /* Ensure NO text shadow */
	font-size: 20px;
	font-weight: 400px;
}

/* Show & Hide */
.custom-toast.show {
    right: 20px;
    opacity: 1;
}

.custom-toast.hide {
    right: -350px;
    opacity: 0;
}

/* Toast Content */
.custom-toast .content {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 16px; /* Ensure same size */
    text-shadow: none; /* Remove any text shadow */
}

/* Text inside toast */
.custom-toast span {
    overflow: visible;
    flex-grow: 1;
    text-shadow: none; /* Remove text shadow */
}

/* Close Button */
.custom-toast .close-btn {
    background: none;
    border: none;
    font-size: 18px;
    font-weight: bold;
    color: red;
    cursor: pointer;
}

.custom-toast .close-btn:hover {
    color: darkred;
    font-size: 20px;
}

/* Success Toast */
.custom-toast.success {
    background: white;
    border-left: 5px solid #25c561;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* Shadow only for success */
}

.custom-toast.success .content i {
    color: #25c561;
    font-size: 24px;
}

/* Error Toast (No Shadow) */
.custom-toast.error {
    background: white;
    border-left: 5px solid red;
    box-shadow: none; /* Remove box shadow */
	font-size: 24px;
}

.custom-toast.error .content i {
    color: red;
    font-size: 24px;
}

/* Progress Bar */
.custom-toast .progress-bar {
    position: relative;
    width: 100%;
    height: 5px;
    background-color: black;
    border-radius: 0 0 10px 10px;
    margin-top: 10px;
}

.custom-toast.success .progress-bar span {
    display: block;
    height: 100%;
    width: 0;
    background-color: #25c561;
    transition: width 3s linear;
}

.custom-toast.error .progress-bar span {
    display: block;
    height: 100%;
    width: 0;
    background-color: #f44336;
    transition: width 3s linear;
}
`;

// Append styles to the document head
const styleSheet = document.createElement("style");
styleSheet.type = "text/css";
styleSheet.innerText = styles;
document.head.appendChild(styleSheet);

/**
 * Function to show a custom toast notification
 * @param {string} message - The message to display
 * @param {string} type - The type of toast ("success" or "error")
 */
function showToast(message, type) {
    const toast = document.createElement("div");
    toast.className = `custom-toast ${type}`;

    // Choose icon based on type
    const iconHtml = type === "success"
        ? `<i class="fas fa-check-circle"></i>`
        : `<i class="fas fa-times-circle"></i>`;

    // Create toast content
    toast.innerHTML = `
        <div class="content">
            ${iconHtml}
            <span>${message}</span>
            <button class="close-btn" onclick="this.parentElement.parentElement.remove();">x</button>
        </div>
        <div class="progress-bar"><span></span></div>
    `;

    // Append to body
    document.body.appendChild(toast);

    // Show toast
    setTimeout(() => toast.classList.add("show"), 100);

    // Animate progress bar
    const progressBar = toast.querySelector(".progress-bar span");
    setTimeout(() => (progressBar.style.width = "100%"), 100);

    // Remove after 3s
    setTimeout(() => {
        toast.classList.remove("show");
        toast.classList.add("hide");
        toast.addEventListener("transitionend", () => toast.remove());
    }, 3000);
}

// Map toast types to messages
const toastMessages = {
    verifysuccess: { text: "OTP sent successfully!", type: "success" },
    otpsuccess: { text: "OTP Verified!", type: "success" },
    updatesuccess: { text: "Password updated", type: "success" },
    loginsuccess: { text: "Login successful", type: "success" },
    registersuccess: { text: "Registration Success", type: "success" },
    emailerror: { text: "Invalid email, try again.", type: "error" },
    otperror: { text: "Invalid OTP.", type: "error" },
    updateerror: { text: "Password doesn't match", type: "error" },
    loginerror: { text: "Invalid login details", type: "error" },
    errorphone: { text: "Invalid phone number", type: "error" },
    accountexist: { text: "Account already exists", type: "error" },
    errorpass: { text: "Passwords don't match", type: "error" },
};

// Check URL parameters for toast type
const urlParams = new URLSearchParams(window.location.search);
const toastType = urlParams.get("toast");

if (toastType && toastMessages[toastType]) {
    const { text, type } = toastMessages[toastType];
    showToast(text, type);
}
