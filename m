From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Tue, 15 Dec 2009 14:19:53 -0800
Subject: [Lustre-devel] Fwd: The Lustre community and GIT
In-Reply-To: <5F225623-87E0-4A91-988C-8B789B63E46D@sun.com>
References: <2b20c7140912130831t658c2790hb38c3752c18ec128@mail.gmail.com>	<2b20c7140912131047qf0417f1mf3f3d9a8fc751dc0@mail.gmail.com>
	<5F225623-87E0-4A91-988C-8B789B63E46D@sun.com>
Message-ID: <4B280B89.3010303@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:

> For people not familiar with Git, it should be clarified that limiting  
> commits to the Sun Prime repository does not in any way restrict  
> access to the Lustre code, or the ability of non-Sun developers to  
> share their own Git clone with the Lustre community.  Developers will  
> be able to host their own Lustre clones (essentially full  
> repositories) as and where they wish.

Ah, right, good point.  We would probably just have an llnl lustre repo 
on github (if not one for each developer...), once we figure out how to 
make our branch more presentable.

> This is the same model used by the Linux kernel, and has proven to  
> work well with Git.  Each kernel developer hosts their own clone(s) at  
> git.kernel.org, or at some other site like repo.or.cz, or github.com,  
> and when they have changes to submit upstream they send an email  
> (usually containing both the patch, and the git URL to pull from) to  
> the subsystem maintainer, or to Linus directly, requesting that he  
> pull their changes.  This pull request is normally only sent after the  
> patch has been reviewed, possibly multiple times,  by the appropriate  
> subsystem maintainers.  Each developer has full control over their own  
> clone, and in fact it is rare that more than one person has push  
> access to a clone.

Has Sun given any thought to how git might be more integrated into the 
Bugzilla patch review process?  In particular, for external developers? 
  I see there is an internal "Lustre GIT page" that I can't access, and 
external contributors are just told to follow the "submitting patches" 
guidelines.

We would love to be able to tell Sun to pull from a branch to get our 
unreviewed patches, and vice versa.

Chris
