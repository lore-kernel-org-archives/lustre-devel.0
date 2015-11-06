From: Simmons, James A. <simmonsja@ornl.gov>
Date: Fri, 6 Nov 2015 22:07:26 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: klnds: socklnd:
 Move extern declarations to header
In-Reply-To: <20151106145652.GA16452@amitoj-Inspiron-3542>
References: <20151106145652.GA16452@amitoj-Inspiron-3542>
Message-ID: <700a373b14c14161b9893727da948ab5@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>From: lustre-devel [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Amitoj Kaur Chawla
>Sent: Friday, November 06, 2015 9:57 AM
>To: oleg.drokin at intel.com; andreas.dilger at intel.com; gregkh at linuxfoundation.org; lustre-devel at lists.lustre.org; devel at driverdev.osuosl.org; linux-kernel at vger.kernel.org
>Subject: [lustre-devel] [PATCH] staging: lustre: lnet: klnds: socklnd: Move extern declarations to header
>
>This patch moves extern declarations in socklnd_lib.c to the respective 
>header file, 'socklnd.h'.
>
>This patch also removes extern keyword from function declarations
>since functions have the extern specifier by default.
>
>Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
>---
> drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h     | 3 +++
> drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c | 2 --
> 2 files changed, 3 insertions(+), 2 deletions(-)

Acked-by: James Simmons <jsimmons@infradead.org>

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

_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
