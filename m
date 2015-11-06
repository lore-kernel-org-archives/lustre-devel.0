From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Fri, 6 Nov 2015 20:26:52 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: klnds: socklnd: Move
 extern declarations to header
Message-ID: <20151106145652.GA16452@amitoj-Inspiron-3542>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch moves extern declarations in socklnd_lib.c to the respective 
header file, 'socklnd.h'.

This patch also removes extern keyword from function declarations
since functions have the extern specifier by default.

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h     | 3 +++
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c | 2 --
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index b349847..f4fa725 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -679,6 +679,9 @@ int ksocknal_lib_recv_kiov(ksock_conn_t *conn);
 int ksocknal_lib_get_conn_tunables(ksock_conn_t *conn, int *txmem,
 				   int *rxmem, int *nagle);
 
+void ksocknal_read_callback(ksock_conn_t *conn);
+void ksocknal_write_callback(ksock_conn_t *conn);
+
 int ksocknal_tunables_init(void);
 
 void ksocknal_lib_csum_tx(ksock_tx_t *tx);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 679785b..04a4653 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -580,8 +580,6 @@ ksocknal_lib_push_conn(ksock_conn_t *conn)
 	ksocknal_connsock_decref(conn);
 }
 
-extern void ksocknal_read_callback(ksock_conn_t *conn);
-extern void ksocknal_write_callback(ksock_conn_t *conn);
 /*
  * socket call back in Linux
  */
-- 
1.9.1
