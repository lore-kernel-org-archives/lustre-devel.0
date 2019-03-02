From: James Simmons <jsimmons@infradead.org>
Date: Sat,  2 Mar 2019 14:12:20 -0500
Subject: [lustre-devel] [PATCH 3/7] ptlrpc: move comments to sphinix format
In-Reply-To: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
References: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1551553944-6419-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre comments was written for DocBook which is no longer used
by the Linux kernel. Move all the DocBook handling to sphinix.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  72 ++---
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   6 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 102 +++----
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  10 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  14 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         | 305 +++++++++++----------
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |  68 ++---
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   8 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         | 104 +++----
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   4 +-
 11 files changed, 350 insertions(+), 345 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index b2b1104..eb5d22a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -65,7 +65,7 @@
 static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async);
 
 /**
- * Initialize passed in client structure \a cl.
+ * Initialize passed in client structure @cl.
  */
 void ptlrpc_init_client(int req_portal, int rep_portal, char *name,
 			struct ptlrpc_client *cl)
@@ -77,7 +77,7 @@ void ptlrpc_init_client(int req_portal, int rep_portal, char *name,
 EXPORT_SYMBOL(ptlrpc_init_client);
 
 /**
- * Return PortalRPC connection for remote uud \a uuid
+ * Return PortalRPC connection for remote uud @uuid
  */
 struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid,
 						    lnet_nid_t nid4refnet)
@@ -167,8 +167,8 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 }
 
 /**
- * Prepare bulk descriptor for specified outgoing request \a req that
- * can fit \a nfrags * pages. \a type is bulk type. \a portal is where
+ * Prepare bulk descriptor for specified outgoing request @req that
+ * can fit @nfrags * pages. @type is bulk type. @portal is where
  * the bulk to be sent. Used on client-side.
  * Returns pointer to newly allocated initialized bulk descriptor or NULL on
  * error.
@@ -296,7 +296,7 @@ void ptlrpc_at_set_req_timeout(struct ptlrpc_request *req)
 		/*
 		 * non-AT settings
 		 *
-		 * \a imp_server_timeout means this is reverse import and
+		 * @imp_server_timeout means this is reverse import and
 		 * we send (currently only) ASTs to the client and cannot afford
 		 * to wait too long for the reply, otherwise the other client
 		 * (because of which we are sending this request) would
@@ -505,7 +505,7 @@ void ptlrpc_request_cache_free(struct ptlrpc_request *req)
 }
 
 /**
- * Wind down request pool \a pool.
+ * Wind down request pool @pool.
  * Frees all requests from the pool too
  */
 void ptlrpc_free_rq_pool(struct ptlrpc_request_pool *pool)
