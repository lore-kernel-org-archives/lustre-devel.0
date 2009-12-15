From: Andreas Dilger <adilger@sun.com>
Date: Tue, 15 Dec 2009 16:25:07 -0700
Subject: [Lustre-devel] Fwd: The Lustre community and GIT
In-Reply-To: <4B280B89.3010303@llnl.gov>
References: <2b20c7140912130831t658c2790hb38c3752c18ec128@mail.gmail.com>
	<2b20c7140912131047qf0417f1mf3f3d9a8fc751dc0@mail.gmail.com>
	<5F225623-87E0-4A91-988C-8B789B63E46D@sun.com>
	<4B280B89.3010303@llnl.gov>
Message-ID: <F661C7A0-E3C8-4B69-A275-F23844DDFCAB@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2009-12-15, at 15:19, Christopher J. Morrone wrote:
> Andreas Dilger wrote:
>> For people not familiar with Git, it should be clarified that  
>> limiting
>> commits to the Sun Prime repository does not in any way restrict
>> access to the Lustre code, or the ability of non-Sun developers to
>> share their own Git clone with the Lustre community.  Developers will
>> be able to host their own Lustre clones (essentially full
>> repositories) as and where they wish.
>
> Ah, right, good point.  We would probably just have an llnl lustre  
> repo
> on github (if not one for each developer...), once we figure out how  
> to
> make our branch more presentable.

You would should rebase your repository against the Lustre git repo,  
but that should be fairly straight forward since topgit keeps each  
patch in a separate branch.  In general, users can use git rebase for  
keeping their patches updated against a remote tree, but since you  
started with a completely different git repo it probably will fail  
horribly.

>> This is the same model used by the Linux kernel, and has proven to
>> work well with Git.  Each kernel developer hosts their own clone(s)  
>> at
>> git.kernel.org, or at some other site like repo.or.cz, or github.com,
>> and when they have changes to submit upstream they send an email
>> (usually containing both the patch, and the git URL to pull from) to
>> the subsystem maintainer, or to Linus directly, requesting that he
>> pull their changes.  This pull request is normally only sent after  
>> the
>> patch has been reviewed, possibly multiple times,  by the appropriate
>> subsystem maintainers.  Each developer has full control over their  
>> own
>> clone, and in fact it is rare that more than one person has push
>> access to a clone.
>
> Has Sun given any thought to how git might be more integrated into the
> Bugzilla patch review process?  In particular, for external  
> developers?

Actually, Robert found a few tools that allow attaching patches to  
bugzilla directly from git that seem very useful.  I don't have the  
names offhand, but it was very simple, like "git bz send-patch  
[bugno]" or similar.  Ideally, the gatekeeper would also be able to  
automatically mark the patch as landed on the appropriate release  
branch, but I suspect that would need a bit more scripting.  There has  
also been some investigation of "Review Board", but I don't know where  
that is today.

>  I see there is an internal "Lustre GIT page" that I can't access, and
> external contributors are just told to follow the "submitting patches"
> guidelines.
>
> We would love to be able to tell Sun to pull from a branch to get our
> unreviewed patches, and vice versa.


I agree that doing git pulls instead of patch submission is cleaner,  
but it definitely isn't a good way to do patch review.  For the kernel  
all of the patch review is done via email, but that has the drawback  
that the discussion about a given patch isn't kept in a single place,  
and it isn't clear who has agreed with or objected to a patch without  
trolling the whole thread each time.

We're still investigating how to improve the patch workflow, and  
welcome input.  The first priority was to make a Git repository  
available, and then we can look at improving how patches are handled  
(tracking, inspections, testing, landing).  I didn't want to entangle  
those two major process changes, as it would have delayed the Git  
transition even further.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
