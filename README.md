[![Travis-CI Build Status](https://travis-ci.org/thewoolleyman/gitrflow.svg?branch=master)](https://travis-ci.org/thewoolleyman/gitrflow)

[Pivotal Tracker Project](https://www.pivotaltracker.com/n/projects/1205482)

# gitrflow

Git extensions to provide high-level repository operations for a rebase-based
git workflow. Similar to [gitflow](https://github.com/nvie/gitflow), but uses
**constant automatic rebasing** instead of manual merges to manage **feature**
branches.

# Installing

* `gitrflow` is a single bash script, for maximum portability and ease of installation
* For now, simply put `gitrflow` on your PATH.  Eventually, it will be distributed
  via various package managers: Rubygems, Homebrew, Npm, Maven, etc...
* Development is still in early stage, see "Commands" section for which commands are
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
    -t, --trace                 Enable the GIT_TRACE environment variable
    -V, --version               Display the program [v]ersion
    --                          Ignore all following options
```

## Init Command (implemented for feature branch prefix)

`rflow init [--defaults`: Initializes a git repo for use with gitrflow, and
prompts you to define prefixes for different branch types.  Branch type
prefixes are required by gitrflow to know what type of branch you are on, so that
it can perform the proper validations and actions.  If you pass the `--default`
option, the default branch prefixes will be automatically used with no prompting.

## Feature Branch Commands

### rflow feature start (implemented)

`rflow feature start <feature branch name>`: creates a new feature branch off of the
current branch, which is then considered the "upstream" of the feature branch.

### rflow feature update (unimplemented)

`rflow feature update`: rebases the current feature branch onto the tip of the upstream
branch.

### rflow feature publish (unimplemented)

`rflow feature publish`: **safely** publishes the current feature branch to the remote
branch. "**safely**" means that the current feature branch is rebased onto the
remote branch before force-pushing it. If there are any rebase conflicts which
cannot be automatically resolved by Git, gitrflow will pause, allow you to
manually resolve them, then `--continue` (just like the `--continue` option
on the underlying rebase command)

### rflow feature finish (unimplemented)

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
on them, there will be two fundamental differences in the release branch
support in gitrflow:

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


# Compatibility

gitrflow is fully Test-Driven via RSpec with integration coverage for all
features, and has a Continuous Integration suite run
[on Travis CI against multiple versions of Bash and
Git](https://travis-ci.org/thewoolleyman/gitrflow).

# Goals, and Philosophy

## Merge or rebase?

Git has become the de-facto tool for version control in the modern software
industry.

However, it is very powerful and complex. One of the largest areas of
contention and disagreement in the Git community is whether to use
`merge` or `rebase` to manage **feature** branches.

For some teams and organizations, this argument can become very heated,
to the point of being a 'religious' war.

The main goal of **gitrflow** is to support the usage of `rebase`, by
solving (and reframing) the problems with `rebase` which drive people
to prefer `merge` instead.

## Problems and their solutions

***IMPORTANT NOTE:*** *The following discussion only applies to ***feature***
 branches. The `merge --no-ff` command is still used to manage the
 master branch and production release branches, which should never have
 their history rewritten by rebase.*

I firmly believe that rebase is a demonstrably superior strategy for managing
feature branches. The main reasons people avoid it are because:

1. It's complex, and requires that specific steps be followed
2. Since it relies on force pushing branches, it can be dangerous, because it's
   possible to "lose" commit data if those steps are not followed. (note the
   "scary quotes" around "lose", because Git provides `reflog`
   to recover "lost" commits from local repositories)

**These are very valid concerns.**

**gitrflow** addresses those concerns, by:

1. Encapsulating the complexity in simple, high-level commands to manage
   feature branches.
2. Preventing "dangerous" things from happening, by enforcing that all steps
   are followed, and preventing outdated branches from ever being pushed
   to a remote.

## "But rebasing loses information..." - A history lesson

Another argument against rebase is that since it rewrites branch history,
"information is lost". However, I believe this is a non-goal, and an
invalid argument.

Why? Because the only "history" that I care about, as a Git user, is the
***current state of history on my upstream branch***.

In other words, if the upstream branch has changed, and my feature branch
needs to change correspondingly, then ***I don't care about the old state
of my feature branch, which only works with the old state of the upstream
branch***.

Another way of explaining this:  Presumably, the upstream branch was changed
for a good reason, and those changes are going to stick around for good.
So, I only care if my feature branch works against those latest changes.
**I'm always moving forward**. There's rarely any benefit in knowing how my feature
branch used to work with an obsolete version of the upstream code.

Of course, a change may be reverted on the upstream branch, in which case
I'll deal with it, and make the corresponding changes when I rebase my feature
branch onto it, because **I'm always moving forward**

If you are still really concerned about this, then you can always keep a
backup copy of the state of your feature branch prior to rebasing. That's
your choice, and I plan to eventually add support for this to gitrflow.

However, there are few cases where this line of argument ever be considered a
valid reason (in isolation) to avoid using rebase, assuming that the
actual valid concerns discussed above are addressed by using gitrflow.

The one exception may be when you want to review old rebased commits which are
deployed or referenced by a tool, but I consider this to be a limitation
of process or tool (see "Lack of tool support" below).

## Lack of tool support

### Handling changing SHAs
Another complaint about rebase-based workflows is how tools, such as IDEs,
continuous integration systems, or other apps that display notifications
of Git commits, deal with it.

Since the SHAs for commits are changed as a result of a rebasing, a naive approach
of simply considering each unique SHA to be a new commit will not work well. It
can result in undesired spammy notifications for every rebased commit, even if
the actual contents of the commit didn't change at all as a result of the rebase.

On the other hand, for commits that DID actually change as a result of the rebase
(i.e. to resolve a conflict), then the tool may or may not want to communicate
or act on that information, and must decide how to present it in the user interface.

This is a somewhat complex problem, but it's solveable - all the information
is available in the git metadata, and if you use GitHub, it's even easier to get
the information you need from their activity webhooks.

For example, in the case of commit notifications, one simple approach is to "collapse"
subsequent rebases of the same commit into a single commit in the UI. This could be
expandable, and by default it could de-emphasize or omit entries for rebases that
didn't actually change a commit.

### Delivery and testing of rebased feature branches
Another problematic area with rebase workflows can be delivery and testing of feature
branches prior to merging them back into the upstream. For a large and longer-lived
feature branch, you may want to frequently deploy it to a running environment in order
to test it, and accept delivered bugs or features. In this case, you may want to
to identify which commits on the branch are associated with a specific bugfix or
feature, and you may have some automated process to generate this via a "changelist"
or similar report. These processes may have issues if the SHAs on the feature
branch have changed as a result of rebasing.

### Considerations

These are real problems, and simply saying "well the tool should deal with it"
is not a practical solution.

**If these problems are severe enough to cause a major disruption in your team or
other processes, and fixing existing tools or changing to new tools isn't an option,
then this may be a valid reason that a rebase-based workflow may not work for your
team**.

However, be aware that this is a tradeoff, and you are missing out on the benefits
of a rebase workflow, and accepting the problems of a merge-based workflow.

## Public / Open Source feature branches - safe to rebase?

If you have a public or open source repo, and people will be pulling
rebased **feature** branches, **AND** they don't know how to properly
work in a rebase workflow (i.e., you can't require them to use gitrflow),
then that would be a reason not to use a rebase workflow on that feature
branch.

**BUT**, I would ask - why are you expecting the general public or other open
 source contributors to work on a **feature** branch?  Remember, the
 master branch, hotfix branches, or production release branches should
 **NOT** be rebased - because they should remain stable.

 In other words, if you have a **feature** branch on a public repo, then
 you should be able to either:

 1. Not expect anybody you don't know to be working with it (they should work
    on master, or a hotfix branch, or a release branch, and submit patches
    or pull requests), or...
 2. Expect anyone who DOES work on it to have a good reason to, and probably
    be a core contributor or part of the development team, and thus can be
    expected to follow a documented rebase-based workflow using gitrflow.

 If you think about it, this is the same approach GitHub uses to solve the
 same problem, but they do it via pull requests.  In the GitHub pull-request
 based workflow, your personal **"forked"** repo is in essence your own
 **"feature"** branch, that only you (or other trusted collaborators)
 work on.  Thus, you are free to rebase it to your hearts content.  Then,
 when you have it ready to merge back into the main repo (i.e. analogous
 to the master or upstream branch in gitrflow), you submit a **pull request**,
 which is simply a request to `merge --no-ff` your changes back into
 the upstream branch (i.e., just like the gitrflow workflow).

 So, I believe you should treat public feature branches just like any other
 feature branch - they are OK to rebase, and if you collaborate on them concurrently
 with anybody, you should ensure they know how to use your preferred rebase
 workflow.

## Squash merges - they DO lose information

To get around some of the drawbacks of a merge-based workflow (a proliferation
of merge commits), you can use `merge --squash --no-commit` to merge the commits
from the feature branch back into the upstream branch as a single commit.

However, this is an anti-pattern in my opinion, because you've now lost all of the
individual atomic commits and their corresponding messages. Small, focused commits
are a good practice (TODO: links), so the individual atomic commit sets and their
message *ARE* useful information which you don't want to lose, especially on feature
branches which have been long-lived, and contain many different changes for different
reasons.

In other words, it's very frustrating to do a `git blame` on a line to find out
why it was changed, only to find out it's part of a commit with dozens (or hundreds)
of files which changed, and a terse commit message of *"merge branch uber_epic
 into master"*.

## Goals and Benefits of rebase over a merge workflow

TODO: flesh this out

* No disincentive to incorporate upstream and remote changes **constantly** - The
  more frequently you incorporate upstream changes, the better, because it minimizes
  the chances of other issues (see other points below). So, all else aside, you
  should do this as frequently as possible, with the extreme being to integrate
  immediately after every upstream or remote commit. With a merge-based
  workflow, every conflict resolution, whether it's automatic or manual, results
  in a separate merge commit, so this approach would result in a great number of
  extra commits. However, since a rebase workflow *rewrites* the same commit,
  it doesn't suffer from this drawback.
* Atomic commits - the intent of every code change is contained in a single commit,
  not spread across the multiple commits in the case of merge-conflict-resolving
  commits.
* Linear history - Every commit has a single parent. No spaghetti git log graphs,
  and simpler to understand diffs in tools (e.g. you don't have to pick "which parent"
  you want to compare to for a diff).
* Minimize chance of conflicts - more frequently incorporating upstream changes into
  feature branches minimizes the chance of needing to manually resolve
  conflicts - because there's less upstream code changed in each rebase.
* Minimize chances of [semantic conflicts](http://martinfowler.com/bliki/SemanticConflict.html)
  (see Martin Fowler's article in Further Reading) by constantly incorporating
  upstream changes.
* Ability to clean up / squash commits feature branches with `rebase --interactive`
  (since it's OK to force push)
* Using git bisect can become harder due to merge commits and multiple parents.
* Knowing when a branch is safe to delete (i.e. fully incorporated to master) -
  When a rebase workflow rebases a feature branch into master, all the commits on
  the feature branch are added into master with the unchanged SHAs. This allows
  you to use `git branch -d` (little `-d` vs. big `-D`) to delete the branch,
  and have git automatically ensure that the branch is fully incorporated to master.
  If you squash-merge a feature branch to master (as is often done in a merge-based
  workflow), you must immediately force-delete the branch with -D, or else manually
  ensure no subsequent commits or other changes are on the branch.


# Further Reading

Here's some links by smart people on the topics of feature branches and rebasing.
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
* Support for multiple Git versions
  * Run spec/gitrflow_suite.rb
  * Override GITRFLOW_SPEC_GIT_VERSIONS to a comma-delimited list of versions to test
  * Or, run a local git version with: `GIT_EXECUTABLE=/path/to/git rspec`

# Credits

* Glen Ivey for helping envisioning and create the first working implementation
  of this workflow.
* Kris Hicks for writing many informative articles on Git, and inspiring me to
  finally learn Git well enough to leverage its full power through rebase.
* Everybody who argued with me against using rebase, forcing me to solidify and back
  up my position with facts and code. :)
