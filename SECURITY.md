# Security Policy

## Supported Versions

Security updates are actively maintained for the following versions of TIMEFLOW:

| Version | Supported |
|---|:---:|
| `0.6.x` / `1.0.x` | :white_check_mark: |
| `< 0.6.0` | :x: |

---

## Reporting a Vulnerability

Because TIMEFLOW is a **Local-First, Offline-First** application that runs entirely on your local device without an online backend or cloud sync, typical server-side vulnerabilities (such as SQL injection via network endpoints, unauthorized API access, or data breaches) do not apply.

However, if you discover an issue relating to:
- Local database file permissions,
- Insecure Android `PendingIntent` or `BroadcastReceiver` flags,
- Data leakage across Android IPC boundaries, or
- Vulnerabilities within our third-party dependencies,

we encourage responsible disclosure:

### How to Report
1. **GitHub Security Advisory:** Please report the vulnerability privately via the **Security** tab of our GitHub repository:  
   [https://github.com/binh123-maker/TIMEFLOW/security/advisories/new](https://github.com/binh123-maker/TIMEFLOW/security/advisories/new)
2. **Alternative:** If GitHub Advisory is unavailable, open an issue labeled `security` without disclosing exploitable payload details.

Please provide:
- A description of the vulnerability and its potential impact.
- Steps or a minimal proof-of-concept to reproduce the behavior.
- Affected device environment (Android OS version, manufacturer).

We aim to acknowledge reports within 48 hours and work with you on a timely fix.

