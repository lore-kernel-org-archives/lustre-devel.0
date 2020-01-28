From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Tue, 28 Jan 2020 20:37:34 +0100
Subject: [lustre-devel] Gerrit option - build only one backend
Message-ID: <1580240254.12827.0@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Dear all,

I am wondering why the Gerrit option "fstype=zfs" in my commit does not 
influence the build process - both targets, ldiskfs and zfs are built:

checking whether to build ldiskfs... yes
checking whether to enable zfs... yes

The option seems to affect only the following tests. Is this behavior 
intended?
Is there any option to build and test only one backend?

Regards
Anna

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200128/973697a0/attachment.html>
