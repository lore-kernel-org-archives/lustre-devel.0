From: Jeremy Filizetti <jeremy.filizetti@gmail.com>
Date: Thu, 28 Oct 2010 23:07:46 -0400
Subject: [Lustre-devel] releasing BKL in lustre_fill_super
Message-ID: <AANLkTinN5dP6KOqE3ZEo2ZKWxo_GJesAN5dvPFyVXc7c@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I've seen a lot of issues with mounting all of our OSTs on an OSS taking an
excessive amount of time.  Most of the individual OST mount time was related
to bug 18456, but we still see mount times take minutes per OST with the
relevant patches.  At mount time the llog does a small write which ends up
scanning nearly our entire 7+ TB OSTs to find the desired block and complete
the write. To reduce startup time mounting multiple OSTs simultaneously
would help, but during that process it looks like the code path is still
holding the big kernel lock from the mount system call.  During that time
all other mount commands are in an uninterruptible sleep (D state).  Based
on the discussions from bug 23790 it doesn't appear that Lustre relies on
the BKL so would it be reasonable to call unlock_kernel in lustre_fill_super
or at least before lustre_start_mgc and lock it again before the return so
multiple OSTs could be mounting at the same time?  I think the same thing
would apply to unmounting but I haven't looked at the code path there.

Jeremy
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101028/c72f73a7/attachment.htm>
