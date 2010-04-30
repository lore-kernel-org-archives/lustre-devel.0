From: John Hammond <jhammond@ices.utexas.edu>
Date: Fri, 30 Apr 2010 08:00:46 -0500
Subject: [Lustre-devel] question about ldlm_server_glimpse_ast
In-Reply-To: <w2je5fcbd181004291959wb9790719ic4dc3a2bd9b64eb@mail.gmail.com>
References: <w2je5fcbd181004291959wb9790719ic4dc3a2bd9b64eb@mail.gmail.com>
Message-ID: <4BDAD47E.401@ices.utexas.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 04/29/2010 09:59 PM, Jeremy Filizetti wrote:
> In our Lustre WAN environment a few times we've had a link drop for an
> extended period of time which causes problems on systems accessing data
> in the same directory as the remote system that becomes unavailable.
> Our OSS's seem to be stuck in a loop of ptlrpc_queue_wait called from
> ldlm_server_glimpse_ast.  The remote site is accesed through an LNet
> router which is still available.  However the OSS resends requests every
> 7 seconds successfully to the router but squbsequently with timeout
> which causes it to loop in ptlrpc_queue_wait.
>
> Looking over the ldlm_server_blocking_ast and ldlm_server_completion_ast
> functions I see they set rq_no_resend = 1, but ldlm_server_glimpse_ast
> does not.  I'm not familiar with the locking in Lustre, is there a
> reason that ldlm_server_glimpse_ast doesn't set rq_no_resend = 1?  This
> would get rid of the loop ptlrpc_queue_wait is stuck in until the client
> comes back, but I'm not sure if it would have other unexpected consequences.

We have the same issue at TACC, and there is a bugzilla entry:

https://bugzilla.lustre.org/show_bug.cgi?id=21937

I tested a patch which set rq_no_resend = 0 for glimpses, and found that 
clients only had about 6 seconds to reply before eviction.  Since 
eviction creates the possibility for data loss, a 6 second timeout was 
deemed too short for production.  (With the patch applied, it was easy 
for me to create cases where data was indeed lost.)  I was also able to 
observe some file consistency issues which lasted for a few seconds 
after eviction, as well as a failure of the file operations on the 
evicted client to return an error.  See also:

https://bugzilla.lustre.org/show_bug.cgi?id=22360

-John

-- 
John L. Hammond, Ph.D.
ICES, The University of Texas at Austin
jhammond at ices.utexas.edu
(512) 471-9304
