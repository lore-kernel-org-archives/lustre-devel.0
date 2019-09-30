From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:53 -0400
Subject: [lustre-devel] [PATCH 034/151] lustre: llite: Implement ladvise
 lockahead
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-35-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

Ladvise lockahead is a new feature allowing userspace to
request extent locks in advance of the IO which will use
them. These locks are not expanded beyond the size
requested by userspace.  They are intended to make it
possible to address lock contention between multiple
clients resulting from lock expansion.  They should allow
optimizing various IO patterns, notably strided writing.
(Further information in LU-6179)

Asynchronous glimpse locks are a speculative version of
glimpse locks, and already implement the required behavior.
Lockahead requests share this behavior.

Additionally, lockahead creates extent locks in advance
of IO, and so breaks the assumption that the holder of the
highest lock knows the current file size.

So we also modify the ofd_intent_policy code to glimpse
PW locks until it finds one it knows to be in use, taking
care to send only one glimpse to each client.

The current patch allows asynchronous non-blocking lock
ahead requests and synchronous blocking requests.  We
cannot do asynchronous blocking requests, because of
deadlocks that occur in having ptlrpcd threads handle
blocking lock requests.

Finally, this patch also adds another advice to disable
lock expansion, setting a per-file descriptor flag.  This
allows user space to control whether or not lock requests
on this file descriptor will undergo lock expansion.

This means if lockahead locks are not created ahead of IO
(due to inherent raciness) or are cancelled by a competing
IO request, the IO requests that should have used the
manually requested locks will not result in expanded locks.
This avoids lock ping-pong, and because the resulting locks
will not extend to the end of the file, future lockahead
requests can be granted.  Effectively, this means that if
lockahead usage for strided IO is interrupted by a
competing request, it can re-assert itself.

lockahead is implented via the ladvise interface from
userspace. As lockahead results in a DLM lock request
rather than file advice, we do not use the lower levels of
the ladvise implementation.

Note this patch has one oddity:
Cray released an earlier version of lockahead without
FL_SPECULATIVE support.  That version uses
OBD_CONNECT_LOCKAHEAD_OLD, this new one uses
OBD_CONNECT_LOCKAHEAD.

The client code in this patch is interoperable with that
version, so it also advertises OBD_CONNECT_LOCKAHEAD_OLD
support, but the server version is not, so the server
advertises only OBD_CONNECT_LOCKAHEAD support.

Client support for the original lockahead is slated for
removal after the release of 2.12.  This is enforced with
a compile time version test that will remove support.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6179
Lustre-commit: a8dcf372f430 ("LU-6179 llite: Implement ladvise lockahead")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/13564
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 Documentation/lustre/ladvise_lockahead.txt | 304 +++++++++++++++++++++++++++++
 fs/lustre/include/cl_object.h              |  36 +++-
 fs/lustre/include/lustre_dlm.h             |   4 +-
 fs/lustre/include/lustre_dlm_flags.h       |  41 +++-
 fs/lustre/include/lustre_export.h          |  20 ++
 fs/lustre/include/lustre_osc.h             |  11 +-
 fs/lustre/ldlm/ldlm_lib.c                  |   1 +
 fs/lustre/ldlm/ldlm_lock.c                 |   7 +-
 fs/lustre/llite/file.c                     | 277 ++++++++++++++++++++++++--
 fs/lustre/llite/glimpse.c                  |  27 ++-
 fs/lustre/llite/llite_internal.h           |   9 +
 fs/lustre/llite/llite_lib.c                |  23 ++-
 fs/lustre/llite/vvp_io.c                   |   3 +
 fs/lustre/lov/lov_io.c                     |   1 +
 fs/lustre/obdclass/cl_lock.c               |   2 +-
 fs/lustre/obdclass/lprocfs_status.c        |   3 +-
 fs/lustre/osc/osc_internal.h               |   3 +-
 fs/lustre/osc/osc_lock.c                   |  71 +++++--
 fs/lustre/osc/osc_request.c                |  50 +++--
 fs/lustre/ptlrpc/wiretest.c                |   8 +-
 include/uapi/linux/lustre/lustre_idl.h     |  12 +-
 include/uapi/linux/lustre/lustre_user.h    |  40 +++-
 22 files changed, 857 insertions(+), 96 deletions(-)
 create mode 100644 Documentation/lustre/ladvise_lockahead.txt

