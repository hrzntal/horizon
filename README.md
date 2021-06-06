# Horizon Station 13

[![GitHub continuous integrations status](https://img.shields.io/github/workflow/status/hrzntal/horizon/CI%20Suite/main?style=for-the-badge)](https://github.com/hrzntal/horizon/actions?query=workflow%3A%22CI+Suite%22)
[![Open GitHub pull requests](https://img.shields.io/github/issues-pr/hrzntal/horizon?color=blue&style=for-the-badge)](https://github.com/hrzntal/horizon/pulls)
[![Open GitHub issues marked as tracked bugs](https://img.shields.io/github/issues/hrzntal/horizon/Issue:Tracked%20Bug?label=Bug%20Reports&style=for-the-badge)](https://github.com/hrzntal/horizon/issues?q=is%3Aissue+is%3Aopen+label%3A%22Issue%3ATracked+Bug%22)
[![Open GitHub issues marked as feature requests](https://img.shields.io/github/issues/hrzntal/horizon/Issue:Feature%20Request?label=Feature%20Requests&color=a180f2&style=for-the-badge)](https://github.com/hrzntal/horizon/issues?q=is%3Aissue+is%3Aopen+label%3A%22Issue%3AFeature+Request%22)

![Built with Resentment](https://img.shields.io/static/v1?label=Built%20with&message=Resentment&labelColor=e36d25&color=d15d27&style=for-the-badge)
![Contains Tasty Spaghetti Code](https://img.shields.io/static/v1?label=Contains&message=Tasty%20Spaghetti%20Code&labelColor=31c4f3&color=389ad5&style=for-the-badge)
![Powered By Tailwags](https://img.shields.io/static/v1?label=Powered%20By&message=Tailwags&labelColor=c1d72f&color=5d9741&style=for-the-badge)

---

## About
Welcome to the Horizon Station 13 codebase.  
TBD

Code based on [/tg/station](https://github.com/tgstation/tgstation) among others.

| Helpful URLs |                               |
|---------|------------------------------------|
| Website | https://hrzn.fun                   |
| Code    | https://github.com/hrzntal/horizon |
| Discord | https://discord.hrzn.fun           |
| Git/GitHub cheatsheet | https://www.notion.so/Git-GitHub-61bc81766b2e4c7d9a346db3078ce833 |
| BYOND   | https://byond.com                  |
---

## DOWNLOADING
[Downloading](.github/DOWNLOADING.md)

[Running on the server](.github/RUNNING_A_SERVER.md)

[Maps and Away Missions](.github/MAPS_AND_AWAY_MISSIONS.md)

## :exclamation: How to compile :exclamation:

On **2021-01-04** we have changed the way to compile the codebase.

Find `BUILD.bat` here in the root folder of tgstation, and double click it to initiate the build. It consists of multiple steps and might take around 1-5 minutes to compile.

After it finishes, you can then [setup the server](.github/RUNNING_A_SERVER.md) normally by opening `tgstation.dmb` in DreamDaemon.

**Building tgstation in DreamMaker directly is now deprecated and might produce errors**, such as `'tgui.bundle.js': cannot find file`.

**[How to compile in VSCode and other build options](tools/build/README.md).**

## Requirements for contributors
[Guidelines for Contributors](.github/CONTRIBUTING.md)

<!-- Hopefully soon.
[/tg/station HACKMD account](https://hackmd.io/@tgstation) - Design documentation here
-->

[Documenting your code](.github/AUTODOC_GUIDE.md)

[Policy configuration system](.github/POLICYCONFIG.md)

## LICENSE

All code after [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU AGPL v3](https://www.gnu.org/licenses/agpl-3.0.html).

All code before [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html).
(Including tools unless their readme specifies otherwise.)

See LICENSE and GPLv3.txt for more details.

The TGS DMAPI API is licensed as a subproject under the MIT license.

See the footer of [code/__DEFINES/tgs.dm](./code/__DEFINES/tgs.dm) and [code/modules/tgs/LICENSE](./code/modules/tgs/LICENSE) for the MIT license.

All assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated.
