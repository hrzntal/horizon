<#
.SYNOPSIS
	This script can cherry-pick commits from an upstream PR, for example to create patches or stay in sync as a downstream
.PARAMETER PrNumber
	The PR id to pull the merge commit(s) from
.PARAMETER PushRemote
	Should the script push a new branch to the remote?
.PARAMETER OpenPull
	Should a PR be opened on the remote after pushing?
	This requires remote credentials and PushRemote to be set!
.PARAMETER KeepBranch
	Should the patch branch be kept locally?
.PARAMETER GitHubToken
	Supply a token for authenticating to GitHub
.PARAMETER DryRun
	Should a "dry-run" be done? This will not push to remotes or leave any traces, intended to test the functionality of the script.
.EXAMPLE
	scriptname.ps1 -PrNumber 42 -PushRemote
.NOTES
	Copyright 2020 Avunia Takiya <https://takiya.cloud>, The Horizon Project <https://github.com/hrzntal>

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

[CmdletBinding(DefaultParameterSetName = 'Default')]
param(
	[Parameter(
		ParameterSetName	= 'Default',
		HelpMessage			= 'Pull Request Number',
		Position 			= 0
	)]
	[Int32] $PrNumber,
	[Parameter(
		ParameterSetName 	= 'Default',
		HelpMessage			= 'Push branch to Remote?'
	)]
	[Switch] $PushRemote,
	[Parameter(
		ParameterSetName 	= 'Default',
		HelpMessage			= 'Open PR on Remote?'
	)]
	[Switch] $OpenPull,
	[Parameter(
		ParameterSetName 	= 'Default',
		HelpMessage 		= 'Keep branch?'
	)]
	[Switch] $KeepBranch,
	[Parameter(
		ParameterSetName 	= 'Default',
		HelpMessage 		= 'Github Auth Token'
	)]
	[string] $GitHubToken,
	[Parameter(
		ParameterSetName 	= 'Default',
		HelpMessage			= 'Do a testrun?'
	)]
	[Switch] $Dryrun
)

# Some vars that need or should be set quite early
## Stop with any errors
$ErrorActionPreference = 'Stop'
$PrNumber = $PrNumber.ToString()

# User Configuration

## Origin
$OriginOwner 			= 'hrzntal'
$OriginRepo 			= 'horizon'
$OriginDefaultBranch	= 'trunk'

## Upstream
$UpstreamOwner 			= 'tgstation'
$UpstreamRepo 			= 'tgstation'
$UpstreamDefaultBranch	= 'master'

## This will show up on the branch before the PR number
## i.e. if its 'patch/' and the upstream is tgstation
## the result will be patch/tgstation-XXXXX
$PrBranchNamePrefix 	= 'patch/'

## PR title prefix
$PrTitlePrefix			= '[MIRROR]'

## Contents of the Issue body that will show up on GH
## Title is omitted as it uses the prefix + original PR's title
$PrIssueBody = @"
(debugmode)
Original PR: $UpstreamOwner  /  $UpstreamRepo  #  $PrNumber
---

"@

## Only change these if you know what you are doing
## WARNING: Further tweaking in the code MAY be required
## 			if any of these are touched!
$ServiceProtocol		= 'https://'
$ServiceDomain			= 'github.com'
$ApiDomain				= 'api.github.com'

## Convenience vars
$ServiceUrl 			= "$ServiceProtocol$ServiceDomain"
$ApiUrl 				= "$SerivceProtocol$ApiDomain"
$OriginUrl 				= "$ServiceUrl/$OriginOwner/$OriginRepo.git"
$UpstreamUrl 			= "$ServiceUrl/$UpstreamOwner/$UpstreamRepo.git"
$ApiEndpoint			= "$ApiUrl/repos/$UpstreamOwner/$UpstreamRepo"

# We take in an Int32 to make sure its a number, but we require it as a string only
$PrBranch = $("$PrBranchNamePrefix{0}-{1}" -f $UpstreamRepo, $PrNumber)

$RequestUrl = ("{0}/pulls/{1}" -f $ApiEndpoint, $PrNumber)
$RequestMethod = 'Get'
$RequestHeader = @{"Accept"="application/vnd.github.v3+json"}

# User Configuration End

