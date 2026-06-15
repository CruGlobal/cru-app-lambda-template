# My Cru App

> Replace this with a sentence describing what your app does.

A Cru application that runs on AWS Lambda.

## Getting started

This repo starts from Cru's Lambda template and isn't tied to a language yet.
Pick one to begin:

```bash
bin/use-language nodejs   # or: ruby | python
```

That sets up a minimal Lambda **handler** you can build on. A Lambda handler is
invoked by an event (API Gateway, SQS, an EventBridge schedule, etc.) and
returns a result — there's no port to listen on or health URL to serve. Then,
depending on the language you chose:

| Language | Install            | Handler                          |
| -------- | ------------------ | -------------------------------- |
| nodejs   | `npm install`      | `src/index.ts` → `handler`       |
| python   | `pip install -r requirements.txt` | `handler.py` → `handler`         |
| ruby     | `bundle install`   | `handler.rb` → `handler`         |

Each handler returns `{ statusCode: 200, body: '{"status":"ok"}' }`. Build on
it, then test by invoking the handler with a sample event (see AGENTS.md).

## Deploying

Open a pull request off `main`, then add the **`On Staging`** label to deploy
to staging; merge to `main` to deploy to production. See
**[QUICK_START.md](./QUICK_START.md)** for provisioning (TerraBloks), the Cru
CLI, and enabling builds.

## For coding agents

See **[AGENTS.md](./AGENTS.md)** — it explains how this repo is wired and how to
work in it safely.
