From: Mag Gam <magawake@gmail.com>
Date: Sat, 28 Feb 2009 19:20:20 -0500
Subject: [Lustre-devel] OST remount problem.
Message-ID: <1cbd6f830902281620h2c87055aqdc58e80e114336af@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I have posted a very similar question in lustre-discuss but the lack
of responses made me move to the developers. I created an OST (while
clients were still active). I then mounted the OST, and it states the
OST's services are already running but nothing is showing up on
/etc/mtab.

I suspect this is a bug. Therefore, I submitted a bug report.
https://bugzilla.lustre.org/show_bug.cgi?id=18651

But, meanwhile, is there a way to override this by changing a flag in
ost's configuration (writeconf) to say, its not mouted up? This will
hopefully enable me to mount up partition as intended.

TIA