diff --git a/Documentation/lustre/ladvise_lockahead.txt b/Documentation/lustre/ladvise_lockahead.txt
new file mode 100644
index 0000000..91dffcd
--- /dev/null
+++ b/Documentation/lustre/ladvise_lockahead.txt
@@ -0,0 +1,304 @@
+Ladvise Lock Ahead design
+
+Lock ahead is a new Lustre feature aimed at solving a long standing problem
+with shared file write performance in Lustre.  It requires client and server
+support.  It will be used primarily via the MPI-I/O library, not directly from
+user applications.
+
+The first part of this document (sections 1 and 2) is an overview of the
+problem and high level description of the solution.  Section 3 explains how the
+library will make use of this feature, and sections 4 and 5 describe the design
+of the Lustre changes.
+
+1. Overview: Purpose & Interface
+Lock ahead is intended to allow optimization of certain I/O patterns which
+would otherwise suffer LDLM* lock contention.  It allows applications to
+manually request locks on specific extents of a file, avoiding the usual
+server side optimizations. This applications which know their I/O pattern to
+use that information to avoid false conflicts due to server side optimizations.
+
+*Lustre distributed lock manager.  This is the locking layer shared between
+clients and servers, to manage access between clients.
+
+Normally, clients get locks automatically as the first step of an I/O.
+The client asks for a lock which covers exactly the area of interest (ie, a
+read or write lock of n bytes at offset x), but the server attempts to optimize
+this by expanding the lock to cover as much of the file as possible.  This is
+useful for a single client, but can be trouble for multiple clients.
+
+In cases where multiple clients wish to write to the same file, this
+optimization can result in locks that conflict when the actual I/O operations
+do not.  This requires clients to wait for one another to complete I/O, even
+when there is no conflict between actual I/O requests.  This can significantly
+reduce performance (Anywhere from 40-90%, depending on system specs) for some
+workloads.
+
+The lockahead feature makes it possible to avoid this problem by acquiring the
+necessary locks in advance, by explicit requests with server side extent
+changes disabled.  We add a new lfs advice type, LU_LADVISE_LOCKAHEAD,
+which allows lock requests from userspace on the client, specifying the extent
+and the I/O mode (read/write) for the lock.  These lock requests explicitly
+disable server side changes to the lock extent, so the lock returned to the
+client covers only the extent requested.
+
+When using this feature, clients which intend to write to a file can request
+locks to cover their I/O pattern, wait a moment for the locks to be granted,
+then write or read the file.
+
+In this way, a set of clients which knows their I/O pattern in advance can
+force the LDLM layer to grant locks appropriate for that I/O pattern.  This
+allows applications which are poorly handled by the default lock optimization
+behavior to significantly improve their performance.
+
+2. I/O Pattern & Locking problems
+2. A. Strided writing and MPI-I/O
+There is a thorough explanation and overview of strided writing and the
+benefits of this functionality in the slides from the lock ahead presentation
+at LUG 2015.  It is highly recommended to read that first, as the graphics are
+much clearer than the prose here.
+
+See slides 1-13:
+http://wiki.lustre.org/images/f/f9/Shared-File-Performance-in-Lustre_Farrell.pdf
+
+MPI-I/O uses strided writing when doing I/O from a large job to a single file.
+I/O is aggregated from all the nodes running a particular application to a
+small number of I/O aggregator nodes which then write out the data, in a
+strided manner.
+
+In strided writing, different clients take turns writing different blocks of a
+file (A block is some arbitrary number of bytes).  Client 1 is responsible for
+writes to block 0, block 2, block 4, etc., client 2 is responsible for block 1,
+block 3, etc.
+
+Without the ability to manually request locks, strided writing is set up in
+concert with Lustre file striping so each client writes to one OST.  (IE, for a
+file striped to three OSTs, we would write from three clients.)
+
+The particular case of interest is when we want to use more than one client
+per OST.  This is important, because an OST typically has much more bandwidth
+than one client.  Strided writes are non-overlapping, so they should be able to
+proceed in parallel with more than one client per OST.  In practice, on Lustre,
+they do not, due to lock expansion.
+
+2. B. Locking problems
+We will now describe locking when there is more than one client per OST.  This
+behavior is the same on a per OST basis in a file striped across multiple OSTs.
+When the first client asks to write block 0, it asks for the required lock from
+the server.  When it receives this request, the server sees that there are no
+other locks on the file.  Since it assumes the client will want to write to the
+file again, the server expands the lock as far as possible.  In this case, it
+expands the lock to the maximum file size (effectively, to infinity), then
+grants it to client 1.
+
+When client 2 wants to write block 1, it conflicts with the expanded lock
+granted to client 1.  The server then must revoke (In Lustre terms,
+'call back') the lock granted to client 1 so it can grant a lock to client 2.
+After the lock granted to client is revoked, there are no locks on the file.
+The server sees this when processing the lock request from client 2, and
+expands that lock to cover the whole file.
+
+Client 1 then wishes to write block 3 of the file...  And the cycle continues.
+The two clients exchange the extended lock throughout the write, allowing only
+one client to write at a time, plus latency to exchange the lock.  The effect is
+dramatic: Two clients are actually slower than one.  (Similar behavior is seen
+with more than two clients.)
+
+The solution is to use this new advice type to acquire locks before they are
+needed.  In effect, before it starts writing to the file, client 1 requests
+locks on block 0, block 2, etc. It locks 'ahead' a certain (tunable) number of
+locks. Client 2 does the same.  Then they both begin to write, and are able to
+do so in parallel.  A description of the actual library implementation follows.
+
+3. Library implementation
+Actually implementing this in the library carries a number of wrinkles.
+The basic pattern is this:
+Before writing, an I/O aggregator requests a certain number of locks on blocks
+that it is responsible for.  It may or may not ever write to these blocks, but
+it takes locks knowing it might.  It then begins to write, tracking how many of
+the locks it has used.  When the number of locks 'ahead' of the I/O is low
+enough, it requests more locks in advance of the I/O.
+
+For technical reasons which are explained in the implementation section, these
+lock requests are either asynchronous and non-blocking or synchronous and
+blocking.  In Lustre terms, non-blocking means if there is already a lock on
+the relevant extent of the file, the manual lock request is not granted.  This
+means that if there is already a lock on the file (quite common; imagine
+writing to a file which was previously read by another process), these lock
+requests will be denied.  However, once the first 'real' write arrives that
+was hoping to use a lockahead lock, that write will cause the blocking lock to
+be cancelled, so this interference is not fatal.
+
+It is of course possible for another process to get in the way by immediately
+asking for a lock on the file.  This is something users should try to avoid.
+When writing out a file, repeatedly trying to read it will impact performance
+even without this feature.
+
+These interfering locks can also happen if a manually requested lock is, for
+some reason, not available in time for the write which intended to use it.
+The lock which results from this write request is expanded using the
+normal rules.  So it's possible for that lock (depending on the position of
+other locks at the time) to be extended to cover the rest of the file.  That
+will block future lockahead locks.
+
+The expanded lock will be revoked when a write happens (from another client)
+in the range covered by that lock, but the lock for that write will be expanded
+as well - And then we return to handing the lock back and forth between
+clients.  These expanded locks will still block future lockahead locks,
+rendering them useless.
+
+The way to avoid this is to turn off lock expansion for I/Os which are
+supposed to be using these manually requested locks.  That way, if the
+manually requested lock is not available, the lock request for the I/O will not
+be expanded.  Instead, that request (which is blocking, unlike a lockahead
+request) will cancel any interfering locks, but the resulting lock will not be
+expanded.  This leaves the later parts of the file open, allowing future
+manual lock requests to succeed.  This means that if an interfering lock blocks
+some manual requests, those are lost, but the next set of manual requests can
+proceed as normal.
+
+In effect, the 'locking ahead of I/O' is interrupted, but then is able to
+re-assert itself. The feature used here is referred to as 'no expansion'
+locking (as only the extent required by the actual I/O operation is locked)
+and is turned on with another new ladvise advice, LU_LADVISE_NOEXPAND.  This
+feature is added as part of the lockahead patch.  The strided writing library
+will use this advice on the file descriptor it uses for writing.
+
+4. Client side design
+4. A. Ladvise lockahead
+Requestlock uses the existing asynchronous lock request functionality
+implemented for asynchronous glimpse locks (AGLs), a long standing Lustre
+feature.  AGLs are locks which are requested by statahead, which are used to
+get file size information before it's requested.  The key thing about an
+asynchronous lock request is that it does not have a specific I/O operation
+waiting for the lock.
+
+This means two key things:
+
+1. There is no OSC lock (lock layer above LDLM for data locking) associated
+with the LDLM lock
+2. There is no thread waiting for the LDLM lock, so lock grant processing
+must be handled by the ptlrpc daemon thread which received the reply
+
+Since both of these issues are addressed by the asynchronous lock request code
+which lockahead shares with AGL, we will not explore them in depth here.
+
+Finally, lockahead requests set the CEF_LOCK_NO_EXPAND flag, which tells the
+OSC (the per OST layer of the client) to set LDLM_FL_NO_EXPANSION on any lock
+requests.  LDLM_FL_NO_EXPANSION is a new LDLM lock flag which tells the server
+not to expand the lock extent.
+
+This leaves the user facing interface.  Requestlock is implemented as a new
+ladvise advice, and it uses the ladvise feature of multiple advices in one API
+call to put many lock requests in to an array of advices.
+
+The arguments required for this advice are a mode (read or write), range (start
+and end), and flags.
+
+The client will then make lock requests on these extents, one at a time.
+Because the lock requests are asynchronous (replies are handled by ptlrpcd),
+many requests can be made quickly by overlapping them, rather than waiting for
+each one to complete.  (This requires that they be non-blocking, as the
+ptlrpcd threads must not wait in the ldlm layer.)
+
+4. B. LU_LADVISE_LOCKNOEXPAND
+The lock no expand ladvise advice sets a boolean in a Lustre data structure
+associated with a file descriptor.  When an I/O is done to this file
+descriptor, the flag is picked up and passed through to the ldlm layer, where
+it sets LDLM_FL_NO_EXPANSION on lock requests made for that I/O.
+
+5. Server side changes
+Implementing lockahead requires server support for LDLM_FL_NO_EXPANSION, but
+it also required an additional pair of server side changes to fix issues which
+came up because of lockahead.  These changes are not part of the core design
+instead, they are separate fixes which are required for it to work.
+
+5. A. Support LDLM_FL_NO_EXPANSION
+
+Disabling server side lock expansion is done with a new LDLM flag.  This is
+done with a simple check for that flag on the server before attempting to
+expand the lock.  If the flag is found, lock expansion is skipped.
+
+5. B. Implement LDLM_FL_SPECULATIVE
+
+As described above, lock ahead locks are non-blocking. The BLOCK_NOWAIT LDLM
+flag is used now to implement some nonblocking behavior, but it only considers
+group locks blocking.  But, for asynchronous lock requests to work correctly,
+they cannot wait for any other locks.  For this purpose, we add
+LDLM_FL_SPECULATIVE.  This new flag is used for asynchronous lock requests,
+and implements the broader non-blocking behavior they require.
+
+5. C. File size & ofd_intent_policy changes
+
+Knowing the current file size during writes is tricky on a distributed file
+system, because multiple clients can be writing to a file at any time.  When
+writes are in progress, the server must identify which client is currently
+responsible for growing the file size, and ask that client what the file size
+is.
+
+To do this, the server uses glimpse locking (in ofd_intent_policy) to get the
+current file size from the clients.  This code uses the assumption that the
+holder of the highest write lock (PW lock) knows the current file size.  A
+client learns the (then current) file size when a lock is granted.  Because
+only the holder of the highest lock can grow a file, either the size hasn't
+changed, or that client knows the new size; so the server only has to contact
+the client which holds this lock, and it knows the current file size.
+
+Note that the above is actually racy. When the server asks, the client can
+still be writing, or another client could acquire a higher lock during this
+time.  The goal is a good approximation while the file is being written, and a
+correct answer once all the clients are done writing.  This is achieved because
+once writes to a file are complete, the holder of that highest lock is
+guaranteed to know the current file size.  This is where manually requested
+locks cause trouble.
+
+By creating write locks in advance of an actual I/O, lockahead breaks the
+assumption that the holder of the highest lock knows the file size.
+
+This assumption is normally true because locks which are created as part of
+IO - rather than in advance of it - are guaranteed to be 'active', IE,
+involved in IO, and the holder of the highest 'active' lock always knows the
+current file size, because the size is either not changing or the holder of
+that lock is responsible for updating it.
+
+Consider:  Two clients, A and B, strided writing.  Each client requests, for
+example, 2 manually requested locks.  (Real numbers are much higher.)  Client A
+holds locks on segments 0 and 2, client B holds locks on segments 1 and 3.
+
+The request comes to write 3 segments of data.  Client A writes to segment 0,
+client B writes to segment 1, and client A also writes to segment 2.  No data
+is written to segment 3.  At this point, the server checks the file size, by
+glimpsing the highest lock . The lock on segment 3.  Client B does not know
+about the writing done by client A to segment 2, so it gives an incorrect file
+size.
+
+This would be OK if client B had pending writes to segment 3, but it does not.
+In this situation, the server will never get the correct file size while this
+lock exists.
+
+The solution is relatively straightforward: The server needs to glimpse every
+client holding a write lock (starting from the top) until we find one holding
+an 'active' lock (because the size is known to be at least the size returned
+from an 'active' lock), and take the largest size returned. This avoids asking
+only a client which may not know the correct file size.
+
+Unfortunately, there is no way to know if a manually requested lock is active
+from the server side.  So when we see such a lock, we must send a glimpse to
+the holder (unless we have already sent a glimpse to that client*).  However,
+because locks without LDLM_FL_NO_EXPANSION set are guaranteed to be 'active',
+once we reach the first such lock, we can stop glimpsing.
+
+*This is because when we glimpse a specific lock, the client holding it returns
+its best idea of the size information, so we only need to send one glimpse to
+each client.
+
+This is less efficient than the standard "glimpse only the top lock"
+methodology, but since we only need to glimpse one lock per client (and the
+number of clients writing to the part of a file on a given OST is fairly
+limited), the cost is restrained.
+
+Additionally, lock cancellation methods such as early lock cancel aggressively
+clean up older locks, particularly when the LRU limit is exceeded, so the
+total lock count should also remain manageable.
+
+In the end, the final verdict here is performance. Requestlock testing for the
+strided I/O case has shown good performance results.
diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index be30ce8..c04f6c9 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1597,10 +1597,14 @@ enum cl_enq_flags {
 	 */
 	CEF_NONBLOCK		= 0x00000001,
 	/**
-	 * take lock asynchronously (out of order), as it cannot
-	 * deadlock. This is for LDLM_FL_HAS_INTENT locks used for glimpsing.
+	 * Tell lower layers this is a glimpse request, translated to
+	 * LDLM_FL_HAS_INTENT at LDLM layer.
+	 *
+	 * Also, because glimpse locks never block other locks, we count this
+	 * as automatically compatible with other osc locks.
+	 * (see osc_lock_compatible)
 	 */
-	CEF_ASYNC		= 0x00000002,
+	CEF_GLIMPSE		= 0x00000002,
 	/**
 	 * tell the server to instruct (though a flag in the blocking ast) an
 	 * owner of the conflicting lock, that it can drop dirty pages
@@ -1609,8 +1613,9 @@ enum cl_enq_flags {
 	CEF_DISCARD_DATA	= 0x00000004,
 	/**
 	 * tell the sub layers that it must be a `real' lock. This is used for
-	 * mmapped-buffer locks and glimpse locks that must be never converted
-	 * into lockless mode.
+	 * mmapped-buffer locks and glimpse locks, manually requested locks
+	 * (LU_LADVISE_LOCKAHEAD) that must be never converted into lockless
+	 * mode.
 	 *
 	 * \see vvp_mmap_locks(), cl_glimpse_lock().
 	 */
@@ -1627,9 +1632,16 @@ enum cl_enq_flags {
 	 */
 	CEF_NEVER		= 0x00000010,
 	/**
-	 * for async glimpse lock.
+	 * tell the dlm layer this is a speculative lock request
+	 * speculative lock requests are locks which are not requested as part
+	 * of an I/O operation.  Instead, they are requested because we expect
+	 * to use them in the future.  They are requested asynchronously at the
+	 * ptlrpc layer.
+	 *
+	 * Currently used for asynchronous glimpse locks and manually requested
+	 * locks (LU_LADVISE_LOCKAHEAD).
 	 */
-	CEF_AGL			= 0x00000020,
+	CEF_SPECULATIVE		= 0x00000020,
 	/**
 	 * enqueue a lock to test DLM lock existence.
 	 */
@@ -1640,9 +1652,13 @@ enum cl_enq_flags {
 	 */
 	CEF_LOCK_MATCH		= BIT(7),
 	/**
+	 * tell the DLM layer to lock only the requested range
+	 */
+	CEF_LOCK_NO_EXPAND	= BIT(8),
+	/**
 	 * mask of enq_flags.
 	 */
-	CEF_MASK		= 0x000000ff,
+	CEF_MASK		= 0x000001ff,
 };
 
 /**
@@ -1849,7 +1865,9 @@ struct cl_io {
 	/**
 	 * O_NOATIME
 	 */
-				ci_noatime:1;
+				ci_noatime:1,
+	/* Tell sublayers not to expand LDLM locks requested for this IO */
+				ci_lock_no_expand:1;
 	/**
 	 * Number of pages owned by this IO. For invariant checking.
 	 */
diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index a1ff852..1c286eb 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -508,8 +508,8 @@ struct ldlm_glimpse_work {
 					   */
 };
 
-/** The ldlm_glimpse_work is allocated on the stack and should not be freed. */
-#define LDLM_GL_WORK_NOFREE 0x1
+/* The ldlm_glimpse_work was slab allocated & must be freed accordingly.*/
+#define LDLM_GL_WORK_SLAB_ALLOCATED 0x1
 
 /**
  * Interval tree for extent locks.
diff --git a/fs/lustre/include/lustre_dlm_flags.h b/fs/lustre/include/lustre_dlm_flags.h
index abeb651..87cda36 100644
--- a/fs/lustre/include/lustre_dlm_flags.h
+++ b/fs/lustre/include/lustre_dlm_flags.h
@@ -62,6 +62,15 @@
 #define ldlm_set_block_wait(_l)		LDLM_SET_FLAG((_l), 1ULL <<  3)
 #define ldlm_clear_block_wait(_l)	LDLM_CLEAR_FLAG((_l), 1ULL <<  3)
 
+/**
+ * Lock request is speculative/asynchronous, and cannot wait for any reason.
+ * Fail the lock request if any blocking locks are encountered.
+ */
+#define LDLM_FL_SPECULATIVE		0x0000000000000010ULL /* bit   4 */
+#define ldlm_is_speculative(_l)		LDLM_TEST_FLAG((_l), 1ULL <<  4)
+#define ldlm_set_speculative(_l)	LDLM_SET_FLAG((_l), 1ULL <<  4)
+#define ldlm_clear_specualtive_(_l)	LDLM_CLEAR_FLAG((_l), 1ULL <<  4)
+
 /** blocking or cancel packet was queued for sending. */
 #define LDLM_FL_AST_SENT		0x0000000000000020ULL /* bit 5 */
 #define ldlm_is_ast_sent(_l)		LDLM_TEST_FLAG((_l), 1ULL <<  5)
@@ -137,6 +146,25 @@
 #define ldlm_clear_cancel_on_block(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 23)
 
 /**
+ * Part of original lockahead implementation, OBD_CONNECT_LOCKAHEAD_OLD.
+ * Reserved temporarily to allow those implementations to keep working.
+ * Will be removed after 2.12 release.
+ */
+#define LDLM_FL_LOCKAHEAD_OLD_RESERVED	0x0000000010000000ULL /* bit  28 */
+#define ldlm_is_do_not_expand_io(_l)	LDLM_TEST_FLAG((_l), 1ULL << 28)
+#define ldlm_set_do_not_expand_io(_l)	LDLM_SET_FLAG((_l), 1ULL << 28)
+#define ldlm_clear_do_not_expand_io(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 28)
+
+/**
+ * Do not expand this lock.  Grant it only on the extent requested.
+ * Used for manually requested locks from the client (LU_LADVISE_LOCKAHEAD).
+ */
+#define LDLM_FL_NO_EXPANSION		0x0000000020000000ULL /* bit  29 */
+#define ldlm_is_do_not_expand(_l)	LDLM_TEST_FLAG((_l), 1ULL << 29)
+#define ldlm_set_do_not_expand(_l)	LDLM_SET_FLAG((_l), 1ULL << 29)
+#define ldlm_clear_do_not_expand(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 29)
+
+/**
  * measure lock contention and return -EUSERS if locking contention is high
  */
 #define LDLM_FL_DENY_ON_CONTENTION	  0x0000000040000000ULL /* bit 30 */
@@ -376,13 +404,16 @@
 #define LDLM_FL_GONE_MASK		(LDLM_FL_DESTROYED		|\
 					 LDLM_FL_FAILED)
 
-/** l_flags bits marked as "inherit" bits */
-/* Flags inherited from wire on enqueue/reply between client/server. */
-/* NO_TIMEOUT flag to force ldlm_lock_match() to wait with no timeout. */
-/* TEST_LOCK flag to not let TEST lock to be granted. */
+/** l_flags bits marked as "inherit" bits
+ * Flags inherited from wire on enqueue/reply between client/server.
+ * NO_TIMEOUT flag to force ldlm_lock_match() to wait with no timeout.
+ * TEST_LOCK flag to not let TEST lock to be granted.
+ * NO_EXPANSION to tell server not to expand extent of lock request
+ */
 #define LDLM_FL_INHERIT_MASK		(LDLM_FL_CANCEL_ON_BLOCK	|\
 					 LDLM_FL_NO_TIMEOUT		|\
-					 LDLM_FL_TEST_LOCK)
+					 LDLM_FL_TEST_LOCK		|\
+					 LDLM_FL_NO_EXPANSION)
 
 /** test for ldlm_lock flag bit set */
 #define LDLM_TEST_FLAG(_l, _b)		(((_l)->l_flags & (_b)) != 0)
diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index fb34e0b..ed0664b 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -149,6 +149,16 @@ static inline u64 exp_connect_flags(struct obd_export *exp)
 	return *exp_connect_flags_ptr(exp);
 }
 
+static inline u64 *exp_connect_flags2_ptr(struct obd_export *exp)
+{
+	return &exp->exp_connect_data.ocd_connect_flags2;
+}
+
+static inline u64 exp_connect_flags2(struct obd_export *exp)
+{
+	return *exp_connect_flags2_ptr(exp);
+}
+
 static inline int exp_max_brw_size(struct obd_export *exp)
 {
 	if (exp_connect_flags(exp) & OBD_CONNECT_BRW_SIZE)
@@ -235,6 +245,16 @@ static inline bool imp_connect_disp_stripe(struct obd_import *imp)
 	return ocd->ocd_connect_flags & OBD_CONNECT_DISP_STRIPE;
 }
 
+static inline int exp_connect_lockahead_old(struct obd_export *exp)
+{
+	return !!(exp_connect_flags(exp) & OBD_CONNECT_LOCKAHEAD_OLD);
+}
+
+static inline int exp_connect_lockahead(struct obd_export *exp)
+{
+	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_LOCKAHEAD);
+}
+
 struct obd_export *class_conn2export(struct lustre_handle *conn);
 
 #define KKUC_CT_DATA_MAGIC	0x092013cea
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index f96583a..6c8a9d4 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -380,7 +380,16 @@ struct osc_lock {
 	/*
 	 * For async glimpse lock.
 	 */
-					ols_agl:1;
+					ols_agl:1,
+	/*
+	 * for speculative locks - asynchronous glimpse locks and ladvise
+	 * lockahead manual lock requests
+	 *
+	 * Used to tell osc layer to not wait for the ldlm reply from the
+	 * server, so the osc lock will be short lived - It only exists to
+	 * create the ldlm request and is not updated on request completion.
+	 */
+					ols_speculative:1;
 };
 
 /*
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 04982b8..67f3297 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -558,6 +558,7 @@ int client_connect_import(const struct lu_env *env,
 			 ocd->ocd_connect_flags, "old %#llx, new %#llx\n",
 			 data->ocd_connect_flags, ocd->ocd_connect_flags);
 		data->ocd_connect_flags = ocd->ocd_connect_flags;
+		data->ocd_connect_flags2 = ocd->ocd_connect_flags2;
 	}
 
 	ptlrpc_pinger_add_import(imp);
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 2f2b1ab..ddebcf6 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -43,6 +43,8 @@
 #include <obd_class.h>
 #include "ldlm_internal.h"
 
+struct kmem_cache *ldlm_glimpse_work_kmem;
+
 /* lock types */
 char *ldlm_lockname[] = {
 	[0]		= "--",
@@ -1756,8 +1758,11 @@ static int ldlm_work_gl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 
 	LDLM_LOCK_RELEASE(lock);
 
-	if ((gl_work->gl_flags & LDLM_GL_WORK_NOFREE) == 0)
+	if (gl_work->gl_flags & LDLM_GL_WORK_SLAB_ALLOCATED)
+		kmem_cache_free(ldlm_glimpse_work_kmem, gl_work);
+	else
 		kfree(gl_work);
+	gl_work = NULL;
 
 	return rc;
 }
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 53b4620..c393856 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1112,9 +1112,12 @@ static bool file_is_noatime(const struct file *file)
 
 static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 {
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct inode *inode = file_inode(file);
 
 	io->u.ci_rw.crw_nonblock = file->f_flags & O_NONBLOCK;
+	io->ci_lock_no_expand = fd->ll_lock_no_expand;
+
 	if (write) {
 		io->u.ci_wr.wr_append = !!(file->f_flags & O_APPEND);
 		io->u.ci_wr.wr_sync = file->f_flags & O_SYNC ||
@@ -2168,6 +2171,203 @@ static int ll_file_futimes_3(struct file *file, const struct ll_futimes_3 *lfu)
 	return rc;
 }
 
+static enum cl_lock_mode cl_mode_user_to_kernel(enum lock_mode_user mode)
+{
+	enum cl_lock_mode cl_mode;
+
+	switch (mode) {
+	case MODE_READ_USER:
+		cl_mode = CLM_READ;
+		break;
+	case MODE_WRITE_USER:
+		cl_mode = CLM_WRITE;
+		break;
+	default:
+		cl_mode = -EINVAL;
+		break;
+	}
+	return cl_mode;
+}
+
+static const char *const user_lockname[] = LOCK_MODE_NAMES;
+
+/* Used to allow the upper layers of the client to request an LDLM lock
+ * without doing an actual read or write.
+ *
+ * Used for ladvise lockahead to manually request specific locks.
+ *
+ * @file	file this ladvise lock request is on
+ * @ladvise	ladvise struct describing this lock request
+ *
+ * Return	0 on success, no detailed result available (sync requests
+ *		and requests sent to the server [not handled locally]
+ *              cannot return detailed results)
+ *
+ *		LLA_RESULT_{SAME,DIFFERENT} - detailed result of the lock
+ *		request, see definitions for details.
+ *
+ *		negative errno on error
+ */
+int ll_file_lock_ahead(struct file *file, struct llapi_lu_ladvise *ladvise)
+{
+	struct dentry *dentry = file->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+	struct cl_lock_descr *descr = NULL;
+	struct cl_lock *lock = NULL;
+	struct cl_io *io  = NULL;
+	struct lu_env *env = NULL;
+	enum cl_lock_mode cl_mode;
+	u64 start = ladvise->lla_start;
+	u64 end = ladvise->lla_end;
+	u16 refcheck;
+	int result;
+
+	CDEBUG(D_VFSTRACE,
+	       "Lock request: file=%.*s, inode=%p, mode=%s start=%llu, end=%llu\n",
+	       dentry->d_name.len, dentry->d_name.name, dentry->d_inode,
+	       user_lockname[ladvise->lla_lockahead_mode], (__u64) start, end);
+
+	cl_mode = cl_mode_user_to_kernel(ladvise->lla_lockahead_mode);
+	if (cl_mode < 0) {
+		result = cl_mode;
+		goto out;
+	}
+
+	/* Get IO environment */
+	result = cl_io_get(inode, &env, &io, &refcheck);
+	if (result <= 0)
+		goto out;
+
+	result = cl_io_init(env, io, CIT_MISC, io->ci_obj);
+	if (result > 0) {
+		/*
+		 * nothing to do for this io. This currently happens when
+		 * stripe sub-object's are not yet created.
+		 */
+		result = io->ci_result;
+	} else if (result == 0) {
+		lock = vvp_env_lock(env);
+		descr = &lock->cll_descr;
+
+		descr->cld_obj = io->ci_obj;
+		/* Convert byte offsets to pages */
+		descr->cld_start = cl_index(io->ci_obj, start);
+		descr->cld_end = cl_index(io->ci_obj, end);
+		descr->cld_mode = cl_mode;
+		/* CEF_MUST is used because we do not want to convert a
+		 * lockahead request to a lockless lock
+		 */
+		descr->cld_enq_flags = CEF_MUST | CEF_LOCK_NO_EXPAND |
+				       CEF_NONBLOCK;
+
+		if (ladvise->lla_peradvice_flags & LF_ASYNC)
+			descr->cld_enq_flags |= CEF_SPECULATIVE;
+
+		result = cl_lock_request(env, io, lock);
+
+		/* On success, we need to release the lock */
+		if (result >= 0)
+			cl_lock_release(env, lock);
+	}
+	cl_io_fini(env, io);
+	cl_env_put(env, &refcheck);
+
+	/* -ECANCELED indicates a matching lock with a different extent
+	 * was already present, and -EEXIST indicates a matching lock
+	 * on exactly the same extent was already present.
+	 * We convert them to positive values for userspace to make
+	 * recognizing true errors easier.
+	 * Note we can only return these detailed results on async requests,
+	 * as sync requests look the same as i/o requests for locking.
+	 */
+	if (result == -ECANCELED)
+		result = LLA_RESULT_DIFFERENT;
+	else if (result == -EEXIST)
+		result = LLA_RESULT_SAME;
+
+out:
+	return result;
+}
+
+static const char *const ladvise_names[] = LU_LADVISE_NAMES;
+
+static int ll_ladvise_sanity(struct inode *inode,
+			     struct llapi_lu_ladvise *ladvise)
+{
+	enum lu_ladvise_type advice = ladvise->lla_advice;
+	/* Note the peradvice flags is a 32 bit field, so per advice flags must
+	 * be in the first 32 bits of enum ladvise_flags
+	 */
+	u32 flags = ladvise->lla_peradvice_flags;
+	/* 3 lines at 80 characters per line, should be plenty */
+	int rc = 0;
+
+	if (advice > LU_LADVISE_MAX || advice == LU_LADVISE_INVALID) {
+		rc = -EINVAL;
+		CDEBUG(D_VFSTRACE,
+		       "%s: advice with value '%d' not recognized, last supported advice is %s (value '%d'): rc = %d\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0), advice,
+		       ladvise_names[LU_LADVISE_MAX - 1], LU_LADVISE_MAX - 1,
+		       rc);
+		goto out;
+	}
+
+	/* Per-advice checks */
+	switch (advice) {
+	case LU_LADVISE_LOCKNOEXPAND:
+		if (flags & ~LF_LOCKNOEXPAND_MASK) {
+			rc = -EINVAL;
+			CDEBUG(D_VFSTRACE,
+			       "%s: Invalid flags (%x) for %s: rc = %d\n",
+			       ll_get_fsname(inode->i_sb, NULL, 0), flags,
+			       ladvise_names[advice], rc);
+			goto out;
+		}
+		break;
+	case LU_LADVISE_LOCKAHEAD:
+		/* Currently only READ and WRITE modes can be requested */
+		if (ladvise->lla_lockahead_mode >= MODE_MAX_USER ||
+		    ladvise->lla_lockahead_mode == 0) {
+			rc = -EINVAL;
+			CDEBUG(D_VFSTRACE,
+			       "%s: Invalid mode (%d) for %s: rc = %d\n",
+			       ll_get_fsname(inode->i_sb, NULL, 0),
+			       ladvise->lla_lockahead_mode,
+			       ladvise_names[advice], rc);
+			goto out;
+		}
+		/* fallthrough */
+	case LU_LADVISE_WILLREAD:
+	case LU_LADVISE_DONTNEED:
+	default:
+		/* Note fall through above - These checks apply to all advices
+		 * except LOCKNOEXPAND
+		 */
+		if (flags & ~LF_DEFAULT_MASK) {
+			rc = -EINVAL;
+			CDEBUG(D_VFSTRACE,
+			       "%s: Invalid flags (%x) for %s: rc = %d\n",
+			       ll_get_fsname(inode->i_sb, NULL, 0), flags,
+			       ladvise_names[advice], rc);
+			goto out;
+		}
+		if (ladvise->lla_start >= ladvise->lla_end) {
+			rc = -EINVAL;
+			CDEBUG(D_VFSTRACE,
+			       "%s: Invalid range (%llu to %llu) for %s: rc = %d\n",
+			       ll_get_fsname(inode->i_sb, NULL, 0),
+			       ladvise->lla_start, ladvise->lla_end,
+			       ladvise_names[advice], rc);
+			goto out;
+		}
+		break;
+	}
+
+out:
+	return rc;
+}
+#undef ERRSIZE
+
 /*
  * Give file access advices
  *
@@ -2216,6 +2416,15 @@ static int ll_ladvise(struct inode *inode, struct file *file, u64 flags,
 	return rc;
 }
 
+static int ll_lock_noexpand(struct file *file, int flags)
+{
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+
+	fd->ll_lock_no_expand = !(flags & LF_UNSET);
+
+	return 0;
+}
+
 int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
 			unsigned long arg)
 {
@@ -2634,61 +2843,89 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 		return ll_file_futimes_3(file, &lfu);
 	}
 	case LL_IOC_LADVISE: {
-		struct llapi_ladvise_hdr *ladvise_hdr;
-		int alloc_size = sizeof(*ladvise_hdr);
+		struct llapi_ladvise_hdr __user *u_ladvise_hdr;
+		struct llapi_ladvise_hdr *k_ladvise_hdr;
+		int alloc_size = sizeof(*k_ladvise_hdr);
 		int num_advise;
 		int i;
 
 		rc = 0;
-		ladvise_hdr = kzalloc(alloc_size, GFP_KERNEL);
-		if (!ladvise_hdr)
+		u_ladvise_hdr = (void __user *)arg;
+		k_ladvise_hdr = kzalloc(alloc_size, GFP_KERNEL);
+		if (!k_ladvise_hdr)
 			return -ENOMEM;
 
-		if (copy_from_user(ladvise_hdr,
-				   (const struct llapi_ladvise_hdr __user *)arg,
-				   alloc_size)) {
+		if (copy_from_user(k_ladvise_hdr, u_ladvise_hdr, alloc_size)) {
 			rc = -EFAULT;
 			goto out_ladvise;
 		}
 
-		if (ladvise_hdr->lah_magic != LADVISE_MAGIC ||
-		    ladvise_hdr->lah_count < 1) {
+		if (k_ladvise_hdr->lah_magic != LADVISE_MAGIC ||
+		    k_ladvise_hdr->lah_count < 1) {
 			rc = -EINVAL;
 			goto out_ladvise;
 		}
 
-		num_advise = ladvise_hdr->lah_count;
+		num_advise = k_ladvise_hdr->lah_count;
 		if (num_advise >= LAH_COUNT_MAX) {
 			rc = -EFBIG;
 			goto out_ladvise;
 		}
 
-		kfree(ladvise_hdr);
-		alloc_size = offsetof(typeof(*ladvise_hdr),
+		kfree(k_ladvise_hdr);
+		alloc_size = offsetof(typeof(*k_ladvise_hdr),
 				      lah_advise[num_advise]);
-		ladvise_hdr = kzalloc(alloc_size, GFP_KERNEL);
-		if (!ladvise_hdr)
+		k_ladvise_hdr = kzalloc(alloc_size, GFP_KERNEL);
+		if (!k_ladvise_hdr)
 			return -ENOMEM;
 
 		/*
 		 * TODO: submit multiple advices to one server in a single RPC
 		 */
-		if (copy_from_user(ladvise_hdr,
-				   (const struct llapi_advise_hdr __user *)arg,
-				   alloc_size)) {
+		if (copy_from_user(k_ladvise_hdr, u_ladvise_hdr, alloc_size)) {
 			rc = -EFAULT;
 			goto out_ladvise;
 		}
 
 		for (i = 0; i < num_advise; i++) {
-			rc = ll_ladvise(inode, file, ladvise_hdr->lah_flags,
-					&ladvise_hdr->lah_advise[i]);
+			struct llapi_lu_ladvise __user *u_ladvise;
+			struct llapi_lu_ladvise *k_ladvise;
+
+			k_ladvise = &k_ladvise_hdr->lah_advise[i];
+			u_ladvise = &u_ladvise_hdr->lah_advise[i];
+
+			rc = ll_ladvise_sanity(inode, k_ladvise);
 			if (rc)
+				goto out_ladvise;
+
+			switch (k_ladvise->lla_advice) {
+			case LU_LADVISE_LOCKNOEXPAND:
+				rc = ll_lock_noexpand(file,
+						      k_ladvise->lla_peradvice_flags);
+				goto out_ladvise;
+			case LU_LADVISE_LOCKAHEAD:
+				rc = ll_file_lock_ahead(file, k_ladvise);
+				if (rc < 0)
+					goto out_ladvise;
+
+				if (put_user(rc,
+					     &u_ladvise->lla_lockahead_result)) {
+					rc = -EFAULT;
+					goto out_ladvise;
+				}
 				break;
+			default:
+				rc = ll_ladvise(inode, file,
+						k_ladvise_hdr->lah_flags,
+						k_ladvise);
+				if (rc)
+					goto out_ladvise;
+				break;
+			}
 		}
 
 out_ladvise:
-		kfree(ladvise_hdr);
+		kfree(k_ladvise_hdr);
 		return rc;
 	}
 	case FS_IOC_FSGETXATTR:
diff --git a/fs/lustre/llite/glimpse.c b/fs/lustre/llite/glimpse.c
index 05c267f..56a5094 100644
--- a/fs/lustre/llite/glimpse.c
+++ b/fs/lustre/llite/glimpse.c
@@ -88,7 +88,7 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 	CDEBUG(D_DLMTRACE, "Glimpsing inode " DFID "\n", PFID(fid));
 
 	/* NOTE: this looks like DLM lock request, but it may
-	 *       not be one. Due to CEF_ASYNC flag (translated
+	 *       not be one. Due to CEF_GLIMPSE flag (translated
 	 *       to LDLM_FL_HAS_INTENT by osc), this is
 	 *       glimpse request, that won't revoke any
 	 *       conflicting DLM locks held. Instead,
@@ -104,14 +104,10 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 	*descr = whole_file;
 	descr->cld_obj = clob;
 	descr->cld_mode = CLM_READ;
-	descr->cld_enq_flags = CEF_ASYNC | CEF_MUST;
+	descr->cld_enq_flags = CEF_GLIMPSE | CEF_MUST;
 	if (agl)
-		descr->cld_enq_flags |= CEF_AGL;
+		descr->cld_enq_flags |= CEF_SPECULATIVE | CEF_NONBLOCK;
 	/*
-	 * CEF_ASYNC is used because glimpse sub-locks cannot
-	 * deadlock (because they never conflict with other
-	 * locks) and, hence, can be enqueued out-of-order.
-	 *
 	 * CEF_MUST protects glimpse lock from conversion into
 	 * a lockless mode.
 	 */
@@ -137,8 +133,21 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 	return result;
 }
 
