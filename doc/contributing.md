# Contributing

We're happy you want to contribute! 💜

You may:

- [Propose changes](#proposing-a-change)
- [Write code](#writing-code)
- [Review code](#reviewing-code)

## Paths to become a contributor

1. To propose changes or write code, the repo is open-source so you're ready to go 🚀
1. If you make loved contributions, we'll surely contact you and invite you to join as a volunteer (join the Slack, become a repo collaborator...) 💪
1. You may then go further and help with reviews, merges, managing ops. At this point, we'll be in touch 😉

## Proposing a change

1. Check if there is something matching in [issues](https://github.com/hostolab/covidliste/issues). If yes, please discuss on it.
2. Otherwise, create a new issue and mention our matching [champions](champions.md).

## Writing code

1. Select an issue from the [roadmap](https://github.com/hostolab/covidliste/projects/1) or [issues](https://github.com/hostolab/covidliste/issues).
2. Check issue priority: `P0` is highest priority, `P3` the lowest.
3. Drop a comment to say you want to work on it.
4. [Setup your dev environment](developing.md) and rock on 🎸.
5. Create a pull-request (we use the [Github flow](https://guides.github.com/introduction/flow/)).

### Recommended practices when taking an issue

- Look for issues tagged `good first issue` for your 1st contribution.
- Drop a comment to say you'll work on it.
  - If possible mention an approximate ETA.
  - Repo admins will assign the issue to you and help if possible.

### Recommended practices for pull-requests

- Be verbose in your description: what have you done, why and screenshots are welcome.
- Link the original issue to your PR.
- Ask for feedback early, don't hesitate to ask for help. Mention our [champions](champions.md).
- **Mark your PR as draft** until you're done and ready for a formal review.
- Check all Github actions are green.
- Ask for review using Github's feature.

### Merge process

- Only some contributors are authorized to merge (see [champions](./champions.md) to see who).
- More are allowed to review, easing the work of those who can merge.
- Merging in `master` will automatically deploy to production.

## Reviewing code

_We have a preference for contributors who also write code, but if you only have time for reviews and you have a significative Rails experience, that will help!_

- If you want to **help with reviews**, we'll add you as a collaborator of the repository. Send an email to [romain-covidliste@runbox.com](mailto:romain-covidliste@runbox.com).
- Once you're in, look at [pull requests](https://github.com/hostolab/covidliste/pulls) and choose one
- Don't forget to **assign yourself** to the PR so others will look at others
- If you need help, mention one of our [champions](./champions.md)
- Once the PR is approved, one of the admins will be able to merge it with a faster review, so thanks in advance for the time you saved them 🙏

**Review guidelines**

- Keep code consistent with the Rails-way and Ruby idioms
- Keep things simple: this is a time-limited project so no need for tech perfection, over-engineering or extraneous features
- Never forget to check for security risks and how personal data is processed

We favor explicit doubts and discussion so don't hesitate to be verbose when commenting a PR to trigger a discussion. Still, let's keep discussion short and efficient!

Of course, you're expected to follow our [code of conduct](./code_of_conduct.md) in all interactions, in particular reviews!

Thanks in advance for your help 🙏