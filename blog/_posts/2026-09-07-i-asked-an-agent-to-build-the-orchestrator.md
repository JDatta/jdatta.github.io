# I asked an agent to build the orchestrator

Man! the world moves fast!

I always wondered how much time I should spend learning agent frameworks when
the landscape is changing so fast.

Today, I can ask a model like GPT-5.6-Sol to “write a checkpointed orchestrator with
sub-agents for this task,” point it at a repository, and get a working starting
point. Dependencies, worker assignments, recovery instructions, the scripts to
check whether the whole thing makes sense. It can write those too.

I recently tried this on a project with a long release checklist. The app itself
had been vibe-coded. Then the release work arrived, and suddenly I was supposed
to become a very diligent project manager.

I had no mood of going through that sh\*t manually.

So I asked GPT-5.6-Sol to build the orchestrator for me.

## Case in point

I'll use a fictional packing-list app, Packlight, throughout this post. It lets
you create a list for a trip, tick things off, and use it offline. The app
details, filenames, task IDs, and prompts below are adapted examples. The
orchestration decisions and the problems I ran into come from the actual
sessions.

The starting request was roughly: “Turn this small HTML and JavaScript app into
an Android app.”

That sounds manageable. Wrap the web app, build it, install it on a phone. Done?

Then came the follow-up work. Check whether a saved list survives an update. Try
launching with no network. Test the keyboard on a small screen. Fix a browser
test that sometimes passes and sometimes fails. ReGPT-5.6-Solve a dependency conflict in
the Android tests. Prepare signing, icons, screenshots, privacy information, and
a store listing.

The checklist ran past a hundred lines of Markdown. Each line was reasonable.
Collectively, it was a lot of boring work between “this runs on my phone” and “I
can release this.”

Some of it could happen together. Someone investigating a browser test did not
need to wait for someone reading a build dependency report. Other work had to
wait: screenshots needed the final app, and testing an update needed an
installable build. A few steps needed decisions from me.

I wanted an agent to keep track of all of that, assign the work, check the
results, and carry on. And when the session ended, I wanted to continue without
explaining the whole project again.

At this point I was thinking of sub-agents, but was too lazy to craft the setup
myself.

## So I asked GPT-5.6-Sol to do it

Here is an adapted version of the planning prompt:

```text
Look into docs/exec-plans/pending/action-items.md and create an
agentic orchestrator implementation spec to execute the remaining
work one by one, or in parallel where possible.

Context:
Read the other pending plans, AGENTS.md, ARCHITECTURE.md, and the
existing test reports. Use them to understand what already works
and what remains.

Task:
Write a spec that I can give to an orchestrator agent. It should
break the work into scoped assignments, use sub-agents, review
their results, and continue through the checklist.

The orchestrator will run on GPT-5.6-Sol with xhigh reasoning and a 1M
context window. It may choose GPT-5.6-Sol, Terra, or Luna for workers.
Prefer a cheaper model for simpler work. Define when to escalate.

You can use the Codex CLI for persistent worker sessions and
configure a smaller context window for each worker.

IMPORTANT: Checkpointing
Keep checkpointing the state so a fresh session can resume from
the last checkpoint. Use local Git commits. Create as many as
needed; I can clean up the history later. Preserve useful helper
scripts and evidence. Keep credentials and private data out of Git.

Resources:
A USB-connected Android phone will be available. Inventory the
host, emulator support, and required software during planning.
Tell me about manual setup, firmware changes, or missing tools
before I start the orchestrator.

Save the implementation spec under docs/exec-plans/pending/.
Prepare the framework now; release execution starts separately.
```

The repository already had useful context: an `AGENTS.md`, architecture notes,
pending plans, and test reports. Those files gave the model something concrete
to work from.

I only had to make two refinements over what GPT-5.6-Sol did on its own.

 - First: migrate the Markdown action items to JSON once, validate that nothing was lost, and use that JSON as the authoritative tracker.
 - Second: Suggested to use ordinary `git add`, `git commit`, and `git worktree`
commands. The first version asked for direct access to the repository's `.git`
directory. I asked it to remove that requirement. Git already manages its own
metadata; any necessary tool permission should be scoped to the command being
run.

That was enough to get the first version. I reviewed what it generated and
corrected things as they surfaced. I did not hand-write the scheduler, tracker,
worker contract, or recovery protocol.

## What GPT-5.6-Sol generated

The resulting setup was a set of repository files and a few validation scripts.
Codex read the spec and did the coordination. There was no separate scheduling
service to deploy.

With the example names, the main pieces looked like this:

