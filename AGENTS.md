# Working in this repo (for coding agents)

This repository was created from Cru's **AWS Lambda app template**. It deploys
a container image to **AWS Lambda** — the app is a **handler invoked by an
event** (API Gateway, SQS, an EventBridge schedule, etc.), not a web server
with a port. The person you're helping may not be a developer — your job is to
make good, safe defaults and explain what you're doing in plain language. This
file tells you how the repo is wired and what to do when you're unsure.

> New here? Do **"Start here"** below before writing app code.

---

## Start here: pick a language

A fresh repo from this template is **not tied to a language**. It ships starter
"stacks" for three, each a minimal Lambda handler that already builds, deploys,
and returns a successful response:

- **nodejs** — TypeScript on Node (bundled with esbuild)
- **ruby** — a Ruby handler
- **python** — a Python handler

**Your first step on a new app:**

1. Ask the user which language they want (if they don't know, **recommend
   Node/TypeScript** — it's the most common here and the easiest to grow).
2. Activate it: `bin/use-language <nodejs|ruby|python>`
   This copies that stack to the repo root and removes the others, leaving one
   language. It only needs to run once.
3. Commit the result ("Use the <language> stack").

After that, the root holds a normal Lambda app for that language — build on it.

## Project layout (after activation)

```
.
├── CLAUDE.md          # this file
├── README.md          # the app's own readme — customize it for the app
├── QUICK_START.md     # how this app is provisioned & deployed at Cru
├── Dockerfile         # how the handler is containerized for Lambda
├── build.sh           # builds the image (CI runs this; you can too)
├── .tool-versions     # pinned language version (asdf / mise)
├── .github/workflows/build-deploy-lambda.yml   # build + deploy pipeline
└── <your handler>     # src/index.ts (node), handler.py (python), handler.rb (ruby)
```

Every starter exports a **`handler`** that returns
`{ statusCode: 200, body: '{"status":"ok"}' }`. Keep the handler's signature
and a fast, successful return — that's what Lambda invokes and the platform
uses to decide a deploy is good.

The Dockerfiles preserve Cru's Lambda wiring: the **secrets-lambda-extension**
(set as `AWS_LAMBDA_EXEC_WRAPPER`, which injects secrets at runtime) and the
**DataDog lambda-extension** plus DataDog instrumentation. Leave that wiring in
place when you edit the Dockerfile.

## Running locally

Lambda handlers aren't web servers — there's no `$PORT` to bind or `/health`
URL to curl. To exercise one:

- **Unit-test the handler** — import it and call it with a sample `event`
  object, asserting on the returned object. This is the fastest loop.
- **nodejs**: `npm install`, then call the exported `handler` from a small
  script or test (the app bundles to `dist/handler.js` via esbuild — `npm run
  build`).
- **python**: `pip install -r requirements.txt`, then
  `python -c "import handler; print(handler.handler({}, None))"`.
- **ruby**: `bundle install`, then
  `ruby -r./handler -e 'p handler(event: {}, context: nil)'`.
- **any**: `./build.sh` builds the Lambda container image exactly like CI does;
  you can then invoke it with the AWS Lambda Runtime Interface Emulator.

## How this app ships

Deploys are driven by branches and a PR label — you don't deploy by hand.

1. **Work on a branch** off `main`, and open a **Pull Request** back to `main`.
2. **To deploy to _staging_:** add the **`On Staging`** label to the PR. Cru's
   merge-bot merges your branch into the long-lived `staging` branch, which
   triggers `build-deploy-lambda.yml` → builds the image → triggers a Lambda
   deploy in [`cru-deploy`](https://github.com/CruGlobal/cru-deploy).
3. **To deploy to _production_:** merge the PR into `main` (once production is
   enabled).

**Builds are disabled by default on a brand-new repo** (the workflow watches a
branch named `disabled_deploy`). Enable them only **after** the app's
infrastructure exists (see QUICK_START.md) by uncommenting `main` and
`staging` under `on: push: branches:` in
`.github/workflows/build-deploy-lambda.yml`. Until the Terraform is applied,
builds fail by design — that's expected, not a bug to chase.

Watch a run with the GitHub CLI: `gh run watch` (or check the Actions tab).

## Tests & CI

`bin/use-language` also writes `.github/workflows/ci.yml` — a check that runs
on every pull request: it installs dependencies, builds / syntax-checks the
app, and runs your tests if there are any (so a fresh repo stays green). Add
real tests as the app grows; the workflow runs them automatically once they
exist.

To actually *block* merges (and dependabot auto-merge) until CI passes, mark
the **CI** check **required** in the repo's branch-protection ruleset — that's
configured via TerraBloks / `cru-terraform`, not in this repo.

## Infrastructure & secrets

- **Provisioning** (the Lambda function, its IAM role, secrets, and the GitHub
  repo's deploy permissions) is generated by **TerraBloks** — Cru's Terraform
  templating engine, available to you as the `terrabloks` MCP server
  (`list_templates` → `get_template` → `preview_pr` → `create_pr`). It opens a
  PR against the `cru-terraform` repo. A maintainer reviews and applies it.
  See **QUICK_START.md**. (Don't hand-write cloud infrastructure.)
- **Secrets** are injected by the platform at runtime — **never commit secrets**
  to this repo. The secrets-lambda-extension makes them available as
  environment variables to the running handler. To run or debug against a real
  environment's secrets, use the **Cru CLI**:
  `cru application impersonate -e staging -- <command>` (see QUICK_START.md).

## If you're not sure what to do

- **Keep changes small and on a branch.** Open a PR; don't push straight to
  `main` or `staging`.
- **Don't invent infrastructure.** If the app needs a database, queue, bucket,
  or new secret, that's a TerraBloks/`cru-terraform` change — say so and use the
  `terrabloks` MCP rather than configuring cloud resources by hand.
- **Never paste secrets** (API keys, passwords, tokens) into files. Use env
  vars; fetch real values through the Cru CLI.
- **Keep the handler's signature and a fast, successful return** — that's what
  Lambda invokes and deploys are judged by.
- **Ask the user about intent, not plumbing.** "What should this app do?" is a
  great question; make the technical calls yourself with sensible defaults.
- **Confirm before anything outward-facing or hard to undo** — pushing,
  opening PRs, deleting things, sending real notifications.
