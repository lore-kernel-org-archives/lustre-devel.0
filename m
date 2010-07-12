From: Yuriy Umanets <yuriy.umanets@clusterstor.com>
Date: Mon, 12 Jul 2010 13:24:45 +0300
Subject: [Lustre-devel] is lustre 2.0.x from repo is broken?
Message-ID: <AANLkTimsvGSd0kJINLjqSWX9fvZS5nXJ1ZSYt-icG7_Z@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

hi all,

Recently I tried 2.0.x from git repo and basically found it quite broken.

Issues:

1. Built lustre with default options does not work due to constant
permission denied and quota errors in dmesg despite messages that quota is
disabled;

2. configure --disable-quota - does not build at all;

3. if one tries to fix build issues from (2) and start lustre again, it does
not work either due to quota errors :) It seemed to be not completely
disabled and keeps sending quota_ctl to server which does not handle it.

Thanks.

-- 
umka
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100712/2fc2cada/attachment.htm>
