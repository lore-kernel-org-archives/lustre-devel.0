From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Wed, 24 Nov 2010 14:17:53 -0800
Subject: [Lustre-devel] Lustre tags
In-Reply-To: <A76D5D7F-5FFD-4802-B298-2CAFCC0E9F98@oracle.com>
References: <4CED66BB.1010706@llnl.gov>
	<A76D5D7F-5FFD-4802-B298-2CAFCC0E9F98@oracle.com>
Message-ID: <4CED8F11.8090606@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 11/24/2010 12:30 PM, Andreas Dilger wrote:

> What specific use do you have for the tags, and is the above tag hash-to-commit-date mapping enough?  Is there any reason NOT to always use "-a" when creating a tag?

I hadn't done a fetch from prime in a couple of weeks, and when I just 
did it I saw that v1_8_5_RC4 had been tagged 1.8.5.  In that case, you 
can see that the change to lustre-version.ac to make it 1.8.5 actually 
happened several commits before the actual 1.8.5 tag.  I have no way of 
knowing how long v1_8_5_RC4 was in existence before it became 1.8.5.

Not a big deal, really.  But it would have been simple to see what 
happened if the tag had been of the annotated/signed type.

Also, in the past "git describe" did not stop at lightweight tags, only 
at annotated/signed tags.  That may have changed in newer versions of git.

I believe that annotated tags for lustre version numbers.

In fact, it kind of seems like annotated tags should be the default 
behavior for "git tag".  I can't think of a good reason why you would 
not want a tag to be annotated if you are going to share it with others.

My guess is that lightweight tags are just the default in git for 
historical reasons (they were implemented first).

Chris
