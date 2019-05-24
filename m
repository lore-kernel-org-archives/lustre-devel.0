From: Kristen Webb <kwebb@teradactyl.com>
Date: Fri, 24 May 2019 12:38:42 -0600
Subject: [lustre-devel] odd behavior on lustre client listxattr for
 directories
Message-ID: <CANPK4HZwHXaMsJA-wz4XARmjFFGbkGsZ_9G6U4Sw_5Bkey=NEg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Our backup software found an unusual result when listing xattrs for
directories.

On the client side, when requesting the buffer size for the list:
listxattr("foo", NULL, 0)               = 36 (bytes)

But when the list is actually read, it comes up short:
listxattr("foo", "trusted.link\0trusted.lma\0", 256) = 25 (bytes)

On the server side, on an ldiskfs mount, the results are more consistent.
listxattr("foo", NULL, 0)               = 25
listxattr("foo", "trusted.lma\0trusted.link\0", 256) = 25

NOTE: we run this code on lot's of FS's and have not seen this anywhere
else, yet.
According to the docs for listxattr, it is possible to get different
results on active objects
but that is not the case here.

I'm reporting this because, while it does not seem to be a problem for us
now,
I'd like to understand the "why"/ . Also, this seems like something that
may cause
problems with more complex directory xatts's which I have not tested yet.

I plan to deep-dive on this one to get more information, unless someone has
a reasonable explanation as to why the inconsistency exists and that is is
"ok".

If this is something that should be reported as a bug, just let me know and
I'll submit
one with as much detail as I can get.

Thanks!
Kris
-- 
This message is NOT encrypted
--------------------------------
Mr. Kristen J. Webb
Chief Technology Officer
Teradactyl LLC.
2450 Baylor Dr. S.E.
Albuquerque, New Mexico 87106
Phone: 1-505-338-6000
Email: kwebb at teradactyl.com
Web: http://www.teradactyl.com



Providers of Scalable Backup Solutions
   for Unique Data Environments

--------------------------------
NOTICE TO RECIPIENTS: Any information contained in or attached to this
message is intended solely for the use of the intended recipient(s). If
you are not the intended recipient of this transmittal, you are hereby
notified that you received this transmittal in error, and we request
that you please delete and destroy all copies and attachments in your
possession, notify the sender that you have received this communication
in error, and note that any review or dissemination of, or the taking of
any action in reliance on, this communication is expressly prohibited.


Regular internet e-mail transmission cannot be guaranteed to be secure
or error-free. Therefore, we do not represent that this information is
complete or accurate, and it should not be relied upon as such. If you
prefer to communicate with Teradactyl LLC. using secure (i.e., encrypted
and/or digitally signed) e-mail transmission, please notify the sender.
Otherwise, you will be deemed to have consented to communicate with
Teradactyl via regular internet e-mail transmission. Please note that
Teradactyl reserves the right to intercept, monitor, and retain all
e-mail messages (including secure e-mail messages) sent to or from its
systems as permitted by applicable law
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190524/86df6a46/attachment.html>
