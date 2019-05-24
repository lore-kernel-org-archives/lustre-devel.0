From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 24 May 2019 20:05:40 +0000
Subject: [lustre-devel] odd behavior on lustre client listxattr for
 directories
In-Reply-To: <CANPK4HZwHXaMsJA-wz4XARmjFFGbkGsZ_9G6U4Sw_5Bkey=NEg@mail.gmail.com>
References: <CANPK4HZwHXaMsJA-wz4XARmjFFGbkGsZ_9G6U4Sw_5Bkey=NEg@mail.gmail.com>
Message-ID: <22AB58D4-19E7-4F18-B142-33E7DDBBB09F@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 24, 2019, at 12:38, Kristen Webb <kwebb@teradactyl.com> wrote:
> 
> Our backup software found an unusual result when listing xattrs for directories.
> 
> On the client side, when requesting the buffer size for the list:
> listxattr("foo", NULL, 0)               = 36 (bytes)
> 
> But when the list is actually read, it comes up short:
> listxattr("foo", "trusted.link\0trusted.lma\0", 256) = 25 (bytes)
> 
> On the server side, on an ldiskfs mount, the results are more consistent.
> listxattr("foo", NULL, 0)               = 25
> listxattr("foo", "trusted.lma\0trusted.link\0", 256) = 25

It seems like a bug in the following piece of code:

ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
{

        /*
         * If we're being called to get the size of the xattr list
         * (size == 0) then just assume that a lustre.lov xattr
         * exists.
         */
        if (!size)
                RETURN(rc + sizeof(XATTR_LUSTRE_LOV));

This is true for regular files, but not directories (or at least not all
of them).  As a starting point, something like the following should fix
the immediate problem you see:

        if (!size) {
                rc += S_ISREG(inode->i_mode) ? sizeof(XATTR_LUSTRE_LOV) : 0;
                RETURN(rc);
        }

though it is still not wholly correct.  We should go through xattr_type_filter()
in all cases, so that e.g. it filters out trusted.* xattrs for regular users.
I guess it depends on whether one considers the returned buffer size "large
enough to hold all xattrs", or "exactly the size of the returned xattrs".  The
latter is definitely more forgiving and could be fixed immediately in your code,
rather than depending on a fix to propagate into all of the installed Lustre
systems you are running on.

Could you please file a ticket at https://jira.whamcloud.com/ so this is tracked and fixed (you can just copy-paste the text above).  Even if you make a change in your code to ignore this discrepancy, it would be good to also fix it in Lustre so that other tools accessing the xattrs don't get heartburn.

> NOTE: we run this code on lot's of FS's and have not seen this anywhere else, yet.
> According to the docs for listxattr, it is possible to get different results on active objects
> but that is not the case here.
> 
> I'm reporting this because, while it does not seem to be a problem for us now,
> I'd like to understand the "why"/ . Also, this seems like something that may cause
> problems with more complex directory xatts's which I have not tested yet.
> 
> I plan to deep-dive on this one to get more information, unless someone has
> a reasonable explanation as to why the inconsistency exists and that is is "ok". 
> 
> If this is something that should be reported as a bug, just let me know and I'll submit
> one with as much detail as I can get.
> 
> Thanks!
> Kris
> -- 
> This message is NOT encrypted 
> -------------------------------- 
> Mr. Kristen J. Webb 
> Chief Technology Officer 
> Teradactyl LLC. 
> 2450 Baylor Dr. S.E. 
> Albuquerque, New Mexico 87106 
> Phone: 1-505-338-6000 
> Email: kwebb at teradactyl.com 
> Web: http://www.teradactyl.com 
> 
> 
> 
> Providers of Scalable Backup Solutions 
>    for Unique Data Environments 
> 
> -------------------------------- 
> NOTICE TO RECIPIENTS: Any information contained in or attached to this 
> message is intended solely for the use of the intended recipient(s). If 
> you are not the intended recipient of this transmittal, you are hereby 
> notified that you received this transmittal in error, and we request 
> that you please delete and destroy all copies and attachments in your 
> possession, notify the sender that you have received this communication 
> in error, and note that any review or dissemination of, or the taking of 
> any action in reliance on, this communication is expressly prohibited. 
> 
> 
> Regular internet e-mail transmission cannot be guaranteed to be secure 
> or error-free. Therefore, we do not represent that this information is 
> complete or accurate, and it should not be relied upon as such. If you 
> prefer to communicate with Teradactyl LLC. using secure (i.e., encrypted 
> and/or digitally signed) e-mail transmission, please notify the sender. 
> Otherwise, you will be deemed to have consented to communicate with 
> Teradactyl via regular internet e-mail transmission. Please note that 
> Teradactyl reserves the right to intercept, monitor, and retain all 
> e-mail messages (including secure e-mail messages) sent to or from its 
> systems as permitted by applicable law
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud
