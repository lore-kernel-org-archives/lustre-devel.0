From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Wed, 24 Nov 2010 13:30:15 -0700
Subject: [Lustre-devel] Lustre tags
In-Reply-To: <4CED66BB.1010706@llnl.gov>
References: <4CED66BB.1010706@llnl.gov>
Message-ID: <A76D5D7F-5FFD-4802-B298-2CAFCC0E9F98@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-11-24, at 12:25, Christopher J. Morrone wrote:
> It would be really nice if Oracle developerss would start using either 
> annotated tags (git tag -a) or signed tags (git tag -s) for lustre 
> version tags.
> 
> The default "git tag" command just creates a lightweight tag, so there 
> is no record of who created the tag, or when the tag was created.

Chris,
thanks for the heads-up on this.  We can start to use "git tag -a" for future build and release tags if that is more useful.  Looking back through the commit history, I do see commit messages that are made whenever we do a build internally:

> - Log -----------------------------------------------------------------
> commit 2a63fa84d379e4261dcdb40ee25cbf3547a9de0a
> Author: Terry Rutledge <terry.rutledge@oracle.com>
> Date:   Fri Nov 19 13:33:04 2010 -0800
> 
>    Updated for 2.1.0 build 08.
> 
> diff --git a/lustre/autoconf/lustre-version.ac b/lustre/autoconf/lustre-version.ac
> index 3454c63..2dc7ecd 100644
> --- a/lustre/autoconf/lustre-version.ac
> +++ b/lustre/autoconf/lustre-version.ac
> @@ -1,6 +1,6 @@
> m4_define([LUSTRE_MAJOR],[2])
> m4_define([LUSTRE_MINOR],[0])
> -m4_define([LUSTRE_PATCH],[55])
> +m4_define([LUSTRE_PATCH],[56])
> m4_define([LUSTRE_FIX],[0])

This is updating the build version number.

> The tag, v2_0_56_0 has been created
>        at  2a63fa84d379e4261dcdb40ee25cbf3547a9de0a (commit)
> 
> - Log -----------------------------------------------------------------
> commit 2a63fa84d379e4261dcdb40ee25cbf3547a9de0a
> Author: Terry Rutledge <terry.rutledge@oracle.com>
> Date:   Fri Nov 19 13:33:04 2010 -0800
> 
>    Updated for 2.1.0 build 08.
> -----------------------------------------------------------------------

This is adding the tag on that commit.  For existing tags it should be possible to determine from the commit hash approximately when the tag was created, though I can imagine that it is possible to create a tag on an old hash long after the fact.


What specific use do you have for the tags, and is the above tag hash-to-commit-date mapping enough?  Is there any reason NOT to always use "-a" when creating a tag?

Terry,
could you please add this into the build/release tagging procedure for the future?

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
