From: Michael Bloom <michael.bloom@trd2inc.com>
Date: Sun, 15 Sep 2013 10:51:34 -0400
Subject: [Lustre-devel] Lustre 2.4 MDT: LustreError: Communicating with
 0@lo: operation mds_connect failed with -11
Message-ID: <CAE8vHZ=q-uSo74vVCR-qOjSgMJsd1sJ2M4EtUk2-5WvDudxrkA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I'm a Lustre newbie who just joined this list.  I'd appreciate any help on
the following Lustre 2.4 issue I'm running into:

Every time I mount the MDT, the mount appears to succeed but
/var/log/messages contains the message: "LustreError: 11-0:
lustre-MDT0000-lwp-MDT0000: Communicating with 0 at lo, operation mds_connect
failed with -11".  The MDT uses 4 local drives in a RAID10 configuration.
Each OSS has their own RAID10  of 36 drives each.  The OSS's mount
correctly without any errors.


I've seen this error mentioned in countless Google searches.  One obscure
reply suggested this was a problem fixed in 2.5.  All other references were
with respect to pre-2.4 releases where the message indicated there was
probably an error somewhere in the connection's configuration.

Is this a real error?  I see the code that probably generates this
in client.c.  In abbreviated form, the code is:
LCONSOLE_ERROR_MSG(0x11, "%s Communicating with %s") in
ptlrpc_check_status().  There's another in mdt_obd_connect() where -EAGAIN
[set to -11 in lustre_errno.h) is returned if the stack isn't ready to
handle requests as indicated by the return code from obd_health_check().

My environment is this:
MDT, OSS0, and OSS1 are all on 3 separate nodes running Centos 6.4 and
connected by Infiniband Mellanox HBAs.  Running this in a VM with the MDT
and a single OSS on one node in a VM using TCP did not exhibit this problem.

Thanks in advance for any help you can provide.

Michael
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20130915/ee3c8f86/attachment.htm>
