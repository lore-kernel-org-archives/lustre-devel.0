From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 2 Nov 2011 13:17:29 -0600
Subject: [Lustre-devel] Lustre  code style Git commit hooks and
Message-ID: <E524F377-9B95-4736-92FF-22C711DD9EE8@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In order to help improve the quality of commits being submitted for
inclusion into Lustre, I've created some Git commit hooks that can
be used to detect problems with the format and coding style of the
patch before it is submitted to Gerrit.


The b1_8, b2_1, and master (2.2) branches of lustre-release now have
scripts called build/commit-msg and build/prepare-commit-msg that
should be copied into the .git/hooks/ subdirectory of any Lustre
checkout.  Currently the commit hooks are optional, but I would
recommend that everyone developing for Lustre would begin using them,
because I hope to make them mandatory in the future, once I'm sure
that they won't interfere with the development process.



The prepare-commit-msg hook will run the build/checkpatch.pl script
when "git commit" is run, and will append a comment with a summary
of any code style issues that it finds in the to-be-committed patch.
It is also possible to run checkpatch.pl manually before committing:

        git diff [--cached] | build/checkpatch.pl -

While checkpatch.pl isn't going to catch all cases that don't follow
the Lustre style style guidelines (as documented in the wiki page:

http://wiki.whamcloud.com/display/PUB/Coding+Guidelines)

This can catch a lot of trivial mistakes that avoid spending the time
of inspectors and test systems, and the need for patch resubmission.

Errors from checkpatch.pl currently won't prevent committing the patch,
but you shouldn't ignore the warnings or errors lightly, since they
can cause the patch to be rejected later after it has consumed test
and inspection resources.  The checkpatch.pl script also won't catch
all style problems, but it covers many of the basic problems.  If you
feel the script is not agreeing with the Lustre "Coding Guidelines"
page, or you would like to improve it, please email me with details
and/or file a bug with a patch to fix the issue.


The commit-msg hook verifies the format of the commit message itself,
so that it contains a Jira ticket number, a "subsystem:" field, a
commit body, and a Signed-off-by: line.  If no Gerrit "Change-Id:"
line is present it will automatically add this as well.  The new
"subsystem:" field is similar to those used for kernel commit messages
all have, so that it is easier to decide what part of the code a patch
affects.  Valid commit messages are of the form:

> LU-000 component: short description of change under 64 columns
> 
> A more detailed explanation of the change being made.  This can be
> as detailed as you'd like, possibly several paragraphs in length.
> 
> Please provide a detailed explanation of what problem was solved,
> a good high-level description of how it was solved, and which
> parts of the code were affected (including function names as
> needed).  Wrap lines at 72 columns or less.
> 
> Signed-off-by: Random J Developer <random@developer.example.org>
> Change-Id: Ica9ed1612eab0c4673dee088f8b441d806c64932

If you haven't looked at the "Using Gerrit" and "Submitting Changes"
wiki pages recently, or want more detailed information about the
patch submission process, they contain a more detailed description:

http://wiki.whamcloud.com/display/PUB/Using+Gerrit
http://wiki.whamcloud.com/display/PUB/Submitting+Changes


I hope that these small additions will help make the Lustre code more consistent and easier to read, and make our inspection, testing, and landing process more efficient as we move into 2.2 development.

Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
