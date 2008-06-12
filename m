From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 11 Jun 2008 21:38:46 -0600
Subject: [Lustre-devel] COS
Message-ID: <C475F666.5B11%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>> A question: the definition still counts parallel file creation as
>> dependent operation but actually the operations can be replayed
>> independently. Is the definition OK for CoS?

I don?t care for the definition that was given, but parallel file creation
in one directory is definitely worth discussing.

Intuitively (in the absence of a definition) only the server is making
multiple updates to the directory content and mtime, and these are not
shared with the clients.  As a result, there are no dependencies for the
part of the transaction that updates the directory as long as clients do not
try to gain access with stat or readdir to the new entries in the directory.

To challenge you a little further ? might it be possible to get a definition
of dependencies that covers cases correctly and coincides with the DLM
usage?  (Notice that the book I pointed you was called ?concurrency
control...?.)


From Alex:

it seems in recent ping-pong about version (what 1.8/2.0 is based on,
features,
etc) we forgot about busy inode issue with VBR. originally we planned to
build
VBR with fids as fid is unique ?

thanks, Alex

-------------------
I?m extremely glad you are catching this.  Let me try to only guide the
design process and not discuss how we might solve this (you are much better
at that).


In a good design, issues like this are traceable.  If they are not, we have
found a defect in the design.  Mike, Zam ? how do busy inodes play into use
cases and requirements shown in the design document?  To take things one
step further, please define a busy inode (and I?m having this feeling that
once you define this, you will immediately add a new requirement to the
design document).

Peter

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080611/8e214a89/attachment.htm>
