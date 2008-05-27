From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 27 May 2008 18:44:18 +0800
Subject: [Lustre-devel] Commit on share
Message-ID: <C4620704.5499%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This HLD is definitely not ready at all.  It is very short, lacks
interaction diagrams and the arguments made are not sufficiently detailed.

* the second sentence is not right.  Commit should happen before
un-committed data coming from a client is shared with a 2nd client.
* Is COS dependent on VBR ? no it is not, and can equally apply to normal
recovery 
* Section 3.2 is wrong: the recovery process will not fail with gaps in the
sequence when there is VBR.  It only fails if there are gaps in the
versions, and this is rare.
* 3.3 parallel creations in one directory are protected with different,
independent lock resources.  Isn?t that sufficient to allow parallel
operations with COS?
* 3.6 provide a detailed explanation please
* GC thread is wrong mechanism this is what we have commit callbacks for
* Why not use the DLM, then we can simply keep the client waiting ? the
mechanism already exists for repack; I am not convinced at all by the
reasoning that rep-ack is so different ? no real facts are quoted
* It is left completely without explanation how the hash table (which I
think we don?t need/want) is used

Regards,

Peter
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080527/11a2ef8f/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: commit-on-sharing-simple-tracking-hld.pdf
Type: application/octet-stream
Size: 63433 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080527/11a2ef8f/attachment.obj>
