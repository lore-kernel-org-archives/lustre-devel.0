From: Vladimir V. Saveliev <Vladimir.Saveliev@Sun.COM>
Date: Fri, 15 Feb 2008 14:54:22 +0200
Subject: [Lustre-devel] subtree locks and path re-validation avoidance
Message-ID: <1203080062.19279.91.camel@linux.site>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

On last rabbit meeting in Moscow we agreed, that with subtree locks
(http://arch.lustre.org/index.php?title=Sub_Tree_Locks) any use of ".."
on client requires path re-validation.


The example shows the details:

1. A client C1 holds ordinary lock on an object O1 (it did
chdir(/a/b/c/d/e), O1 is inode of /a/b/c/d/e). C1 is idle now.

2. Another client C2 does ls -ld /a/b/c/d/e, MD server sends a BAST to
C1 and C1 cancels the lock of O1.

3. C2 is not interested anymore in O1, so it drops the lock. 

4. Yet another client C3 acquires subtree lock on /a/b and caches and
possibly changes (if under WBC) objects under /a/b including /a/b/c/d/e
(the object O1). The key issue is that MDS neither remembers about O1 on
C1 nor keeps information about objects cached by a client under a
subtree lock.

5. Now C1 continues with stat(``.''). It sees that the lock on O1 is
canceled, so it goes to MD server and acquires the lock on O1.

Now we have:
uptodate O1 is on C3;
MDS has a request for O1 from C1 and MDS can not easily deterimine
whether O1 is under any subtree lock. In order to find whether the lock
conflict exists we need to have a special procedure. It is referred to
as path re-validation.

The main thing to be done on path re-validation is to look for above
subtree lock. While it is probably doable, the path re-validation is not
going to be very efficient (especially in case of CMD). I can provide
more details if necessary.


However, it looks like it is possible to avoid having to do path
re-validation completely.


The problem appears when clients request locks on objects directly,
without doing downward lookup through a directory structure.
This happens, for example, when clients access directly components of
current working directories (CWDs).
If a client cancels locks on such objects (either due to a BAST or
voluntary) - it has to go through the path re-validation later.

Objects to which a client may access directly appear in result of normal
downward lookup. Therefore, they were locked, and their locks can be
canceled. That is the point where we can take care about future accesses
without re-validation.
On canceling a lock of directly accessible object we have to inform DLM
that the ordinary locking has to be used for that object. That will
prevent the object from getting cached under a subtree lock.

The problem with this schema is to determine which objects are directly
accessible. But wouldn't solving it be worth doing given that it may
help to avoid path re-validation deal.

Any comments are welcome.

Best regards,
Vladimir
