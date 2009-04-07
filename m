From: Andreas Dilger <adilger@sun.com>
Date: Mon, 06 Apr 2009 23:18:43 -0700
Subject: [Lustre-devel] WBC HLD outline
In-Reply-To: <200904061423.51437.alexander.zarochentsev@sun.com>
References: <200903240058.30343.alexander.zarochentsev@sun.com>
	<00a001c9b2a2$45665430$d032fc90$@com>
	<200904061423.51437.alexander.zarochentsev@sun.com>
Message-ID: <20090407061843.GA3204@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Apr 06, 2009  13:23 +0300, Alexander Zarochentsev wrote:
> On 1 April 2009 12:17:17 Eric Barton wrote:
> I think we can't avoid tagging OST object creation w/ epoch counter.
> Would Lustre users complain if file writes are out-of-epochs?
> 
> There is a security problem with out-of-epochs writes and setting 
> file attributes (especially permissions):
> chmod 400 foo; cat /etc/secret-file >> foo. Chmod/chown can be a special 
> case which triggers wbc flush.

While this example has been given many times as a security issue that
forces many strange actions on the part of Lustre, the example is
fundamentally broken because POSIX allows "foo" to be opened before the
chmod, and kept open until after the write and then read the "secret-file"
content.  The "foo" file needs to be created securely in the first place
to be safe.

> > 6. The section on recovering from WBC client death seems imprecise.
> >    Is (a) just describing V1-4 in Nikita's original post - similarly
> >    (b) for V1-2, V3'-5'?  Also, for (c) I think we may have discussed
> >    the possibility of always sending updates as the full operation +
> >    context to select which updates apply locally so that an operation
> >    can always be recovered from any of its updates.
> 
> It is only a rough schema of client eviction to list what support might 
> be needed in wbc protocol, like sending full MD op instead of update-- 
> what you just mentioned. BTW, I thought Epochs HLD would cover the 
> detailed algorithm descriptions, no?

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