-static int cl_io_get(struct inode *inode, struct lu_env **envout,
-		     struct cl_io **ioout, u16 *refcheck)
+/**
+ * Get an IO environment for special operations such as glimpse locks and
+ * manually requested locks (ladvise lockahead)
+ *
+ * @inode	inode the operation is being performed on
+ * @envout	thread specific execution environment
+ * @ioout	client io description
+ * @refcheck	reference check
+ *
+ * Return	1 on success
+ *		0 not a regular file, cannot get environment
+ *		negative errno on error
+ */
+int cl_io_get(struct inode *inode, struct lu_env **envout,
+	      struct cl_io **ioout, u16 *refcheck)
 {
 	struct lu_env *env;
 	struct cl_io *io;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index b8f4e0e..392d82c 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -652,6 +652,7 @@ struct ll_file_data {
 	 * false: unknown failure, should report.
 	 */
 	bool fd_write_failed;
+	bool ll_lock_no_expand;
 	rwlock_t fd_lock; /* protect lcc list */
 	struct list_head fd_lccs; /* list of ll_cl_context */
 };
@@ -1163,11 +1164,19 @@ static inline int cl_glimpse_size(struct inode *inode)
 	return __cl_glimpse_size(inode, 0);
 }
 
+/* AGL is 'asychronous glimpse lock', which is a speculative lock taken as
+ * part of statahead
+ */
 static inline int cl_agl(struct inode *inode)
 {
 	return __cl_glimpse_size(inode, 1);
 }
 
