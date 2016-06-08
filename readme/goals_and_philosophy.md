# Goals, and Philosophy

# Table of Contents

* [Intro](#intro)
* [Merge or rebase?](#merge-or-rebase)
  * [The debate](#the-debate)
  * [The Git Book's summary of positions](#the-git-books-summary-of-positions)
  * [The case for rebasing feature branches](#the-case-for-rebasing-feature-branches)
* [Problems and their solutions](#problems-and-their-solutions)
* ["But rebasing loses information..." - A history lesson](#but-rebasing-loses-information---a-history-lesson)
* [Lack of tool support](#lack-of-tool-support)
  * [Handling changing SHAs](#handling-changing-shas)
  * [Delivery and testing of rebased feature branches](#delivery-and-testing-of-rebased-feature-branches)
  * [Considerations](#considerations)
* [Public / Open Source feature branches - safe to rebase?](#public--open-source-feature-branches---safe-to-rebase)
* [Squash merges - they DO lose information](#squash-merges---they-do-lose-information)
* [When committing merge conflicts is unavoidable](#when-committing-merge-conflicts-is-unavoidable)
* [Goals and Benefits of rebase over a merge workflow](#goals-and-benefits-of-rebase-over-a-merge-workflow)

## Intro

gitrflow is based upon an opinionated premise:

*"You should use a rebase-based workflow to manage Git feature/story branches."*

If you understand and agree with this, then gitrflow is for you!  See the
[README.md](../README.md) for docs and summary of gitrflow usage, or use the command line help.

If you don't understand what that means, or if you disagree with using a rebase-based workflow
for feature branches, then I respectfully invite you to review this
Goals, and Philosophy page with an open mind.

Thanks for reading. :)

**UPDATE: Actually you can have a "develop" branch as your main if you want.
My thinking has evolved on this, it doesn't really matter what you name
your upstream branch, or if you have it "promoted" to other branches,
e.g. the standard Gitflow develop -> master approach.  I'll update the docs
accordingly, but everything else still applies.  TODO: UPDATE ACCORDINGLY.**

## Merge or rebase?

### The debate

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

### The Git Book's summary of positions

The **Git Book** provides [the following excellent summary](http://git-scm.com/book/en/v2/Git-Branching-Rebasing#Rebase-vs.-Merge)
of both sides of the debate.

The case for merging:

> One point of view on this is that your repository’s commit history is a record
> of what actually happened. It’s a historical document, valuable in its own right,
> and shouldn’t be tampered with. From this angle, changing the commit history is
> almost blasphemous; you’re lying about what actually transpired. So what if
> there was a messy series of merge commits? That’s how it happened, and the
> repository should preserve that for posterity.

...and the case for rebasing:

> The opposing point of view is that the commit history is the story of how your
> project was made. You wouldn’t publish the first draft of a book, and the manual
> for how to maintain your software deserves careful editing. This is the camp
> that uses tools like rebase and filter-branch to tell the story in the way
> that’s best for future readers.

So, the position of gitrflow is that **BOTH** positions are correct:

* For master and production release branches, you should NEVER change history,
  and therefore these types branches should never be rebased.
* For feature branches, you only care about the story of how the feature branch
  was made, not about any draft versions.  This is because it will eventually be
  merged, in its final, rebased form, to the master branch, and that final version
  of the feature branch's history IS the one (and the ONLY one) that matters.
  to master, which is 

### The case for rebasing feature branches

The best justification for rebasing I've seen is by Randy Fay in
his article [A Rebase Workflow for Git](http://randyfay.com/content/rebase-workflow-git):

> The merge workflow will do you no damage at all if you
> * Only have one committer (or a very small number of committers, and you trust them all)
> * AND (*emphasis mine*)
> * You don't care much about reading your history.

So, to follow up on that, I would ask this: If you are a small team or a team of one,
AND you ***don't care about reading your history***, why are you using Git with
feature branches?  It would be much simpler to just always work on master, or
even use an versioned document system like Google Docs.

In other words (and to invert the above points), if you have a large team, **OR**
you care about reading your history (which I believe every responsible software
developer should), then you should be using rebase for feature branches.

Granted, it's hard to get right, especially if you are new to Git, and especially if you
have a team larger than one to coordinate among, but that's exactly the problems
gitrflow is designed to solve.  For more detailed discussions of these problems
and their solutions, continue reading...

## Problems and their solutions

***IMPORTANT NOTE:*** *The following discussion only applies to* ***feature***
 *branches. The `merge --no-ff` command is still used to manage the
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
***current state of history on my upstream branch*** and the ***logical
intent of the commits on my feature branch***.

In other words, if the upstream branch has changed, and my feature branch
needs to change correspondingly, then ***I don't care about the old state
of my feature branch, which only works with the old state of the upstream
branch***, as long as the ***logical intent of the atomic commits on the
feature branch are preserved***.

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

## When committing merge conflicts is unavoidable

*(Note: this section is **NOT** referring to merges with `--no-ff` which
do **NOT** resolve merge conflicts - that's done normally, every time that
`gitrflow feature finish` is used to merge a feature branch into master,
and also on github pull requests)*

The only time it might be unavoidable to make a merge-conflict-resolving commit
is when merging a *'hotfix'* branch into the master and release branch(es).

This is because master and the release branches should ordinarily never be
rebased (as feature branches are).  Therefore, it is possible for a hotfix
branch to introduce a conflict which is unresolvable without making a merge
commit which resolves the conflict.

Of course, you might still decide it is safe to do a rebase of master or
a release branch in this case if you think it's safe.  E.g., if you
know nobody else uses master or can be trusted to properly reset it, or if
you have not yet made any tags on a release branch, and thus know it's
safe to rebase.  Just be aware this will involve ensuring everyone/everywhere
with a local copy of the branches will need to fetch and
`reset --hard origin/branch` in order to get the changes (and ensure subsequent
gitrflow operations on these branches still operate properly).

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
