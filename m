From: Simmons, James A. <simmonsja@ornl.gov>
Date: Wed, 13 Apr 2016 18:18:56 +0000
Subject: [lustre-devel] Staging: lustre: Make lustre_profile_list static
In-Reply-To: <1460495314-31976-1-git-send-email-iban.rodriguez@ono.com>
References: <1460495314-31976-1-git-send-email-iban.rodriguez@ono.com>
Message-ID: <e29f48b0971b4f08b20c878affda0a11@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Iban Rodriguez' <iban.rodriguez@ono.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann <arnd@arndb.de>, Shraddha Barke <shraddha.6596@gmail.com>, Dmitry Eremin <dmitry.eremin@intel.com>, Mike Rapoport <mike.rapoport@gmail.com>, Julia Lawall <Julia.Lawall@lip6.fr>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

>Variable lustre_profile_list is only used inside obd_config.c,
>better make it static
>
>Signed-off-by: Iban Rodriguez <iban.rodriguez@ono.com>

Acked-by: James Simmons <jsimmons@infradead.org>

>---
> drivers/staging/lustre/lustre/obdclass/obd_config.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 5395e994deab..8d484633b83a 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -606,7 +606,7 @@ static int class_del_conn(struct obd_device *obd, struct lustre_cfg *lcfg)
 	return rc;
 }
 
-LIST_HEAD(lustre_profile_list);
+static LIST_HEAD(lustre_profile_list);
 
 struct lustre_profile *class_get_profile(const char *prof)
 {
-- 
1.9.1

_______________________________________________
devel mailing list
devel at linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