+int ll_file_lock_ahead(struct file *file, struct llapi_lu_ladvise *ladvise);
+
+int cl_io_get(struct inode *inode, struct lu_env **envout,
+	      struct cl_io **ioout, __u16 *refcheck);
+
 static inline int ll_glimpse_size(struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 83b63d8..3896dc7 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -185,7 +185,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	 */
 	data->ocd_grant_blkbits = PAGE_SHIFT;
 
-	/* indicate the features supported by this client */
+	/* indicate MDT features supported by this client */
 	data->ocd_connect_flags = OBD_CONNECT_IBITS	| OBD_CONNECT_NODEVOH  |
 				  OBD_CONNECT_ATTRFID	|
 				  OBD_CONNECT_VERSION	| OBD_CONNECT_BRW_SIZE |
@@ -374,6 +374,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 		goto out_md_fid;
 	}
 
+	/* indicate OST features supported by this client */
 	data->ocd_connect_flags = OBD_CONNECT_GRANT     | OBD_CONNECT_VERSION  |
 				  OBD_CONNECT_REQPORTAL | OBD_CONNECT_BRW_SIZE |
 				  OBD_CONNECT_CANCELSET | OBD_CONNECT_FID      |
@@ -386,9 +387,25 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_JOBSTATS	| OBD_CONNECT_LVB_TYPE |
 				  OBD_CONNECT_LAYOUTLOCK  |
 				  OBD_CONNECT_PINGLESS	| OBD_CONNECT_LFSCK |
