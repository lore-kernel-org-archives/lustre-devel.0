From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 19:16:31 -0400
Subject: [lustre-devel] [PATCH 0/3] lustre: llite: rework client mount code
Message-ID: <1532992594-2576-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Most of the lustre mount code is stuffed in obd_mount.c. That code
was designed with support for both servers and clients. Move the
code that is specific to just the client to the llite layer which
makes the code simpler.

James Simmons (3):
  lustre: obd: migrate lustre_fill_super() to llite
  lustre: llite: handle registering file system
  lustre: llite: simplify lustre_fill_super()

 .../staging/lustre/lustre/include/lustre_disk.h    |   6 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   3 +
 drivers/staging/lustre/lustre/llite/super25.c      |  98 +++++++++++-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   6 -
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 165 ++-------------------
 5 files changed, 115 insertions(+), 163 deletions(-)

-- 
1.8.3.1
