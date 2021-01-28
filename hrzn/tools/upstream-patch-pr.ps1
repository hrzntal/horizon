<#
.SYNOPSIS
	This script can cherry-pick commits from an upstream PR, for example to create patches or stay in sync as a downstream
.PARAMETER PrNumber
	The PR id to pull the merge commit(s) from
.PARAMETER PushRemote
	Should the script push a new branch to the remote?
.PARAMETER OpenPR
	Should a PR be opened on the remote after pushing?
	This requires remote credentials and PushRemote to be set!
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
	[Int32]$PrNumber,
	[Parameter(
		ParameterSetName 	= 'Default',
		HelpMessage			= 'Push branch to Remote?'
	)]
	[Switch]$PushRemote,
	[Parameter(
		ParameterSetName 	= 'Default',
		HelpMessage			= 'Open PR on Remote?'
	)]
	[Switch]$OpenPR,
	[Parameter(
		ParameterSetName 	= 'Default',
		HelpMessage			= 'Do a testrun?'
	)]
	[Switch]$Dryrun
)

# Stop with any errors
$ErrorActionPreference = 'Stop'

# User Configuration

## This will show up on the branch before the PR number
## i.e. if its 'patch/' and the upstream is tgstation
## the result will be patch/tgstation-XXXXX
$PrBranchNamePrefix 	= 'patch/'

## PR title prefix
$PrTitlePrefix			= '[Mirror]'

## Contents of the Issue body that will show up on GH
## Title is omitted as it uses the prefix + original PR's title
$PrIssueBody = @"
Original PR: $UpstreamOwner/$UpstreamRepo#$PrNumber
---
"@

## Origin
$OriginOwner 			= 'hrzntal'
$OriginRepo 			= 'horizon'
$OriginDefaultBranch	= 'trunk'

## Upstream
$UpstreamOwner 			= 'tgstation'
$UpstreamRepo 			= 'tgstation'
$UpstreamDefaultBranch	= 'master'

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

# User Configuration End

trap {
	if ($LASTEXITCODE -ne 0) {
		if($_.Exception.Message) {
			Write-Error ("`n{0}" -f $_.Exception.Message)
		} else {
			Write-Error ("`n{0}" -f $_)
		}
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

# We take in an Int32 to make sure its a number, but we require it as a string only
$PrNumber = $PrNumber.ToString()

$PrBranch = $("$PrBranchNamePrefix{0}-{1}" -f $UpstreamRepo, $PrNumber)

Write-Verbose "Attempting to get PR information from GitHub..."
$RequestUrl = ("{0}/pulls/{1}" -f $ApiEndpoint, $PrNumber)
$RequestMethod = 'Get'
$RequestHeader = @{"Accept"="application/vnd.github.v3+json"}

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

# Checkout a new branch so we don't break anything, wherever we are!
# And yes it does not matter where we create the branch from
# 	as resetting to FETCH_HEAD will move us to the correct place!
# Ad astra!
Write-Verbose "Checking out branch $PrBranch ..."
git checkout -b "$PrBranch" 2>&1

# Get our origin's current master/main/trunk commit into FETCH_HEAD
Write-Verbose ("Fetching base branch {0} @ {1} ..." -f $OriginDefaultBranch, $OriginUrl)
git fetch "$OriginUrl" "$OriginDefaultBranch" 2>&1

# Reset to our FETCH_HEAD so the branch is in sync with our origin
Write-Verbose 'Resetting to fetched content...'
if (-not $Dryrun)
{
	git reset --hard FETCH_HEAD 2>&1
} else {
	# There's no dryrun equivalent, but mixed should do the most without
	# outright deleting exiting changes on tracked files
	# This may leave traces, should be investigated into
	git reset --no-quiet --mixed FETCH_HEAD
}

Write-Verbose 'Cleaning untracked and modified files/dirs...'
if (-not $Dryrun)
{
	# Clean EVERYTHING - yes this is destructive, but ideally
	# 	we should already be on a clean git repo
	# Don't @ me if you run this on your work folder and lost your uncommitted files
	git clean -df 2>&1
} else {
	# Just do a dryrun
	git clean --no-quiet -ndf
}

# We will need to be aware of the commit SHA's on the upstream to cherry-pick them.
Write-Verbose ("Fetching upstream branch {0} @ {1} ..." -f $UpstreamDefaultBranch, $UpstreamUrl)
git fetch "$UpstreamUrl" "$UpstreamDefaultBranch" 2>&1

# Do the cherry pickings 🍒🤏
Write-Verbose "Cherry picking $MergeChecksum into branch..."
git -c core.editor=$true cherry-pick --no-gpg-sign "$MergeChecksum" 2>&1

if ($PushRemote)
{
	Write-Verbose "Pushing branch $PrBranch to $OriginUrl ..."
	if (-not $Dryrun)
	{
		#git push -u "$OriginUrl" "$PrBranch" 2>&1
	} else {
		Write-Verbose " ℹ This is a dryrun so we're not pushing anything :)"
	}
}

if ($OpenPR)
{
	if(-not $PushRemote)
	{
		Write-Error "-PushRemote was not set, cannot open a PR this way."
		continue
	}
	Write-Verbose "Attempting to create a PR..."
	if (-not $Dryrun)
	{
		# Mmmm hopefully this will work out fine.
		#gh pr create -R "$OriginUrl" --title "$PrIssueTitle" --body "$PrIssueBody" 2>&1
	} else {
		Write-Verbose " ℹ Dryrun! Not doing anything."
	}
}

# Clean up after ourselves
git checkout "$OriginDefaultBranch" 2>&1
git branch -D "$PrBranch" 2>&1


Write-Verbose "`nAll Done!`n"