-				  OBD_CONNECT_BULK_MBITS;
+				  OBD_CONNECT_BULK_MBITS  | OBD_CONNECT_FLAGS2;
+
+	/* The client currently advertises support for OBD_CONNECT_LOCKAHEAD_OLD
+	 * so it can interoperate with an older version of lockahead which was
+	 * released prior to landing in master. This support will be dropped
+	 * when 2.13 development starts. At the point, we should not just drop
+	 * the connect flag (below), we should also remove the support in the
+	 * code.
+	 *
+	 * Removing it means a few things:
+	 * 1. Remove this section here
+	 * 2. Remove CEF_NONBLOCK in ll_file_lockahead()
+	 * 3. Remove function exp_connect_lockahead_old
+	 * 4. Remove LDLM_FL_LOCKAHEAD_OLD_RESERVED in lustre_dlm_flags.h
+	 */
+	if (data->ocd_version < OBD_OCD_VERSION(2, 12, 50, 0))
+		data->ocd_connect_flags |= OBD_CONNECT_LOCKAHEAD_OLD;
 
-	data->ocd_connect_flags2 = 0;
+	data->ocd_connect_flags2 = OBD_CONNECT2_LOCKAHEAD;
 
 	if (!OBD_FAIL_CHECK(OBD_FAIL_OSC_CONNECT_GRANT_PARAM))
 		data->ocd_connect_flags |= OBD_CONNECT_GRANT_PARAM;
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index b2160d6..dea820e 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -524,6 +524,9 @@ static int vvp_io_rw_lock(const struct lu_env *env, struct cl_io *io,
 
 	if (io->u.ci_rw.crw_nonblock)
 		ast_flags |= CEF_NONBLOCK;
+	if (io->ci_lock_no_expand)
+		ast_flags |= CEF_LOCK_NO_EXPAND;
+
 	result = vvp_mmap_locks(env, vio, io);
 	if (result == 0)
 		result = vvp_io_one_lock(env, io, ast_flags, mode, start, end);
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 8214493..a72069f 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -120,6 +120,7 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 	sub_io->ci_type = io->ci_type;
 	sub_io->ci_no_srvlock = io->ci_no_srvlock;
 	sub_io->ci_noatime = io->ci_noatime;
+	sub_io->ci_lock_no_expand = io->ci_lock_no_expand;
 
 	rc = cl_io_sub_init(sub->sub_env, sub_io, io->ci_type, sub_obj);
 	if (rc < 0)
diff --git a/fs/lustre/obdclass/cl_lock.c b/fs/lustre/obdclass/cl_lock.c
index af88383..fe24379 100644
--- a/fs/lustre/obdclass/cl_lock.c
+++ b/fs/lustre/obdclass/cl_lock.c
@@ -188,7 +188,7 @@ int cl_lock_request(const struct lu_env *env, struct cl_io *io,
 	if (rc < 0)
 		return rc;
 
-	if ((enq_flags & CEF_ASYNC) && !(enq_flags & CEF_AGL)) {
+	if ((enq_flags & CEF_GLIMPSE) && !(enq_flags & CEF_SPECULATIVE)) {
 		anchor = &cl_env_info(env)->clt_anchor;
 		cl_sync_io_init(anchor, 1);
 	}
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 01b8f90..1ff12d55 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -106,12 +106,13 @@
 	"multi_mod_rpcs",
 	"dir_stripe",
 	"subtree",
-	"lock_ahead",
+	"lockahead",
 	"bulk_mbits",
 	"compact_obdo",
 	"second_flags",
 	/* flags2 names */
 	"file_secctx",
+	"lockaheadv2",
 	NULL
 };
 
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index af2f237..72cf131 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -53,7 +53,8 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		     struct ost_lvb *lvb, int kms_valid,
 		     osc_enqueue_upcall_f upcall,
 		     void *cookie, struct ldlm_enqueue_info *einfo,
-		     struct ptlrpc_request_set *rqset, int async, int agl);
+		     struct ptlrpc_request_set *rqset, int async,
+		     bool speculative);
 
 int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		   enum ldlm_type type, union ldlm_policy_data *policy,
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 917ae71..f976230 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -158,11 +158,13 @@ static u64 osc_enq2ldlm_flags(u32 enqflags)
 {
 	u64 result = 0;
 
+	CDEBUG(D_DLMTRACE, "flags: %x\n", enqflags);
+
 	LASSERT((enqflags & ~CEF_MASK) == 0);
 
 	if (enqflags & CEF_NONBLOCK)
 		result |= LDLM_FL_BLOCK_NOWAIT;
-	if (enqflags & CEF_ASYNC)
+	if (enqflags & CEF_GLIMPSE)
 		result |= LDLM_FL_HAS_INTENT;
 	if (enqflags & CEF_DISCARD_DATA)
 		result |= LDLM_FL_AST_DISCARD_DATA;
@@ -170,6 +172,10 @@ static u64 osc_enq2ldlm_flags(u32 enqflags)
 		result |= LDLM_FL_TEST_LOCK;
 	if (enqflags & CEF_LOCK_MATCH)
 		result |= LDLM_FL_MATCH_LOCK;
+	if (enqflags & CEF_LOCK_NO_EXPAND)
+		result |= LDLM_FL_NO_EXPANSION;
+	if (enqflags & CEF_SPECULATIVE)
+		result |= LDLM_FL_SPECULATIVE;
 	return result;
 }
 
@@ -345,8 +351,9 @@ static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 	return rc;
 }
 
