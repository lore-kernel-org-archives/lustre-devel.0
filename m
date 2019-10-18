From: Charlie Olmstead <colmstead@ddn.com>
Date: Fri, 18 Oct 2019 19:00:23 +0000
Subject: [lustre-devel] New optional security review sessions
Message-ID: <6B32EA46-7D69-422A-925D-73D3A474DC17@ddn.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

3 new optional test sessions have been added to lustre-reviews:

  *   review-dne-selinux: Runs sanity, recovery-small and sanity-selinux with selinux enabled on the clients
  *   review-dne-ssk: Runs sanity, recovery-small and sanity-sec with SHARED_KEY set to true
  *   review-dne-selinux-ssk: Runs sanity, recovery-small, sanity-selinux and sanity-sec with selinux enabled on the clients and SHARED_KEY set to true

These sessions will not impact the score sent by Maloo and they?ll only run if test nodes are immediately available.

Charlie Olmstead
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20191018/93610cf4/attachment.html>
