# [GAME NAME] — Architecture

**status:** scaffold
**last_reconciled:** YYYY-MM-DD
**research_run:** none

Cross-zone structural primitives. The persona reads this file for all cross-zone reasoning — lookahead warnings (Rule 2), backtrack queries (Rule 3), reachability checks (Rule 4), locks-and-keys notifications (Rule 5). Per-zone gate lists live in `nav/<zone>.md` and reference this file's graph by edge ID. Drift between this file and per-zone files is a bug; run a consistency pass after each ingestion.

## Zone Graph

**Game-type label:** [dungeon-linear | hub-and-spoke-with-dungeons | open-world-with-distinct-dungeons | open-world-explorative-only | procedural | on-rails | narrative-no-nav]
**Localization-mechanism class:** [map-system | landmark | hybrid | none]
**Entry node:** [zone-id where a new game starts]
**Hub nodes:** [list of zone-ids serving as hubs, or "none"]

**Nodes:**
- [zone-id] — [canonical name]

**Edges:**

| From | To | Type | Direction | Condition | Point of no return | Notes |
|---|---|---|---|---|---|---|
| [zone-id] | [zone-id] | story-gate \| one-way \| optional \| hub-spoke \| fast-travel \| conditional | bidirectional \| one-way src→tgt | [unlock condition or leave blank] | none \| permanent \| chapter-bound \| missable-trigger \| point-of-divergence | [one-line context] |

**Edge types:**
- `story-gate` — passing this edge advances the story; usually one-way at time of passing
- `one-way` — direction is permanently fixed
- `optional` — player's choice; access is permanent
- `hub-spoke` — connection between hub node and a dungeon/zone; usually bidirectional
- `fast-travel` — fast-travel network edge
- `conditional` — access depends on a flag (item, story progress, NG+)

**Point-of-no-return subtypes:**
- `permanent` — passing locks out the source zone forever
- `chapter-bound` — access ends at chapter transition, may resume later
- `missable-trigger` — passing locks out a missable item or quest in another zone
- `point-of-divergence` — choice gate; alternative branch becomes unreachable

## Chapter ↔ Zone Mapping

| Chapter | Zones | Notes |
|---|---|---|
| [Chapter name] | [zone-id-1, zone-id-2] | [e.g., sequential — no backtrack between zones] |

## Optional Content

| Name | Unlock condition | Access window | Parent zone | Recommended chapter | Failure mode |
|---|---|---|---|---|---|
| [name] | [story flag, item, level, NG+] | permanent \| chapter-bound \| one-shot | [zone-id you launch into it from] | [chapter from walkthroughs] | missable \| always-available \| NG+-only |

## Support Topology

### Save stations

| Zone | Locations |
|---|---|
| [zone-id] | [description of location in-zone] |

### Fast-travel network

[Describe the game's fast-travel system. List accessible nodes if applicable. Write "None — no fast-travel in this game." if absent.]

### Hub access

[Describe hub nodes and how the player returns to them from dungeons/zones. E.g. "Return-to-hub trigger: exit elevator at polygon exit."]

## Locks and Keys

| Lock location | Key required | Key source | Visible before key? | Notes |
|---|---|---|---|---|
| [zone + description of gate] | [item or ability] | [zone where key is obtained] | yes \| no | [optional one-liner] |