-static int osc_lock_upcall_agl(void *cookie, struct lustre_handle *lockh,
-			       int errcode)
+static int osc_lock_upcall_speculative(void *cookie,
+				       struct lustre_handle *lockh,
+				       int errcode)
 {
 	struct osc_object *osc = cookie;
 	struct ldlm_lock *dlmlock;
@@ -370,7 +377,7 @@ static int osc_lock_upcall_agl(void *cookie, struct lustre_handle *lockh,
 	lock_res_and_lock(dlmlock);
 	LASSERT(dlmlock->l_granted_mode == dlmlock->l_req_mode);
 
-	/* there is no osc_lock associated with AGL lock */
+	/* there is no osc_lock associated with speculative lock */
 	osc_lock_lvb_update(env, osc, dlmlock, NULL);
 
 	unlock_res_and_lock(dlmlock);
@@ -808,7 +815,7 @@ static bool osc_lock_compatible(const struct osc_lock *qing,
 	struct cl_lock_descr *qed_descr = &qed->ols_cl.cls_lock->cll_descr;
 	struct cl_lock_descr *qing_descr = &qing->ols_cl.cls_lock->cll_descr;
 
-	if (qed->ols_glimpse)
+	if (qed->ols_glimpse || qed->ols_speculative)
 		return true;
 
 	if (qing_descr->cld_mode == CLM_READ && qed_descr->cld_mode == CLM_READ)
@@ -925,13 +932,14 @@ static int osc_lock_enqueue(const struct lu_env *env,
 	struct osc_io *oio = osc_env_io(env);
 	struct osc_object *osc = cl2osc(slice->cls_obj);
 	struct osc_lock *oscl = cl2osc_lock(slice);
+	struct obd_export *exp = osc_export(osc);
 	struct cl_lock *lock = slice->cls_lock;
 	struct ldlm_res_id *resname = &info->oti_resname;
 	union ldlm_policy_data *policy = &info->oti_policy;
 	osc_enqueue_upcall_f upcall = osc_lock_upcall;
 	void *cookie = oscl;
 	bool async = false;
-	int result;
+	int result = 0;
 
 	LASSERTF(ergo(oscl->ols_glimpse, lock->cll_descr.cld_mode <= CLM_READ),
 		 "lock = %p, ols = %p\n", lock, oscl);
@@ -939,11 +947,23 @@ static int osc_lock_enqueue(const struct lu_env *env,
 	if (oscl->ols_state == OLS_GRANTED)
 		return 0;
 
+	if ((oscl->ols_flags & LDLM_FL_NO_EXPANSION) &&
+	    !(exp_connect_lockahead_old(exp) || exp_connect_lockahead(exp))) {
+		result = -EOPNOTSUPP;
+		CERROR("%s: server does not support lockahead/locknoexpand: rc = %d\n",
+		       exp->exp_obd->obd_name, result);
+		return result;
+	}
+
 	if (oscl->ols_flags & LDLM_FL_TEST_LOCK)
 		goto enqueue_base;
 
-	if (oscl->ols_glimpse) {
-		LASSERT(equi(oscl->ols_agl, !anchor));
+	/* For glimpse and/or speculative locks, do not wait for reply from
+	 * server on LDLM request
+	 */
+	if (oscl->ols_glimpse || oscl->ols_speculative) {
+		/* Speculative and glimpse locks do not have an anchor */
+		LASSERT(equi(oscl->ols_speculative, !anchor));
 		async = true;
 		goto enqueue_base;
 	}
@@ -970,25 +990,31 @@ static int osc_lock_enqueue(const struct lu_env *env,
 
 	/**
 	 * DLM lock's ast data must be osc_object;
-	 * if glimpse or AGL lock, async of osc_enqueue_base() must be true,
+	 * if glimpse or speculative lock, async of osc_enqueue_base()
+	 * must be true
+	 *
+	 * For non-speculative locks:
 	 * DLM's enqueue callback set to osc_lock_upcall() with cookie as
 	 * osc_lock.
+	 * For speculative locks:
+	 * osc_lock_upcall_speculative & cookie is the osc object, since
+	 * there is no osc_lock
 	 */
 	ostid_build_res_name(&osc->oo_oinfo->loi_oi, resname);
 	osc_lock_build_policy(env, lock, policy);
-	if (oscl->ols_agl) {
+	if (oscl->ols_speculative) {
 		oscl->ols_einfo.ei_cbdata = NULL;
 		/* hold a reference for callback */
 		cl_object_get(osc2cl(osc));
-		upcall = osc_lock_upcall_agl;
+		upcall = osc_lock_upcall_speculative;
 		cookie = osc;
 	}
-	result = osc_enqueue_base(osc_export(osc), resname, &oscl->ols_flags,
+	result = osc_enqueue_base(exp, resname, &oscl->ols_flags,
 				  policy, &oscl->ols_lvb,
 				  osc->oo_oinfo->loi_kms_valid,
 				  upcall, cookie,
 				  &oscl->ols_einfo, PTLRPCD_SET, async,
-				  oscl->ols_agl);
+				  oscl->ols_speculative);
 	if (!result) {
 		if (osc_lock_is_lockless(oscl)) {
 			oio->oi_lockless = 1;
@@ -997,9 +1023,12 @@ static int osc_lock_enqueue(const struct lu_env *env,
 			LASSERT(oscl->ols_hold);
 			LASSERT(oscl->ols_dlmlock);
 		}
-	} else if (oscl->ols_agl) {
+	} else if (oscl->ols_speculative) {
 		cl_object_put(env, osc2cl(osc));
-		result = 0;
+		if (oscl->ols_glimpse) {
+			/* hide error for AGL request */
+			result = 0;
+		}
 	}
 
 out:
@@ -1161,10 +1190,16 @@ int osc_lock_init(const struct lu_env *env,
 	INIT_LIST_HEAD(&oscl->ols_wait_entry);
 	INIT_LIST_HEAD(&oscl->ols_nextlock_oscobj);
 
+	/* Speculative lock requests must be either no_expand or glimpse
+	 * request (CEF_GLIMPSE).  non-glimpse no_expand speculative extent
+	 * locks will break ofd_intent_cb. (see comment there)
+	 */
+	LASSERT(ergo((enqflags & CEF_SPECULATIVE) != 0,
+		(enqflags & (CEF_LOCK_NO_EXPAND | CEF_GLIMPSE)) != 0));
+
 	oscl->ols_flags = osc_enq2ldlm_flags(enqflags);
-	oscl->ols_agl = !!(enqflags & CEF_AGL);
-	if (oscl->ols_agl)
-		oscl->ols_flags |= LDLM_FL_BLOCK_NOWAIT;
+	oscl->ols_speculative = !!(enqflags & CEF_SPECULATIVE);
+
 	if (oscl->ols_flags & LDLM_FL_HAS_INTENT) {
 		oscl->ols_flags |= LDLM_FL_BLOCK_GRANTED;
 		oscl->ols_glimpse = 1;
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 64c4fd1..e703cf1 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -106,7 +106,7 @@ struct osc_enqueue_args {
 	void			*oa_cookie;
 	struct ost_lvb		*oa_lvb;
 	struct lustre_handle	oa_lockh;
-	unsigned int		oa_agl:1;
+	unsigned int		oa_speculative;
 };
 
 static void osc_release_ppga(struct brw_page **ppga, u32 count);
@@ -2044,7 +2044,7 @@ static int osc_set_lock_data(struct ldlm_lock *lock, void *data)
 static int osc_enqueue_fini(struct ptlrpc_request *req,
 			    osc_enqueue_upcall_f upcall, void *cookie,
 			    struct lustre_handle *lockh, enum ldlm_mode mode,
-			    u64 *flags, int agl, int errcode)
+			    u64 *flags, int speculative, int errcode)
 {
 	bool intent = *flags & LDLM_FL_HAS_INTENT;
 	int rc;
@@ -2059,7 +2059,7 @@ static int osc_enqueue_fini(struct ptlrpc_request *req,
 			ptlrpc_status_ntoh(rep->lock_policy_res1);
 		if (rep->lock_policy_res1)
 			errcode = rep->lock_policy_res1;
-		if (!agl)
+		if (!speculative)
 			*flags |= LDLM_FL_LVB_READY;
 	} else if (errcode == ELDLM_OK) {
 		*flags |= LDLM_FL_LVB_READY;
@@ -2107,7 +2107,7 @@ static int osc_enqueue_interpret(const struct lu_env *env,
 	/* Let CP AST to grant the lock first. */
 	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 1);
 
-	if (aa->oa_agl) {
+	if (aa->oa_speculative) {
 		LASSERT(!aa->oa_lvb);
 		LASSERT(!aa->oa_flags);
 		aa->oa_flags = &flags;
@@ -2119,7 +2119,7 @@ static int osc_enqueue_interpret(const struct lu_env *env,
 				   lockh, rc);
 	/* Complete osc stuff. */
 	rc = osc_enqueue_fini(req, aa->oa_upcall, aa->oa_cookie, lockh, mode,
-			      aa->oa_flags, aa->oa_agl, rc);
+			      aa->oa_flags, aa->oa_speculative, rc);
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_CANCEL_RACE, 10);
 
@@ -2141,7 +2141,8 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		     struct ost_lvb *lvb, int kms_valid,
 		     osc_enqueue_upcall_f upcall, void *cookie,
 		     struct ldlm_enqueue_info *einfo,
-		     struct ptlrpc_request_set *rqset, int async, int agl)
+		     struct ptlrpc_request_set *rqset, int async,
+		     bool speculative)
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lustre_handle lockh = { 0 };
@@ -2182,7 +2183,11 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	mode = einfo->ei_mode;
 	if (einfo->ei_mode == LCK_PR)
 		mode |= LCK_PW;
-	if (agl == 0)
+	/* Normal lock requests must wait for the LVB to be ready before
+	 * matching a lock; speculative lock requests do not need to,
+	 * because they will not actually use the lock.
+	 */
+	if (!speculative)
 		match_flags |= LDLM_FL_LVB_READY;
 	if (intent != 0)
 		match_flags |= LDLM_FL_BLOCK_GRANTED;
@@ -2195,14 +2200,23 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 			return ELDLM_OK;
 
 		matched = ldlm_handle2lock(&lockh);
-		if (agl) {
-			/* AGL enqueues DLM locks speculatively. Therefore if
-			 * it already exists a DLM lock, it wll just inform the
-			 * caller to cancel the AGL process for this stripe.
+		if (speculative) {
+			/* This DLM lock request is speculative, and does not
+			 * have an associated IO request. Therefore if there
+			 * is already a DLM lock, it wll just inform the
+			 * caller to cancel the request for this stripe.
 			 */
+			lock_res_and_lock(matched);
+			if (ldlm_extent_equal(&policy->l_extent,
+					      &matched->l_policy_data.l_extent))
+				rc = -EEXIST;
+			else
+				rc = -ECANCELED;
+			unlock_res_and_lock(matched);
+
 			ldlm_lock_decref(&lockh, mode);
 			LDLM_LOCK_PUT(matched);
-			return -ECANCELED;
+			return rc;
 		}
 		if (osc_set_lock_data(matched, einfo->ei_cbdata)) {
 			*flags |= LDLM_FL_LVB_READY;
@@ -2254,14 +2268,14 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 			lustre_handle_copy(&aa->oa_lockh, &lockh);
 			aa->oa_upcall = upcall;
 			aa->oa_cookie = cookie;
-			aa->oa_agl = !!agl;
-			if (!agl) {
+			aa->oa_speculative = speculative;
+			if (!speculative) {
 				aa->oa_flags = flags;
 				aa->oa_lvb = lvb;
 			} else {
-				/* AGL is essentially to enqueue an DLM lock
-				 * in advance, so we don't care about the
-				 * result of AGL enqueue.
+				/* speculative locks are essentially to enqueue
+				 * a DLM lock  in advance, so we don't care
+				 * about the result of the enqueue.
 				 */
 				aa->oa_lvb = NULL;
 				aa->oa_flags = NULL;
@@ -2277,7 +2291,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	}
 
 	rc = osc_enqueue_fini(req, upcall, cookie, &lockh, einfo->ei_mode,
-			      flags, agl, rc);
+			      flags, speculative, rc);
 	if (intent)
 		ptlrpc_req_finished(req);
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 5dde349..eb8bffe 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -40,6 +40,8 @@
 #include <obd_class.h>
 #include <lustre_net.h>
 #include <lustre_disk.h>
+#include <uapi/linux/lustre/lustre_idl.h>
+
 #include "ptlrpc_internal.h"
 
 void lustre_assert_wire_constants(void)
@@ -1113,14 +1115,16 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT_DIR_STRIPE);
 	LASSERTF(OBD_CONNECT_SUBTREE == 0x800000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_SUBTREE);
-	LASSERTF(OBD_CONNECT_LOCK_AHEAD == 0x1000000000000000ULL, "found 0x%.16llxULL\n",
-		 OBD_CONNECT_LOCK_AHEAD);
+	LASSERTF(OBD_CONNECT_LOCKAHEAD_OLD == 0x1000000000000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT_LOCKAHEAD_OLD);
 	LASSERTF(OBD_CONNECT_OBDOPACK == 0x4000000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_OBDOPACK);
 	LASSERTF(OBD_CONNECT_FLAGS2 == 0x8000000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_FLAGS2);
 	LASSERTF(OBD_CONNECT2_FILE_SECCTX == 0x1ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_FILE_SECCTX);
+	LASSERTF(OBD_CONNECT2_LOCKAHEAD == 0x2ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_LOCKAHEAD);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index c2f2670..ec19d31 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -774,7 +774,8 @@ struct ptlrpc_body_v2 {
 						       */
 #define OBD_CONNECT_DIR_STRIPE	 0x400000000000000ULL/* striped DNE dir */
 #define OBD_CONNECT_SUBTREE	 0x800000000000000ULL /* fileset mount */
-#define OBD_CONNECT_LOCK_AHEAD	 0x1000000000000000ULL /* lock ahead */
+#define OBD_CONNECT_LOCKAHEAD_OLD 0x1000000000000000ULL /* Old Cray lockahead */
+
 /** bulk matchbits is sent within ptlrpc_body */
 #define OBD_CONNECT_BULK_MBITS	 0x2000000000000000ULL
 #define OBD_CONNECT_OBDOPACK	 0x4000000000000000ULL /* compact OUT obdo */
@@ -783,6 +784,9 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_FILE_SECCTX	0x1ULL		/* set file security
 							 * context at create
 							 */
+#define OBD_CONNECT2_LOCKAHEAD		0x2ULL		/* ladvise lockahead
+							 * v2
+							 */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
@@ -2097,6 +2101,12 @@ struct ldlm_extent {
 	__u64 gid;
 };
 
+static inline bool ldlm_extent_equal(const struct ldlm_extent *ex1,
+				     const struct ldlm_extent *ex2)
+{
+	return ex1->start == ex2->start && ex1->end == ex2->end;
+}
+
 struct ldlm_inodebits {
 	__u64 bits;
 };
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index d432cfd..17bad49 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1409,11 +1409,16 @@ enum lu_ladvise_type {
 	LU_LADVISE_INVALID	= 0,
 	LU_LADVISE_WILLREAD	= 1,
 	LU_LADVISE_DONTNEED	= 2,
+	LU_LADVISE_LOCKNOEXPAND	= 3,
+	LU_LADVISE_LOCKAHEAD    = 4,
+	LU_LADVISE_MAX
 };
 
-#define LU_LADVISE_NAMES {				\
-	[LU_LADVISE_WILLREAD]	= "willread",		\
-	[LU_LADVISE_DONTNEED]	= "dontneed",		\
+#define LU_LADVISE_NAMES {					\
+	[LU_LADVISE_WILLREAD]		= "willread",		\
+	[LU_LADVISE_DONTNEED]		= "dontneed",		\
+	[LU_LADVISE_LOCKNOEXPAND]	= "locknoexpand",	\
+	[LU_LADVISE_LOCKAHEAD]		= "lockahead",		\
 }
 
 /*
@@ -1433,10 +1438,20 @@ struct llapi_lu_ladvise {
 
 enum ladvise_flag {
 	LF_ASYNC	= 0x00000001,
+	LF_UNSET	= 0x00000002,
 };
 
 #define LADVISE_MAGIC 0x1ADF1CE0
-#define LF_MASK LF_ASYNC
+/* Masks of valid flags for each advice */
+#define LF_LOCKNOEXPAND_MASK LF_UNSET
+/* Flags valid for all advices not explicitly specified */
+#define LF_DEFAULT_MASK LF_ASYNC
+/* All flags */
+#define LF_MASK (LF_ASYNC | LF_UNSET)
+
+#define lla_lockahead_mode	lla_value1
+#define lla_peradvice_flags	lla_value2
+#define lla_lockahead_result	lla_value3
 
 /*
  * This is the userspace argument for ladvise, corresponds to ladvise_hdr which
@@ -1455,6 +1470,23 @@ struct llapi_ladvise_hdr {
 
 #define LAH_COUNT_MAX		1024
 
+enum lock_mode_user {
+	MODE_READ_USER = 1,
+	MODE_WRITE_USER,
+	MODE_MAX_USER,
+};
+
+#define LOCK_MODE_NAMES {			\
+	[MODE_READ_USER]	= "READ",	\
+	[MODE_WRITE_USER]	= "WRITE"	\
+}
+
+enum lockahead_results {
+	LLA_RESULT_SENT = 0,
+	LLA_RESULT_DIFFERENT,
+	LLA_RESULT_SAME,
+};
+
 /** @} lustreuser */
 
 #endif /* _LUSTRE_USER_H */
-- 
1.8.3.1
