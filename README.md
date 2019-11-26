# Configurable Github Action For Building and Optionally Deploying Jekyll Builds.

Goes to a configured directory, optionally destroys the Gemfile.lock, builds the jekyll site, and optionally goes to a configured directory to push to specified branch of the repo.

Really helpful if you just want to build your site and let another action in your workflow do something with it... like [push to s3 maybe?](https://github.com/jakejarvis/s3-sync-action)

## Options

Set these in the `env` of the github action.
BUILD_DIR and REMOTE_BRANCH don't matter if DEPLOY_SITE is not `true`... obviously.


`JEKYLL_ROOT` **Default**:`./`  If your jekyll site isn't at the root if your repo, change this so that a `cd` command points to the jekyll root.


`GEMFILE` **Default**:`Gemfile` If you aren't using a default named Gemfile; change its name here.


`REMOVE_GEMLOCK` **Default**:`true` When `true` we'll `rm Gemfile.lock` before trying to build the jekyll site.


`DELETE_BEFORE_BUILD` **Default**:`no default!`... If set calls `rm -rf <>` before building the site... Useful for removing directories you don't want in your final site for whatever reason.


`DEPLOY_SITE` **Default**:`true` If we should try and build the site and deploy it the REMOTE_DIR.


`BUILD_DIR` **Default**:`_site/` What directly will the site get built into.  *This is telling our deployment actions where to work, it does NOT change where your site gets built into, use your `_config.yml` for that*.


`REMOTE_BRANCH` **Default**:`gh-pages` Which branch of the repo should we push our BUILD_DIR to?


## Example

This would build and deploy the jekyll site contained within the `MySite` dir of the repo to the `staging` branch of the repo when ever the `dev` branch gets pushed to.

Change `dev` to `master` if and remove the `JEKYLL_ROOT` and `REMOTE_BRANCH` `env` settings if you want vanilla default actions to happen when master gets pushed.

The `GITHUB_*` env variables are populated by github actions, they must be defined but you don't need to set them yourself. 

```yml
name: Jekyll Build - Optional Deploy

on:
  push:
    branches:
    - dev

jobs: 
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: Building a jekyll site from configured directory, maybe deploying it.
        env: 
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITHUB_REPOSITORY: ${{ secrets.GITHUB_REPOSITORY }}
          GITHUB_ACTOR: ${{ secrets.GITHUB_ACTOR }}
          JEKYLL_ROOT: "MySite/"
          REMOTE_BRANCH: "staging"
        uses: agentd00nut/jekyll-build-optional-deploy-gh-pages@master
```

## Multiple sites

This isn't tested but it should be possible within the same job.  Just explicitly state all the env variables for each `- name`'d use of the action.  

## Gotchas

**Changes pushed to your gh-pages branch will only be picked up by the Github Pages server if your workflow is in a private repository.**
