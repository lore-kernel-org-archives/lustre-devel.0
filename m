From: Benjamin Bennett <ben@psc.edu>
Date: Fri, 20 Jun 2008 00:16:51 -0400
Subject: [Lustre-devel] GSS cross-realm broken in lsvcgssd
Message-ID: <485B2F33.2020608@psc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

lsvcgssd from the current HEAD refuses all remote-realm principals, the 
culprit is get_ids() in lustre/utils/gss/svcgssd_proc.c

In the previous revision (1.4):
   MDS accepts remote principals with mapping to local user.
   OSS accepts remote "lustre_root at SOMEREALM" principals.
   Any other remote principals are logged as unmapped and failed.

In the current revision (1.5, since Jan):
   MDS fails all remote principals.
   OSS fails all remote principals.
   Unmapped remote principals are logged, mapped are not.

The attached patch (against 1.5):
   Restores previous MDS behavior of accepting remote principals with 
mapping to local user.
   Modifies OSS behavior to accept remote "lustre_root at SOMEREALM" and 
"lustre_root/hostname at SOMEREALM" principals.
   Fixes logging errors in get_ids().


Notice of any problems with this patch, or other suggestions, are 
appreciated.


thanks,

--ben
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lsvcgssd-xrealm.patch
Type: text/x-patch
Size: 3199 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080620/3fd48709/attachment.bin>
