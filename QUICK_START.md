# Quick Start — Cru App on AWS Lambda

How a Cru application built from this template is provisioned, built, and
deployed. If you're a coding agent, read **[AGENTS.md](./AGENTS.md)** first —
it covers day-to-day work; this file covers the platform around it.

## 1. Pick a language

This template isn't tied to a language. Activate one of the starter stacks:

```bash
bin/use-language nodejs   # or: ruby | python
```

That copies the chosen stack (`stacks/<lang>/`) to the repo root — a minimal
Lambda **handler** with a `Dockerfile`, `build.sh`, `.tool-versions`, and a
dependency manifest — and removes the rest. These are Lambda handlers, not web
servers: each is invoked by an event and returns a result, not a long-running
process listening on a port. Commit the result, then build your app on top of
it. (See [AGENTS.md](./AGENTS.md) for the per-language run commands.)

## 2. Provision the application (TerraBloks)

All Cru cloud infrastructure is managed as code in the
[`cru-terraform`](https://github.com/CruGlobal/cru-terraform) repo. You don't
create cloud resources by hand — you generate them with **TerraBloks**, Cru's
Terraform templating engine. This app is provisioned with the
[aws/lambda/app](https://github.com/CruGlobal/cru-terraform-modules/blob/main/aws/lambda/app/README.md)
Terraform module.

TerraBloks is available as an MCP server (`terrabloks`) that a coding agent can
drive directly:

```
list_templates → get_template → preview_pr → create_pr
```

It opens a Pull Request against `cru-terraform` containing your app's
infrastructure (the Lambda function, its IAM role, secrets, and the GitHub
deploy permissions). A maintainer reviews and applies it; applying creates the
real resources and wires up the permissions this repo's CI uses to deploy.

Provision the `staging` and `production` environments as you need them.

## 3. Build & deploy

Builds and deployments run from
[`.github/workflows/build-deploy-lambda.yml`](./.github/workflows/build-deploy-lambda.yml).
`build.sh` builds and pushes the Lambda container image to ECR; a successful
build then triggers a Lambda deploy in
[`cru-deploy`](https://github.com/CruGlobal/cru-deploy).

**The deploy flow:**

1. Work on a branch off `main` and open a Pull Request.
2. Add the **`On Staging`** label to the PR → the merge-bot merges your branch
   into the `staging` branch → CI builds and deploys to **staging**.
3. Merge the PR into `main` to deploy to **production**.

**Builds are disabled by default** on a new repo (the workflow watches a
placeholder branch `disabled_deploy`). Once an environment's Terraform from
step 2 has been applied, enable it by uncommenting `main` / `staging` under
`on: push: branches:` in the workflow. Builds fail until the infrastructure
exists — that's expected, so leave them disabled until you're ready.

## 4. The Cru CLI

The `cru` CLI talks to Cru's platform — use it to run commands against a real
environment's injected secrets without ever copying secret values locally:

```bash
# Run a command with staging's secrets injected as environment variables:
cru application impersonate -e staging -- <command>

# Read specific secret keys (values are never committed):
cru application secrets read --keys DATABASE_URL -e staging
```

Run `cru --help` for the full command set.

## Reference

- **[AGENTS.md](./AGENTS.md)** — how coding agents should work in this repo.
- [`cru-terraform`](https://github.com/CruGlobal/cru-terraform) — infrastructure as code.
- [`cru-deploy`](https://github.com/CruGlobal/cru-deploy) — where deployments run.
- [aws/lambda/app Terraform module](https://github.com/CruGlobal/cru-terraform-modules/blob/main/aws/lambda/app/README.md)
