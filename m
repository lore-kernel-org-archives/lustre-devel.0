From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Fri, 08 Feb 2008 18:31:47 +0300
Subject: [Lustre-devel] [RFC] parallel enqueue
Message-ID: <47AC75E3.7010901@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

in some cases (truncate, append) we still use serialized enqueue
when all locks have to be enqueued synchronously one by one.

what if we could mark all locks issued by single client with some
unique tag (timestamp + nid?), then enqueue them all and then, in
case of conflict, in blocking ast handler compare tag of conflicting
lock with own tag, cancel our granted locks if our tag is greater
than tag of conflicting lock and enqueue them again?

thanks, Alex