# Function wrappers for commonly used binaries
function Invoke-GitCommand($Arguments)
{
	$command = "git $Arguments"

	cmd /c $command '1>&2'

	if ($?)
	{
		Write-Verbose "Ran command `"$command`""
		Write-Verbose "$_"
	} else {
		Write-Error "$command"
		Write-Error "$_"
	}
}

function Invoke-GitHub($Arguments)
{
	if ($WarnNo_gh) {
		Write-Warning "No GitHub CLI installed - skipping command `"$command`""
		return
	}
	$command = "gh $Arguments"

	cmd /c $command '1>&2'

	if ($?)
	{
		Write-Verbose "Ran command `"$command`""
		Write-Verbose "$_"
	} else {
		Write-Error "$command"
		Write-Error "$_"
	}
}

# Environment checks
## Make sure we're running on an environment with powershell v5 or later
if ($PSVersionTable['PSVersion'].Major -lt 5)
{
	trap {
		Write-Error "`nPowershell version is < 5"
		Write-Verbose 'Upgrade your version!'
		Write-Verbose 'https://github.com/PowerShell/PowerShell/releases/latest'
	}
	throw 'Running shell is outdated'
}

## Check if git is available
if (-not (Get-Command "git" -ErrorAction SilentlyContinue))
{
	trap {
		Write-Error "`ngit was not found on PATH, aborting!"
		Write-Verbose 'Install git to resolve this issue'
		Write-Verbose 'https://git-scm.com/downloads'
	}
	throw 'Git not found'
}

if (-not (Get-Command "gh" -ErrorAction SilentlyContinue))
{
	Write-Warning "`ngh (GitHub CLI) was not found on PATH."
	Write-Verbose 'Will not be able to do any github-related actions.'
	$WarnNo_gh = $true
}

## Check if we are in a git repository - on CI this should be set up by the workflow
## We could do it here, but this script is intended to also be used by users
## And we don't want to break anything (too much)
if (-not (Test-Path -Path './.git'))
{
	throw 'Directory does not seem to contain a .git repo'
}

if (-not ($PSBoundParameters.ContainsKey('PrNumber')))
{
	trap {
		Write-Error "`nThe PrNumber parameter is missing"
	}
	throw
}

# Is this a dryrun? If so, make sure the user knows
if ($Dryrun)
{
	Write-Warning "`nA dry-run was requested, not doing any lasting changes!`n"
}

Write-Verbose "Attempting to get PR information from GitHub..."
try {
	# Get the pull request data from the remote provider
	$PullRequestData = Invoke-RestMethod -Method "$RequestMethod" -Uri "$RequestUrl" -Headers $RequestHeader
	# And also the commits if possible
	$PullRequestCommits = Invoke-RestMethod -Method "$RequestMethod" -Uri "$RequestUrl/commits" -Headers $RequestHeader
}
catch {
	if ($_.ErrorDetails.Message)
	{
		Write-Error $_.ErrorDetails.Message
	} else {
		Write-Error $_
	}
}

$MergeChecksum = $PullRequestData.merge_commit_sha
$PrIssueTitle = ("$PrTitlePrefix {0}" -f $PullRequestData.title)

$PrIssueBody = ("$PrIssueBody {0}" -f $PullRequestData.body)

