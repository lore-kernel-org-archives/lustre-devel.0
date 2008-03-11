From: pravin shelar <Pravin.Shelar@Sun.COM>
Date: Tue, 11 Mar 2008 16:37:24 +0530
Subject: [Lustre-devel] lu_dirent changes for zfs based mds
Message-ID: <47D667EC.4050107@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi All,
        Lustre based on zfs need a change readdir page wire protocol.

lu_dirent->lde_hash maintains iterator cookie. with zfs - zap cursor API 
we have 64bit cookie (ref. zap_cursor_serialize()). So we need to change 
this lde_hash to 64 bit.
This changes layout of readdir pages which is transmitted on wire, so we 
need to merge it into head asap.

I have posted patch on bugzilla : 
https://bugzilla.lustre.org/attachment.cgi?id=15817&action=edit

plz post your comment there.

Thanks,
Pravin.
