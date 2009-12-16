From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Tue, 15 Dec 2009 17:18:47 -0800
Subject: [Lustre-devel] Fwd: The Lustre community and GIT
In-Reply-To: <F661C7A0-E3C8-4B69-A275-F23844DDFCAB@sun.com>
References: <2b20c7140912130831t658c2790hb38c3752c18ec128@mail.gmail.com>
	<2b20c7140912131047qf0417f1mf3f3d9a8fc751dc0@mail.gmail.com>
	<5F225623-87E0-4A91-988C-8B789B63E46D@sun.com>
	<4B280B89.3010303@llnl.gov>
	<F661C7A0-E3C8-4B69-A275-F23844DDFCAB@sun.com>
Message-ID: <4B283577.3070905@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> On 2009-12-15, at 15:19, Christopher J. Morrone wrote:
>> Andreas Dilger wrote:
>>> For people not familiar with Git, it should be clarified that limiting
>>> commits to the Sun Prime repository does not in any way restrict
>>> access to the Lustre code, or the ability of non-Sun developers to
>>> share their own Git clone with the Lustre community.  Developers will
>>> be able to host their own Lustre clones (essentially full
>>> repositories) as and where they wish.
>>
>> Ah, right, good point.  We would probably just have an llnl lustre repo
>> on github (if not one for each developer...), once we figure out how to
>> make our branch more presentable.
> 
> You would should rebase your repository against the Lustre git repo, but 
> that should be fairly straight forward since topgit keeps each patch in 
> a separate branch.  In general, users can use git rebase for keeping 
> their patches updated against a remote tree, but since you started with 
> a completely different git repo it probably will fail horribly.

I'm not really clear what you mean here.  I am not worried about merging 
in the latest from Sun's repo, that can be done a number of ways easily 
enough.

Lets say that I DON'T use topgit, because it is just going to be 
confusing for anyone else who tries to look at our repo.  And lets say 
that I have a branch of lustre that has 50 "patches" against the 
upstream code (our 1.6.6 branch had 175 patches! lets hope we don't 
diverge that much again...)

How do I keep track of the logical set of patches?  I am not worried 
that I will lose them, I'm worried that cruft will accumulate, and that 
their will be hidden conflicts.  I am worried that llnl will fix the 
problem one way, and then Sun will fix it another, and now we have two 
fixes that don't get along in our tree.  Its entirely possible that 
there will be no contextual conflicts, even thought the fixes don't work 
together.

Also, if we commit all of our work to one tree, how do we keep track of 
which commits belong to the same "bug"?

Maybe I am just overthinking the problem.  I'm hoping that I am.

Sun is never going to perform a full "pull" from the "llnl" branch.  And 
rightly so, that would just be too many disparate fixes to digest.  So 
(at llnl) have two somewhat conflicting goals:

1) Keep every logical change separate (so we can interact with Sun sanely)
2) Keep all changes together (so we can tag and install it :))

Previously we solved the problem with quilt, and now we solve this with 
topgit.  As long as we do not publish our repo, using topgit is probably 
going to be fine.  But I am worried that if we publish our repo, the 
history will just look like nonsense to other (because of topgit), and 
not be terribly useful beyond those folks that just want to blindly use 
our latest tag.

Chris
