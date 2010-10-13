From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Wed, 13 Oct 2010 00:42:34 -0500
Subject: [Lustre-devel] Query to understand the Lustre request/reply
 message
In-Reply-To: <AANLkTi=8OuaC20Q5avckBL4LKZ16aYgAJneSq_Wg-sj0@mail.gmail.com>
References: <AANLkTikzzrewMtTrpwkWLCJ3soL+HerfSBU6G3KT6O8j@mail.gmail.com>
	<5A70DB00-9F04-47AF-A31C-01ADA3B87D5E@clusterstor.com>
	<AANLkTinvwRnLHaqv2-tpKpm6R2fBP51OtGR1fQCEa3KP@mail.gmail.com>
	<17D943BA-FF0B-467F-8413-CB8C8184858C@clusterstor.com>
	<AANLkTi==UJQRO+5iBKpUNfFVLWSHz4cumBApbjCz5xBe@mail.gmail.com>
	<72D9946A-6452-4BC3-8C18-D2CA607D82DC@clusterstor.com>
	<AANLkTi=8OuaC20Q5avckBL4LKZ16aYgAJneSq_Wg-sj0@mail.gmail.com>
Message-ID: <20101013054233.GC1635@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 13, 2010 at 12:35:13AM -0400, Vilobh Meshram wrote:
> Thanks a lot Alexey for the reply.The information will be really useful.
> 
> Since I am using 1.8.1.1 for my research project I will have to rely on the
> old API.Since in the source tree prior to 2.0 we do not have a
> mdt/mdt_handler.c and layout.c files will have to work with the low level
> buffer management structures(ptlrpc_request,lustre_msg_v2,etc).Do you know a
> place or a function which make use of the old API which I can use as a
> reference to write the RPC for my task.

The new API is _much_ easier to use than the old API.

To add an RPC you must:

 - decide what it looks like

   Every PTLRPC has an opcode and one or more "buffers", with each
   buffer containing a C struct, a string, whatever.  If a buffer
   contains a C struct, then it has to be fixed sized.  The first buffer
   is struct ptlrpc_body.

   A single RPC opcode can denote multiple different layouts, depending
   on contents of various buffers.  A single layout is called a
   "layout".  See below.

 - add any struct, enum, and other C types you need to lustre_idl.h

   You must make sure to use the base types we use in lustre_idl.h, such
   as __u64.

 - create swabber functions for your data, if necessary

 - add handlers for the new RPC to mdt_handler.c (for the MDS) or
   ost_handler.c (for the OST), and so on

   The handlers are responsible for knowing which buffers contain what,
   and for swabbing them.  You have to make sure that you don't swab a
   buffer more than once.

The new API allows you define formats quite nicely, and it takes care of
calling swabbers and ensuring that no buffer is swabbed more than once.
The formats are defined in lustre/ptlrpc/layout.c and look like this:

struct req_format RQF_MDS_SYNC =
        DEFINE_REQ_FMT0("MDS_SYNC", mdt_body_capa, mdt_body_only);
...
static const struct req_msg_field *mdt_body_capa[] = {
        &RMF_PTLRPC_BODY,
        &RMF_MDT_BODY,
        &RMF_CAPA1
};
static const struct req_msg_field *mdt_body_only[] = {
        &RMF_PTLRPC_BODY,
        &RMF_MDT_BODY
};
...

An RPC consists of a request and reply, with their formats given in the
DEFINE_REQ_FMT0() macro (there's other macros).  Each message format
defines a layout of buffers or, as we call them now, "fields", and each
field has a format definition as well, such as:

struct req_msg_field RMF_PTLRPC_BODY =
        DEFINE_MSGF("ptlrpc_body", 0,
                    sizeof(struct ptlrpc_body), lustre_swab_ptlrpc_body, NULL);

for a struct buffer.  Other types of RMFs are possible (e.g., strings);
see layout.c.

So an MDS_SYNC RPC consists of a three-field (buffer) request and
two-field reply.  The request's fields are: PTLRPC_BODY, MDT_BODY, and
CAPA1.  The reply's fields are: PTLRPC_BODY and MDT_BODY.  PTLRPC_BODY
is a fixed-sized field containing a C structure, and that the swabber
for this field is lustre_swab_ptlrpc_body().  And so on.

If you look at Lustre 2.0's mdt_handler.c and ost_handler.c you'll find
that one of the first things done is to initialize a "capsule", and that
the expected message format of a request is decided based on its opcode.
That is, the mapping of opcode to RQF is not given by some array, but
decided as we go.  Indeed, the RQF of a capsule can be changed
mid-stream, with some constraints.

So, with the new API you:

 - add C types to lustre_idl.h for on-the-wire data
 - add any swabbers to lustre/ptlrpc/pack_generic.c (declare them in
   lustre_idl.h)
 - add RQFs and, possibly, RMFs to layout.c
 - declare the RQFs/RMFs in lustre/include/lustre_req_layout.h

 - on the server-side:
    - Modify the relevant handler to add an arm to the existing switch
      on the request's opcode, call req_capsule_set() to set the
      capsule's format, then call a function that will use
      req_capsule_*get*() to get at the fields (buffers) (both, request
      and reply buffers) to read from (request) or write to (reply).

 - on the client-side:
    - You'll do something very similar, except that there's no handler
      function -- the pattern is less consistent, so you'll have to read
      mdc*.c and so on to get a flavor for this...  Typically you'll
      allocate a request using ptlrpc_request_alloc_pack(), fill in its
      fields (again, using req_capsule_client_get() and friends), then
      you'll send it using, for example, ptlrpc_queue_wait().

      Take a good look at mdc_request.c in 2.0 to get a better idea of
      how to build client stubs for your new RPCs.

I haven't described the wirecheck part -- I can do that later, once
you've made enough progress.  (We have a wirecheck/wiretest program pair
to check that only backwards interoperable changes are made to
lustre_idl.h.)

I hope that helps.  Yes, it'd be nice to have something closer to an
actual IDL.  The RQF/RMF/wirecheck/wiretest stuff could be extended to:

 - auto-generate swabbers from lustre_idl.h structs
 - provide a default opcode->RQF mapping
 - provide more static type safety (by having req_capsule_*get() be
   macros that cast the buffer address to the right type)
 - auto-generate simple request constructors (that take pointers to
   values of an RQF's correct request field C types)

Compared to the old thing, the new API is much closer to an IDL.  It's a
good thing.  I strongly recommend that you use it,

Nico
-- 
