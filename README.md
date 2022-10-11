[![Travis-CI Build Status](https://travis-ci.org/thewoolleyman/gitrflow.svg?branch=master)](https://travis-ci.org/thewoolleyman/gitrflow)

[Pivotal Tracker Project](https://www.pivotaltracker.com/n/projects/1205482)

# THIS PROJECT IS NO LONGER UNDER DEVELOPMENT

**UPDATE: This project is abandoned and I won't be continuing to work on it. The most important and still-relevant take-away from it is my argument for using a rebase-based workflow instead of merge-based workflow for managing feature branches, which you can read in the [Goals, and Philosophy page](readme/goals_and_philosophy.md)**

This is because I have evolved in my thinking on the process of updating feature branches, and whether it should be scripted or not:

1. A solid understanding of how to manage your own feature branches directly via git is a prerequisite for any dev working in modern software development teams.
1. In my opinion, the process for managing a feature branch shouldn't be attempted to be automated or scripted, for two reasons:
    1. You can't, because it will often involve manual conflict resolution, which can't be scripted. Or, even if you did, it sort of defeats the point, because the conflict resolution is the hardest part anyway, and you have to have some complex script process to "resume" after the conflict resolution step.
    1. Developers should understand the underlying git commands and what they are doing. This is because there's invariably eventually some unexpected or edge case situation that you need to resolve, and if you always rely on a script that only handles the happy path case, you will be lost as to how to handle these edge cases.

Other people's opinions may differ, though. If you feel like this would be useful, feel free to steal any ideas or code from this repo :)

Also, my plan to use bash as a cross-platform language was a bad idea. If I did attempt to write a cross-platform CLI such as this today, I would definitely use the Rust language.

# gitrflow

Git extensions to provide high-level repository operations for a rebase-based
git workflow. Similar to [gitflow](https://github.com/nvie/gitflow), but uses
**constant automatic rebasing** instead of manual merges to manage **feature**
branches.

gitrflow is based upon an opinionated premise:

*"You should use a rebase-based workflow to manage Git feature/story branches."*

If you understand and agree with this, then gitrflow is for you!  Scroll down for
the TL;DR docs and summary of gitrflow usage, or use the command line help.

If you don't understand what that means, or if you disagree with using a rebase-based workflow
for feature branches, then I respectfully invite you to review the
[Goals, and Philosophy](readme/goals_and_philosophy.md) page with an open mind.

Thanks for reading. :)

# Table of Contents

* [Installing](#installing)
* [Usage](#usage)
  * [Init Command](#init-command)
  * [Update Command](#update-command)
  * [Feature Branch Commands](#feature-branch-commands)
    * [rflow feature start](#rflow-feature-start)
    * [rflow feature publish](#rflow-feature-publish)
    * [rflow feature finish](#rflow-feature-finish)
  * [Release Branch Commands](#release-branch-commands)
    * [rflow release start](#rflow-release-start)
    * [rflow release tag](#rflow-release-tag)
  * [Hotfix Branch Commands](#hotfix-branch-commands)
    * [rflow hotfix start](#rflow-hotfix-start)
    * [rflow hotfix finish](#rflow-hotfix-finish)
* [Compatibility](#compatibility)
* [Goals, and Philosophy](readme/goals_and_philosophy.md)
  * [Intro](readme/goals_and_philosophy.md#intro)
  * [Merge or rebase?](readme/goals_and_philosophy.md#merge-or-rebase)
    * [The debate](readme/goals_and_philosophy.md#the-debate)
    * [The Git Book's summary of positions](readme/goals_and_philosophy.md#the-git-books-summary-of-positions)
    * [The case for rebasing feature branches](readme/goals_and_philosophy.md#the-case-for-rebasing-feature-branches)
  * [Problems and their solutions](readme/goals_and_philosophy.md#problems-and-their-solutions)
  * ["But rebasing loses information..." - A history lesson](readme/goals_and_philosophy.md#but-rebasing-loses-information---a-history-lesson)
  * [Lack of tool support](readme/goals_and_philosophy.md#lack-of-tool-support)
    * [Handling changing SHAs](readme/goals_and_philosophy.md#handling-changing-shas)
    * [Delivery and testing of rebased feature branches](readme/goals_and_philosophy.md#delivery-and-testing-of-rebased-feature-branches)
    * [Considerations](readme/goals_and_philosophy.md#considerations)
  * [Public / Open Source feature branches - safe to rebase?](readme/goals_and_philosophy.md#public--open-source-feature-branches---safe-to-rebase)
  * [Squash merges - they DO lose information](readme/goals_and_philosophy.md#squash-merges---they-do-lose-information)
  * [When committing merge conflicts is unavoidable](readme/goals_and_philosophy.md#when-committing-merge-conflicts-is-unavoidable)
  * [Goals and Benefits of rebase over a merge workflow](readme/goals_and_philosophy.md#goals-and-benefits-of-rebase-over-a-merge-workflow)
* [Further Reading](#further-reading)
  * [Articles Supporting a Rebase Workflow](#articles-supporting-a-rebase-workflow)
  * [General Articles on Git, Branching, and SCM Workflows](#general-articles-on-git-branching-and-scm-workflows)
* [Glossary](#glossary)
* [Hacking / Contributing](#hacking--contributing)
* [Credits](#credits)

# Installing

* `gitrflow` is a single bash script, for maximum portability and ease of installation
* For now, simply put `gitrflow` on your PATH.  Eventually, it will be distributed
  via various package managers: Rubygems, Homebrew, Npm, Maven, etc...
* Development is still in early stage, see "Usage" section for which commands are
  implemented

# Usage

TODO: Work in progress, for now this is just a high-level description of the
commands, they will be labeled "unimplemented", "in progress", or "implemented"
for now.

```
Usage:
  gitrflow [global options] init [--defaults]
  gitrflow [global options] <branch type> <command> [command options]

'init' command options:
    --defaults                  Use defaults for init config without prompting

Branch Types:
    feature

'feature' branch type commands and options:
    feature start <branch_name>

Global options:
    -c, --print-git-commands    Print git [c]ommands as they are run
    -d, --debug                 Debug git-rflow script with bash xtrace
    -h, --help                  Display this [h]elp
    -o, --print-git-output      Print [o]utput from git commands
    -V, --version               Display the program [v]ersion
    --                          Ignore all following options
```

## Init Command

**(implemented for feature branch prefix)**

`rflow init [--defaults`: Initializes a git repo for use with gitrflow, and
prompts you to define prefixes for different branch types.  Branch type
prefixes are required by gitrflow to know what type of branch you are on, so that
it can perform the proper validations and actions.  If you pass the `--default`
option, the default branch prefixes will be automatically used with no prompting.

## Update Command

**(unimplemented)**

`rflow update`: For feature branches, pulls the current
feature branch from the remote, then rebases it onto the tip of the upstream branch
(currently, only master is supported as an upstream).  For master and all other non-feature
branches, does a pull.  Always first verifies local working copy is clean with no unpushed
changes.

## Feature Branch Commands

### rflow feature start

**(implemented)**

`rflow feature start <feature branch name>`: creates a new feature branch off of the
current branch, which is then considered the "upstream" of the feature branch.

### rflow feature publish

**(unimplemented)**

`rflow feature publish`: **safely** publishes the current feature branch to the remote
branch. "**safely**" means that the current feature branch is rebased onto the
remote branch before force-pushing it. If there are any rebase conflicts which
cannot be automatically resolved by Git, gitrflow will pause, allow you to
manually resolve them, then `--continue` (just like the `--continue` option
on the underlying rebase command)

### rflow feature finish

**(unimplemented)**

`rflow feature finish`: merges (`merge --no-ff`) a feature branch back into the upstream
branch, after first ensuring it is fully rebased onto the remote branch and
the upstream branch.

## Release Branch Commands

"Production" release branches should never have their history rewritten by rebase,
because their previous history **is** very important to preserve. So, the
`merge --no-ff` command is used to manage the production release branches.

TODO: Since they don't involve rebasing, managing release branches is a
secondary goal for gitrflow, and won't be implemented until the feature
branch support (the primary goal) is solid and complete.

[gitflow](https://github.com/nvie/gitflow) has very good support for managing
production release branches and hotfix branches via merge, and there's no reason
(AFAIK) that it couldn't be used in conjunction with gitrflow - e.g. manage
feature branches with gitrflow, and everything else with gitflow.

However, after carefully reading many articles on gitflow, and all the comments
on them, there will be some fundamental differences in the release branch
support in gitrflow:

**UPDATE: Actually you can have a "develop" branch as your main if you want.
My thinking has evolved on this, it doesn't really matter what you name
your upstream branch, or if you have it "promoted" to other branches,
e.g. the standard Gitflow develop -> master approach.  I'll update the docs
accordingly, but everything else still applies.  TODO: UPDATE ACCORDINGLY.**

1. There will be no "develop" branch.
  * All feature and release branches will have the "master" branch as their
    upstream.  The only purpose of the "master" branch in the gitflow workflow
    is as a stable branch of the code with tagged versions.  But, there's no
    reason release branches can't serve this same purpose, if tags are made on
    the release branches themselves.
  * Also, and more importantly, having 'develop' as the primary branch confuses
    people, especially if they are used to a Github pull-request-based workflow,
    and it require that you override settings in tools (such as IDEs and GitHub)
    to specify develop as the "primary" branch.
  * So, there's no real reason not to integrate feature and hotfix branches directly
    to the master branch, especially for teams with collective code ownership,
    and projects with strong test coverage and continuous integration.
  * Plus, if a team does find a need for a "develop" branch in order to integrate
    and stabilize changes prior to merging them to master, then it's easy to just
    treat it as a feature branch (which is also an upstream) using
    gitrflow.
2. Multiple concurrent active release branches will be supported.
  * This is one of the main complaints you see in comments on the various
    gitflow articles.  It's very common to be required to support multiple
    versions of production code "in the wild" - especially if you develop
    enterprise software or tools, or pretty much anything other than a website.
  * This limitation is a direct result of gitflow's focus on a single "master"
    branch and a single active production release branch.  I believe that the
    "experimental" "support" branches are intended to address this limitation,
    but there's [little documentation on them](http://yakiloo.com/getting-started-git-flow/)
  * But, if every release branch comes directly off of master, and is maintained
    solely through hotfix branches, and is tagged for versioned
    release, there's no problems with supporting any number of concurrent
    release branches with multiple tagged semantic versions each.
3. All changes to a release branch must be done via "hotfix" branches, or else
   manually cherry-picked back to master.
  * This is required in order to reliably support the approach where release
    branches exist concurrently and "are never finished" (see next point).
4. Release branches are never "finished"
  * Since there's no separate develop/master branch, there's no need to
    "finish" a release branch and merge it back anywhere.  As long as all
    changes to the release branch are managed via hotfix branches or
    by manually cherry-picking commits from the release branch to master
    (see previous point), they "live forever" and are never "finished"

### rflow release start

**(unimplemented)**

`rflow release start <release branch name> [BASE]`: creates a new release branch off
of master, optionally starting from the BASE commit.

### rflow release tag

**(unimplemented)**

`rflow release tag <release branch name> <tag name>`: creates a new tag on a
release branch with the specified tag name, and automatically pushes it.


## Hotfix Branch Commands

**(unimplemented)**

"hotfix" branches are used to make fixes which need to be incorporated
into one or more existing release branches, and also back into master
to ensure that the fix is incorporated into any future releases.

Then, the release branch(es) can be independently (and individually)
tagged as appropriate using `rflow release tag`.

Note that in gitrflow, hotfix branches are also handled differently than
in gitflow, because:

1. They are not tied to a specific release version or tag
2. They can be applied to multiple release branches

### rflow hotfix start

**(unimplemented)**

`rflow hotfix start <hotfix branch name> <release branch name>`: creates a new hotfix
branch off of the specified release branch.

### rflow hotfix finish

**(unimplemented)**

`rflow hotfix finish <hotfix branch name> [<additional release branch names> ...]`:
merges the specified hotfix branch name back into the release branch it was
originally branched from and into master, and optionally into one or more additional
release branches.  Then, the hotfix branch is deleted (TODO: "archived")

NOTE that this **can result in merge-conflict-resolving commits being committed**,
since master and release branches are never normally rebased.  See
"[When committing merge conflicts is unavoidable](readme/goals_and_philosophy.md#when-committing-merge-conflicts-is-unavoidable)"
for more information.


# Compatibility

gitrflow is fully Test-Driven via RSpec with integration coverage for all
features, and has a Continuous Integration suite run
[on Travis CI against multiple versions of Bash and
Git](https://travis-ci.org/thewoolleyman/gitrflow).

# [Goals, and Philosophy](readme/goals_and_philosophy.md)

* [Merge or rebase?](readme/goals_and_philosophy.md#merge-or-rebase)
* [Problems and their solutions](readme/goals_and_philosophy.md#problems-and-their-solutions)
* ["But rebasing loses information..." - A history lesson](readme/goals_and_philosophy.md#but-rebasing-loses-information---a-history-lesson)
* [Lack of tool support](readme/goals_and_philosophy.md#lack-of-tool-support)
  * [Handling changing SHAs](readme/goals_and_philosophy.md#handling-changing-shas)
  * [Delivery and testing of rebased feature branches](readme/goals_and_philosophy.md#delivery-and-testing-of-rebased-feature-branches)
  * [Considerations](readme/goals_and_philosophy.md#considerations)
* [Public / Open Source feature branches - safe to rebase?](readme/goals_and_philosophy.md#public--open-source-feature-branches---safe-to-rebase)
* [Squash merges - they DO lose information](readme/goals_and_philosophy.md#squash-merges---they-do-lose-information)
* [When committing merge conflicts is unavoidable](readme/goals_and_philosophy.md#when-committing-merge-conflicts-is-unavoidable)
* [Goals and Benefits of rebase over a merge workflow](readme/goals_and_philosophy.md#goals-and-benefits-of-rebase-over-a-merge-workflow)


# Further Reading

## Articles Supporting a Rebase Workflow

Here's some links to articles specifically recommending and/or describing a rebase-based workflow
for feature branches:

* [A Rebase Workflow for Git](http://randyfay.com/content/rebase-workflow-git) - Randy Fay
* [Agile git and the story branch pattern](http://blog.hasmanythrough.com/2008/12/18/agile-git-and-the-story-branch-pattern) - Josh Susser
* [A Git Workflow for Agile Teams](http://reinh.com/blog/2009/03/02/a-git-workflow-for-agile-teams.html) - Rein Henrichs
* [Pro Git Book, Section 5.3](http://git-scm.com/book/ch5-3.html) - Scott Chacon and Ben Straub (see section "Rebasing and Cherry Picking Workflows")

## General Articles on Git, Branching, and SCM Workflows

Here's some links to articles by smart people on the topics of feature branches and rebasing.
I believe that gitrflow reframes and eliminates many of the problems described
therein:

* Martin Fowler on [Semantic Conflict](http://martinfowler.com/bliki/SemanticConflict.html)
  * As he says in the article, constant rebasing of feature branches (as gitrflow
    does) addresses many of these issues, in conjunction with automated self-testing
    code (which you should also have).
* Martin Fowler on [Opportunistic Refactoring](http://martinfowler.com/bliki/OpportunisticRefactoring.html)
  * This is also facilitated by constant rebasing of feature branches and powerful,
    high level commands to make branching and merging easy - because you can
    quickly perform the opportunistic refactoring on the upstream branch, then
    immediately rebase it onto your current feature branch (e.g.:
    `git stash`, `git rflow update`, `git stash pop`)
* Chris Birmele on [Branching and Merging Anti-Patterns](http://msdn.microsoft.com/en-us/library/aa730834(VS.80).aspx#branchandmerge_antipatterns)
  * Git, used with gitrflow, solves many of these problems.
* Jeff Atwood [Software Branching and Parallel Universes](http://blog.codinghorror.com/software-branching-and-parallel-universes/)
  * A good overview of how to think of branches and their associated complexity,
    as well as an illustration of how gitrflow can address these problems.
* [Git team workflows: merge or rebase?](http://blogs.atlassian.com/2013/10/git-team-workflows-merge-or-rebase/)
  * This is a good article, but it contains one misleading claim: "Using rebase
    to keep your feature branch updated requires that you resolve similar conflicts
    again and again."  This is **NOT** true, unless you abort the rebase. Since
    rebase incorporates all changes up to the tip of the upstream branch you've
    rebased onto, by definition you never have to resolve the **same** conflict
    twice. You may need to resolve a ***similar*** conflict, in the same commit,
    in the same code location, because the code has changed *again* in that location
    on the upstream branch since the last rebase, but it's a ***new*** conflict,
    not the same one. Furthermore, this problem exists regardless of whether
    you are using a rebase or merge workflow.


# Glossary

* Feature Branch: A short-lived branch off of an upstream branch (i.e. will eventually
  be merged back into the upstream branch, unless it is discarded)
* Upstream Branch: A branch off of which a feature branch is made
* Remote Branch: A branch on the remote repository (i.e. Github)
* Integrate/Incorporate: Used synonymously to describe the act of including changes
  from an upstream branch or remote branch into the current feature branch.

# Hacking / Contributing

* `gitrflow` is a single bash script, for maximum portability and ease of installation
* All bash `set -o` commands are set to maximum strictness, to prevent bugs
* All features are Test-Driven, and should be accompanied by a corresponding spec
* Specs are written in Ruby Rspec.  To run them:
  * Checkout the repo
  * Ensure the correct ruby version is installed (consider `rvm`)
  * `gem install bundler`
  * `bundle install`
  * `rspec`
* Code quality is enforced by static analysis tools (run as part of the Rspec suite):
  * shellcheck
  * ruby-lint
  * rubocop
* Support for multiple Bash versions
  * Run spec/gitrflow_suite.rb
  * Override GITRFLOW_SPEC_BASH_VERSIONS to a comma-delimited list of versions to test
  * Or, run a local bash version with: `BASH_EXECUTABLE=/path/to/bash rspec`
* Support for multiple Git versions
  * Run spec/gitrflow_suite.rb
  * Override GITRFLOW_SPEC_GIT_VERSIONS to a comma-delimited list of versions to test
  * Or, run a local git version with: `GIT_EXECUTABLE=/path/to/git rspec`
* Automatically download, compile, and run suite with a specific Bash and Git version:
  * `GITRFLOW_SPEC_GIT_VERSIONS=2.1.3 GITRFLOW_SPEC_BASH_VERSIONS=4.3.30 spec/gitrflow_suite.rb`
* Run a focused rspec example via the suite (double-quote ALL rspec args):
  * `GITRFLOW_SPEC_GIT_VERSIONS=1.8.2.3 GITRFLOW_SPEC_BASH_VERSIONS=4.3.30 spec/gitrflow_suite.rb "spec/feature_start_spec.rb --example 'feature start fails if local branch is behind remote'"`
* Continuous Integration runs on Travis CI against all supported
  Bash and Git versions: [![Travis-CI Build Status](https://travis-ci.org/thewoolleyman/gitrflow.svg?branch=master)](https://travis-ci.org/thewoolleyman/gitrflow)
* For verbose bash debugging, set GITRFLOW_BASH_XTRACE=true (note this will cause
  specs to fail, as they test against stdout, but it is useful to see exactly what
  the git-rflow script is doing, and why it is failing)


# Credits

* Glen Ivey for helping envisioning and create the first working implementation
  of this workflow.
* Kris Hicks for writing many informative articles on Git, and inspiring me to
  finally learn Git well enough to leverage its full power through rebase.
* Vincent Driessen for creating [gitflow][https://github.com/nvie/gitflow],
  which much of gitrflow is based upon and inspired by.
* Everybody who argued with me against using rebase, forcing me to solidify and back
  up my position with facts and code. :)