| File | What it contained |
| --- | --- |
| `docs/exec-plans/active/release-orchestrator.md` | Rules for assigning work, reviewing results, integrating changes, pausing, and resuming. |
| `docs/exec-plans/release-tasks.json` | Task status, dependencies, workers, sessions, worktrees, resource ownership, checkpoints, and next actions. |
| `docs/exec-plans/release-tasks.schema.json` | The allowed shape and values of the tracker. |
| `docs/exec-plans/worker-result.schema.json` | The structured result every worker had to return. |
| `scripts/validate-release-tasks.mjs` | Validator helper. Checks for invalid state, dependency cycles, readiness, and checkpoint consistency. |
| `docs/runbooks/release/` | Host setup instructions and the steps that needed my input. |

Only the orchestrator could update the tracker. Workers returned results for
review. That avoided three agents independently deciding what the shared task
list should say.

### GPT-5.6-Sol worked out the full task dependency graph

Each task had explicit dependencies. For the packing-list example, part of the
task graph could look like this:

<div class="task-dependency-diagram">
  <img class="task-dependency-diagram__light" src="{{ site.baseurl }}/resources/orchestrator-task-dependencies-light.png" alt="Release task dependency graph: REL-01, REL-02, and REL-04 lead to review of test evidence; signing-key custody leads to release signing; the review and signing paths lead to candidate validation and then internal testing.">
  <img class="task-dependency-diagram__dark" src="{{ site.baseurl }}/resources/orchestrator-task-dependencies-dark.png" alt="" aria-hidden="true">
</div>

 - **Selecting work:** The orchestrator identifies tasks whose dependencies are satisfied and assigns up to three workers at a time. It prevents conflicts over shared files or resources and integrates results in rank order.
 - **Assigning a task:** Each worker receives one task, its completion criteria, and a model suited to the work. Workers make changes in separate checkouts and can resume interrupted sessions. Difficult tasks can escalate to a more capable model.
 - **Reviewing results:** Workers return their changes, test results, supporting evidence, blockers, and recommended next action. The orchestrator reviews the changes and reruns relevant tests before accepting the work and updating the tracker. It preserves the evidence needed to continue in a later session.

## Checkpointing saves progress for the next session

Checkpointing uses local git commits to save the integrated changes, supporting
evidence, and updated task tracker together. Each checkpoint records the work
completed, test or diagnostic results, remaining blockers, and next actions so
a fresh session can pick up from the saved progress.

The orchestrator creates a checkpoint after reviewing, retesting, and integrating
each task. It also commits useful diagnostic findings while a task is still
unfinished—for example, a reproduced build failure and the evidence needed to
continue investigating it. Saving that progress does not mark the task complete.

Checkpoints also capture the reviewed baseline before implementation begins,
activation of the release plan, and the final release archive when the program
finishes. Before a planned handoff to a fresh session, the orchestrator finishes
the current work and checkpoints its results. These commits stay local; pushing
them is a separate action.

## Using the orchestrator

To start, point the agent at the orchestrator spec:

```text
Start the orchestrator in docs/exec-plans/pending/release-orchestrator.md.
```

To pause for a fresh session:

```text
Finish the in-progress work, checkpoint, and pause.
```

Then, in a new session:

```text
Resume the orchestrator in docs/exec-plans/active/release-orchestrator.md.
```

The spec tells the orchestrator how to find and validate the saved state and
choose the next task.

## In action

I’m using the orchestrator to work through a release checklist across multiple
sessions. It assigns eligible tasks to workers, reviews and tests their results,
integrates completed work, and checkpoints progress. When work is interrupted,
it uses the saved state to continue. I review decisions and provide access or
approval where needed; independent tasks can proceed while others are blocked.

The agent also resolved problems in the orchestration itself: incompatible
output schemas, incorrect worker directories, brittle tracker tests, and a
misleading checkpoint error caused by sandbox restrictions. It recovered
unfinished work after a worker hit a usage limit, verified the results, and
checkpointed them.

So far, this has produced integrated fixes, repeatable test evidence, and
successful recovery across sessions. The release is still in progress.

## What I took away

I skipped the deep LangChain agent stack. Understanding the concepts still
mattered.

I needed to recognize why the tracker should have one writer, why a worker's
result needed review, and why a saved session could disagree with the files on
disk. Those decisions shaped the prompt and helped me review what came back. The
model wrote the machinery around them.

I expect to spend less time reviewing the routine parts as the models improve.
In this run, the review caught things worth catching. I would be quite happy to
stop finding working-directory mistakes in generated worker commands.

For the next long checklist, I will probably start the same way: give the model
the repository context, ask it to design the execution and recovery rules,
review those rules, and let it begin. 
