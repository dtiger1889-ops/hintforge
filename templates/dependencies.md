# Dependencies — [Game Name]
<!-- hintforge · stitch pass · last run: YYYY-MM-DD -->
<!-- Append rows only. Never overwrite existing entries. Re-running stitch adds new rows; it does not re-evaluate old ones unless the user explicitly requests a full re-pass. -->

## Cross-system edges

| Edge ID | System A | System B | Dependency description | Confidence | Source files |
|---------|----------|----------|------------------------|------------|--------------|
| DEP-001 | [system name] | [system name] | [one sentence: action/state in A affects state/outcome in B] | high | [file-A.md], [file-B.md] |

## PoNR / lockout edges

| Edge ID | Trigger | Locked out | Notes | Source files |
|---------|---------|------------|-------|--------------|
| PON-001 | [action or zone entry] | [what becomes inaccessible] | [timing window if known] | [file.md] |

## Missable / sequencing dependencies

| Edge ID | Action | Window | Consequence | Source files |
|---------|--------|--------|-------------|--------------|
| SEQ-001 | [action] | [before/after what] | [what is missed or altered] | [file.md] |

## Stitch run log

| Date | Scope | Edges written | Edges proposed (pending) | Model |
|------|-------|---------------|--------------------------|-------|
| YYYY-MM-DD | full | [N] | [N] | sonnet-class |