@@ -525,7 +525,7 @@ void ptlrpc_free_rq_pool(struct ptlrpc_request_pool *pool)
 EXPORT_SYMBOL(ptlrpc_free_rq_pool);
 
 /**
- * Allocates, initializes and adds \a num_rq requests to the pool \a pool
+ * Allocates, initializes and adds @num_rq requests to the pool @pool
  */
 int ptlrpc_add_rqs_to_pool(struct ptlrpc_request_pool *pool, int num_rq)
 {
@@ -568,9 +568,9 @@ int ptlrpc_add_rqs_to_pool(struct ptlrpc_request_pool *pool, int num_rq)
 
 /**
  * Create and initialize new request pool with given attributes:
- * \a num_rq - initial number of requests to create for the pool
- * \a msgsize - maximum message size possible for requests in thid pool
- * \a populate_pool - function to be called when more requests need to be added
+ * @num_rq - initial number of requests to create for the pool
+ * @msgsize - maximum message size possible for requests in thid pool
+ * @populate_pool - function to be called when more requests need to be added
  *		    to the pool
  * Returns pointer to newly created pool or NULL on error.
  */
@@ -601,7 +601,7 @@ struct ptlrpc_request_pool *
 EXPORT_SYMBOL(ptlrpc_init_rq_pool);
 
 /**
- * Fetches one request from pool \a pool
+ * Fetches one request from pool @pool
  */
 static struct ptlrpc_request *
 ptlrpc_prep_req_from_pool(struct ptlrpc_request_pool *pool)
@@ -643,7 +643,7 @@ struct ptlrpc_request_pool *
 }
 
 /**
- * Returns freed \a request to pool.
+ * Returns freed @request to pool.
  */
 static void __ptlrpc_free_req_to_pool(struct ptlrpc_request *request)
 {
@@ -816,8 +816,8 @@ int ptlrpc_request_pack(struct ptlrpc_request *request,
 EXPORT_SYMBOL(ptlrpc_request_pack);
 
 /**
- * Helper function to allocate new request on import \a imp
- * and possibly using existing request from pool \a pool if provided.
+ * Helper function to allocate new request on import @imp
+ * and possibly using existing request from pool @pool if provided.
  * Returns allocated request structure with import field filled or
  * NULL on error.
  */
@@ -852,7 +852,7 @@ struct ptlrpc_request *__ptlrpc_request_alloc(struct obd_import *imp,
 /**
  * Helper function for creating a request.
  * Calls __ptlrpc_request_alloc to allocate new request structure and inits
- * buffer structures according to capsule template \a format.
+ * buffer structures according to capsule template @format.
  * Returns allocated request structure pointer or NULL on error.
  */
 static struct ptlrpc_request *
@@ -872,8 +872,8 @@ struct ptlrpc_request *__ptlrpc_request_alloc(struct obd_import *imp,
 }
 
 /**
- * Allocate new request structure for import \a imp and initialize its
- * buffer structure according to capsule template \a format.
+ * Allocate new request structure for import @imp and initialize its
+ * buffer structure according to capsule template @format.
  */
 struct ptlrpc_request *ptlrpc_request_alloc(struct obd_import *imp,
 					    const struct req_format *format)
@@ -883,8 +883,8 @@ struct ptlrpc_request *ptlrpc_request_alloc(struct obd_import *imp,
 EXPORT_SYMBOL(ptlrpc_request_alloc);
 
 /**
- * Allocate new request structure for import \a imp from pool \a pool and
- * initialize its buffer structure according to capsule template \a format.
+ * Allocate new request structure for import @imp from pool @pool and
+ * initialize its buffer structure according to capsule template @format.
  */
 struct ptlrpc_request *ptlrpc_request_alloc_pool(struct obd_import *imp,
 						 struct ptlrpc_request_pool *pool,
@@ -908,7 +908,7 @@ void ptlrpc_request_free(struct ptlrpc_request *request)
 EXPORT_SYMBOL(ptlrpc_request_free);
 
 /**
- * Allocate new request for operation \a opcode and immediately pack it for
+ * Allocate new request for operation @opcode and immediately pack it for
  * network transfer.
  * Only used for simple requests like OBD_PING where the only important
  * part of the request is operation itself.
@@ -1178,10 +1178,10 @@ static int ptlrpc_import_delay_req(struct obd_import *imp,
  * Decide if the error message should be printed to the console or not.
  * Makes its decision based on request type, status, and failure frequency.
  *
- * \param[in] req  request that failed and may need a console message
+ * @req:	request that failed and may need a console message
  *
- * \retval false if no message should be printed
- * \retval true  if console message should be printed
+ * Return:	false if no message should be printed
+ *		true if console message should be printed
  */
 static bool ptlrpc_console_allow(struct ptlrpc_request *req)
 {
@@ -1285,7 +1285,7 @@ u64 ptlrpc_known_replied_xid(struct obd_import *imp)
 }
 
 /**
- * Callback function called when client receives RPC reply for \a req.
+ * Callback function called when client receives RPC reply for @req.
  * Returns 0 on success or error code.
  * The return value would be assigned to req->rq_status by the caller
  * as request processing status.
@@ -1482,7 +1482,7 @@ static int after_reply(struct ptlrpc_request *req)
 }
 
 /**
- * Helper function to send request \a req over the network for the first time
+ * Helper function to send request @req over the network for the first time
  * Also adjusts request phase.
  * Returns 0 on success or error code.
  */
@@ -1629,7 +1629,7 @@ static inline int ptlrpc_set_producer(struct ptlrpc_request_set *set)
 }
 
 /**
- * this sends any unsent RPCs in \a set and returns 1 if all are sent
+ * this sends any unsent RPCs in @set and returns 1 if all are sent
  * and no more replies are expected.
  * (it is possible to get less replies than requests sent e.g. due to timed out
  * requests or requests that we had trouble to send out)
@@ -2046,7 +2046,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 EXPORT_SYMBOL(ptlrpc_check_set);
 
 /**
- * Time out request \a req. is \a async_unlink is set, that means do not wait
+ * Time out request @req. is @async_unlink is set, that means do not wait
  * until LNet actually confirms network buffer unlinking.
  * Return 1 if we should give up further retrying attempts or 0 otherwise.
  */
@@ -2119,7 +2119,7 @@ int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink)
 }
 
 /**
- * Time out all uncompleted requests in request set pointed by \a data
+ * Time out all uncompleted requests in request set pointed by @data
  * Called when wait_event_idle_timeout times out.
  */
 void ptlrpc_expired_set(struct ptlrpc_request_set *set)
@@ -2153,7 +2153,7 @@ void ptlrpc_expired_set(struct ptlrpc_request_set *set)
 
 /**
  * Interrupts (sets interrupted flag) all uncompleted requests in
- * a set \a data. Called when l_wait_event_abortable_timeout receives signal.
+ * a set @data. Called when l_wait_event_abortable_timeout receives signal.
  */
 static void ptlrpc_interrupted_set(struct ptlrpc_request_set *set)
 {
@@ -2343,7 +2343,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
  * Called when request count reached zero and request needs to be freed.
  * Removes request from all sorts of sending/replay lists it might be on,
  * frees network buffers if any are present.
- * If \a locked is set, that means caller is already holding import imp_lock
+ * If @locked is set, that means caller is already holding import imp_lock
  * and so we no longer need to reobtain it (for certain lists manipulations)
  */
 static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
@@ -2403,8 +2403,8 @@ static void __ptlrpc_free_req(struct ptlrpc_request *request, int locked)
 
 /**
  * Helper function
- * Drops one reference count for request \a request.
- * \a locked set indicates that caller holds import imp_lock.
+ * Drops one reference count for request @request.
+ * @locked set indicates that caller holds import imp_lock.
  * Frees the request when reference count reaches zero.
  *
  * RETURN 1	the request is freed
@@ -2466,7 +2466,7 @@ void ptlrpc_req_finished(struct ptlrpc_request *request)
 EXPORT_SYMBOL(ptlrpc_req_finished);
 
 /**
- * Returns xid of a \a request
+ * Returns xid of a @request
  */
 u64 ptlrpc_req_xid(struct ptlrpc_request *request)
 {
@@ -2699,7 +2699,7 @@ void ptlrpc_resend_req(struct ptlrpc_request *req)
 }
 
 /**
- * Grab additional reference on a request \a req
+ * Grab additional reference on a request @req
  */
 struct ptlrpc_request *ptlrpc_request_addref(struct ptlrpc_request *req)
 {
@@ -2949,7 +2949,7 @@ int ptlrpc_replay_req(struct ptlrpc_request *req)
 }
 
 /**
- * Aborts all in-flight request on import \a imp sending and delayed lists
+ * Aborts all in-flight request on import @imp sending and delayed lists
  */
 void ptlrpc_abort_inflight(struct obd_import *imp)
 {
@@ -3002,7 +3002,7 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
 }
 
 /**
- * Abort all uncompleted requests in request set \a set
+ * Abort all uncompleted requests in request set @set
  */
 void ptlrpc_abort_set(struct ptlrpc_request_set *set)
 {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 7bb2e06..18823d5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -56,7 +56,7 @@ struct ptlrpc_connect_async_args {
 };
 
 /**
- * Updates import \a imp current state to provided \a state value
+ * Updates import @imp current state to provided @state value
  * Helper function. Must be called under imp_lock.
  */
 static void __import_set_state(struct obd_import *imp,
@@ -435,7 +435,7 @@ int ptlrpc_reconnect_import(struct obd_import *imp)
 EXPORT_SYMBOL(ptlrpc_reconnect_import);
 
 /**
- * Connection on import \a imp is changed to another one (if more than one is
+ * Connection on import @imp is changed to another one (if more than one is
  * present). We typically chose connection that we have not tried to connect to
  * the longest
  */
@@ -579,7 +579,7 @@ static int ptlrpc_first_transno(struct obd_import *imp, u64 *transno)
 }
 
 /**
- * Attempt to (re)connect import \a imp. This includes all preparations,
+ * Attempt to (re)connect import @imp. This includes all preparations,
  * initializing CONNECT RPC request and passing it to ptlrpcd for
  * actual sending.
  * Returns 0 on success or error code.
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index d9f2b3d..3bebfd7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -771,8 +771,8 @@ struct req_msg_field {
 	const char  *rmf_name;
 	/**
 	 * Field length. (-1) means "variable length".  If the
-	 * \a RMF_F_STRUCT_ARRAY flag is set the field is also variable-length,
-	 * but the actual size must be a whole multiple of \a rmf_size.
+	 * @RMF_F_STRUCT_ARRAY flag is set the field is also variable-length,
+	 * but the actual size must be a whole multiple of @rmf_size.
 	 */
 	const int   rmf_size;
 	void	(*rmf_swabber)(void *);
@@ -786,13 +786,13 @@ enum rmf_flags {
 	 */
 	RMF_F_STRING = BIT(0),
 	/**
-	 * The field's buffer size need not match the declared \a rmf_size.
+	 * The field's buffer size need not match the declared @rmf_size.
 	 */
 	RMF_F_NO_SIZE_CHECK = BIT(1),
 	/**
-	 * The field's buffer size must be a whole multiple of the declared \a
-	 * rmf_size and the \a rmf_swabber function must work on the declared \a
-	 * rmf_size worth of bytes.
+	 * The field's buffer size must be a whole multiple of the declared
+	 * @rmf_size and the @rmf_swabber function must work on the declared
+	 * @rmf_size worth of bytes.
 	 */
 	RMF_F_STRUCT_ARRAY = BIT(2)
 };
@@ -1603,8 +1603,8 @@ struct req_format RQF_OST_LADVISE =
 #define FMT_FIELD(fmt, i, j) ((fmt)->rf_fields[(i)].d[(j)])
 
 /**
- * Initializes the capsule abstraction by computing and setting the \a rf_idx
- * field of RQFs and the \a rmf_offset field of RMFs.
+ * Initializes the capsule abstraction by computing and setting the @rf_idx
+ * field of RQFs and the @rmf_offset field of RMFs.
  */
 int req_layout_init(void)
 {
@@ -1643,11 +1643,11 @@ void req_layout_fini(void)
 EXPORT_SYMBOL(req_layout_fini);
 
 /**
- * Initializes the expected sizes of each RMF in a \a pill (\a rc_area) to -1.
+ * Initializes the expected sizes of each RMF in a @pill (@rc_area) to -1.
  *
  * Actual/expected field sizes are set elsewhere in functions in this file:
  * req_capsule_init(), req_capsule_server_pack(), req_capsule_set_size() and
- * req_capsule_msg_size().  The \a rc_area information is used by.
+ * req_capsule_msg_size().  The @rc_area information is used by.
  * ptlrpc_request_set_replen().
  */
 static void req_capsule_init_area(struct req_capsule *pill)
@@ -1663,7 +1663,7 @@ static void req_capsule_init_area(struct req_capsule *pill)
 /**
  * Initialize a pill.
  *
- * The \a location indicates whether the caller is executing on the client side
+ * The @location indicates whether the caller is executing on the client side
  * (RCL_CLIENT) or server side (RCL_SERVER)..
  */
 void req_capsule_init(struct req_capsule *pill,
@@ -1717,7 +1717,7 @@ static struct lustre_msg *__req_msg(const struct req_capsule *pill,
 }
 
 /**
- * Set the format (\a fmt) of a \a pill; format changes are not allowed here
+ * Set the format (@fmt) of a @pill; format changes are not allowed here
  * (see req_capsule_extend()).
  */
 void req_capsule_set(struct req_capsule *pill, const struct req_format *fmt)
@@ -1730,12 +1730,12 @@ void req_capsule_set(struct req_capsule *pill, const struct req_format *fmt)
 EXPORT_SYMBOL(req_capsule_set);
 
 /**
- * Fills in any parts of the \a rc_area of a \a pill that haven't been filled in
+ * Fills in any parts of the @rc_area of a @pill that haven't been filled in
  * yet.
 
- * \a rc_area is an array of REQ_MAX_FIELD_NR elements, used to store sizes of
- * variable-sized fields.  The field sizes come from the declared \a rmf_size
- * field of a \a pill's \a rc_fmt's RMF's.
+ * @rc_area is an array of REQ_MAX_FIELD_NR elements, used to store sizes of
+ * variable-sized fields.  The field sizes come from the declared @rmf_size
+ * field of a @pill's @rc_fmt's RMF's.
  */
 size_t req_capsule_filled_sizes(struct req_capsule *pill,
 				enum req_location loc)
@@ -1766,7 +1766,7 @@ size_t req_capsule_filled_sizes(struct req_capsule *pill,
 /**
  * Capsule equivalent of lustre_pack_request() and lustre_pack_reply().
  *
- * This function uses the \a pill's \a rc_area as filled in by
+ * This function uses the @pill's @rc_area as filled in by
  * req_capsule_set_size() or req_capsule_filled_sizes() (the latter is called by
  * this function).
  */
@@ -1793,8 +1793,8 @@ int req_capsule_server_pack(struct req_capsule *pill)
 EXPORT_SYMBOL(req_capsule_server_pack);
 
 /**
- * Returns the PTLRPC request or reply (\a loc) buffer offset of a \a pill
- * corresponding to the given RMF (\a field).
+ * Returns the PTLRPC request or reply (@loc) buffer offset of a @pill
+ * corresponding to the given RMF (@field).
  */
 u32 __req_capsule_offset(const struct req_capsule *pill,
 			 const struct req_msg_field *field,
@@ -1886,13 +1886,13 @@ u32 __req_capsule_offset(const struct req_capsule *pill,
 }
 
 /**
- * Returns the pointer to a PTLRPC request or reply (\a loc) buffer of a \a pill
- * corresponding to the given RMF (\a field).
+ * Returns the pointer to a PTLRPC request or reply (@loc) buffer of a @pill
+ * corresponding to the given RMF (@field).
  *
- * The buffer will be swabbed using the given \a swabber.  If \a swabber == NULL
- * then the \a rmf_swabber from the RMF will be used.  Soon there will be no
- * calls to __req_capsule_get() with a non-NULL \a swabber; \a swabber will then
- * be removed.  Fields with the \a RMF_F_STRUCT_ARRAY flag set will have each
+ * The buffer will be swabbed using the given @swabber.  If @swabber == NULL
+ * then the @rmf_swabber from the RMF will be used. Soon there will be no
+ * calls to __req_capsule_get() with a non-NULL @swabber; @swabber will then
+ * be removed.  Fields with the @RMF_F_STRUCT_ARRAY flag set will have each
  * element of the array swabbed.
  */
 static void *__req_capsule_get(struct req_capsule *pill,
@@ -1960,7 +1960,7 @@ static void *__req_capsule_get(struct req_capsule *pill,
 
 /**
  * Trivial wrapper around __req_capsule_get(), that returns the PTLRPC request
- * buffer corresponding to the given RMF (\a field) of a \a pill.
+ * buffer corresponding to the given RMF (@field) of a @pill.
  */
 void *req_capsule_client_get(struct req_capsule *pill,
 			     const struct req_msg_field *field)
@@ -1970,7 +1970,7 @@ void *req_capsule_client_get(struct req_capsule *pill,
 EXPORT_SYMBOL(req_capsule_client_get);
 
 /**
- * Same as req_capsule_client_get(), but with a \a swabber argument.
+ * Same as req_capsule_client_get(), but with a @swabber argument.
  *
  * Currently unused; will be removed when req_capsule_server_swab_get() is
  * unused too.
@@ -1986,8 +1986,8 @@ void *req_capsule_client_swab_get(struct req_capsule *pill,
 /**
  * Utility that combines req_capsule_set_size() and req_capsule_client_get().
  *
- * First the \a pill's request \a field's size is set (\a rc_area) using
- * req_capsule_set_size() with the given \a len.  Then the actual buffer is
+ * First the @pill's request @field's size is set (@rc_area) using
+ * req_capsule_set_size() with the given @len.  Then the actual buffer is
  * returned.
  */
 void *req_capsule_client_sized_get(struct req_capsule *pill,
@@ -2001,7 +2001,7 @@ void *req_capsule_client_sized_get(struct req_capsule *pill,
 
 /**
  * Trivial wrapper around __req_capsule_get(), that returns the PTLRPC reply
- * buffer corresponding to the given RMF (\a field) of a \a pill.
+ * buffer corresponding to the given RMF (@field) of a @pill.
  */
 void *req_capsule_server_get(struct req_capsule *pill,
 			     const struct req_msg_field *field)
@@ -2011,7 +2011,7 @@ void *req_capsule_server_get(struct req_capsule *pill,
 EXPORT_SYMBOL(req_capsule_server_get);
 
 /**
- * Same as req_capsule_server_get(), but with a \a swabber argument.
+ * Same as req_capsule_server_get(), but with a @swabber argument.
  *
  * Ideally all swabbing should be done pursuant to RMF definitions, with no
  * swabbing done outside this capsule abstraction.
@@ -2027,8 +2027,8 @@ void *req_capsule_server_swab_get(struct req_capsule *pill,
 /**
  * Utility that combines req_capsule_set_size() and req_capsule_server_get().
  *
- * First the \a pill's request \a field's size is set (\a rc_area) using
- * req_capsule_set_size() with the given \a len.  Then the actual buffer is
+ * First the @pill's request @field's size is set (@rc_area) using
+ * req_capsule_set_size() with the given @len.  Then the actual buffer is
  * returned.
  */
 void *req_capsule_server_sized_get(struct req_capsule *pill,
@@ -2050,8 +2050,8 @@ void *req_capsule_server_sized_swab_get(struct req_capsule *pill,
 EXPORT_SYMBOL(req_capsule_server_sized_swab_get);
 
 /**
- * Set the size of the PTLRPC request/reply (\a loc) buffer for the given \a
- * field of the given \a pill.
+ * Set the size of the PTLRPC request/reply (@loc) buffer for the given
+ * @field of the given @pill.
  *
  * This function must be used when constructing variable sized fields of a
  * request or reply.
@@ -2086,8 +2086,8 @@ void req_capsule_set_size(struct req_capsule *pill,
 EXPORT_SYMBOL(req_capsule_set_size);
 
 /**
- * Return the actual PTLRPC buffer length of a request or reply (\a loc)
- * for the given \a pill's given \a field.
+ * Return the actual PTLRPC buffer length of a request or reply (@loc)
+ * for the given @pill's given @field.
  *
  * NB: this function doesn't correspond with req_capsule_set_size(), which
  * actually sets the size in pill.rc_area[loc][offset], but this function
@@ -2106,8 +2106,8 @@ u32 req_capsule_get_size(const struct req_capsule *pill,
 
 /**
  * Wrapper around lustre_msg_size() that returns the PTLRPC size needed for the
- * given \a pill's request or reply (\a loc) given the field size recorded in
- * the \a pill's rc_area.
+ * given @pill's request or reply (@loc) given the field size recorded in
+ * the @pill's rc_area.
  *
  * See also req_capsule_set_size().
  */
@@ -2120,8 +2120,8 @@ u32 req_capsule_msg_size(struct req_capsule *pill, enum req_location loc)
 
 /**
  * While req_capsule_msg_size() computes the size of a PTLRPC request or reply
- * (\a loc) given a \a pill's \a rc_area, this function computes the size of a
- * PTLRPC request or reply given only an RQF (\a fmt).
+ * (@loc) given a @pill's @rc_area, this function computes the size of a
+ * PTLRPC request or reply given only an RQF (@fmt).
  *
  * This function should not be used for formats which contain variable size
  * fields.
@@ -2154,19 +2154,19 @@ u32 req_capsule_fmt_size(u32 magic, const struct req_format *fmt,
  * Changes the format of an RPC.
  *
  * The pill must already have been initialized, which means that it already has
- * a request format.  The new format \a fmt must be an extension of the pill's
+ * a request format.  The new format @fmt must be an extension of the pill's
  * old format.  Specifically: the new format must have as many request and reply
  * fields as the old one, and all fields shared by the old and new format must
  * be at least as large in the new format.
  *
  * The new format's fields may be of different "type" than the old format, but
  * only for fields that are "opaque" blobs: fields which have a) have no
- * \a rmf_swabber, b) \a rmf_flags == 0 or RMF_F_NO_SIZE_CHECK, and c) \a
- * rmf_size == -1 or \a rmf_flags == RMF_F_NO_SIZE_CHECK.  For example,
+ * @rmf_swabber, b) @rmf_flags == 0 or RMF_F_NO_SIZE_CHECK, and c)
+ * @rmf_size == -1 or @rmf_flags == RMF_F_NO_SIZE_CHECK.  For example,
  * OBD_SET_INFO has a key field and an opaque value field that gets interpreted
  * according to the key field.  When the value, according to the key, contains a
  * structure (or array thereof) to be swabbed, the format should be changed to
- * one where the value field has \a rmf_size/rmf_flags/rmf_swabber set
+ * one where the value field has @rmf_size/rmf_flags/rmf_swabber set
  * accordingly.
  */
 void req_capsule_extend(struct req_capsule *pill, const struct req_format *fmt)
@@ -2207,8 +2207,8 @@ void req_capsule_extend(struct req_capsule *pill, const struct req_format *fmt)
 EXPORT_SYMBOL(req_capsule_extend);
 
 /**
- * This function returns a non-zero value if the given \a field is present in
- * the format (\a rc_fmt) of \a pill's PTLRPC request or reply (\a loc), else it
+ * This function returns a non-zero value if the given @field is present in
+ * the format (@rc_fmt) of @pill's PTLRPC request or reply (@loc), else it
  * returns 0.
  */
 int req_capsule_has_field(const struct req_capsule *pill,
@@ -2222,8 +2222,8 @@ int req_capsule_has_field(const struct req_capsule *pill,
 EXPORT_SYMBOL(req_capsule_has_field);
 
 /**
- * Returns a non-zero value if the given \a field is present in the given \a
- * pill's PTLRPC request or reply (\a loc), else it returns 0.
+ * Returns a non-zero value if the given @field is present in the given
+ * @pill's PTLRPC request or reply (@loc), else it returns 0.
  */
 static int req_capsule_field_present(const struct req_capsule *pill,
 				     const struct req_msg_field *field,
@@ -2239,8 +2239,8 @@ static int req_capsule_field_present(const struct req_capsule *pill,
 }
 
 /**
- * This function shrinks the size of the _buffer_ of the \a pill's PTLRPC
- * request or reply (\a loc).
+ * This function shrinks the size of the _buffer_ of the @pill's PTLRPC
+ * request or reply (@loc).
  *
  * This is not the opposite of req_capsule_extend().
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 25858b8..08f9282 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -415,7 +415,7 @@ static ssize_t threads_max_store(struct kobject *kobj, struct attribute *attr,
 /**
  * Translates \e ptlrpc_nrs_pol_state values to human-readable strings.
  *
- * \param[in] state The policy state
+ * @state:	The policy state
  */
 static const char *nrs_state2str(enum ptlrpc_nrs_pol_state state)
 {
@@ -436,12 +436,12 @@ static const char *nrs_state2str(enum ptlrpc_nrs_pol_state state)
 }
 
 /**
- * Obtains status information for \a policy.
+ * Obtains status information for @policy.
  *
- * Information is copied in \a info.
+ * Information is copied in @info.
  *
- * \param[in] policy The policy
- * \param[out] info  Holds returned status information
+ * @policy:	The policy
+ * @info:	Holds returned status information
  */
 static void nrs_policy_get_info_locked(struct ptlrpc_nrs_policy *policy,
 				       struct ptlrpc_nrs_pol_info *info)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index ea7a7f9..c279fb1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -41,8 +41,8 @@
 #include "ptlrpc_internal.h"
 
 /**
- * Helper function. Sends \a len bytes from \a base at offset \a offset
- * over \a conn connection to portal \a portal.
+ * Helper function. Sends @len bytes from @base at offset @offset
+ * over @conn connection to portal @portal.
  * Returns 0 on success or error code.
  */
 static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
@@ -343,8 +343,8 @@ static void ptlrpc_at_set_reply(struct ptlrpc_request *req, int flags)
 }
 
 /**
- * Send request reply from request \a req reply buffer.
- * \a flags defines reply types
+ * Send request reply from request @req reply buffer.
+ * @flags defines reply types
  * Returns 0 on success or error code
  */
 int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
@@ -443,7 +443,7 @@ int ptlrpc_reply(struct ptlrpc_request *req)
 }
 
 /**
- * For request \a req send an error reply back. Create empty
+ * For request @req send an error reply back. Create empty
  * reply buffers if necessary.
  */
 int ptlrpc_send_error(struct ptlrpc_request *req, int may_be_difficult)
@@ -474,8 +474,8 @@ int ptlrpc_error(struct ptlrpc_request *req)
 }
 
 /**
- * Send request \a request.
- * if \a noreply is set, don't expect any reply back and don't set up
+ * Send request @request.
+ * if @noreply is set, don't expect any reply back and don't set up
  * reply buffers.
  * Returns 0 on success or error code.
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index ef7dd5d..a56b7b3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -131,11 +131,11 @@ static int nrs_policy_stop_locked(struct ptlrpc_nrs_policy *policy)
 }
 
 /**
- * Transitions the \a nrs NRS head's primary policy to
+ * Transitions the @nrs NRS head's primary policy to
  * ptlrpc_nrs_pol_state::NRS_POL_STATE_STOPPING and if the policy has no
  * pending usage references, to ptlrpc_nrs_pol_state::NRS_POL_STATE_STOPPED.
  *
- * \param[in] nrs the NRS head to carry out this operation on
+ * @nrs:	the NRS head to carry out this operation on
  */
 static void nrs_policy_stop_primary(struct ptlrpc_nrs *nrs)
 {
@@ -347,17 +347,17 @@ static void nrs_resource_put(struct ptlrpc_nrs_resource *res)
 
 /**
  * Obtains references for each resource in the resource hierarchy for request
- * \a nrq if it is to be handled by \a policy.
+ * @nrq if it is to be handled by @policy.
  *
- * \param[in] policy	  the policy
- * \param[in] nrq	  the request
- * \param[in] moving_req  denotes whether this is a call to the function by
- *			  ldlm_lock_reorder_req(), in order to move \a nrq to
- *			  the high-priority NRS head; we should not sleep when
- *			  set.
+ * @policy:	the policy
+ * @nrq:	the request
+ * @moving_req:	denotes whether this is a call to the function by
+ *		ldlm_lock_reorder_req(), in order to move @nrq to
+ *		the high-priority NRS head; we should not sleep when
+ *		set.
  *
- * \retval NULL		  resource hierarchy references not obtained
- * \retval valid-pointer  the bottom level of the resource hierarchy
+ * Returns:	NULL		resource hierarchy references not obtained
+ *		valid-pointer	the bottom level of the resource hierarchy
  *
  * \see ptlrpc_nrs_pol_ops::op_res_get()
  */
@@ -398,19 +398,19 @@ struct ptlrpc_nrs_resource *nrs_resource_get(struct ptlrpc_nrs_policy *policy,
 /**
  * Obtains resources for the resource hierarchies and policy references for
  * the fallback and current primary policy (if any), that will later be used
- * to handle request \a nrq.
- *
- * \param[in]  nrs  the NRS head instance that will be handling request \a nrq.
- * \param[in]  nrq  the request that is being handled.
- * \param[out] resp the array where references to the resource hierarchy are
- *		    stored.
- * \param[in]  moving_req  is set when obtaining resources while moving a
- *			   request from a policy on the regular NRS head to a
- *			   policy on the HP NRS head (via
- *			   ldlm_lock_reorder_req()). It signifies that
- *			   allocations to get resources should be atomic; for
- *			   a full explanation, see comment in
- *			   ptlrpc_nrs_pol_ops::op_res_get().
+ * to handle request @nrq.
+ *
+ * @nrs:	the NRS head instance that will be handling request @nrq.
+ * @nrq:	the request that is being handled.
+ * @resp:	the array where references to the resource hierarchy are
+ *		stored.
+ * @moving_req:	is set when obtaining resources while moving a
+ *		request from a policy on the regular NRS head to a
+ *		policy on the HP NRS head (via
+ *		ldlm_lock_reorder_req()). It signifies that
+ *		allocations to get resources should be atomic; for
+ *		a full explanation, see comment in
+ *		ptlrpc_nrs_pol_ops::op_res_get().
  */
 static void nrs_resource_get_safe(struct ptlrpc_nrs *nrs,
 				  struct ptlrpc_nrs_request *nrq,
@@ -461,7 +461,7 @@ static void nrs_resource_get_safe(struct ptlrpc_nrs *nrs,
  * longer required; used when request handling has been completed, or the
  * request is moving to the high priority NRS head.
  *
- * \param resp	the resource hierarchy that is being released
+ * @resp:	the resource hierarchy that is being released
  *
  * \see ptlrpc_nrs_req_finalize()
  */
@@ -487,20 +487,20 @@ static void nrs_resource_put_safe(struct ptlrpc_nrs_resource **resp)
 }
 
 /**
- * Obtains an NRS request from \a policy for handling or examination; the
+ * Obtains an NRS request from @policy for handling or examination; the
  * request should be removed in the 'handling' case.
  *
  * Calling into this function implies we already know the policy has a request
  * waiting to be handled.
  *
- * \param[in] policy the policy from which a request
- * \param[in] peek   when set, signifies that we just want to examine the
- *		     request, and not handle it, so the request is not removed
- *		     from the policy.
- * \param[in] force  when set, it will force a policy to return a request if it
- *		     has one pending
+ * @policy:	the policy from which a request
+ * @peek:	when set, signifies that we just want to examine the
+ *		request, and not handle it, so the request is not removed
+ *		from the policy.
+ * @force:	when set, it will force a policy to return a request if it
+ *		has one pending
  *
- * \retval the NRS request to be handled
+ * Returns:	the NRS request to be handled
  */
 static inline
 struct ptlrpc_nrs_request *nrs_request_get(struct ptlrpc_nrs_policy *policy,
@@ -518,12 +518,12 @@ struct ptlrpc_nrs_request *nrs_request_get(struct ptlrpc_nrs_policy *policy,
 }
 
 /**
- * Enqueues request \a nrq for later handling, via one one the policies for
+ * Enqueues request @nrq for later handling, via one one the policies for
  * which resources where earlier obtained via nrs_resource_get_safe(). The
  * function attempts to enqueue the request first on the primary policy
  * (if any), since this is the preferred choice.
  *
- * \param nrq the request being enqueued
+ * @nrq:	the request being enqueued
  *
  * \see nrs_resource_get_safe()
  */
@@ -562,8 +562,8 @@ static inline void nrs_request_enqueue(struct ptlrpc_nrs_request *nrq)
 /**
  * Called when a request has been handled
  *
- * \param[in] nrs the request that has been handled; can be used for
- *		  job/resource control.
+ * @nrs:	the request that has been handled; can be used for
+ *		job/resource control.
  *
  * \see ptlrpc_nrs_req_stop_nolock()
  */
@@ -587,17 +587,17 @@ static inline void nrs_request_stop(struct ptlrpc_nrs_request *nrq)
  * Handles opcodes that are common to all policy types within NRS core, and
  * passes any unknown opcodes to the policy-specific control function.
  *
- * \param[in]	  nrs  the NRS head this policy belongs to.
- * \param[in]	  name the human-readable policy name; should be the same as
- *		       ptlrpc_nrs_pol_desc::pd_name.
- * \param[in]	  opc  the opcode of the operation being carried out.
- * \param[in,out] arg  can be used to pass information in and out between when
- *		       carrying an operation; usually data that is private to
- *		       the policy at some level, or generic policy status
- *		       information.
- *
- * \retval -ve error condition
- * \retval   0 operation was carried out successfully
+ * @nrs:	the NRS head this policy belongs to.
+ * @name	the human-readable policy name; should be the same as
+ *		ptlrpc_nrs_pol_desc::pd_name.
+ * @opc:	the opcode of the operation being carried out.
+ * @arg:	can be used to pass information in and out between when
+ *		carrying an operation; usually data that is private to
+ *		the policy at some level, or generic policy status
+ *		information.
+ *
+ * Return:	-ve error condition
+ *		0 operation was carried out successfully
  */
 static int nrs_policy_ctl(struct ptlrpc_nrs *nrs, char *name,
 			  enum ptlrpc_nrs_ctl opc, void *arg)
@@ -647,12 +647,12 @@ static int nrs_policy_ctl(struct ptlrpc_nrs *nrs, char *name,
 /**
  * Unregisters a policy by name.
  *
- * \param[in] nrs  the NRS head this policy belongs to.
- * \param[in] name the human-readable policy name; should be the same as
- *		   ptlrpc_nrs_pol_desc::pd_name
+ * @nrs:	the NRS head this policy belongs to.
+ * @name:	the human-readable policy name; should be the same as
+ *		ptlrpc_nrs_pol_desc::pd_name
  *
- * \retval -ve error
- * \retval   0 success
+ * Return:	-ve error
+ *		0 success
  */
 static int nrs_policy_unregister(struct ptlrpc_nrs *nrs, char *name)
 {
@@ -701,14 +701,14 @@ static int nrs_policy_unregister(struct ptlrpc_nrs *nrs, char *name)
 }
 
 /**
- * Register a policy from \policy descriptor \a desc with NRS head \a nrs.
+ * Register a policy from \policy descriptor @desc with NRS head @nrs.
  *
- * \param[in] nrs   the NRS head on which the policy will be registered.
- * \param[in] desc  the policy descriptor from which the information will be
- *		    obtained to register the policy.
+ * @nrs:	the NRS head on which the policy will be registered.
+ * @desc:	the policy descriptor from which the information will be
+ *		obtained to register the policy.
  *
- * \retval -ve error
- * \retval   0 success
+ * Return:	-ve error
+ *		0 success
  */
 static int nrs_policy_register(struct ptlrpc_nrs *nrs,
 			       struct ptlrpc_nrs_pol_desc *desc)
@@ -775,10 +775,10 @@ static int nrs_policy_register(struct ptlrpc_nrs *nrs,
 }
 
 /**
- * Enqueue request \a req using one of the policies its resources are referring
+ * Enqueue request @req using one of the policies its resources are referring
  * to.
  *
- * \param[in] req the request to enqueue.
+ * @req:	the request to enqueue.
  */
 static void ptlrpc_nrs_req_add_nolock(struct ptlrpc_request *req)
 {
@@ -803,7 +803,7 @@ static void ptlrpc_nrs_req_add_nolock(struct ptlrpc_request *req)
 /**
  * Enqueue a request on the high priority NRS head.
  *
- * \param req the request to enqueue.
+ * @req:	the request to enqueue.
  */
 static void ptlrpc_nrs_hpreq_add_nolock(struct ptlrpc_request *req)
 {
@@ -819,13 +819,13 @@ static void ptlrpc_nrs_hpreq_add_nolock(struct ptlrpc_request *req)
 
 /**
  * Returns a boolean predicate indicating whether the policy described by
- * \a desc is adequate for use with service \a svc.
+ * @desc is adequate for use with service @svc.
  *
- * \param[in] svc  the service
- * \param[in] desc the policy descriptor
+ * @svc:	the service
+ * @desc:	the policy descriptor
  *
- * \retval false the policy is not compatible with the service
- * \retval true	 the policy is compatible with the service
+ * Return:	false the policy is not compatible with the service
+ *		true the policy is compatible with the service
  */
 static inline bool nrs_policy_compatible(const struct ptlrpc_service *svc,
 					 const struct ptlrpc_nrs_pol_desc *desc)
@@ -835,12 +835,12 @@ static inline bool nrs_policy_compatible(const struct ptlrpc_service *svc,
 
 /**
  * Registers all compatible policies in nrs_core.nrs_policies, for NRS head
- * \a nrs.
+ * @nrs.
  *
- * \param[in] nrs the NRS head
+ * @nrs:	the NRS head
  *
- * \retval -ve error
- * \retval   0 success
+ * Return:	-ve error
+ *		0 success
  *
  * \pre mutex_is_locked(&nrs_core.nrs_mutex)
  *
@@ -876,14 +876,14 @@ static int nrs_register_policies_locked(struct ptlrpc_nrs *nrs)
 }
 
 /**
- * Initializes NRS head \a nrs of service partition \a svcpt, and registers all
+ * Initializes NRS head @nrs of service partition @svcpt, and registers all
  * compatible policies in NRS core, with the NRS head.
  *
- * \param[in] nrs   the NRS head
- * \param[in] svcpt the PTLRPC service partition to setup
+ * @nrs:	the NRS head
+ * @svcpt:	the PTLRPC service partition to setup
  *
- * \retval -ve error
- * \retval   0 success
+ * Return:	-ve error
+ *		0 success
  *
  * \pre mutex_is_locked(&nrs_core.nrs_mutex)
  */
@@ -915,7 +915,7 @@ static int __nrs_svcpt_setup_locked(struct ptlrpc_nrs *nrs,
  * handles high-priority RPCs), and then registers all available compatible
  * policies on those NRS heads.
  *
- * \param[in,out] svcpt the PTLRPC service partition to setup
+ * @svcpt:	the PTLRPC service partition to setup
  *
  * \pre mutex_is_locked(&nrs_core.nrs_mutex)
  */
@@ -960,7 +960,7 @@ static int nrs_svcpt_setup_locked(struct ptlrpc_service_part *svcpt)
  * Unregisters all policies on all available NRS heads in a service partition;
  * called at PTLRPC service unregistration time.
  *
- * \param[in] svcpt the PTLRPC service partition
+ * @svcpt:	the PTLRPC service partition
  *
  * \pre mutex_is_locked(&nrs_core.nrs_mutex)
  */
@@ -1000,12 +1000,12 @@ static void nrs_svcpt_cleanup_locked(struct ptlrpc_service_part *svcpt)
 }
 
 /**
- * Returns the descriptor for a policy as identified by by \a name.
+ * Returns the descriptor for a policy as identified by by @name.
  *
- * \param[in] name the policy name
+ * @name:	the policy name
  *
- * \retval the policy descriptor
- * \retval NULL
+ * Return:	the policy descriptor
+ *		NULL if not found
  */
 static struct ptlrpc_nrs_pol_desc *nrs_policy_find_desc_locked(const char *name)
 {
@@ -1022,10 +1022,10 @@ static struct ptlrpc_nrs_pol_desc *nrs_policy_find_desc_locked(const char *name)
  * Removes the policy from all supported NRS heads of all partitions of all
  * PTLRPC services.
  *
- * \param[in] desc the policy descriptor to unregister
+ * @desc:	the policy descriptor to unregister
  *
- * \retval -ve error
- * \retval  0  successfully unregistered policy on all supported NRS heads
+ * Return:	-ve error
+ *		0 successfully unregistered policy on all supported NRS heads
  *
  * \pre mutex_is_locked(&nrs_core.nrs_mutex)
  * \pre mutex_is_locked(&ptlrpc_all_services_mutex)
@@ -1088,10 +1088,10 @@ static int nrs_policy_unregister_locked(struct ptlrpc_nrs_pol_desc *desc)
  *	time when registering a policy that ships with NRS core, or in a
  *	module's init() function for policies registering from other modules.
  *
- * \param[in] conf configuration information for the new policy to register
+ * @conf:	configuration information for the new policy to register
  *
- * \retval -ve error
- * \retval   0 success
+ * Return:	-ve error
+ *		0 success
  */
 static int ptlrpc_nrs_policy_register(struct ptlrpc_nrs_pol_conf *conf)
 {
@@ -1236,15 +1236,16 @@ static int ptlrpc_nrs_policy_register(struct ptlrpc_nrs_pol_conf *conf)
 }
 
 /**
- * Setup NRS heads on all service partitions of service \a svc, and register
+ * Setup NRS heads on all service partitions of service @svc, and register
  * all compatible policies on those NRS heads.
  *
  * To be called from within ptl
- * \param[in] svc the service to setup
  *
- * \retval -ve error, the calling logic should eventually call
- *		      ptlrpc_service_nrs_cleanup() to undo any work performed
- *		      by this function.
+ * @svc:	the service to setup
+ *
+ * Return:	-ve error, the calling logic should eventually call
+ *		ptlrpc_service_nrs_cleanup() to undo any work performed
+ *		by this function.
  *
  * \see ptlrpc_register_service()
  * \see ptlrpc_service_nrs_cleanup()
@@ -1290,9 +1291,9 @@ int ptlrpc_service_nrs_setup(struct ptlrpc_service *svc)
 }
 
 /**
- * Unregisters all policies on all service partitions of service \a svc.
+ * Unregisters all policies on all service partitions of service @svc.
  *
- * \param[in] svc the PTLRPC service to unregister
+ * @svc:	the PTLRPC service to unregister
  */
 void ptlrpc_service_nrs_cleanup(struct ptlrpc_service *svc)
 {
@@ -1324,15 +1325,15 @@ void ptlrpc_service_nrs_cleanup(struct ptlrpc_service *svc)
 }
 
 /**
- * Obtains NRS head resources for request \a req.
+ * Obtains NRS head resources for request @req.
  *
- * These could be either on the regular or HP NRS head of \a svcpt; resources
+ * These could be either on the regular or HP NRS head of @svcpt; resources
  * taken on the regular head can later be swapped for HP head resources by
  * ldlm_lock_reorder_req().
  *
- * \param[in] svcpt the service partition
- * \param[in] req   the request
- * \param[in] hp    which NRS head of \a svcpt to use
+ * @svcpt:	the service partition
+ * @req:	the request
+ * @hp:		which NRS head of @svcpt to use
  */
 void ptlrpc_nrs_req_initialize(struct ptlrpc_service_part *svcpt,
 			       struct ptlrpc_request *req, bool hp)
@@ -1354,7 +1355,7 @@ void ptlrpc_nrs_req_initialize(struct ptlrpc_service_part *svcpt,
  * Releases resources for a request; is called after the request has been
  * handled.
  *
- * \param[in] req the request
+ * @req:	the request
  *
  * \see ptlrpc_server_finish_request()
  */
@@ -1376,13 +1377,13 @@ void ptlrpc_nrs_req_stop_nolock(struct ptlrpc_request *req)
 }
 
 /**
- * Enqueues request \a req on either the regular or high-priority NRS head
- * of service partition \a svcpt.
+ * Enqueues request @req on either the regular or high-priority NRS head
+ * of service partition @svcpt.
  *
- * \param[in] svcpt the service partition
- * \param[in] req   the request to be enqueued
- * \param[in] hp    whether to enqueue the request on the regular or
- *		    high-priority NRS head.
+ * @svcpt:	the service partition
+ * @req:	the request to be enqueued
+ * @hp:		whether to enqueue the request on the regular or
+ *		high-priority NRS head.
  */
 void ptlrpc_nrs_req_add(struct ptlrpc_service_part *svcpt,
 			struct ptlrpc_request *req, bool hp)
@@ -1428,19 +1429,19 @@ static void nrs_request_removed(struct ptlrpc_nrs_policy *policy)
 
 /**
  * Obtains a request for handling from an NRS head of service partition
- * \a svcpt.
- *
- * \param[in] svcpt the service partition
- * \param[in] hp    whether to obtain a request from the regular or
- *		    high-priority NRS head.
- * \param[in] peek  when set, signifies that we just want to examine the
- *		    request, and not handle it, so the request is not removed
- *		    from the policy.
- * \param[in] force when set, it will force a policy to return a request if it
- *		    has one pending
- *
- * \retval the	request to be handled
- * \retval NULL the head has no requests to serve
+ * @svcpt.
+ *
+ * @svcpt:	the service partition
+ * @hp:		whether to obtain a request from the regular or
+ *		high-priority NRS head.
+ * @peek:	when set, signifies that we just want to examine the
+ *		request, and not handle it, so the request is not removed
+ *		from the policy.
+ * @force:	when set, it will force a policy to return a request if it
+ *		has one pending
+ *
+ * Return:	the request to be handled
+ *		NULL the head has no requests to serve
  */
 struct ptlrpc_request *
 __ptlrpc_nrs_req_get_nolock(struct ptlrpc_service_part *svcpt, bool hp,
@@ -1475,16 +1476,16 @@ struct ptlrpc_request *
 
 /**
  * Returns whether there are any requests currently enqueued on any of the
- * policies of service partition's \a svcpt NRS head specified by \a hp. Should
+ * policies of service partition's @svcpt NRS head specified by @hp. Should
  * be called while holding ptlrpc_service_part::scp_req_lock to get a reliable
  * result.
  *
- * \param[in] svcpt the service partition to enquire.
- * \param[in] hp    whether the regular or high-priority NRS head is to be
- *		    enquired.
+ * @svcpt:	the service partition to enquire.
+ * @hp:		whether the regular or high-priority NRS head is to be
+ *		enquired.
  *
- * \retval false the indicated NRS head has no enqueued requests.
- * \retval true	 the indicated NRS head has some enqueued requests.
+ * Return:	false the indicated NRS head has no enqueued requests.
+ *		true the indicated NRS head has some enqueued requests.
  */
 bool ptlrpc_nrs_req_pending_nolock(struct ptlrpc_service_part *svcpt, bool hp)
 {
@@ -1494,30 +1495,30 @@ bool ptlrpc_nrs_req_pending_nolock(struct ptlrpc_service_part *svcpt, bool hp)
 };
 
 /**
- * Carries out a control operation \a opc on the policy identified by the
- * human-readable \a name, on either all partitions, or only on the first
- * partition of service \a svc.
- *
- * \param[in]	  svc	 the service the policy belongs to.
- * \param[in]	  queue  whether to carry out the command on the policy which
- *			 belongs to the regular, high-priority, or both NRS
- *			 heads of service partitions of \a svc.
- * \param[in]	  name   the policy to act upon, by human-readable name
- * \param[in]	  opc	 the opcode of the operation to carry out
- * \param[in]	  single when set, the operation will only be carried out on the
- *			 NRS heads of the first service partition of \a svc.
- *			 This is useful for some policies which e.g. share
- *			 identical values on the same parameters of different
- *			 service partitions; when reading these parameters via
- *			 lprocfs, these policies may just want to obtain and
- *			 print out the values from the first service partition.
- *			 Storing these values centrally elsewhere then could be
- *			 another solution for this.
- * \param[in,out] arg	 can be used as a generic in/out buffer between control
- *			 operations and the user environment.
- *
- *\retval -ve error condition
- *\retval   0 operation was carried out successfully
+ * Carries out a control operation @opc on the policy identified by the
+ * human-readable @name, on either all partitions, or only on the first
+ * partition of service @svc.
+ *
+ * @svc:	the service the policy belongs to.
+ * @queue:	whether to carry out the command on the policy which
+ *		belongs to the regular, high-priority, or both NRS
+ *		heads of service partitions of @svc.
+ * @name:	the policy to act upon, by human-readable name
+ * @opc:	the opcode of the operation to carry out
+ * @single:	when set, the operation will only be carried out on the
+ *		NRS heads of the first service partition of @svc.
+ *		This is useful for some policies which e.g. share
+ *		identical values on the same parameters of different
+ *		service partitions; when reading these parameters via
+ *		lprocfs, these policies may just want to obtain and
+ *		print out the values from the first service partition.
+ *		Storing these values centrally elsewhere then could be
+ *		another solution for this.
+ * @arg:	can be used as a generic in/out buffer between control
+ *		operations and the user environment.
+ *
+ * Return:	-ve error condition
+ *		0 operation was carried out successfully
  */
 int ptlrpc_nrs_policy_control(const struct ptlrpc_service *svc,
 			      enum ptlrpc_nrs_queue_type queue, char *name,
@@ -1564,8 +1565,8 @@ int ptlrpc_nrs_policy_control(const struct ptlrpc_service *svc,
  * Adds all policies that ship with the ptlrpc module, to NRS core's list of
  * policies \e nrs_core.nrs_policies.
  *
- * \retval 0 all policies have been registered successfully
- * \retval -ve error
+ * Return:	0 all policies have been registered successfully
+ *		-ve error
  */
 int ptlrpc_nrs_init(void)
 {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
index ab186d8..d0eaebc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
@@ -66,10 +66,10 @@
  * ptlrpc_nrs_pol_state::NRS_POL_STATE_STARTED; allocates and initializes a
  * policy-specific private data structure.
  *
- * \param[in] policy The policy to start
+ * @policy	The policy to start
  *
- * \retval -ENOMEM OOM error
- * \retval  0	   success
+ * Return:	-ENOMEM OOM error
+ *		0 for success
  *
  * \see nrs_policy_register()
  * \see nrs_policy_ctl()
@@ -94,7 +94,7 @@ static int nrs_fifo_start(struct ptlrpc_nrs_policy *policy)
  * ptlrpc_nrs_pol_state::NRS_POL_STATE_STOPPED; deallocates the policy-specific
  * private data structure.
  *
- * \param[in] policy The policy to stop
+ * @policy	The policy to stop
  *
  * \see __nrs_policy_stop()
  */
@@ -111,18 +111,18 @@ static void nrs_fifo_stop(struct ptlrpc_nrs_policy *policy)
 /**
  * Is called for obtaining a FIFO policy resource.
  *
- * \param[in]  policy	  The policy on which the request is being asked for
- * \param[in]  nrq	  The request for which resources are being taken
- * \param[in]  parent	  Parent resource, unused in this policy
- * \param[out] resp	  Resources references are placed in this array
- * \param[in]  moving_req Signifies limited caller context; unused in this
- *			  policy
+ * @policy	The policy on which the request is being asked for
+ * @nrq		The request for which resources are being taken
+ * @parent	Parent resource, unused in this policy
+ * @resp	Resources references are placed in this array
+ * @moving_req	Signifies limited caller context; unused in this
+ *		policy
  *
- * \retval 1 The FIFO policy only has a one-level resource hierarchy, as since
- *	     it implements a simple scheduling algorithm in which request
- *	     priority is determined on the request arrival order, it does not
- *	     need to maintain a set of resources that would otherwise be used
- *	     to calculate a request's priority.
+ * Return	1 The FIFO policy only has a one-level resource hierarchy, as
+ *		since it implements a simple scheduling algorithm in which
+ *		request priority is determined on the request arrival order,
+ *		it does not need to maintain a set of resources that would
+ *		otherwise be used to calculate a request's priority.
  *
  * \see nrs_resource_get_safe()
  */
@@ -143,15 +143,15 @@ static int nrs_fifo_res_get(struct ptlrpc_nrs_policy *policy,
  * Called when getting a request from the FIFO policy for handling, or just
  * peeking; removes the request from the policy when it is to be handled.
  *
- * \param[in] policy The policy
- * \param[in] peek   When set, signifies that we just want to examine the
- *		     request, and not handle it, so the request is not removed
- *		     from the policy.
- * \param[in] force  Force the policy to return a request; unused in this
- *		     policy
+ * @policy	The policy
+ * @peek	When set, signifies that we just want to examine the
+ *		request, and not handle it, so the request is not removed
+ *		from the policy.
+ * @force	Force the policy to return a request; unused in this
+ *		policy
  *
- * \retval The request to be handled; this is the next request in the FIFO
- *	   queue
+ * Return:	The request to be handled; this is the next request in the
+ *		FIFO queue
  *
  * \see ptlrpc_nrs_req_get_nolock()
  * \see nrs_request_get()
@@ -183,13 +183,13 @@ struct ptlrpc_nrs_request *nrs_fifo_req_get(struct ptlrpc_nrs_policy *policy,
 }
 
 /**
- * Adds request \a nrq to \a policy's list of queued requests
+ * Adds request @nrq to @policy's list of queued requests
  *
- * \param[in] policy The policy
- * \param[in] nrq    The request to add
+ * @policy	The policy
+ * @nrq		The request to add
  *
- * \retval 0 success; nrs_request_enqueue() assumes this function will always
- *		      succeed
+ * Return:	0 success; nrs_request_enqueue() assumes this function will
+ *		always succeed
  */
 static int nrs_fifo_req_add(struct ptlrpc_nrs_policy *policy,
 			    struct ptlrpc_nrs_request *nrq)
@@ -208,10 +208,10 @@ static int nrs_fifo_req_add(struct ptlrpc_nrs_policy *policy,
 }
 
 /**
- * Removes request \a nrq from \a policy's list of queued requests.
+ * Removes request @nrq from @policy's list of queued requests.
  *
- * \param[in] policy The policy
- * \param[in] nrq    The request to remove
+ * @policy	The policy
+ * @nrq		The request to remove
  */
 static void nrs_fifo_req_del(struct ptlrpc_nrs_policy *policy,
 			     struct ptlrpc_nrs_request *nrq)
@@ -221,11 +221,11 @@ static void nrs_fifo_req_del(struct ptlrpc_nrs_policy *policy,
 }
 
 /**
- * Prints a debug statement right before the request \a nrq stops being
+ * Prints a debug statement right before the request @nrq stops being
  * handled.
  *
- * \param[in] policy The policy handling the request
- * \param[in] nrq    The request being handled
+ * @policy	The policy handling the request
+ * @nrq		The request being handled
  *
  * \see ptlrpc_server_finish_request()
  * \see ptlrpc_nrs_req_stop_nolock()
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index c7cc86c..75be2d7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -648,11 +648,11 @@ static inline u32 lustre_msg_buflen_v2(struct lustre_msg_v2 *m, u32 n)
 }
 
 /**
- * lustre_msg_buflen - return the length of buffer \a n in message \a m
- * \param m lustre_msg (request or reply) to look at
- * \param n message index (base 0)
+ * lustre_msg_buflen - return the length of buffer @n in message @m
+ * @m		lustre_msg (request or reply) to look at
+ * @n		message index (base 0)
  *
- * returns zero for non-existent message indices
+ * Return:	zero for non-existent message indices
  */
 u32 lustre_msg_buflen(struct lustre_msg *m, u32 n)
 {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 6dc7731..1cf0e9b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -316,16 +316,16 @@ static int import_sec_check_expire(struct obd_import *imp)
 
 /**
  * Get and validate the client side ptlrpc security facilities from
- * \a imp. There is a race condition on client reconnect when the import is
+ * @imp. There is a race condition on client reconnect when the import is
  * being destroyed while there are outstanding client bound requests. In
  * this case do not output any error messages if import secuity is not
  * found.
  *
- * \param[in] imp obd import associated with client
- * \param[out] sec client side ptlrpc security
+ * @imp		obd import associated with client
+ * @sec		client side ptlrpc security
  *
- * \retval 0 if security retrieved successfully
- * \retval -ve errno if there was a problem
+ * Return:	0 if security retrieved successfully
+ *		-ve errno if there was a problem
  */
 static int import_sec_validate_get(struct obd_import *imp,
 				   struct ptlrpc_sec **sec)
@@ -355,11 +355,11 @@ static int import_sec_validate_get(struct obd_import *imp,
 }
 
 /**
- * Given a \a req, find or allocate a appropriate context for it.
+ * Given a @req, find or allocate a appropriate context for it.
  * \pre req->rq_cli_ctx == NULL.
  *
- * \retval 0 succeed, and req->rq_cli_ctx is set.
- * \retval -ev error number, and req->rq_cli_ctx == NULL.
+ * Return:	0 succeed, and req->rq_cli_ctx is set.
+ *		-ev error number, and req->rq_cli_ctx == NULL.
  */
 int sptlrpc_req_get_ctx(struct ptlrpc_request *req)
 {
@@ -387,11 +387,11 @@ int sptlrpc_req_get_ctx(struct ptlrpc_request *req)
 }
 
 /**
- * Drop the context for \a req.
+ * Drop the context for @req.
  * \pre req->rq_cli_ctx != NULL.
  * \post req->rq_cli_ctx == NULL.
  *
- * If \a sync == 0, this function should return quickly without sleep;
+ * If @sync == 0, this function should return quickly without sleep;
  * otherwise it might trigger and wait for the whole process of sending
  * an context-destroying rpc to server.
  */
@@ -475,9 +475,9 @@ int sptlrpc_req_ctx_switch(struct ptlrpc_request *req,
 }
 
 /**
- * If current context of \a req is dead somehow, e.g. we just switched flavor
+ * If current context of @req is dead somehow, e.g. we just switched flavor
  * thus marked original contexts dead, we'll find a new context for it. if
- * no switch is needed, \a req will end up with the same context.
+ * no switch is needed, @req will end up with the same context.
  *
  * \note a request must have a context, to keep other parts of code happy.
  * In any case of failure during the switching, we must restore the old one.
@@ -589,17 +589,17 @@ void req_off_ctx_list(struct ptlrpc_request *req, struct ptlrpc_cli_ctx *ctx)
 
 /**
  * To refresh the context of \req, if it's not up-to-date.
- * \param timeout
- * - < 0: don't wait
- * - = 0: wait until success or fatal error occur
- * - > 0: timeout value (in seconds)
+ * @timeout
+ *	- < 0: don't wait
+ *	- = 0: wait until success or fatal error occur
+ *	- > 0: timeout value (in seconds)
  *
  * The status of the context could be subject to be changed by other threads
  * at any time. We allow this race, but once we return with 0, the caller will
  * suppose it's uptodated and keep using it until the owning rpc is done.
  *
- * \retval 0 only if the context is uptodated.
- * \retval -ev error number.
+ * Return:	0 only if the context is uptodated.
+ *		-ev error number.
  */
 int sptlrpc_req_refresh_ctx(struct ptlrpc_request *req, long timeout)
 {
@@ -781,7 +781,7 @@ int sptlrpc_req_refresh_ctx(struct ptlrpc_request *req, long timeout)
 }
 
 /**
- * Initialize flavor settings for \a req, according to \a opcode.
+ * Initialize flavor settings for @req, according to @opcode.
  *
  * \note this could be called in two situations:
  * - new request from ptlrpc_pre_req(), with proper @opcode
@@ -865,7 +865,7 @@ void sptlrpc_request_out_callback(struct ptlrpc_request *req)
 }
 
 /**
- * Given an import \a imp, check whether current user has a valid context
+ * Given an import @imp, check whether current user has a valid context
  * or not. We may create a new context and try to refresh it, and try
  * repeatedly try in case of non-fatal errors. Return 0 means success.
  */
@@ -917,7 +917,7 @@ int sptlrpc_import_check_ctx(struct obd_import *imp)
 
 /**
  * Used by ptlrpc client, to perform the pre-defined security transformation
- * upon the request message of \a req. After this function called,
+ * upon the request message of @req. After this function called,
  * req->rq_reqmsg is still accessible as clear text.
  */
 int sptlrpc_cli_wrap_request(struct ptlrpc_request *req)
@@ -1024,7 +1024,7 @@ static int do_cli_unwrap_reply(struct ptlrpc_request *req)
 
 /**
  * Used by ptlrpc client, to perform security transformation upon the reply
- * message of \a req. After return successfully, req->rq_repmsg points to
+ * message of @req. After return successfully, req->rq_repmsg points to
  * the reply message in clear text.
  *
  * \pre the reply buffer should have been un-posted from LNet, so nothing is
@@ -1057,7 +1057,7 @@ int sptlrpc_cli_unwrap_reply(struct ptlrpc_request *req)
 
 /**
  * Used by ptlrpc client, to perform security transformation upon the early
- * reply message of \a req. We expect the rq_reply_off is 0, and
+ * reply message of @req. We expect the rq_reply_off is 0, and
  * rq_nob_received is the early reply size.
  *
  * Because the receive buffer might be still posted, the reply data might be
@@ -1065,10 +1065,11 @@ int sptlrpc_cli_unwrap_reply(struct ptlrpc_request *req)
  * we allocate a separate ptlrpc_request and reply buffer for early reply
  * processing.
  *
- * \retval 0 success, \a req_ret is filled with a duplicated ptlrpc_request.
- * Later the caller must call sptlrpc_cli_finish_early_reply() on the returned
- * \a *req_ret to release it.
- * \retval -ev error number, and \a req_ret will not be set.
+ * Return:	0 success, @req_ret is filled with a duplicated ptlrpc_request.
+ *		Later the caller must call sptlrpc_cli_finish_early_reply()
+ *		on the returned @*req_ret to release it.
+ *
+ *		-ev error number, and @req_ret will not be set.
  */
 int sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
 				   struct ptlrpc_request **req_ret)
@@ -1162,9 +1163,9 @@ int sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
 }
 
 /**
- * Used by ptlrpc client, to release a processed early reply \a early_req.
+ * Used by ptlrpc client, to release a processed early reply @early_req.
  *
- * \pre \a early_req was obtained from calling sptlrpc_cli_unwrap_early_reply().
+ * \pre @early_req was obtained from calling sptlrpc_cli_unwrap_early_reply().
  */
 void sptlrpc_cli_finish_early_reply(struct ptlrpc_request *early_req)
 {
@@ -1369,11 +1370,11 @@ static void sptlrpc_import_sec_adapt_inplace(struct obd_import *imp,
 }
 
 /**
- * To get an appropriate ptlrpc_sec for the \a imp, according to the current
+ * To get an appropriate ptlrpc_sec for the @imp, according to the current
  * configuration. Upon called, imp->imp_sec may or may not be NULL.
  *
- *  - regular import: \a svc_ctx should be NULL and \a flvr is ignored;
- *  - reverse import: \a svc_ctx and \a flvr are obtained from incoming request.
+ *  - regular import: @svc_ctx should be NULL and @flvr is ignored;
+ *  - reverse import: @svc_ctx and @flvr are obtained from incoming request.
  */
 int sptlrpc_import_sec_adapt(struct obd_import *imp,
 			     struct ptlrpc_svc_ctx *svc_ctx,
@@ -1506,8 +1507,8 @@ void sptlrpc_import_flush_all_ctx(struct obd_import *imp)
 EXPORT_SYMBOL(sptlrpc_import_flush_all_ctx);
 
 /**
- * Used by ptlrpc client to allocate request buffer of \a req. Upon return
- * successfully, req->rq_reqmsg points to a buffer with size \a msgsize.
+ * Used by ptlrpc client to allocate request buffer of @req. Upon return
+ * successfully, req->rq_reqmsg points to a buffer with size @msgsize.
  */
 int sptlrpc_cli_alloc_reqbuf(struct ptlrpc_request *req, int msgsize)
 {
@@ -1536,7 +1537,7 @@ int sptlrpc_cli_alloc_reqbuf(struct ptlrpc_request *req, int msgsize)
 }
 
 /**
- * Used by ptlrpc client to free request buffer of \a req. After this
+ * Used by ptlrpc client to free request buffer of @req. After this
  * req->rq_reqmsg is set to NULL and should not be accessed anymore.
  */
 void sptlrpc_cli_free_reqbuf(struct ptlrpc_request *req)
@@ -1602,8 +1603,8 @@ void _sptlrpc_enlarge_msg_inplace(struct lustre_msg *msg,
 EXPORT_SYMBOL(_sptlrpc_enlarge_msg_inplace);
 
 /**
- * Used by ptlrpc client to enlarge the \a segment of request message pointed
- * by req->rq_reqmsg to size \a newsize, all previously filled-in data will be
+ * Used by ptlrpc client to enlarge the @segment of request message pointed
+ * by req->rq_reqmsg to size @newsize, all previously filled-in data will be
  * preserved after the enlargement. this must be called after original request
  * buffer being allocated.
  *
@@ -1635,7 +1636,7 @@ int sptlrpc_cli_enlarge_reqbuf(struct ptlrpc_request *req,
 EXPORT_SYMBOL(sptlrpc_cli_enlarge_reqbuf);
 
 /**
- * Used by ptlrpc client to allocate reply buffer of \a req.
+ * Used by ptlrpc client to allocate reply buffer of @req.
  *
  * \note After this, req->rq_repmsg is still not accessible.
  */
@@ -1656,7 +1657,7 @@ int sptlrpc_cli_alloc_repbuf(struct ptlrpc_request *req, int msgsize)
 }
 
 /**
- * Used by ptlrpc client to free reply buffer of \a req. After this
+ * Used by ptlrpc client to free reply buffer of @req. After this
  * req->rq_repmsg is set to NULL and should not be accessed anymore.
  */
 void sptlrpc_cli_free_repbuf(struct ptlrpc_request *req)
@@ -1712,8 +1713,8 @@ static int flavor_allowed(struct sptlrpc_flavor *exp,
 #define EXP_FLVR_UPDATE_EXPIRE      (OBD_TIMEOUT_DEFAULT + 10)
 
 /**
- * Given an export \a exp, check whether the flavor of incoming \a req
- * is allowed by the export \a exp. Main logic is about taking care of
+ * Given an export @exp, check whether the flavor of incoming @req
+ * is allowed by the export @exp. Main logic is about taking care of
  * changing configurations. Return 0 means success.
  */
 int sptlrpc_target_export_check(struct obd_export *exp,
@@ -1943,14 +1944,17 @@ static int sptlrpc_svc_check_from(struct ptlrpc_request *req, int svc_rc)
 
 /**
  * Used by ptlrpc server, to perform transformation upon request message of
- * incoming \a req. This must be the first thing to do with a incoming
+ * incoming @req. This must be the first thing to do with a incoming
  * request in ptlrpc layer.
  *
- * \retval SECSVC_OK success, and req->rq_reqmsg point to request message in
- * clear text, size is req->rq_reqlen; also req->rq_svc_ctx is set.
- * \retval SECSVC_COMPLETE success, the request has been fully processed, and
- * reply message has been prepared.
- * \retval SECSVC_DROP failed, this request should be dropped.
+ * Return:	SECSVC_OK success, and req->rq_reqmsg point to request message
+ *		in clear text, size is req->rq_reqlen; also req->rq_svc_ctx is
+ *		set.
+ *
+ *		SECSVC_COMPLETE success, the request has been fully processed,
+ *		and reply message has been prepared.
+ *
+ *		SECSVC_DROP failed, this request should be dropped.
  */
 int sptlrpc_svc_unwrap_request(struct ptlrpc_request *req)
 {
@@ -2007,9 +2011,9 @@ int sptlrpc_svc_unwrap_request(struct ptlrpc_request *req)
 }
 
 /**
- * Used by ptlrpc server, to allocate reply buffer for \a req. If succeed,
+ * Used by ptlrpc server, to allocate reply buffer for @req. If succeed,
  * req->rq_reply_state is set, and req->rq_reply_state->rs_msg point to
- * a buffer of \a msglen size.
+ * a buffer of @msglen size.
  */
 int sptlrpc_svc_alloc_rs(struct ptlrpc_request *req, int msglen)
 {
@@ -2127,7 +2131,7 @@ void sptlrpc_svc_ctx_decref(struct ptlrpc_request *req)
  ****************************************/
 
 /**
- * Perform transformation upon bulk data pointed by \a desc. This is called
+ * Perform transformation upon bulk data pointed by @desc. This is called
  * before transforming the request message.
  */
 int sptlrpc_cli_wrap_bulk(struct ptlrpc_request *req,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 54130ae..35ebd56 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -568,7 +568,7 @@ static int sptlrpc_conf_merge_rule(struct sptlrpc_conf *conf,
 }
 
 /**
- * process one LCFG_SPTLRPC_CONF record. if \a conf is NULL, we
+ * process one LCFG_SPTLRPC_CONF record. if @conf is NULL, we
  * find one through the target name in the record inside conf_lock;
  * otherwise means caller already hold conf_lock.
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index eda921c..5a7e9fa 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -877,7 +877,7 @@ static void ptlrpc_server_finish_active_request(
 }
 
 /**
- * Sanity check request \a req.
+ * Sanity check request @req.
  * Return 0 if all is ok, error code otherwise.
  */
 static int ptlrpc_check_req(struct ptlrpc_request *req)
@@ -2375,7 +2375,7 @@ static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
 }
 
 /**
- * Stops all threads of a particular service \a svc
+ * Stops all threads of a particular service @svc
  */
 static void ptlrpc_stop_all_threads(struct ptlrpc_service *svc)
 {
-- 
1.8.3.1
