From: Eric Barton <eeb@sun.com>
Date: Wed, 01 Apr 2009 09:17:17 +0100
Subject: [Lustre-devel] WBC HLD outline
In-Reply-To: <200903240058.30343.alexander.zarochentsev@sun.com>
References: <200903240058.30343.alexander.zarochentsev@sun.com>
Message-ID: <00a001c9b2a2$45665430$d032fc90$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Zam,

Some notes on the WBC HLD outline

1. The requirement is for 32K creates/second on one node of small
   files with a random size of up to 64K.  It's basically HPCS IO
   Scenario 4.

2. Reintegration must change the filesystem from one consistent state
   to another consistent state _atomically_.

3. Not all the updates in a batch for 1 server need to have the same
   epoch number - i.e. being forced to advance your epoch
   (e.g. because you acquired a lock) doesn't force you to create
   a new batch.

   I think this got mentioned in other emails.

4. Most readers won't know what "bulk transfers are used" for batches.

5. Is ensuring file data is delayed until file creation is
   reintegrated sufficient for correct operation?  Are we not
   effectively doing create-on-write with a WBC?  I'm sure there
   are more issues (e.g. orphans).

   Does including the OSTs in epoch recovery solve all the issues?  If
   so, what are the expected bounds on client redo and server undo
   storage?  Can we avoid needing server undo for data with some
   compromises?  Can we exploit the DMU at all?

6. The section on recovering from WBC client death seems imprecise.
   Is (a) just describing V1-4 in Nikita's original post - similarly
   (b) for V1-2, V3'-5'?  Also, for (c) I think we may have discussed
   the possibility of always sending updates as the full operation +
   context to select which updates apply locally so that an operation
   can always be recovered from any of its updates.

    Cheers,
              Eric
