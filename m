From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Mon, 25 Feb 2008 00:01:40 +0300
Subject: [Lustre-devel] subtree locks and path re-validation avoidance
In-Reply-To: <1203080062.19279.91.camel@linux.site>
References: <1203080062.19279.91.camel@linux.site>
Message-ID: <200802250001.40778.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

On 15 February 2008 15:54:22 Vladimir V. Saveliev wrote:
> Hello

[...]

>
> The problem appears when clients request locks on objects directly,
> without doing downward lookup through a directory structure.
> This happens, for example, when clients access directly components of
> current working directories (CWDs).
> If a client cancels locks on such objects (either due to a BAST or
> voluntary) - it has to go through the path re-validation later.
>
> Objects to which a client may access directly appear in result of
> normal downward lookup. Therefore, they were locked, and their locks
> can be canceled. That is the point where we can take care about
> future accesses without re-validation.

what to do if a lookup looses all its locks due to a conflict with STL 
holder? Of course the parent lock can be correctly re-acquired but the 
lookup result may be incorrect -- the result lock may be done for 
STL-cached object.

There is a more detailed example:

Suppose parent lock in a lookup step has been lost before acquiring a 
lock on child. If we don't want to perform path re-validation we have 
to inform any STL-holder that the child is not-stl-lockable. I think 
the problem looks even worse, any ancestor of the revoked parent should 
be not-stl-lockable.

When lookup (C1) holding at least one lock, the lock is a barrier for 
STL-holder, who can't go over the lock into the subtree. Once C1 looses 
all its locks, an STL-holder may leak into the subtree, cache those 
locks and cause locking correctness problems.

I suggest any STL-holder to switch to ordinary locks mode when going 
over that parent dir. The parent dir would have a marker: "well, STL 
behave not well under this dir, please use ordinary locks instead".

> On canceling a lock of directly accessible object we have to inform
> DLM that the ordinary locking has to be used for that object. That
> will prevent the object from getting cached under a subtree lock.
>
> The problem with this schema is to determine which objects are
> directly accessible. But wouldn't solving it be worth doing given
> that it may help to avoid path re-validation deal.
>
> Any comments are welcome.
>
> Best regards,
> Vladimir
>

Thanks.
