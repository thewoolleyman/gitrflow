# gitrflow

Git extensions to provide high-level repository operations for a rebase-based
git workflow.  Similar to [gitflow](https://github.com/nvie/gitflow), but uses
**constant automatic rebasing** instead of manual merges to manage **feature**
branches.

# Commands

TODO: Work in progress, for now this is just a high-level description of the
commands.

## Feature Branch Commands

### rflow start

`rflow start <feature branch name>`: creates a new feature branch off of the
current branch, which is then considered the "upstream" of the feature branch.

### rflow update

`rflow update`: rebases the current feature branch onto the tip of the upstream
branch.

### rflow publish

`rflow publish`: **safely** publishes the current feature branch to the remote
branch.  "**safely**" means that the current feature branch is rebased onto the
remote branch before force-pushing it.  If there are any rebase conflicts which
cannot be automatically resolved by Git, gitrflow will pause, allow you to
manually resolve them, then `--continue` (just like the `--continue` option
on the underlying rebase command)

### rflow end

`rflow end`: merges (`merge --no-ff`) a feature branch back into the upstream
branch, after first ensuring it is fully rebased onto the remote branch and
the upstream branch.

## Release Branch Commands

"Production" release branches should never have their history rewritten by rebase,
because their previous history **is** very important to preserve.  So, the
`merge --no-ff` command is used to manage the production release branches.

TODO: Since they don't involve rebasing, managing release branches is a
secondary goal for gitrflow, and won't be implemented until the feature
branch support (the primary goal) is solid and complete.

[gitflow](https://github.com/nvie/gitflow) has very good support for managing
production release branches and hotfix branches via merge, and there's no reason
(AFAIK) that it couldn't be used in conjunction with gitrflow - e.g. manage
feature branches with gitrflow, and everything else with gitflow.

However, I would simplify it in some cases. E.g., I don't see the need for a
"develop" branch in many cases, because teams with collective code ownership
and strong test coverage and continuous integration can integrate directly
to the master branch.  Plus, if a team does find a need for a "develop" branch
to integrate and stabilize changes prior to merging them to master, then
it's easy to just treat it as a feature branch (which is also an upstream) using
gitrflow.

# Goals, and Philosophy

## Merge or rebase?

Git has become the de-facto tool for version control in the modern software
industry.

However, it is very powerful and complex.  One of the largest areas of
contention and disagreement in the Git community is whether to use
`merge` or `rebase` to manage **feature** branches.

For some teams and organizations, this argument can become very heated,
to the point of being a 'religious' war.

The main goal of **gitrflow** is to support the usage of `rebase`, by
solving (and reframing) the problems with `rebase` which drive people
to prefer `merge` instead.

## Problems and their solutions

***IMPORTANT NOTE:*** *The following discussion only applies to ***feature***
 branches.  The `merge --no-ff` command is still used to manage the
 master branch and production release branches, which should never have
 their history rewritten by rebase.*

I firmly believe that rebase is a demonstrably superior strategy for managing
feature branches.  The main reasons people avoid it are because:

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
"information is lost".  However, I believe this is a non-goal, and an
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
**I'm always moving forward**.  There's rarely any benefit in knowing how my feature
branch used to work with an obsolete version of the upstream code.

Of course, a change may be reverted on the upstream branch, in which case
I'll deal with it, and make the corresponding changes when I rebase my feature
branch onto it, because **I'm always moving forward**

If you are still really concerned about this, then you can always keep a
backup copy of the state of your feature branch prior to rebasing.  That's
your choice, and I plan to eventually add support for this to gitrflow.

However, in no case should this line of argument ever be considered a
valid reason (in isolation) to avoid using rebase, assuming that the
actual valid concerns discussed above are addressed by using gitrflow.

## Lack of tool support

### Handling changing SHAs
Another complaint about rebase-based workflows is how tools, such as IDEs,
continuous integration systems, or other apps that display notifications
of Git commits, deal with it.

Since the SHAs for commits are changed as a result of a rebasing, a naive approach
of simply considering each unique SHA to be a new commit will not work well.  It
can result in undesired spammy notifications for every rebased commit, even if
the actual contents of the commit didn't change at all as a result of the rebase.

On the other hand, for commits that DID actually change as a result of the rebase
(i.e. to resolve a conflict), then the tool may or may not want to communicate
or act on that information, and must decide how to present it in the user interface.

This is a somewhat complex problem, but it's solveable - all the information
is available in the git metadata, and if you use GitHub, it's even easier to get
the information you need from their activity webhooks.

For example, in the case of commit notifications, one simple approach is to "collapse"
subsequent rebases of the same commit into a single commit in the UI.  This could be
expandable, and by default it could de-emphasize or omit entries for rebases that
didn't actually change a commit.

### Delivery and testing of rebased feature branches
Another problematic area with rebase workflows can be delivery and testing of feature
branches prior to merging them back into the upstream.  For a large and longer-lived
feature branch, you may want to frequently deploy it to a running environment in order
to test it, and accept delivered bugs or features.  In this case, you may want to
to identify which commits on the branch are associated with a specific bugfix or
feature, and you may have some automated process to generate this via a "changelist"
or similar report.  These processes may have issues if the SHAs on the feature
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

## Squash merges - they DO lose information

To get around some of the drawbacks of a merge-based workflow (a proliferation
of merge commits), you can use `merge --squash --no-commit` to merge the commits
from the feature branch back into the upstream branch as a single commit.

However, this is an anti-pattern in my opinion, because you've now lost all of the
individual atomic commits and their corresponding messages.  Small, focused commits
are a good practice (TODO: links), so the individual atomic commit sets and their
message *ARE* useful information which you don't want to lose, especially on feature
branches which have been long-lived, and contain many different changes for different
reasons.

In other words, it's very frustrating to do a `git blame` on a line to find out
why it was changed, only to find out it's part of a commit with dozens (or hundreds)
of files which changed, and a terse commit message of *"merge branch uber_epic
 into master"*.

## Goals and Benefits of rebase vs. merge workflow

TODO: flesh this out

* No disincentive to incorporate upstream and remote changes **constantly** - The
  more frequently you incorporate upstream changes, the better, because it minimizes
  the chances of other issues (see other points below).  So, all else aside, you
  should do this as frequently as possible, with the extreme being to integrate
  immediately after every upstream or remote commit.  With a merge-based
  workflow, every conflict resolution, whether it's automatic or manual, results
  in a separate merge commit, so this approach would result in a great number of
  extra commits.  However, since a rebase workflow *rewrites* the same commit,
  it doesn't suffer from this drawback.
* Atomic commits - the intent of every code change is contained in a single commit,
  not spread across the multiple commits in the case of merge-conflict-resolving
  commits.
* Linear history - Every commit has a single parent.  No spaghetti git log graphs,
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
  the feature branch are added into master with the unchanged SHAs.  This allows
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
    again and again."  This is **NOT** true, unless you abort the rebase.  Since
    rebase incorporates all changes up to the tip of the upstream branch you've
    rebased onto, by definition you never have to resolve the **same** conflict
    twice.  You may need to resolve a ***similar*** conflict, in the same commit,
    in the same code location, because the code has changed *again* in that location
    on the upstream branch since the last rebase, but it's a ***new*** conflict,
    not the same one.  Furthermore, this problem exists regardless of whether
    you are using a rebase or merge workflow.

# Glossary

* Feature Branch: A short-lived branch off of an upstream branch (i.e. will eventually
  be merged back into the upstream branch, unless it is discarded)
* Upstream Branch: A branch off of which a feature branch is made
* Remote Branch: A branch on the remote repository (i.e. Github)
* Integrate/Incorporate: Used synonymously to describe the act of including changes
  from an upstream branch or remote branch into the current feature branch.

# Credits

* Glen Ivey for helping envisioning and create the first working implementation
  of this workflow.
* Kris Hicks for writing many informative articles on Git, and inspiring me to
  finally learn Git well enough to leverage its full power through rebase.
* Everybody who argued with me against using rebase, forcing me to solidify and back
  up my position with facts and code. :)