Write-Verbose "Stashing any existing changes..."
Invoke-GitCommand("add .")
Invoke-GitCommand("stash -m `"Automatic stash generated for $PrBranch`"")

# Checkout a new branch so we don't break anything, wherever we are!
# And yes it does not matter where we create the branch from
# 	as resetting to FETCH_HEAD will move us to the correct place!
# Ad astra!
Write-Verbose "Checking out branch $PrBranch ..."
if ($Dryrun)
{
	Invoke-GitCommand("checkout -B $PrBranch")
} else {
	Invoke-GitCommand("checkout --quiet -B $PrBranch")
}

# Get our origin's current master/main/trunk commit into FETCH_HEAD
Write-Verbose ("Fetching base branch {0} @ {1} ..." -f $OriginDefaultBranch, $OriginUrl)
if ($Dryrun)
{
	Invoke-GitCommand("fetch $OriginUrl $OriginDefaultBranch")
} else {
	Invoke-GitCommand("fetch --quiet $OriginUrl $OriginDefaultBranch")
}

# Reset to our FETCH_HEAD so the branch is in sync with our origin
Write-Verbose 'Resetting to fetched content...'
# There's no dryrun equivalent, but mixed should do the most without
# outright deleting exiting changes on tracked files
# This may leave traces, should be investigated into
if ($Dryrun)
{
	Invoke-GitCommand("reset --no-quiet --mixed FETCH_HEAD")
} else {
	Invoke-GitCommand("reset --hard FETCH_HEAD")
}

Write-Verbose 'Cleaning untracked and modified files/dirs...'
# Clean EVERYTHING - yes this is destructive, but ideally
# 	we should already be on a clean git repo
# Don't @ me if you run this on your work folder and lost your uncommitted files
if ($Dryrun)
{
	Invoke-GitCommand("clean --dry-run --force -d")
} else {
	Invoke-GitCommand("clean --quiet --force -d")
}


# We will need to be aware of the commit SHA's on the upstream to cherry-pick them.
Write-Verbose ("Fetching upstream branch {0} @ {1} ..." -f $UpstreamDefaultBranch, $UpstreamUrl)
if ($Dryrun)
{
	Invoke-GitCommand("fetch $UpstreamUrl $UpstreamDefaultBranch")
} else {
	Invoke-GitCommand("fetch --quiet $UpstreamUrl $UpstreamDefaultBranch")
}

# Do the cherry pickings 🍒🤏
Write-Verbose "Cherry picking $MergeChecksum into branch..."
$CherryPickOutput = (git -c core.editor=$true cherry-pick --no-gpg-sign $MergeChecksum)
if ($CherryPickOutput -match "Merge conflict")
{
	Invoke-GitHub("add -A .")
	Invoke-GitHub("-c core.editor=$true cherry-pick --no-gpg-sign --continue")
}

# Remove all mentions from the commit message by adding a space after the @
$cherryPickCommitMessage = (git -c core.editor=$true log -1 --pretty=%B) -replace "@", "@ "
Write-Verbose "Rewriting commit message..."
Invoke-GitCommand("-c core.editor=$true commit --no-gpg-sign -m `"$cherryPickCommitMessage`" --amend")

if ($PushRemote)
{
	Write-Verbose "Pushing branch $PrBranch to $OriginUrl ..."
	if ($Dryrun)
	{
		Write-Verbose " ℹ This is a dryrun so we're not pushing anything :)"
		Invoke-GitCommand("push --dry-run -u $OriginUrl $PrBranch")
	} else {
		# Push it to the limit 🎶
		# Porcelain there but unsure if pwsh would complain about stdout as its being redirected, hence quiet
		Invoke-GitCommand("push --porcelain --quiet -u $OriginUrl $PrBranch")
	}
}

if ($OpenPull)
{
	Write-Verbose 'Attempting to create a PR...'
	if (-not ($PushRemote))
	{
		Write-Error 'PushRemote was not set, cannot open a PR this way.'
	}
	if (-not ($Dryrun))
	{
		# Mmmm hopefully this will work out fine.
		if ($GitHubToken)
		{
			Invoke-GitHub("pr auth login --with-token `"$GitHubToken`"")
		}
		Invoke-GitHub("pr create -R `"$OriginOwner/$OriginRepo`" --base `"$OriginDefaultBranch`" --head `"$PrBranch`" --title `"$PrIssueTitle`" --body `"$PrIssueBody`"")
	} else {
		Write-Verbose ' ℹ Dryrun! Not doing anything.'
	}
}

# Clean up after ourselves
if ($Dryrun) {
	Invoke-GitCommand("checkout --force `"$OriginDefaultBranch`"")
} else {
	Invoke-GitCommand("checkout --force --quiet `"$OriginDefaultBranch`"")
}

if (-not $KeepBranch)
{
	if ($Dryrun) {
		Invoke-GitCommand("branch --delete --force `"$PrBranch`"")
	} else {
		Invoke-GitCommand("branch --quiet --delete --force `"$PrBranch`"")
	}
}

Write-Verbose "`nAll Done!`n"

trap {
	if ((git branch --show-current) -match "$PrBranch")
	{
		Invoke-GitCommand("checkout `"$OriginDefaultBranch`"")
		Invoke-GitCommand("branch -D `"$PrBranch`"")
	}
}
