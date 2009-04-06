From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Mon, 06 Apr 2009 13:23:51 +0300
Subject: [Lustre-devel] WBC HLD outline
In-Reply-To: <00a001c9b2a2$45665430$d032fc90$@com>
References: <200903240058.30343.alexander.zarochentsev@sun.com>
	<00a001c9b2a2$45665430$d032fc90$@com>
Message-ID: <200904061423.51437.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Eric,

Thanks for the review,

On 1 April 2009 12:17:17 Eric Barton wrote:
> Zam,
>
> Some notes on the WBC HLD outline

[...]

>
> 5. Is ensuring file data is delayed until file creation is
>    reintegrated sufficient for correct operation?  Are we not
>    effectively doing create-on-write with a WBC?  I'm sure there
>    are more issues (e.g. orphans).
>
>    Does including the OSTs in epoch recovery solve all the issues? 
> If so, what are the expected bounds on client redo and server undo
> storage?  Can we avoid needing server undo for data with some
> compromises?  Can we exploit the DMU at all?

I think we can't avoid tagging OST object creation w/ epoch counter.
Would Lustre users complain if file writes are out-of-epochs?

So a write to existing OST object may survive loosing the context of MD 
operations where the write operation was issued, object 
creation/deletion may not.

The alternative is to implement undo logging for file data. It would 
require support from underlaying server fs. It could be done for 
ldiskfs, not sure about DMU.

There is a security problem with out-of-epochs writes and setting 
file attributes (especially permissions):
chmod 400 foo; cat /etc/secret-file >> foo. Chmod/chown can be a special 
case which triggers wbc flush.

> 6. The section on recovering from WBC client death seems imprecise.
>    Is (a) just describing V1-4 in Nikita's original post - similarly
>    (b) for V1-2, V3'-5'?  Also, for (c) I think we may have discussed
>    the possibility of always sending updates as the full operation +
>    context to select which updates apply locally so that an operation
>    can always be recovered from any of its updates.

It is only a rough schema of client eviction to list what support might 
be needed in wbc protocol, like sending full MD op instead of update-- 
what you just mentioned. BTW, I thought Epochs HLD would cover the 
detailed algorithm descriptions, no?

>     Cheers,
>               Eric

Thanks,
-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
