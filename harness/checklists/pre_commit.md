---
name: pre_commit_checklist
type: checklists
---

# Pre-Commit Checklist

Complete every item before staging or committing. **No automatic commits.**

## Review

- [ ] Ran `git status` and reviewed every file listed
- [ ] Only the intended files are staged
- [ ] No secrets, API keys, or `.env` files are staged
- [ ] No build artifacts (`build/`, `.dart_tool/`, etc.) are staged

## Commit Message

- [ ] Follows the format: `<type>(<scope>): <short description>`
- [ ] Type is one of: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`
- [ ] Description is concise and accurate

## Approval

- [ ] **Received explicit user approval to commit**

## After Committing

- [ ] Ran `git log --oneline -3` to confirm the commit looks correct
- [ ] Did NOT push automatically — push only on explicit instruction

---

*This is a manual process. Do not automate it.*
