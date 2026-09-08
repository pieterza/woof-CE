const DEFAULT_SETTINGS = {
  enabled: false,
  username: "",
  password: "",
  proxyHost: "",
  proxyPort: "",
  maxAttemptsPerRequest: 2
};

const fields = {
  enabled: document.querySelector("#enabled"),
  username: document.querySelector("#username"),
  password: document.querySelector("#password"),
  proxyHost: document.querySelector("#proxyHost"),
  proxyPort: document.querySelector("#proxyPort"),
  maxAttemptsPerRequest: document.querySelector("#maxAttemptsPerRequest")
};

const form = document.querySelector("#settings-form");
const clearButton = document.querySelector("#clear");
const status = document.querySelector("#status");

function showStatus(message) {
  status.textContent = message;
  window.clearTimeout(showStatus.timeoutId);
  showStatus.timeoutId = window.setTimeout(() => {
    status.textContent = "";
  }, 2500);
}

async function loadSettings() {
  const settings = await chrome.storage.local.get(DEFAULT_SETTINGS);

  fields.enabled.checked = Boolean(settings.enabled);
  fields.username.value = settings.username || "";
  fields.password.value = settings.password || "";
  fields.proxyHost.value = settings.proxyHost || "";
  fields.proxyPort.value = settings.proxyPort || "";
  fields.maxAttemptsPerRequest.value = settings.maxAttemptsPerRequest || 2;
}

async function saveSettings() {
  await chrome.storage.local.set({
    enabled: fields.enabled.checked,
    username: fields.username.value.trim(),
    password: fields.password.value,
    proxyHost: fields.proxyHost.value.trim(),
    proxyPort: fields.proxyPort.value.trim(),
    maxAttemptsPerRequest: Number(fields.maxAttemptsPerRequest.value) || 2
  });

  showStatus("Saved");
}

form.addEventListener("submit", async (event) => {
  event.preventDefault();
  await saveSettings();
});

fields.enabled.addEventListener("change", saveSettings);

clearButton.addEventListener("click", async () => {
  await chrome.storage.local.set(DEFAULT_SETTINGS);
  await loadSettings();
  showStatus("Cleared");
});

loadSettings();
