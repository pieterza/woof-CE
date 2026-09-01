const DEFAULT_SETTINGS = {
  enabled: false,
  username: "",
  password: "",
  proxyHost: "",
  proxyPort: "",
  maxAttemptsPerRequest: 2
};

const attemptCounts = new Map();

async function getSettings() {
  const stored = await chrome.storage.local.get(DEFAULT_SETTINGS);
  return { ...DEFAULT_SETTINGS, ...stored };
}

function proxyMatches(details, settings) {
  if (!details.isProxy) {
    return false;
  }

  const challenger = details.challenger || {};
  const configuredHost = settings.proxyHost.trim().toLowerCase();
  const configuredPort = String(settings.proxyPort).trim();

  if (configuredHost && challenger.host?.toLowerCase() !== configuredHost) {
    return false;
  }

  if (configuredPort && String(challenger.port || "") !== configuredPort) {
    return false;
  }

  return true;
}

function rememberAttempt(requestId, maxAttempts) {
  const nextCount = (attemptCounts.get(requestId) || 0) + 1;
  attemptCounts.set(requestId, nextCount);
  return nextCount <= maxAttempts;
}

function forgetAttempt(details) {
  attemptCounts.delete(details.requestId);
}

chrome.webRequest.onAuthRequired.addListener(
  (details, callback) => {
    getSettings()
      .then((settings) => {
        const maxAttempts = Number(settings.maxAttemptsPerRequest) || 1;

        if (
          !settings.enabled ||
          !settings.username ||
          !settings.password ||
          !proxyMatches(details, settings) ||
          !rememberAttempt(details.requestId, maxAttempts)
        ) {
          callback({});
          return;
        }

        callback({
          authCredentials: {
            username: settings.username,
            password: settings.password
          }
        });
      })
      .catch(() => {
        callback({});
      });
  },
  { urls: ["<all_urls>"] },
  ["asyncBlocking"]
);

chrome.webRequest.onCompleted.addListener(forgetAttempt, { urls: ["<all_urls>"] });
chrome.webRequest.onErrorOccurred.addListener(forgetAttempt, { urls: ["<all_urls>"] });
