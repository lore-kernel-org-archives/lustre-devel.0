From: Peter J. Braam <peter.braam@gmail.com>
Date: Fri, 9 Jan 2009 12:21:39 -0700
Subject: [Lustre-devel] global epochs
Message-ID: <7bb097cc0901091121r427623e7wf89a19658b7f99ac@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi -

Nikita's discussion is excellent.  I read through and thought about this a
bit over the vacation.   Two important issues remain unclear in my mind:

1. the write back cache mode is not good for scaling (eg. for many nodes
creating files in one directory); for that intents save a lot of RPCs.  The
recovery correctness discussion doesn't cover this, and I've found this to
introduce new opportunities for cascading aborts, that are not managed by
client locks.  I think it would be most beautiful if the epoch protocol was
somewhat enhanced to also handle intent style processing (where there is
dependence on RPC responses).  I think some of the response data (FIDs
notably) is not protected by locks (as it is immutable).

2. I'm nervous about broadcasting epoch messages to, for example, 1 million
clients (I think that is the current target).  You'd want a tree model for
this, and do careful calculations how often failures will occur and what
their impact is on recovery time.

Peter
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090109/1c387527/attachment.htm>
