From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 4 Nov 2011 10:40:41 -0600
Subject: [Lustre-devel] [wc-discuss] Lustre code style Git commit hooks
	and
In-Reply-To: <20111103222831.GB19258@llnl.gov>
References: <E524F377-9B95-4736-92FF-22C711DD9EE8@whamcloud.com>
	<20111103222831.GB19258@llnl.gov>
Message-ID: <8FB8F9D4-A179-490D-AE9F-61C731FD98AA@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-11-03, at 4:28 PM, Prakash Surya <surya1@llnl.gov> wrote:
> I like the idea of cleaning up the commit messages in Lustre, although I
> feel enforcing these rules is better suited at the server level.

There are already limited checks at the server level, and they may be tightened in the near future. The concerns about doing this included making sure that the verification scripts were working correctly first (i.e. as local hooks which can be bypassed if needed), to avoid too much disruption before developers got a chance to conform to the new requirements (i.e. some time after this initial announcement), and to catch the errors as early in the development process as possible (i.e. when the commit message is first created).

> Currently, the proposed hooks will not allow any local commits to occur
> if the message does not fit the format required. This presents
> unnecessary overhead if the commit in question is intended to be
> squashed or reworded later down the road.

True, but I've been using them for some time w/o undue effort for patches not intended for upstream use either. Note that there is a sample Signed-off-by: at the end of the commit comment that can be uncommented, and if you think it would be helpful a full template could be provided in the comments. 

> It also prevents downstream commits, which are not intended to make it
> upstream, from using any other commit message format. Thus, making it
> impossible to use downstream bug numbers in the message which don't
> take the form LU-nnn.
> 
> I think until those two use cases are accounted for, it will be tough
> for me to use the proposed commit hooks.

I thought about this previously, and tried (but did not commit) an environment variable that the commit-msg hook could could check to skip verification, something like:

COMCHECK=y git commit -a

> Perhaps, simply emitting a
> warning on offending messages, leaving enforcement to the upstream
> repository would suffice? Or bypass the local checks altogether if the
> first line summary does not begin with LU-nnn? Or both?

Since there are different Jira spaces (LU-nnn, ORI-nnn, MRP-nnn, etc.) this would be error prone. 

> On Wed, Nov 02, 2011 at 12:17:29PM -0700, Andreas Dilger wrote:
>> In order to help improve the quality of commits being submitted for
>> inclusion into Lustre, I've created some Git commit hooks that can
>> be used to detect problems with the format and coding style of the
>> patch before it is submitted to Gerrit.
>> 
>> 
>> The b1_8, b2_1, and master (2.2) branches of lustre-release now have
>> scripts called build/commit-msg and build/prepare-commit-msg that
>> should be copied into the .git/hooks/ subdirectory of any Lustre
>> checkout.  Currently the commit hooks are optional, but I would
>> recommend that everyone developing for Lustre would begin using them,
>> because I hope to make them mandatory in the future, once I'm sure
>> that they won't interfere with the development process.
>> 
>> 
>> 
>> The prepare-commit-msg hook will run the build/checkpatch.pl script
>> when "git commit" is run, and will append a comment with a summary
>> of any code style issues that it finds in the to-be-committed patch.
>> It is also possible to run checkpatch.pl manually before committing:
>> 
>>        git diff [--cached] | build/checkpatch.pl -
>> 
>> While checkpatch.pl isn't going to catch all cases that don't follow
>> the Lustre style style guidelines (as documented in the wiki page:
>> 
>> http://wiki.whamcloud.com/display/PUB/Coding+Guidelines)
>> 
>> This can catch a lot of trivial mistakes that avoid spending the time
>> of inspectors and test systems, and the need for patch resubmission.
>> 
>> Errors from checkpatch.pl currently won't prevent committing the patch,
>> but you shouldn't ignore the warnings or errors lightly, since they
>> can cause the patch to be rejected later after it has consumed test
>> and inspection resources.  The checkpatch.pl script also won't catch
>> all style problems, but it covers many of the basic problems.  If you
>> feel the script is not agreeing with the Lustre "Coding Guidelines"
>> page, or you would like to improve it, please email me with details
>> and/or file a bug with a patch to fix the issue.
>> 
>> 
>> The commit-msg hook verifies the format of the commit message itself,
>> so that it contains a Jira ticket number, a "subsystem:" field, a
>> commit body, and a Signed-off-by: line.  If no Gerrit "Change-Id:"
>> line is present it will automatically add this as well.  The new
>> "subsystem:" field is similar to those used for kernel commit messages
>> all have, so that it is easier to decide what part of the code a patch
>> affects.  Valid commit messages are of the form:
>> 
>>> LU-000 component: short description of change under 64 columns
>>> 
>>> A more detailed explanation of the change being made.  This can be
>>> as detailed as you'd like, possibly several paragraphs in length.
>>> 
>>> Please provide a detailed explanation of what problem was solved,
>>> a good high-level description of how it was solved, and which
>>> parts of the code were affected (including function names as
>>> needed).  Wrap lines at 72 columns or less.
>>> 
>>> Signed-off-by: Random J Developer <random@developer.example.org>
>>> Change-Id: Ica9ed1612eab0c4673dee088f8b441d806c64932
>> 
>> If you haven't looked at the "Using Gerrit" and "Submitting Changes"
>> wiki pages recently, or want more detailed information about the
>> patch submission process, they contain a more detailed description:
>> 
>> http://wiki.whamcloud.com/display/PUB/Using+Gerrit
>> http://wiki.whamcloud.com/display/PUB/Submitting+Changes
>> 
>> 
>> I hope that these small additions will help make the Lustre code more consistent and easier to read, and make our inspection, testing, and landing process more efficient as we move into 2.2 development.
>> 
>> Cheers, Andreas
>> --
>> Andreas Dilger 
>> Principal Engineer
>> Whamcloud, Inc.
>> 
>> 
> 
> -- 
> Cheers,
> Prakash
