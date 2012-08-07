From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 7 Aug 2012 13:45:43 -0600
Subject: [Lustre-devel] [lustre-devel]  merges to b2_<x>
In-Reply-To: <20120807160854.GL6857@llnl.gov>
References: <50209FD0.8000306@cray.com> <20120807160854.GL6857@llnl.gov>
Message-ID: <E6EEE694-681F-4414-A41C-AD634C17800B@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-08-07, at 10:08 AM, Prakash Surya wrote:
> Looking at the man page for git-cherry-pick, I'm not sure the "-x"
> option would entirely work:
> 
>    "Append the note only for cherry picks without conflicts."
> 
> How often do the backported patches apply without conflicts? With the
> amount of code change taking place, my guess is conflicts are normal
> operation. A developer enforced convention detailing the commit
> backported and perhaps what and why changes were necessary to apply
> cleanly would suffice. So long as it doesn't clutter the commit message.

I agree that having some standardized way of linking two commits on different branches would be quite useful.  In some cases, Oleg is able to do a cherry-pick of the original patch from master to b2_1, but in other cases there are separate patches submitted to Gerrit (with separate Change-Ids) for each branch in order to simplify patch testing.

> Another way to do this would be to use the same Change-Id field for the
> backported patch. One could grep for the Change-Id in the commit logs
> relatively easily, although I'm not sure how the review system would
> handle this.

Using the same Change-Id on two different branches causes heartburn for Gerrit, unfortunately.  This has happened by accident a few times, when a series of patches were merged into a development branch and then accidentally pushed to Gerrit.  It thinks that these previously-landed patches are all "in progress" again, and causes every later patch on the original branch (usually master) to claim them as open dependencies.

I'd rather have standardized keyword(s) that contain the original Git commit from master, and possibly the original Change-Id value.  There is already a "{name}-bug-id:" tag in use for tracking a patch from different upstream ticketing systems (e.g. Xyratex, Oracle, Whamcloud).

Cheers, Andreas

> On Mon, Aug 06, 2012 at 09:55:44PM -0700, Cory Spitz wrote:
>> Hi.
>> 
>> We at Cray have been looking at b2_1 landings, and one thing that I 
>> think would be nice is if we could identify the master commit that the 
>> b2_1 commit is based on directly from the mod header.  Unless, of 
>> course, there is an easy way to derive this information via git.  I hope 
>> that this isn't a stupid question, but is there?  It seems to me that 
>> since most b2_1 commits are cherry picked that we lose that bit.  It 
>> seems that git cherry-pick -x might be useful here.  Is that all we need?
>> 
>> If there isn't an easy way for git to provide the lineage, would we be 
>> able to add an additional commit tag or just advertise a convention to 
>> follow at http://wiki.whamcloud.com/display/PUB/Commit+Comments?
>> 
>> Thanks,
>> -Cory
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.opensfs.org
> http://lists.opensfs.org/listinfo.cgi/lustre-devel-opensfs.org


Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Lustre Engineer            http://www.whamcloud.com/
